#!/usr/bin/env perl
# $Id: tlmgrgui.pl 20244 2010-10-29 05:03:34Z preining $
#
# Copyright 2009, 2010 Norbert Preining
# This file is licensed under the GNU General Public License version 2
# or any later version.
#
# GUI for tlmgr
# version 2, completely rewritten GUI
#
# TODO: Fix return codes of execute_action sub items and execute_action
#       so that we can give a decent warning window
# TODO: implement path adjustment also for Windows
# TODO: make the path adjustment dialog for Unix a bit nicer

$^W = 1;
use strict;

my $guisvnrev = '$Revision: 20244 $';
my $guidatrev = '$Date: 2010-10-29 07:03:34 +0200 (Fri, 29 Oct 2010) $';
my $tlmgrguirevision;
if ($guisvnrev =~ m/: ([0-9]+) /) {
  $tlmgrguirevision = $1;
} else {
  $tlmgrguirevision = "unknown";
}
$guidatrev =~ s/^.*Date: //;
$guidatrev =~ s/ \(.*$//;
$tlmgrguirevision .= " ($guidatrev)";

use Tk;
use Tk::Dialog;
use Tk::Adjuster;
use Tk::BrowseEntry;
use Tk::ROText;
use Tk::HList;
use Tk::ItemStyle;

use Pod::Text;

#use TeXLive::Splashscreen;
#use Devel::Leak;

use TeXLive::TLUtils qw(setup_programs platform_desc win32 debug);
use TeXLive::TLConfig;

#
# GUI mode
#
our %config;
my $mode_expert = $config{"gui-expertmode"};

#
# stuff defined in tlmgr.pl that needs to be our-ed
our $Master;
our $tlmediatlpdb;
our $tlmediasrc;
our $localtlmedia;
our $localtlpdb;
our $location;
our %opts;
our @update_function_list;

my $tlpdb_location;
my $cmdline_location;
my @critical_updates = ();
#
# shortcuts for padding, expand/fill, and pack sides, anchors
my @p_ii = qw/-padx 2m -pady 2m/;
my @p_iii= qw/-padx 3m -pady 3m/;
my @x_x = qw/-expand 1 -fill x/;
my @x_y = qw/-expand 1 -fill y/;
my @x_xy= qw/-expand 1 -fill both/;
my @left = qw/-side left/;
my @right= qw/-side right/;
my @bot  = qw/-side bottom/;
my @a_w = qw/-anchor w/;
my @a_c = qw/-anchor c/;
my @htype = qw/-relief ridge/;

#
# the list of packages as shown by TixGrid
#
my %Packages;
my $taxonomy;
my $mw;
my $tlmgrrev;
my $menu;
my $menu_file;
my $menu_options;
my $menu_actions;
my $menu_help;

#
# GUI elements
#
my $g;          # the scrolled list of packages
my $lighttext;
my $darktext;
my $match_entry;
my $loaded_text;

#
# communication between filters and the rest
my $status_all = 0;
my $status_only_installed = 1;
my $status_only_not_installed = 2;
my $status_only_updated = 3;
my $status_value = 0;
my $show_packages = 1;
my $show_collections = 1;
my $show_schemes = 1;
my $match_descriptions = 0;
my $match_filenames = 0;
my $match_taxonomies = 0;
my $selection_value = 0;


# prepare for loading of lang.pl which expects $::lang and $::opt_lang
$::opt_lang = $opts{"gui-lang"} if (defined($opts{"gui-lang"}));
require("TeXLive/trans.pl");


my @archsavail;
my @archsinstalled;
my %archs;
my $currentarch;

my @fileassocdesc;
$fileassocdesc[0] = __("None");
$fileassocdesc[1] = __("Only new");
$fileassocdesc[2] = __("All");
my %defaults;
my %changeddefaults;

my %papers;
my %currentpaper;
my %changedpaper;
my %init_paper_subs;
$init_paper_subs{"xdvi"} = \&init_paper_xdvi;
$init_paper_subs{"pdftex"} = \&init_paper_pdftex;
$init_paper_subs{"dvips"} = \&init_paper_dvips;
$init_paper_subs{"context"} = \&init_paper_context;
$init_paper_subs{"dvipdfm"} = \&init_paper_dvipdfm;
$init_paper_subs{"dvipdfmx"} = \&init_paper_dvipdfmx;


guimain();

############# MAIN FUNCTION ##########################

sub guimain {
  build_initial_gui();
  init_hooks();

  info(__("Loading local TeX Live Database\nThis may take some time, please wait!") . "\n");

  # call the init function from tlmgr.pl
  # with 0 as argument, so that it does not call die on errors.
  init_local_db(0);
  # before this code was used, which is a duplication, and in addition
  # it does not handle auto-loading of $location
  #$localtlmedia = TeXLive::TLMedia->new ( $Master );
  #die("cannot setup TLMedia in $Master") unless (defined($localtlmedia));
  #$localtlpdb = $localtlmedia->tlpdb;
  #die("cannot find tlpdb!") unless (defined($localtlpdb));

  #
  # init_local_db sets up $location to the winning one:
  #  cmd line > tlpdb
  # save the two possible location for the menu
  $tlpdb_location = $localtlpdb->option("location");
  if (defined($opts{"location"})) {
    $cmdline_location = $opts{"location"};
  }


  push @update_function_list, \&check_location_on_ctan;
  push @update_function_list, \&init_install_media;

  # already done by init_local_db above
  # setup_programs("$Master/tlpkg/installer", $localtlmedia->platform);

  #
  # check that we can actually save the database
  #
  if (check_on_writable()) {
    $::we_can_save = 1;
  } else {
    $::we_can_save = 0;
    # here we should pop up a warning window!!!
  }
  $::action_button_state = ($::we_can_save ? "normal" : "disabled");

  $tlmgrrev = give_version();
  chomp($tlmgrrev);

  setup_menu_system();
  $taxonomy = load_taxonomy_datafile();
  if (!defined($taxonomy)) {
    info(__("Cannot load taxonomy file") . "\n");
  }
  do_rest_of_gui();
  setup_list();
  update_grid();


  if ($opts{"load"}) {
    setup_location($tlpdb_location);
  }


  info(__("Completed") . ".\n");
  $mw->deiconify;


  if (!$::we_can_save) {
    my $no_write_warn = $mw->Dialog(-title => __("Warning"),
      -text => __("You don't have permissions to change the installation in any way,\nspecifically, the directory %s is not writable.\nPlease run this program as administrator, or contact your local admin.\n\nMost buttons will be disabled.", "$Master/tlpkg/"),
      -buttons => [ __("Ok") ])->Show();
  }

  Tk::MainLoop();
}


############## GUI ########################

sub build_initial_gui {
  $mw = MainWindow->new;
  $mw->title("TeX Live Manager $TeXLive::TLConfig::ReleaseYear");
  $mw->withdraw;

  #
  # default layout definitions
  #
  # priority 20 = widgetDefault 
  # see Mastering Perl/Tk, 16.2. Using the Option Database
  $mw->optionAdd("*Button.Relief", "ridge", 20);
  #
  # does not work, makes all buttons exactely 10, which is not a good idea
  # I would like to have something like MinWidth 10...
  #$mw->optionAdd("*Button.Width", "10", 20);

  # create a progress bar window
  $::progressw = $mw->Scrolled("ROText", -scrollbars => "e", -height => 4);
  $::progressw->pack(-fill => "x", @bot);
}

sub do_rest_of_gui {
  # This needs to come first as we call update_grid rather early
  #my $list_frame = $mw->Labelframe(-text => "Packages");
  my $gf = $mw->Frame;

  #my $list_frame = $mw->Frame;
  my $list_frame = $gf->Frame;
  $g = $list_frame->Scrolled('HList', -scrollbars => "se", -bd => 0,
        -command => \&show_extended_info, # does not work, double click!
        -columns => 5, -header => 1,
        -borderwidth => 1, #-padx => 0, -pady => 0,
        -separator => "/",
        -selectmode => "none");

  my $button_frame = $mw->Frame;
  my $but;
  $but = $button_frame->Button(-text => __("Load default"),
    -command => sub { setup_location($tlpdb_location); $but->packForget; });
  $but->pack(
      -anchor => 'e', -padx => 0, -pady => 0,
      -ipadx => 0, -ipady => 0, -side => 'right');
  $loaded_text = $button_frame->Label(
    -text => __("Loaded repository:") . " " .__("none"));
  $loaded_text->pack(-anchor => 'e', -padx => 0, -pady => 0, 
    -ipadx => 0, -ipady => 0, -side => 'right');
    
  #$button_frame->pack(-expand => 1, -fill => 'x', @p_ii);

  #my $top_frame = $mw->Labelframe(-text => __("Display configuration"));
  my $top_frame = $gf->Labelframe(-text => __("Display configuration"));

  my $filter_frame = $top_frame->Frame();
  $filter_frame->pack(-expand => 1, -fill => 'both');

  my $filter_status = $filter_frame->Labelframe(-text => __("Status"));
  $filter_status->pack(@left, @x_y, @p_ii);

  $filter_status->Radiobutton(-text => __("all"), -command => \&update_grid,
    -variable => \$status_value, -value => $status_all)->pack(@a_w);
  $filter_status->Radiobutton(-text => __("installed"), -command => \&update_grid,
    -variable => \$status_value, -value => $status_only_installed)->pack(@a_w);
  $filter_status->Radiobutton(-text => __("not installed"), -command => \&update_grid,
    -variable => \$status_value, -value => $status_only_not_installed)->pack(@a_w);
  $filter_status->Radiobutton(-text => __("updates"), -command => \&update_grid,
    -variable => \$status_value, -value => $status_only_updated)->pack(@a_w);

  my $filter_category = $filter_frame->Labelframe(-text => __("Category"));
  if ($mode_expert) { $filter_category->pack(@left, @x_y, @p_ii); }
  $filter_category->Checkbutton(-text => __("packages"), -command => \&update_grid,
    -variable => \$show_packages)->pack(@a_w);
  $filter_category->Checkbutton(-text => __("collections"), -command => \&update_grid,
    -variable => \$show_collections)->pack(@a_w);
  $filter_category->Checkbutton(-text => __("schemes"), -command => \&update_grid,
    -variable => \$show_schemes)->pack(@a_w);

  my $filter_match = $filter_frame->Labelframe(-text => __("Match"));
  $filter_match->pack(@left, @x_y, @p_ii);
  $filter_match->Checkbutton(-text => __("descriptions"),
          -command => \&update_grid,
          -variable => \$match_descriptions)->pack(@a_w);
  $filter_match->Checkbutton(-text => __("taxonomies"),
          -command => \&update_grid,
          -state => (defined($taxonomy) ? "normal" : "disabled"),
          -variable => \$match_taxonomies)->pack(@a_w);
  $filter_match->Checkbutton(-text => __("filenames"),
          -command => \&update_grid,
          -variable => \$match_filenames)->pack(@a_w);
  $match_entry = 
    $filter_match->Entry(-width => 15, -validate => 'key',
                        )->pack(@a_w, -padx => '2m', @x_x);

  $match_entry->configure(-validate => 'key',
    -validatecommand => sub { 
      my ($new_val, undef, $old_val) = @_;
      if (!$new_val) {
        $match_descriptions = 0;
        $match_taxonomies = 0;
        $match_filenames = 0;
      } else {
        # if something is already in the search field don't change selection
        if (!$old_val) {
          $match_descriptions = 1;
          $match_taxonomies = 1 if (defined($taxonomy));
          $match_filenames = 1;
        }
      }
      update_grid(); return 1; });

  my $filter_selection = $filter_frame->Labelframe(-text => __("Selection"));
  if ($mode_expert) { $filter_selection->pack(@left, @x_y, @p_ii); }
  $filter_selection->Radiobutton(-text => __("all"), -command => \&update_grid,
                      -variable => \$selection_value, -value => 0)->pack(@a_w);
  $filter_selection->Radiobutton(-text => __("selected"), 
    -command => \&update_grid, -variable => \$selection_value, -value => 1)
    ->pack(@a_w);
  $filter_selection->Radiobutton(-text => __("not selected"), 
    -command => \&update_grid, -variable => \$selection_value, -value => 2)
    ->pack(@a_w);


  my $filter_button = $filter_frame->Frame;
  $filter_button->pack(@left, @x_y, @p_ii);
  if ($mode_expert) {
    $filter_button->Button(-text => __("Select all"), 
      -command => [ \&update_grid, 1 ])->pack(@x_x, @a_c);
    $filter_button->Button(-text => __("Select none"), 
      -command => [ \&update_grid, 0 ])->pack(@x_x, @a_c);
  }

  $filter_button->Button(-text => __("Reset filters"),
    -command => sub { $status_value = $status_all;
                      $show_packages = 1; $show_collections = 1; 
                      $show_schemes = 1;
                      $selection_value = 0;
                      $match_descriptions = 0;
                      $match_taxonomies = 0;
                      $match_filenames = 0;
                      update_grid();
                    })->pack(@x_x, @a_c);

  ########## Packages #######################
  $g->pack(qw/-expand 1 -fill both -padx 3 -pady 3/);
  $g->focus;

  $lighttext = $g->ItemStyle('text', -background => 'gray90',
    -selectbackground => 'gray90', -selectforeground => 'blue');
  $darktext = $g->ItemStyle('text', -background => 'gray70',
    -selectbackground => 'gray70', -selectforeground => 'blue');


  $g->headerCreate(0, @htype, -itemtype => 'text', -text => "");
  $g->headerCreate(1, @htype, -itemtype => 'text', -text => __("Package name"));
  $g->headerCreate(2, @htype, -itemtype => 'text', -text => __("Local rev. (ver.)"));
  $g->headerCreate(3, @htype, -itemtype => 'text', -text => __("Remote rev. (ver.)"));
$g->headerCreate(4, @htype, -itemtype => 'text', -text => __("Short description"));

  $g->columnWidth(0, 40);
  $g->columnWidth(2, -char => 20);
  $g->columnWidth(3, -char => 20);

  my $bot_frame = $gf->Frame;
  #my $bot_frame = $mw->Frame;

  my $actions_frame = $bot_frame->Frame;
  $actions_frame->pack();

  my $with_all_frame = $actions_frame->Frame;
  $with_all_frame->pack(@left, -padx => '5m');
  $with_all_frame->Button(-text => __('Update all installed'),
                          -state => $::action_button_state,
                          -command => sub { update_all_packages(); }
    )->pack(@p_ii);
  $with_all_frame->Checkbutton(-text => __("Reinstall previously removed packages"), 
    -variable => \$opts{"reinstall-forcibly-removed"})->pack();


  my $with_sel_frame = $actions_frame->Frame;
  $with_sel_frame->pack(@left, -padx => '5m');


  #
  # disable the with filter applied or not applied, it is too complicated, or?
  #

  if ($mode_expert) {
    $with_sel_frame->Button(-text => __('Update'),
                            -state => $::action_button_state,
                            -command => sub { update_selected_packages(); }
      )->pack(@left, @p_ii);
  }
  $with_sel_frame->Button(-text => __('Install'),
                          -state => $::action_button_state,
                          -command => sub { install_selected_packages(); }
    )->pack(@left, @p_ii);
  $with_sel_frame->Button(-text => __('Remove'),
                          -state => $::action_button_state,
                          -command => sub { remove_selected_packages(); }
    )->pack(@left, @p_ii);
  if ($mode_expert) {
    $with_sel_frame->Button(-text => __('Backup'),
                            -state => $::action_button_state,
                            -command => sub { backup_selected_packages(); }
      )->pack(@left, @p_ii);
  }

  $button_frame->pack(-expand => 0, -fill => 'x', @p_ii);
  $top_frame->pack(-fill => 'x', -padx => '2m');
  $bot_frame->pack(-fill => 'x', @p_ii, -side => 'bottom');
  $list_frame->pack(@x_xy, @p_ii);

  $mw->Adjuster(-widget => $::progressw, -side => 'bottom')
    ->pack(-side => 'bottom', -fill => 'x');

  $gf->pack(-side => 'top', -fill => 'both', -expand => 1);

}

########### LOGGING ETC FUNCTIONS #############

sub update_status_box {
  update_status(join(" ", @_));
  $mw->update;
}

sub init_hooks {
  push @::info_hook, \&update_status_box;
  push @::warn_hook, \&update_status_box;
  push @::debug_hook, \&update_status_box;
  push @::ddebug_hook, \&update_status_box;
  push @::dddebug_hook, \&update_status_box;
}

sub update_status {
  my ($p) = @_;
  $::progressw->insert("end", "$p");
  $::progressw->see("end");
}

############# GUI CALLBACKS ##################

sub setup_menu_system {
  $menu = $mw->Menu();
  $menu_file = $menu->Menu();
  $menu_options = $menu->Menu();
  $menu_actions = $menu->Menu();
  $menu_help = $menu->Menu();
  $menu->add('cascade', -label => "tlmgr", -menu => $menu_file);
  $menu->add('cascade', -label => __("Options"), -menu => $menu_options);
  if ($mode_expert) {
    $menu->add('cascade', -label => __("Actions"), -menu => $menu_actions);
  }
  # on win32 people expect to have the Help button on the right side
  if (win32()) { $menu->add('separator'); }
  $menu->add('cascade', -label => __("Help"), -menu => $menu_help);

  #
  # FILE MENU
  #
  $menu_file->add('command', 
    -label => __("Load default repository:") . " $tlpdb_location",
    -command => sub { setup_location($tlpdb_location); });
  if (defined($cmdline_location)) {
    $menu_file->add('command', -label => __("Load cmd line repository:") . " $cmdline_location",
      -command => sub { setup_location($cmdline_location); });
  }
  $menu_file->add('command', -label => __("Load default net repository:") . " $TeXLiveURL",
    -command => sub { setup_location($TeXLiveURL); });
  if ($mode_expert) {
    $menu_file->add('command', -label => __("Load other repository ..."),
      -command => \&cb_edit_location);
  }
  $menu_file->add('separator');
  $menu_file->add('command', -label => __("Quit"),
                             -command => sub { $mw->destroy; exit(0); });

  #
  # OPTIONS MENU
  #
  $menu_options->add('command', -label => __("General ..."),
    -command => sub { do_general_settings(); });
  $menu_options->add('command', -label => __("Paper ..."),
    -command => sub { do_paper_settings(); });
  if (!win32() && $mode_expert) {
    $menu_options->add('command', -label => __("Platforms ..."),
      -command => sub { do_arch_settings(); });
  }
  $menu_options->add('separator');
  $menu_options->add('checkbutton', -label => __("Expert options"),
    -variable => \$mode_expert,
    -command => sub { do_and_warn_gui_mode_settings(); });
  if ($mode_expert) {
    $menu_options->add('checkbutton', -label => __("Enable debugging output"),
      -onvalue => ($::opt_verbosity == 0 ? 1 : $::opt_verbosity),
      -variable => \$::opt_verbosity);
    $menu_options->add('checkbutton', 
      -label => __("Disable auto-install of new packages"),
      -variable => \$opts{"no-auto-install"});
    $menu_options->add('checkbutton', 
      -label => __("Disable auto-removal of server-deleted packages"),
      -variable => \$opts{"no-auto-remove"});
  }

  #
  # Actions menu
  #
  $menu_actions->add('command', -label => __("Update filename database"),
    -state => $::action_button_state,
    -command => sub { 
                      $mw->Busy(-recurse => 1);
                      info("Running mktexlsr, this may take some time ...\n");
                      info(`mktexlsr 2>&1`); 
                      $mw->Unbusy;
                    });
  $menu_actions->add('command', -label => __("Rebuild all formats"),
    -state => $::action_button_state,
    -command => sub { 
                      $mw->Busy(-recurse => 1);
                      info("Running fmtutil-sys --all, this may take some time ...\n");
                      for my $l (`fmtutil-sys --all 2>&1`) {
                        info($l);
                        $mw->update;
                      }
                      $mw->Unbusy;
                    });
  $menu_actions->add('command', -label => __("Update font map database"),
    -state => $::action_button_state,
    -command => sub { 
                      $mw->Busy(-recurse => 1);
                      info("Running updmap-sys, this may take some time ...\n");
                      for my $l (`updmap-sys 2>&1`) {
                        info($l);
                        $mw->update;
                      }
                      $mw->Unbusy;
                    });

  $menu_actions->add('command', 
    -label => __("Restore packages from backup") . " ...",
    -state => $::action_button_state,
    -command => \&cb_handle_restore);

  if (!win32()) {
    $menu_actions->add('command', 
      -label => __("Handle symlinks in system dirs") . " ...",
      -state => $::action_button_state,
      -command => \&cb_handle_symlinks);
  }
  if (!win32()) {
    $menu_actions->add('separator');
    $menu_actions->add('command', -label => __("Remove TeX Live %s ...", $TeXLive::TLConfig::ReleaseYear),
      -state => $::action_button_state,
      -command => sub { 
        my $sw = $mw->DialogBox(-title => __("Remove TeX Live %s", $TeXLive::TLConfig::ReleaseYear),
                                -buttons => [ __("Ok"), __("Cancel") ],
                                -cancel_button => __("Cancel"),
                                -command => sub { 
                                  my $b = shift;
                                  if ($b eq __("Ok")) {
                                    system("tlmgr", "uninstall", "--force");
                                    $mw->Dialog(-text => __("Complete removal completed"), -buttons => [ __("Ok") ])->Show;
                                    $mw->destroy; 
                                    exit(0); 
                                  }
                                });
        $sw->add("Label", -text =>  __("Really remove (uninstall) the COMPLETE TeX Live %s installation?\nYour last chance to change your mind!", $TeXLive::TLConfig::ReleaseYear))->pack(@p_iii);
        $sw->Show;
      });
  }
  


  #
  # HELP MENU
  $menu_help->add('command', -label => __("Manual"), -command => \&pod_to_text);
  $menu_help->add('command', -label => __("About"),
    -command => sub {
      my $sw = $mw->DialogBox(-title => __("About"),
                              -buttons => [ __("Ok") ]);
      $sw->add("Label", -text => "TeX Live Manager

tlmgrgui revision $tlmgrguirevision
$tlmgrrev
Copyright 2009, 2010 Norbert Preining

Licensed under the GNU General Public License version 2 or higher
In case of problems, please contact: texlive\@tug.org"
        )->pack(@p_iii);
      $sw->Show;
      });
 

  $mw->configure(-menu => $menu);
}

sub show_extended_info {
  my $p = shift;
  $g->selectionClear;
  $g->anchorClear;
  my $sw = $mw->Toplevel(-title => __("Details on:") . $p, @p_ii);
  $sw->transient($mw);

  my $tlp = $Packages{$p}{'tlp'};

  our $tf = $sw->Frame;
  my $bf = $sw->Frame;
  $tf->pack;
  $bf->pack(-pady => '3m');

  $tf->Label(-text => __("Package:"))->grid(
    $tf->Label(-text => $p), -sticky => "nw");
  $tf->Label(-text => __("Category:"))->grid(
    $tf->Label(-text => $tlp->category), -sticky => "nw");
  $tf->Label(-text => __("Short description:"))->grid(
    $tf->Label(-wraplength => '500', -justify => 'left',
    -text => $tlp->shortdesc), -sticky => "nw");
  # old version with ROText
  #my $t = $sw->Scrolled('ROText', -scrollbars => "oe", -height => 10,
  #  -width => 50, -wrap => 'word', -relief => 'flat');
  #$t->insert("1.0", $tlp->longdesc);
  #$sw->Label(-text => "Long Desc:")->grid($t, -sticky => 'nw');
  $tf->Label(-text => __("Long description:"))->grid(
    $tf->Label(-wraplength => '500', -justify => 'left', 
      -text => $tlp->longdesc), -sticky => "nw");
  $tf->Label(-text => __("Installed:"))->grid(
    $tf->Label(-text => ($Packages{$p}{'installed'} ? __("Yes") : __("No"))),
    -sticky => "nw");
  $tf->Label(-text => __("Local Revision:"))->grid(
    $tf->Label(-text => $Packages{$p}{'localrevision'}),
    -sticky => "nw");
  if (defined($Packages{$p}{'localcatalogueversion'})) {
    $tf->Label(-text => __("Local Catalogue Version:"))->grid(
      $tf->Label(-text => $Packages{$p}{'localcatalogueversion'}),
      -sticky => "nw");
  }
  $tf->Label(-text => __("Remote Revision:"))->grid(
    $tf->Label(-text => $Packages{$p}{'remoterevision'}),
    -sticky => "nw");
  if (defined($Packages{$p}{'remotecatalogueversion'})) {
    $tf->Label(-text => __("Remote Catalogue Version:"))->grid(
      $tf->Label(-text => $Packages{$p}{'remotecatalogueversion'}),
      -sticky => "nw");
  }
  if (defined($Packages{$p}{'keyword'})) {
    $tf->Label(-text => __("Keywords:"))->grid(
      $tf->Label(-text => $Packages{$p}{'keyword'}),
      -sticky => "nw");
  }
  if (defined($Packages{$p}{'functionality'})) {
    $tf->Label(-text => __("Functionality:"))->grid(
      $tf->Label(-text => $Packages{$p}{'functionality'}),
      -sticky => "nw");
  }
  if (defined($Packages{$p}{'primary'})) {
    $tf->Label(-text => __("Primary characterization:"))->grid(
      $tf->Label(-text => $Packages{$p}{'primary'}),
      -sticky => "nw");
  }
  if (defined($Packages{$p}{'secondary'})) {
    $tf->Label(-text => __("Secondary characterization:"))->grid(
      $tf->Label(-text => $Packages{$p}{'secondary'}),
      -sticky => "nw");
  }
  if ($tlmediatlpdb) {
    my @colls;
    if ($tlp->category ne "Collection" && $tlp->category ne "Scheme") {
      @colls = $tlmediatlpdb->needed_by($tlp->name);
    }
    @colls = grep {m;^collection-;} @colls;
    if (@colls) {
      $tf->Label(-text => __("Collection:"))->grid(
        $tf->Label(-text => "@colls"), -sticky => "nw");
    }
  }
  $tf->Label(-text => __("Warning: Catalogue versions might be lagging behind or be simply wrong."))->grid(-stick => "nw", -columnspan => 2);

  our %further_a;
  our %further_b;

  @{$further_a{$p}} = ();
  @{$further_b{$p}} = ();
  
  sub add_filelist_text {
    my $p = shift;
    my $text = shift;
    my @files = @_;
    if (@files) {
      my $t = "";
      for my $f (@files) { $t .= "$f\n"; }
      $t =~ s/\n$//;
      push @{$further_a{$p}}, $tf->Label(-text => $text);
      if ($#files >= 4) {
        my $foo = $tf->Scrolled('ROText', -scrollbars => "oe", -height => 5,
          -width => 50, -wrap => 'word', -relief => 'flat');
        $foo->insert("1.0", $t);
        push @{$further_b{$p}}, $foo;
      } else {
        push @{$further_b{$p}},
          $tf->Label(-wraplength => '500', -justify => 'left', -text => $t);
      }
    }
  }
  my @deps;
  my $do_arch;
  my @arch_deps;
  for my $d ($tlp->depends) {
    if ($d eq "$p.ARCH") {
      $do_arch = 1;
    } else {
      push @deps, $d;
    }
  }
  add_filelist_text($p, __("Depends:"), @deps);
  if ($do_arch) {
    my @archs = $localtlpdb->available_architectures;
    @arch_deps = map { "$p.$_"; } @archs;
    add_filelist_text($p, __("Binaries' dependencies:"), sort(@arch_deps));
  }
  add_filelist_text($p, __("Runfiles:"), $tlp->runfiles);
  add_filelist_text($p, __("Docfiles:"), $tlp->docfiles);
  add_filelist_text($p, __("Srcfiles:"), $tlp->srcfiles);
  my @binf = $tlp->allbinfiles;
  if ($do_arch) {
    for my $bp (@arch_deps) {
      my $tlpb = $localtlpdb->get_package($bp);
      if (!$tlpb) {
        tlwarn("Cannot find $bp.\n");
      } else {
        push @binf, $tlpb->allbinfiles;
      }
    }
  }
  add_filelist_text($p, __("Binfiles:"), @binf);

  my $f = $tf->Frame;
  my $fb = $f->Button(-padx => 0, -pady => 0,
    -text => "+", -borderwidth => 1, -relief => "ridge");
  my $ff = $f->Label(-text => "------ " . __("Further information") . " ------");
  $fb->grid($ff, -sticky => "nw");

  $f->grid(-sticky => "nw", -columnspan => 2);
  my $showdetails = 0;
  $fb->configure(-command =>
    sub {
      $showdetails = not($showdetails);
      if ($showdetails) {
        for my $i (0..$#{$further_a{$p}}) {
          ${$further_a{$p}}[$i]->grid(${$further_b{$p}}[$i], -sticky => "nw");
        }
      } else {
        for my $i (0..$#{$further_a{$p}}) {
          ${$further_a{$p}}[$i]->gridForget(${$further_b{$p}}[$i]);
        }
      }
    });


  $bf->Button(-text => __("Ok"), -width => 10,
    -command => sub { for (@{$further_a{$p}}) { $_->destroy; };
                      for (@{$further_b{$p}}) { $_->destroy; };
                      $sw->destroy; })->pack;
}

sub update_grid {
  # select code
  # if not given just do nothing
  # if == 1 select all packages that will be shown
  # if == 0 deselect all packages that will be shown
  my $selectcode = shift;

  my @schemes;
  my @colls;
  my @packs;
  for my $p (sort keys %Packages) {
    if ($Packages{$p}{'category'} eq "Scheme") {
      push @schemes, $p;
    } elsif ($Packages{$p}{'category'} eq "Collection") {
      push @colls, $p;
    } else {
      push @packs, $p;
    }
  }
  $g->delete('all');
  my $i = 0;
  my @displist;
  my $crit_match = 0;
  if (@critical_updates) {
    @displist = @critical_updates;
    $crit_match = 1;
    $lighttext->configure(-foreground => 'red');
    $darktext->configure(-foreground => 'red');
  } else {
    @displist = (@schemes, @colls, @packs);
  }
  for my $p (@displist) {
    if ($crit_match || MatchesFilters($p)) {
      if (defined($selectcode)) {
        $Packages{$p}{'selected'} = $selectcode;
      }
      $g->add($p);
      my $st = ($i%2 ? $lighttext : $darktext);
      $g->itemCreate($p, 0, -itemtype => 'window', 
        -widget => $Packages{$p}{'cb'});
      $Packages{$p}{'cb'}->configure(-background => ($i%2?'gray90':'gray70'));
      $g->itemCreate($p, 1, -itemtype => 'text', -style => $st, 
        -text => $Packages{$p}{'displayname'});
      my $t = ($Packages{$p}{'localrevision'} || '');
      if ($Packages{$p}{'localcatalogueversion'}) {
        $t .= " ($Packages{$p}{'localcatalogueversion'})";
      }
      $g->itemCreate($p, 2, -itemtype => 'text', -style => $st, -text => $t);
      $t = ($Packages{$p}{'remoterevision'} || '');
      if ($Packages{$p}{'remotecatalogueversion'}) {
        $t .= " ($Packages{$p}{'remotecatalogueversion'})";
      }
      $g->itemCreate($p, 3, -itemtype => 'text', -style => $st, -text => $t);
      $g->itemCreate($p, 4, -itemtype => 'text', -style => $st,
        -text => $Packages{$p}{'tlp'}->shortdesc);
      $i++;
    }
  }
}
  
sub MatchesFilters {
  my $p = shift;
  sub maybe_strip_last_plus {
    my $v = shift;
    if ($v =~ m/\+$/) {
      chop($v);
      # just for comparison add one to the version of there is a "+"
      $v++;
    }
    return $v;
  }
  # we have to take care since strings in revision numbers on the remote
  # and might contain "+" indicating sub-package updates
  # status
  if (( ($status_value == $status_all) ) ||
      ( ($status_value == $status_only_installed) && 
        (defined($Packages{$p}{'installed'})) && 
        ($Packages{$p}{'installed'} == 1) ) ||
      ( ($status_value == $status_only_not_installed) &&
        ( !defined($Packages{$p}{'installed'}) ||
          ($Packages{$p}{'installed'} == 0)) ) ||
      ( ($status_value == $status_only_updated) &&
        (defined($Packages{$p}{'localrevision'})) &&
        (defined($Packages{$p}{'remoterevision'})) &&
        ($Packages{$p}{'localrevision'} < 
         maybe_strip_last_plus($Packages{$p}{'remoterevision'})))) {
    # do nothing, more checks have to be done
  } else {
    return 0;
  }
  # category
  if (($show_packages    && ($Packages{$p}{'category'} eq 'Other')) ||
      ($show_collections && ($Packages{$p}{'category'} eq 'Collection')) ||
      ($show_schemes     && ($Packages{$p}{'category'} eq 'Scheme')) ) {
    # do nothing, more checks have to be done
  } else {
    return 0;
  }
  #
  # match dealing
  # here we have an "or" condition, either it matches the one or the
  # other, so since we are in negative branch returning 0 we have to
  # make sure that we negate the value
  # (sorry if you don't understand that one, I had some Sake)
  #
  # SPECIAL: If neiter description matching nor file name matching is
  # selected, we do NOT do any checks at all. Somehow that is what
  # feels right to me, but please correct me!
  if ($match_descriptions || $match_taxonomies || $match_filenames) {
    my $found = 0;
    my $r = $match_entry->get;
    if ($r eq "") {
      return 0;
    }
    # check first for the default search type, the descriptions
    if ($match_descriptions) {
      if ($Packages{$p}{'match_desc'} =~ m/$r/i) {
        $found = 1;
      }
    }
    if (!$found) {
      if ($match_taxonomies) {
        if ($Packages{$p}{'taxonomy'} =~ m/$r/i) {
          $found = 1;
        }
      }
    }
    # if we already dound, don't check the next condition!
    if (!$found) {
      if ($match_filenames) {
        if ($Packages{$p}{'match_files'} =~ m/$r/i) {
          $found = 1;
        }
      }
    } 
    if (!$found) {
      # not matched in either of the above cases, return 0 immediately
      return 0;
    }
    # otherwise more checks have to be done
  }
  # selection
  if ($selection_value == 0) {
    # all -> maybe more checks
  } elsif ($selection_value == 1) {
    # only selected
    if ($Packages{$p}{'selected'}) {
      # do nothing, maybe more checks
    } else {
      # not selected package and only selected packages shown
      return 0;
    }
  } else {
    # only not selected
    if ($Packages{$p}{'selected'}) {
      # selected, but only not selected should be shown
      return 0;
    } # else do nothing
  }
  # if we come down to here the package matches
  return 1;
}

############# ARCH HANDLING #####################

sub init_archs {
  if (!defined($tlmediatlpdb)) {
    @archsavail = $localtlpdb->available_architectures;
  } else {
    @archsavail = $tlmediatlpdb->available_architectures;
  }
  $currentarch = $localtlmedia->platform();
  @archsinstalled = $localtlpdb->available_architectures;
  foreach my $a (@archsavail) {
    $archs{$a} = 0;
    if (grep(/^$a$/,@archsinstalled)) {
      $archs{$a} = 1;
    }
  }
}


sub do_arch_settings {
  my $sw = $mw->Toplevel(-title => __("Select platforms to support"));
  my %archsbuttons;
  init_archs();
  $sw->transient($mw);
  $sw->grab();
  my $subframe = $sw->Labelframe(-text => __("Select platforms to support"));
  $subframe->pack(-fill => "both", -padx => "2m", -pady => "2m");
  foreach my $a (sort @archsavail) {
    $archsbuttons{$a} = 
      $subframe->Checkbutton(-command => sub { check_on_removal($sw, $a); },
                          -variable => \$archs{$a}, 
                          -text => platform_desc($a)
                         )->pack(-anchor => 'w');
  }
  my $arch_frame = $sw->Frame;
  $arch_frame->pack(-padx => "10m", -pady => "5m");
  $arch_frame->Button(-text => __("Apply changes"), 
    -state => $::action_button_state,
    -command => sub { apply_arch_changes(); $sw->destroy; })->pack(-side => 'left', -padx => "3m");
  $arch_frame->Button(-text => __("Cancel"), 
    -command => sub { $sw->destroy; })->pack(-side => 'left', -padx => "3m");
}

sub check_on_removal {
  my $arch_frame = shift;
  my $a = shift;
  if (!$archs{$a} && $a eq $currentarch) {
    # removal not supported
    $archs{$a} = 1;
    $arch_frame->Dialog(-title => __("Warning"),
                        -text => __("Removals of the main platform not possible!"),
                        -buttons => [ __("Ok") ])->Show;
  }
}

sub apply_arch_changes {
  my @todo_add;
  my @todo_remove;
  foreach my $a (@archsavail) {
    if (!$archs{$a} && grep(/^$a$/,@archsinstalled)) {
      push @todo_remove, $a;
      next;
    }
    if ($archs{$a} && !grep(/^$a$/,@archsinstalled)) {
      push @todo_add, $a;
      next;
    }
  }
  if (@todo_add) {
    execute_action_gui ( "platform", "add", @todo_add );
  }
  if (@todo_remove) {
    execute_action_gui ( "platform", "remove", @todo_remove );
  }
  if (@todo_add || @todo_remove) {
    reinit_local_tlpdb();
    init_archs();
  }
}


######### CONFIG HANDLING #############

sub init_defaults_setting {
  for my $key (keys %TeXLive::TLConfig::TLPDBOptions) {
    if ($TeXLive::TLConfig::TLPDBOptions{$key}->[0] eq "b") {
      $defaults{$key} = ($localtlpdb->option($key) ? 1 : 0);
    } else {
      $defaults{$key} = $localtlpdb->option($key);
    }
  }
  %changeddefaults = ();
  for my $k (keys %defaults) {
    $changeddefaults{$k}{'value'}   = $defaults{$k};
    if ($TeXLive::TLConfig::TLPDBOptions{$k}->[0] eq "b") {
      $changeddefaults{$k}{'display'} = ($defaults{$k} ? __("Yes") : __("No"));
    } else {
      if ($k eq "file_assocs") {
        $changeddefaults{$k}{'display'} = $fileassocdesc[$defaults{$k}];
      } else {
        $changeddefaults{$k}{'display'} = $defaults{$k};
      }
    }
  }
}

sub do_general_settings {
  my $sw = $mw->Toplevel(-title => __("General options"));
  $sw->transient($mw);
  $sw->grab();
  init_defaults_setting();

  my @config_set_l;
  my @config_set_m;
  my @config_set_r;

  my $back_config_set = $sw->Labelframe(-text => __("General options"));
  my $back_config_buttons = $sw->Frame();
  $back_config_set->pack(-fill => "both", -padx => "2m", -pady => "2m");

  push @config_set_l, 
    $back_config_set->Label(-text => __("Default package repository"), -anchor => "w");
  push @config_set_m,
    $back_config_set->Label(-textvariable => \$changeddefaults{"location"}{'display'});
  push @config_set_r,
    $back_config_set->Button(-text => __("Change"), 
      -command => sub { menu_default_location($sw); });


  if ($mode_expert) {
    push @config_set_l,
      $back_config_set->Label(-text => __("Create formats on installation"), -anchor => "w");
    push @config_set_m,
      $back_config_set->Label(-textvariable => \$changeddefaults{"create_formats"}{'display'});
    push @config_set_r,
      $back_config_set->Button(-text => __("Toggle"),
        -command => sub { toggle_setting("create_formats"); });
  
    push @config_set_l,
      $back_config_set->Label(-text => __("Install macro/font sources"), -anchor => "w");
    push @config_set_m,
      $back_config_set->Label(-textvariable => \$changeddefaults{"install_srcfiles"}{'display'});
    push @config_set_r,
      $back_config_set->Button(-text => __("Toggle"),
        -command => sub { toggle_setting("install_srcfiles"); });

    push @config_set_l,
      $back_config_set->Label(-text => __("Install macro/font docs"), -anchor => "w");
    push @config_set_m,
      $back_config_set->Label(-textvariable => \$changeddefaults{"install_docfiles"}{'display'});
    push @config_set_r,
      $back_config_set->Button(-text => __("Toggle"),
        -command => sub { toggle_setting("install_docfiles"); });

    push @config_set_l,
      $back_config_set->Label(-text => __("Default backup directory"), -anchor => "w");
    push @config_set_m,
      $back_config_set->Label(-textvariable => \$changeddefaults{"backupdir"}{'display'});
    push @config_set_r,
      $back_config_set->Button(-text => __("Change"),
        -command => sub { 
          my $dir = $sw->chooseDirectory();
          if (defined($dir) && ($defaults{"backupdir"} ne $dir)) {
            # see warning concerning UTF8 or other encoded dir names!!
            $changeddefaults{"backupdir"}{'value'} = $dir;
            $changeddefaults{"backupdir"}{'display'} = $dir;
          }
        });

    push @config_set_l,
      $back_config_set->Label(-text => __("Auto backup setting"), -anchor => "w");
    push @config_set_m,
      $back_config_set->Label(-textvariable => \$changeddefaults{"autobackup"}{'display'});
    push @config_set_r,
      $back_config_set->Button(-text => __("Change"),
        -command => sub { select_autobackup($sw); });

    if (!win32()) {
      push @config_set_l,
        $back_config_set->Label(-text => __("Link destination for programs"), -anchor => "w");
      push @config_set_m,
        $back_config_set->Label(-textvariable => \$changeddefaults{"sys_bin"}{'display'});
      push @config_set_r,
        $back_config_set->Button(-text => __("Change"),
          -command => sub { edit_link_dir($sw, "sys_bin"); });

      push @config_set_l,
        $back_config_set->Label(-text => __("Link destination for info docs"), -anchor => "w");
      push @config_set_m,
        $back_config_set->Label(-textvariable => \$changeddefaults{"sys_info"}{'display'});
      push @config_set_r,
        $back_config_set->Button(-text => __("Change"),
          -command => sub { edit_link_dir($sw, "sys_info"); });

      push @config_set_l,
        $back_config_set->Label(-text => __("Link destination for man pages"), -anchor => "w");
      push @config_set_m,
        $back_config_set->Label(-textvariable => \$changeddefaults{"sys_man"}{'display'});
      push @config_set_r,
        $back_config_set->Button(-text => __("Change"),
          -command => sub { edit_link_dir($sw, "sys_man"); });
    }

    if (win32()) {
      push @config_set_l,
        $back_config_set->Label(-text => __("Create shortcuts in menu and on desktop"), -anchor => "w");
      push @config_set_m,
        $back_config_set->Label(-textvariable => \$changeddefaults{"desktop_integration"}{'display'});
      push @config_set_r,
        $back_config_set->Button(-text => __("Toggle"),
          -command => sub { toggle_setting("desktop_integration"); });
  
      if (admin()) {
        push @config_set_l,
          $back_config_set->Label(-text => __("Install for all users"), -anchor => "w");
        push @config_set_m,
          $back_config_set->Label(-textvariable => \$changeddefaults{"w32_multi_user"}{'display'});
        push @config_set_r,
          $back_config_set->Button(-text => __("Toggle"),
            -command => sub { toggle_setting("w32_multi_user"); });
      }
  
      push @config_set_l,
        $back_config_set->Label(-text => __("Change file associations"), -anchor => "w");
      push @config_set_m,
        $back_config_set->Label(-textvariable => \$changeddefaults{'file_assocs'}{'display'});
      push @config_set_r,
        $back_config_set->Button(-text => __("Change"),
          -command => sub { select_file_assocs($sw); });
  
    }
  } # of $mode_export

  for my $i (0..$#config_set_l) {
    $config_set_l[$i]->grid( $config_set_m[$i], $config_set_r[$i],
                              -padx => "1m", -pady => "1m", -sticky => "nwe");
  }

  $back_config_buttons->pack(-padx => "10m", -pady => "5m");
  $back_config_buttons->Button(-text => __("Apply changes"), 
    -state => $::action_button_state,
    -command => sub { apply_settings_changes(); $sw->destroy; })->pack(-side => 'left', -padx => "3m");
  $back_config_buttons->Button(-text => __("Cancel"), 
    -command => sub { $sw->destroy; })->pack(-side => 'left', -padx => "3m");
}
  
sub apply_settings_changes {
  for my $k (keys %defaults) {
    if ($defaults{$k} ne $changeddefaults{$k}{'value'}) {
      $localtlpdb->option($k, $changeddefaults{$k}{'value'});
      if ($k eq "location") {
        # change interface to program, too
        # set default tlpdb location
        $tlpdb_location = $changeddefaults{'location'}{'value'};
        # change the menu entry in File->Load defualt...
        $menu_file->entryconfigure(1, -label => __("Load default repository:") . " $tlpdb_location");
      }
    }
  }
  $localtlpdb->save;
}



########## PAPER HANDLING #################

sub init_paper_xdvi {
  if (!win32()) {
    @{$papers{"xdvi"}} = TeXLive::TLPaper::get_paper_list("xdvi");
    $currentpaper{"xdvi"} = ${$papers{"xdvi"}}[0];
  }
}
sub init_paper_pdftex {
  @{$papers{"pdftex"}} = TeXLive::TLPaper::get_paper_list("pdftex");
  $currentpaper{"pdftex"} = ${$papers{"pdftex"}}[0];
}
sub init_paper_dvips {
  @{$papers{"dvips"}} = TeXLive::TLPaper::get_paper_list("dvips");
  $currentpaper{"dvips"} = ${$papers{"dvips"}}[0];
}
sub init_paper_dvipdfm {
  @{$papers{"dvipdfm"}} = TeXLive::TLPaper::get_paper_list("dvipdfm");
  $currentpaper{"dvipdfm"} = ${$papers{"dvipdfm"}}[0];
}
sub init_paper_context {
  if (defined($localtlpdb->get_package("bin-context"))) {
    @{$papers{"context"}} = TeXLive::TLPaper::get_paper_list("context");
    $currentpaper{"context"} = ${$papers{"context"}}[0];
  }
}
sub init_paper_dvipdfmx {
  @{$papers{"dvipdfmx"}} = TeXLive::TLPaper::get_paper_list("dvipdfmx");
  $currentpaper{"dvipdfmx"} = ${$papers{"dvipdfmx"}}[0];
}


sub init_all_papers {
  for my $p (keys %init_paper_subs) {
    &{$init_paper_subs{$p}}();
  }
}


sub do_paper_settings {
  init_all_papers();
  my $sw = $mw->Toplevel(-title => __("Paper options"));
  $sw->transient($mw);
  $sw->grab();
  
  %changedpaper = %currentpaper;

  my $lower = $sw->Frame;
  $lower->pack(-fill => "both");

  my $back_config_pap = $lower->Labelframe(-text => __("Paper options"));
  my $back_config_buttons = $sw->Frame();


  my $back_config_pap_l1 = $back_config_pap->Label(-text => __("Default paper for all"), -anchor => "w");
  my $back_config_pap_m1 = $back_config_pap->Button(-text => __("a4"),
    -command => sub { change_paper("all", "a4"); });
  my $back_config_pap_r1 = $back_config_pap->Button(-text => __("letter"),
    -command => sub { change_paper("all", "letter"); });

  $back_config_pap_l1->grid( $back_config_pap_m1, $back_config_pap_r1,
    -padx => "2m", -pady => "2m", -sticky => "nswe");

  my (%l,%m,%r);
  if ($mode_expert) {
    foreach my $p (sort keys %papers) {
      if (($p eq "context") && !defined($localtlpdb->get_package("bin-context"))) {
        next;
      }
      $l{$p} = $back_config_pap->Label(-text => __("Default paper for") . " $p", -anchor => "w");
      $m{$p} = $back_config_pap->Label(-textvariable => \$changedpaper{$p}, -anchor => "w");
      $r{$p} = $back_config_pap->Button(-text => __("Change"),
        -command => sub { select_paper($sw,$p); }, -anchor => "w");
      $l{$p}->grid( $m{$p}, $r{$p},
        -padx => "2m", -pady => "2m", -sticky => "nsw");
    }
  }

  $back_config_pap->pack(-side => 'left', -fill => "both", -padx => "2m", -pady => "2m");

  $back_config_buttons->pack(-padx => "10m", -pady => "5m");
  $back_config_buttons->Button(-text => __("Apply changes"), 
    -state => $::action_button_state,
    -command => sub { apply_paper_changes(); $sw->destroy; })->pack(-side => 'left', -padx => "3m");
  $back_config_buttons->Button(-text => __("Cancel"), 
    -command => sub { $sw->destroy; })->pack(-side => 'left', -padx => "3m");
}

sub do_and_warn_gui_mode_settings {
  my $ans = $mw->Dialog(-text => __("Changes will take effect after restart"),
    -title => __("Expert options"),
    -default_button => 'Ok',
    -buttons => [__("Ok"), __("Cancel")])->Show;
  if ($ans eq __("Ok")) {
    $config{"gui-expertmode"} = $mode_expert;
    write_config_file();
  }
}

#
# this function is used to edit/change the default tlpdb repository
# we also want to change the menu entry if we change that
sub menu_default_location {
  my $mw = shift;
  my $val;
  my $sw = $mw->Toplevel(-title => __("Change default package repository"));
  $sw->transient($mw);
  $sw->grab();
  $sw->Label(-text => __("New default package repository"))->pack(-padx => "2m", -pady => "2m");

  my $f1 = $sw->Frame;
  my $entry = $f1->Entry(-text => $val, -width => 50);
  $entry->pack(-side => "left",-padx => "2m", -pady => "2m");

  my $f2 = $sw->Frame;
  $f2->Button(-text => __("Choose Directory"), 
    -command => sub {
                      my $var = $sw->chooseDirectory;
                      if (defined($var)) {
                        $entry->delete(0,"end");
                        $entry->insert(0,$var);
                      }
                    })->pack(-side => "left",-padx => "2m", -pady => "2m");
  $f2->Button(-text => __("Default remote repository"),
    -command => sub {
                      $entry->delete(0,"end");
                      $entry->insert(0,$TeXLiveURL);
                    })->pack(-side => "left",-padx => "2m", -pady => "2m");
  $f1->pack;
  $f2->pack;

  my $f = $sw->Frame;
  my $okbutton = $f->Button(-text => __("Ok"), 
    -command => 
      sub { 
        $changeddefaults{'location'}{'value'} = 
          $changeddefaults{'location'}{'display'} = $entry->get;
        $sw->destroy;
      })->pack(-side => 'left',-padx => "2m", -pady => "2m");
  my $cancelbutton = $f->Button(-text => __("Cancel"), 
          -command => sub { $sw->destroy })->pack(-side => 'right',-padx => "2m", -pady => "2m");
  $f->pack(-expand => 'x');
  $sw->bind('<Return>', [ $okbutton, 'Invoke' ]);
  $sw->bind('<Escape>', [ $cancelbutton, 'Invoke' ]);
}

sub toggle_setting() {
  my ($key) = @_;
  my $old = $changeddefaults{$key}{'value'};
  my $new = ($old ? 0 : 1);
  $changeddefaults{$key}{'display'} = ($new ? __("Yes") : __("No"));
  $changeddefaults{$key}{'value'} = $new;
}


sub apply_paper_changes {
  $mw->Busy(-recurse => 1);
  for my $k (keys %changedpaper) {
    if ($currentpaper{$k} ne $changedpaper{$k}) {
      execute_action_gui ( "paper", $k, "paper", $changedpaper{$k});
      &{$init_paper_subs{$k}}();
    }
  }
  $mw->Unbusy;
}

sub change_paper {
  my ($prog, $pap) = @_;
  if ($prog eq "all") {
    for my $k (keys %changedpaper) {
      $changedpaper{$k} = $pap;
    }
  } else {
    $changedpaper{$prog} = $pap;
  }
}

sub select_paper {
  my $back_config = shift;
  my $prog = shift;
  my $foo = $back_config->Toplevel(-title => __("Select paper format for") . " $prog");
  $foo->transient($back_config);
  $foo->grab();
  my $var = $changedpaper{$prog};
  my $opt = $foo->BrowseEntry(-label => __("Default paper for") . " $prog", -variable => \$var);
  foreach my $p (sort @{$papers{$prog}}) {
    $opt->insert("end",$p);
  }
  $opt->pack(-padx => "2m", -pady => "2m");
  my $f = $foo->Frame;
  my $okbutton = $f->Button(-text => __("Ok"), -command => sub { change_paper($prog,$var); $foo->destroy; })->pack(-side => "left", -padx => "2m", -pady => "2m");
  my $cancelbutton = $f->Button(-text => __("Cancel"), -command => sub { $foo->destroy; })->pack(-side => "left", -padx => "2m", -pady => "2m");
  $f->pack;
  $foo->bind('<Return>', [ $okbutton, 'Invoke' ]);
  $foo->bind('<Escape>', [ $cancelbutton, 'Invoke' ]);
}

sub select_autobackup {
  my $mw = shift;
  my $foo = $mw->Toplevel(-title => __("Auto backup setting"));
  $foo->transient($mw);
  $foo->grab();
  my $var = $defaults{"autobackup"};
  my $opt = $foo->BrowseEntry(-label => __("Auto backup setting"), 
                              -variable => \$var);
  my @al;
  push @al, "-1 (" . __("keep arbitrarily many") . ")";
  push @al, "0  (" . __("disable") . ")";
  for my $i (1..100) {
    push @al, $i;
  }
  foreach my $p (@al) {
    $opt->insert("end",$p);
  }
  $opt->pack(-padx => "2m", -pady => "2m");
  my $f = $foo->Frame;
  my $okbutton = $f->Button(-text => __("Ok"), 
        -command => sub { 
                          $var =~ s/ .*$//;
                          $changeddefaults{"autobackup"}{'value'} = $var;
                          $changeddefaults{"autobackup"}{'display'} = $var;
                          $foo->destroy;
                        }
     )->pack(-side => "left", -padx => "2m", -pady => "2m");
  my $cancelbutton = $f->Button(-text => __("Cancel"), -command => sub { $foo->destroy; })->pack(-side => "left", -padx => "2m", -pady => "2m");
  $f->pack;
  $foo->bind('<Return>', [ $okbutton, 'Invoke' ]);
  $foo->bind('<Escape>', [ $cancelbutton, 'Invoke' ]);
}


sub select_file_assocs {
  my $sw = shift;
  my $foo = $sw->Toplevel(-title => __("Change file associations"));
  $foo->transient($mw);
  $foo->grab();
  my $var = $defaults{"file_assocs"};
  my $opt = $foo->BrowseEntry(-label => __("Change file associations"), 
                              -variable => \$var);
  my @al;
  for my $i (0..2) {
    push @al, "$i $fileassocdesc[$i]";
  }
  foreach my $p (@al) {
    $opt->insert("end",$p);
  }
  $opt->pack(-padx => "2m", -pady => "2m");
  my $f = $foo->Frame;
  my $okbutton = $f->Button(-text => __("Ok"), 
        -command => sub { 
                          $var = substr($var,0,1);
                          $changeddefaults{"file_assocs"}{'display'} = $fileassocdesc[$var];
                          $changeddefaults{"file_assocs"}{'value'} = $var;

                          $foo->destroy;
                        }
     )->pack(-side => "left", -padx => "2m", -pady => "2m");
  my $cancelbutton = $f->Button(-text => __("Cancel"), -command => sub { $foo->destroy; })->pack(-side => "left", -padx => "2m", -pady => "2m");
  $f->pack;
  $foo->bind('<Return>', [ $okbutton, 'Invoke' ]);
  $foo->bind('<Escape>', [ $cancelbutton, 'Invoke' ]);
}


 
############################

sub setup_location {
  my $loc = shift;
  $location = $loc; 
  update_loaded_location_string();
  run_update_functions(); 
}

sub init_install_media {
  my $newroot = $location;
  if (defined($tlmediatlpdb) && ($tlmediatlpdb->root eq $newroot)) {
    # nothing to be done
  } else {
    $mw->Busy(-recurse => 1);
    info(__("Loading remote TeX Live Database\nThis may take some time, please wait!") . "\n");
    $tlmediasrc = TeXLive::TLMedia->new($newroot);
    info(__("Completed") . ".\n");
    $mw->Unbusy;
    if (!defined($tlmediasrc)) {
      # something went badly wrong, maybe the newroot is wrong?
      $mw->Dialog(-title => __("Warning"),
                 -text => __("Could not load the TeX Live Database from %s\nIf you want to install or update packages, please try with a different package repository!\n\nFor configuration and removal you don\'t have to do anything.", $newroot),
                        -buttons => [ __("Ok") ])->Show;
      $tlmediatlpdb = undef;
      $tlmediasrc = undef;
      update_list_remote();
      update_grid();
      update_loaded_location_string("none");
    } else {
      $tlmediatlpdb = $tlmediasrc->tlpdb;
      update_list_remote();
      update_grid();
      update_loaded_location_string($location);
    }
  }
}

sub set_text_win {
  my ($w, $t) = @_;
  $w->delete("0.0", "end");
  $w->insert("0.0", "$t");
  $w->see("0.0");
}

sub install_selected_packages {
  my @foo = SelectedPackages();
  if (@foo) {
    # that doesn't hurt if it is already loaded
    init_install_media();
    my @args = qw/install/;
    push @args, @foo;
    execute_action_gui(@args);
    reinit_local_tlpdb();
    # now we check that the installation has succeeded by checking that 
    # all packages in @_ are installed. Otherwise we pop up a warning window
    my $do_warn = 0;
    for my $p (@_) {
      if (!defined($localtlpdb->get_package($p))) {
        $do_warn = 1;
        last;
      }
    }
    give_warning_window(__("Installation"), @_) if $do_warn;
  }
}

sub SelectedPackages {
  my @ret;
  # first select those that are
  for my $p (keys %Packages) {
    next if !$Packages{$p}{'selected'};
    if (MatchesFilters($p)) {
      push @ret, $p;
    }
  }
  return @ret;
}

sub update_all_packages {
  my @args = qw/update/;
  if (@critical_updates) {
    $opts{"self"} = 1;
  } else {
    $opts{"all"} = 1;
  }
  # that doesn't hurt if it is already loaded
  init_install_media();
  execute_action_gui(qw/update/);
  if (@critical_updates) {
    # terminate here immediately so that we are sure the auto-updater
    # is run immediately
    # make sure we exit in finish(0)
    $::gui_mode = 0;
    # also delete the main window before we kill the process to 
    # make sure that Tk is happy (segfault on cmd line, email Taco)
    $mw->destroy;
    finish(0); 
  }
  reinit_local_tlpdb();
}
    
sub update_selected_packages {
  my @foo = SelectedPackages();
  if (@foo) {
    # that doesn't hurt if it is already loaded
    init_install_media();
    my @args = qw/update/;
    # argument processing
    # in case we have critical updates present we do put the list of
    # critical updates into the argument instead of --all
    if (@critical_updates) {
      $opts{"self"} = 1;
    }
    push @args, @foo;
    execute_action_gui(@args);
    if (@critical_updates) {
      # terminate here immediately so that we are sure the auto-updater
      # is run immediately
      # make sure we exit in finish(0)
      $::gui_mode = 0;
      # also delete the main window before we kill the process to 
      # make sure that Tk is happy (segfault on cmd line, email Taco)
      $mw->destroy;
      finish(0); 
    }
    reinit_local_tlpdb();
  }
}

sub remove_selected_packages {
  my @foo = SelectedPackages();
  if (@foo) {
    my @args = qw/remove/;
    push @args, @foo;
    execute_action_gui(@args);
    reinit_local_tlpdb();
    my $do_warn = 0;
    for my $p (@_) {
      if (defined($localtlpdb->get_package($p))) {
        $do_warn = 1;
        last;
      }
    }
    give_warning_window(__("Remove"), @_) if $do_warn;
  }
}

sub backup_selected_packages {
  my @foo = SelectedPackages();
  if (@foo) {
    my @args = qw/backup/;
    push @args, @foo;
    execute_action_gui(@args);
  }
}

sub reinit_local_tlpdb {
  $mw->Busy(-recurse => 1);
  $localtlpdb = TeXLive::TLPDB->new ("root" => "$Master");
  die("cannot find tlpdb!") unless (defined($localtlpdb));
  setup_list();
  update_grid();
  $mw->Unbusy;
}

#
# sub populate_Packages
#
sub populate_Packages {
  my ($mode, $tlp) = @_;
  my $p = $tlp->name;
  $Packages{$p}{'displayname'}   = $p;
  if ($mode eq "local") {
    $Packages{$p}{'localrevision'} = $tlp->revision;
    $Packages{$p}{'installed'}     = 1;
    $Packages{$p}{'selected'}      = 0;
    delete($Packages{$p}{'tlp'}) if defined($Packages{$p}{'tlp'});
    $Packages{$p}{'tlp'}           = $tlp;
  } else {
    $Packages{$p}{'remoterevision'} = $tlp->revision;
    $Packages{$p}{'selected'}      = 0
      unless defined $Packages{$p}{'selected'};
    if (!defined($Packages{$p}{'tlp'})) {
      $Packages{$p}{'tlp'}           = $tlp;
    }
  }
  $Packages{$p}{'match_desc'}    = "$p\n";
  $Packages{$p}{'match_desc'}    .= ($tlp->shortdesc || "");
  $Packages{$p}{'match_desc'}    .= "\n";
  $Packages{$p}{'match_desc'}    .= ($tlp->longdesc || "");
  #
  # taxonomy matching
  if (defined($taxonomy)) {
    $Packages{$p}{'taxonomy'} = "";
    if (defined($taxonomy->{'by-package'}{'keyword'}{$p})) {
      $Packages{$p}{'keyword'} = 
        join(", ", @{$taxonomy->{'by-package'}{'keyword'}{$p}});
      $Packages{$p}{'taxonomy'} .=
        join('\n', @{$taxonomy->{'by-package'}{'keyword'}{$p}});
      $Packages{$p}{'taxonomy'} .= '\n';
    }
    if (defined($taxonomy->{'by-package'}{'functionality'}{$p})) {
      $Packages{$p}{'functionality'} =
        join(' > ', @{$taxonomy->{'by-package'}{'functionality'}{$p}});
      $Packages{$p}{'taxonomy'} .=
        join('\n', @{$taxonomy->{'by-package'}{'functionality'}{$p}});
      $Packages{$p}{'taxonomy'} .= '\n';
    }
    if (defined($taxonomy->{'by-package'}{'primary'}{$p})) {
      $Packages{$p}{'primary'} = $taxonomy->{'by-package'}{'primary'}{$p};
      $Packages{$p}{'taxonomy'} .= $taxonomy->{'by-package'}{'primary'}{$p};
      $Packages{$p}{'taxonomy'} .= "\n";
    }
    if (defined($taxonomy->{'by-package'}{'secondary'}{$p})) {
      $Packages{$p}{'secondary'} = $taxonomy->{'by-package'}{'secondary'}{$p};
      $Packages{$p}{'taxonomy'} .= $taxonomy->{'by-package'}{'secondary'}{$p};
      $Packages{$p}{'taxonomy'} .= "\n";
    }
  }
  #
  # file matching
  my @all_f = $tlp->all_files;
  if ($tlp->relocated) { for (@all_f) { s:^$RelocPrefix/:$RelocTree/:; } }
  $Packages{$p}{'match_files'}   = "@all_f";
  if ($mode eq "local") {
    $Packages{$p}{'cb'}->destroy() if defined($Packages{$p}{'cb'});
    $Packages{$p}{'cb'}            = $g->Checkbutton(-variable => \$Packages{$p}{'selected'});
  } else {
    $Packages{$p}{'cb'}            = $g->Checkbutton(-variable => \$Packages{$p}{'selected'})
            unless defined $Packages{$p}{'cb'};
  }
  if (($tlp->category eq "Collection") ||
      ($tlp->category eq "Scheme")) {
    $Packages{$p}{'category'}      = $tlp->category;
  } else {
    $Packages{$p}{'category'}      = "Other";
  }
  if (defined($tlp->cataloguedata->{'version'})) {
    if ($mode eq "local") {
      $Packages{$p}{'localcatalogueversion'} = $tlp->cataloguedata->{'version'};
    } else {
      $Packages{$p}{'remotecatalogueversion'} = $tlp->cataloguedata->{'version'};
    }
  }
}

#
# creates/updates the list of packages as shown in tix grid
# 
sub setup_list {
  my @do_later;
  for my $p ($localtlpdb->list_packages()) {
    # skip 00texlive packages
    next if ($p =~ m!^00texlive!);
    # collect packages containing a . for later
    # we want to ignore them in most cases but those where there is 
    # no father package (without .)
    if ($p =~ m;\.;) {
      push @do_later, $p;
      next;
    }
    my $tlp = $localtlpdb->get_package($p);
    populate_Packages("local", $tlp);
  }
  my @avail_arch = $localtlpdb->available_architectures;
  for my $p (@do_later) {
    my ($mp, $ma) = ($p =~ m/^(.*)\.([^.]*)$/);
    if (!defined($mp)) {
      tlerror("very strange, above it matched and now not anymore?!?! $p\n");
      next;
    }
    if (!defined($Packages{$mp})) {
      my $tlp = $localtlpdb->get_package($p);
      populate_Packages("local", $tlp);
    } else {
      # two cases:
      # - $mp.$ma where $ma is in available_archs
      #   check if $pkg itself has been update present, otherwise
      #   add a "+" to the revision number of the upstream package
      #   but do NOT show the sub package
      #
      #   this has to be deferred to later processing as we don't have
      #   this information at hand at this time
      #
      # - $pkg.$arch where $arch is NOT in available_arch
      #   thus it was installed by the user, show it
      #
      if (!TeXLive::TLUtils::member($ma, @avail_arch)) {
        my $tlp = $localtlpdb->get_package($p);
        populate_Packages("local", $tlp);
      }
    }
  }
  update_list_remote();
}

sub update_list_remote {
  my @do_later_media;
  #my $handle;
  #Devel::Leak::NoteSV($handle);
  # clear old info from remote media
  for my $p (keys %Packages) {
    if (!$Packages{$p}{'installed'}) {
      $Packages{$p}{'cb'}->destroy() if defined($Packages{$p}{'cb'});
      delete($Packages{$p}{'tlp'}) if defined($Packages{$p}{'tlp'});
      delete $Packages{$p};
      next;
    }
    delete $Packages{$p}{'remoterevision'};
    delete $Packages{$p}{'remotecatalogueversion'};
  }
  if (defined($tlmediatlpdb)) {
    for my $p ($tlmediatlpdb->list_packages()) {
      # skip 00texlive packages
      next if ($p =~ m!^00texlive!);
      if ($p =~ m;\.;) {
        push @do_later_media, $p;
        next;
      }
      my $tlp = $tlmediatlpdb->get_package($p);
      populate_Packages("remote", $tlp);
    }
  }
  my @avail_arch = $localtlpdb->available_architectures;
  for my $p (@do_later_media) {
    my ($mp, $ma) = ($p =~ m/^(.*)\.([^.]*)$/);
    if (!defined($mp)) {
      tlerror("very strange, above it matched and now not anymore?!?! $p\n");
      next;
    }
    my $tlp = $tlmediatlpdb->get_package($p);
    if (!defined($Packages{$mp})) {
      populate_Packages("remote", $tlp);
    } else {
      # two cases:
      # - $mp.$ma where $ma is in available_archs
      #   check if $pkg itself has been update present, otherwise
      #   add a "+" to the revision number of the upstream package
      #   but do NOT show the sub package
      #
      if (TeXLive::TLUtils::member($ma, @avail_arch)) {
        if (defined($Packages{$mp}{'localrevision'}) &&
            defined($Packages{$mp}{'remoterevision'}) &&
            $Packages{$mp}{'localrevision'} < $Packages{$mp}{'remoterevision'}) {
          # the main package is updated, so just do nothing
        } else {
          # if there is an update to a binary sub package mark that with
          # a "+" in the remote revision
          my $ltlp = $localtlpdb->get_package($p);
          if (defined($ltlp) && $ltlp->revision < $tlp->revision) {
            $Packages{$mp}{'remoterevision'} .= "+";
          }
        }
      # - $pkg.$arch where $arch is NOT in available_arch
      #   thus it was installed by the user, show it
      #
      } else {
        # only show that one if it is locally installed
        if (defined($Packages{$p})) {
          populate_Packages("remote", $tlp);
        }
      }
    }
  }
  #
  # check for critical updates
  my @critical = $localtlpdb->expand_dependencies("-no-collections",
    $localtlpdb, @TeXLive::TLConfig::CriticalPackagesList);
  @critical_updates = ();
  for my $p (@critical) {
    if (defined($Packages{$p}) &&
        defined($Packages{$p}{'localrevision'}) &&
        defined($Packages{$p}{'remoterevision'}) &&
        $Packages{$p}{'localrevision'} < $Packages{$p}{'remoterevision'}) {
      push @critical_updates, $p;
    }
  }
  #
  #
  if (@critical_updates) {
    # add to the warning text if further updates are available
    # compute the number of further updates 
    # we do NOT make a correct computation here like done in the actual
    # tlmgr.pl sub action_update, but only count the numbers of packages
    # that would be updated (without any forcibly remove/new counting)
    my $min_action = 0;
    for my $p (keys %Packages) {
      next if member($p, @critical);
      if (defined($Packages{$p}{'localrevision'}) &&
          defined($Packages{$p}{'remoterevision'}) &&
          $Packages{$p}{'localrevision'} < $Packages{$p}{'remoterevision'}) {
        $min_action++;
      }
    }
    #
    # create the warning dialog
    #
    my $sw = $mw->DialogBox(-title => __("Warning"), -buttons => [ __("Ok") ]);
    my $t = __("Updates for the tlmgr are present.\nInstallation and upgrades won't work without being forced.\nPlease select \"Update all installed\" button below.\nThe program will terminate after the update.\nThen you can restart the program for further updates.");
    if ($min_action) {
      $t .= "\n\n" . __("At least %s further updates are available after tlmgr has been updated.", $min_action);
    }
    $t .= "\n\n" . __("Please wait a bit after the program has terminated so that the update can be completed.") if win32();
    $sw->add("Label", -text => $t)->pack(-padx => "3m", -pady => "3m");
    $sw->Show;
  }
  # change display names
  for my $p (keys %Packages) {
    if ($p =~ m/^collection-documentation-(.*)$/) {
      $Packages{$p}{'displayname'} = "collection-doc-$1";
    }
  }
  #Devel::Leak::CheckSV($handle);
  #warn join(",", currmem());
}

sub currmem {
    my $pid = shift || $$;
    if (open(MAP, "dd if=/proc/$pid/map bs=64k 2>/dev/null |")) { # FreeBSD
        my $mem = 0;
        my $realmem = 0;
        while(<MAP>) {
            my(@l) = split /\s+/;
            my $delta = (hex($l[1])-hex($l[0]));
            $mem += $delta;
            if ($l[11] ne 'vnode') {
                $realmem += $delta;
            }
        }
        close MAP;
        ($mem, $realmem);
    } elsif (open(MAP, "/proc/$pid/maps")) { # Linux
        my $mem = 0;
        my $realmem = 0;
        while(<MAP>) {
            my(@l) = split /\s+/;
            my($start,$end) = split /-/, $l[0];
            my $delta = (hex($end)-hex($start));
            $mem += $delta;
            if (!defined $l[5] || $l[5] eq '') {
                $realmem += $delta;
            }
        }
        close MAP;
        ($mem, $realmem);
    } else {
        undef;
    }
}

sub cb_handle_restore {
  init_defaults_setting();
  # first do the handling of the backup dir selection
  {
    my ($a, $b) = check_backupdir_selection();
    if (!$a) {
      # in all these cases we want to terminate in the non-gui mode
      my $sw = $mw->DialogBox(-title => __("Warning"), -buttons => [ __("Ok") ]);
      $sw->add("Label", -text => $b)->pack(@p_iii);
      $sw->Show;
      # delete the backupdir setting it might contain rubbish and
      # we want to recheck
      delete $opts{'backupdir'};
      return;
    }
  }

  my $sw = $mw->Toplevel(-title => __("Restore packages from backup"));
  $sw->transient($mw);
  $sw->grab;

  my $tf = $sw->Frame;
  $tf->pack(-ipadx => '3m', -ipady => '3m');

  my %backups = get_available_backups($opts{"backupdir"});

  my @pkgbackup = sort keys %backups;
  my $lstlen = ($#pkgbackup >= 10 ? 10 : ($#pkgbackup + 1));

  my $pkg;
  my $rev;

  my $restore_dialog = $sw->DialogBox(-title => __("Restore done"), 
                                      -buttons => [ __("Ok") ]);
  $restore_dialog->add("Label", -text => __("Restore completed"))->pack(@p_iii);


  my $revbrowser;

  $tf->Label(-text => __("Select the package to restore, or restore all packages"))->pack(@p_ii);

  $tf->BrowseEntry(-label => __("Package:"),
    -listheight => $lstlen,
    -autolistwidth => 1,
    -choices => \@pkgbackup,
    -browsecmd => 
      sub { my @revlist = sort { $b <=> $a } (keys %{$backups{$pkg}});
            $revbrowser->delete(0,"end"); 
            for my $r (@revlist) { 
              $revbrowser->insert("end", $r); 
            }; 
            $rev = "";
      },
    -variable => \$pkg)->pack(@p_ii);

  $revbrowser = $tf->BrowseEntry(-label => __("Revision:"),
    -listheight => 10,
    -variable => \$rev)->pack(@p_ii);

  $tf->pack(-ipadx => '3m', -ipady => '3m');
  $tf->Button(-text => __("Restore selected package"),
    -command => sub {
                      if (!defined($pkg) || !defined($rev) ||
                          !($backups{$pkg}->{$rev})) {
                        tlwarn("Please select a package and revision first!\n");
                        return;
                      }
                      $mw->Busy(-recurse => 1);
                      info("Restoring $pkg, rev $rev from $opts{'backupdir'}/${pkg}.r${rev}.tar.xz\n");
                      restore_one_package($pkg, $rev, $opts{"backupdir"});
                      reinit_local_tlpdb;
                      $restore_dialog->Show;
                      $pkg = "";
                      $rev = "";
                      $mw->Unbusy;
                    })->pack(@p_ii);
  $tf->Button(-text => __("Restore all package to latest version"),
    -command => sub {
                      $mw->Busy(-recurse => 1);
                      for my $p (@pkgbackup) {
                        my @tmp = sort {$b <=> $a} (keys %{$backups{$p}});
                        my $r = $tmp[0];
                        info("Restoring $p, rev $r from $opts{'backupdir'}/${p}.r${r}.tar.xz\n");
                        restore_one_package($p, $r, $opts{"backupdir"});
                      }
                      reinit_local_tlpdb;
                      $restore_dialog->Show;
                      $pkg = "";
                      $rev = "";
                      $mw->Unbusy;
                    })->pack(@p_ii);

  $tf->Button(-text => __("Close"),
    -command => sub { $sw->destroy; })
    ->pack(@p_iii);
}


sub cb_handle_symlinks {
  my $sw = $mw->Toplevel(-title => __("Handle symlinks in system dirs"));
  $sw->transient($mw);
  $sw->grab;
  init_defaults_setting();

  my $tp = $sw->Frame;
  $tp->pack(-ipadx => '3m', -ipady => '3m');
  $tp->Label(-text => __("Link destination for programs"), @a_w)->grid(
    $tp->Label(-textvariable => \$changeddefaults{"sys_bin"}{'display'}, @a_w),
    $tp->Button(-text => __("Change"),
      -command => sub { edit_link_dir($sw, "sys_bin"); }),
    -sticky => 'w');
  $tp->Label(-text => __("Link destination for info docs"), @a_w)->grid(
    $tp->Label(-textvariable => \$changeddefaults{"sys_info"}{'display'}, @a_w),
    $tp->Button(-text => __("Change"), 
      -command => sub { edit_link_dir($sw, "sys_info"); }),
    -sticky => 'w');
  $tp->Label(-text => __("Link destination for man pages"), @a_w)->grid(
    $tp->Label(-textvariable => \$changeddefaults{"sys_man"}{'display'}, @a_w),
    $tp->Button(-text => __("Change"),
      -command => sub { edit_link_dir($sw, "sys_man"); }),
    -sticky => 'w');
  
  my $md = $sw->Frame;
  $md->pack(-ipadx => '3m', -ipady => '3m');
  $md->Button(-text => __("Update symbolic links"),
    -command => sub {
                      $mw->Busy(-recurse => 1);
                      info("Updating symlinks ...\n");
                      execute_action_gui("path", "add");
                      $mw->Unbusy;
                    })->pack(@left, -padx => '3m');
  $md->Button(-text => __("Remove symbolic links"),
    -command => sub {
                      $mw->Busy(-recurse => 1);
                      info("Removing symlinks ...\n");
                      execute_action_gui("path", "remove");
                      $mw->Unbusy;
                    })->pack(@left, -padx => '3m');

  my $bt = $sw->Frame;
  $bt->pack(-ipadx => '3m', -ipady => '3m');
  $bt->Button(-text => __("Ok"),
    -command => sub { apply_settings_changes(); $sw->destroy; })
    ->pack(@left, -padx => '3m');
  $bt->Button(-text => __("Cancel"),
    -command => sub { $sw->destroy; })->pack(-side => 'left', -padx => "3m");
}

sub edit_link_dir {
  my $sw = shift;
  my $what = shift;
  my $dir = $sw->chooseDirectory();
  if (defined($dir) && ($defaults{$what} ne $dir)) {
    # see warning concerning UTF8 or other encoded dir names!!
    $changeddefaults{$what}{'value'} = $dir;
    $changeddefaults{$what}{'display'} = $dir;
  }
}
  
sub cb_edit_location {
  my $key = shift;
  my $val;
  my $sw = $mw->Toplevel(-title => __("Load package repository"));
  $sw->transient($mw);
  $sw->grab();
  $sw->Label(-text => __("Package repository:"))->pack(@p_ii);
  my $entry = $sw->Entry(-text => $location, -width => 30);
  $entry->pack();
  my $f1 = $sw->Frame;
  $f1->Button(-text => __("Choose Directory"),
    -command => sub {
                      my $var = $sw->chooseDirectory;
                      if (defined($var)) {
                        $entry->delete(0,"end");
                        $entry->insert(0,$var);
                      }
                    })->pack(@left, @p_ii);
  $f1->Button(-text => __("Default net package repository"),
    -command => sub {
                      $entry->delete(0,"end");
                      $entry->insert(0,$TeXLiveURL);
                    })->pack(@left, @p_ii);
  $f1->pack;
  my $f = $sw->Frame;
  my $okbutton = $f->Button(-text => __("Ok"),
    -command => sub { $location = $entry->get;
                      $sw->destroy;
                      setup_location($location);
                    })->pack(@left, @p_ii);
  my $cancelbutton = $f->Button(-text => __("Cancel"),
          -command => sub { $sw->destroy })->pack(@right, @p_ii);
  $f->pack(-expand => 1);
  $sw->bind('<Return>', [ $okbutton, 'Invoke' ]);
  $sw->bind('<Escape>', [ $cancelbutton, 'Invoke' ]);
}

sub update_loaded_location_string {
  my $arg = shift;
  $arg || ($arg = $location);
  $loaded_text->configure(-text => __("Loaded repository:") . " " . $arg);
}

sub run_update_functions {
  foreach my $f (@update_function_list) {
    &{$f}();
  }
}

sub check_location_on_ctan {
  # we want to check that if mirror.ctan.org
  # is used that we select a mirror once
  if ($location =~ m/$TeXLive::TLConfig::TeXLiveServerURL/) {
    $location = TeXLive::TLUtils::give_ctan_mirror();
  }
}

sub execute_action_gui {
  $mw->Busy(-recurse => 1);
  info ("Executing action @_\n");
  my $error_code = execute_action(@_);
  if ($error_code) {
    give_warning_window(@_);
  }
  info(__("Completed") . ".\n");
  $mw->Unbusy;
}

sub give_warning_window {
  my ($act, @args) = @_;
  my $sw = $mw->DialogBox(-title => __("Warning"), -buttons => [ __("Ok") ]);
  $sw->add("Label", -text => __("Running %s failed.\nPlease consult the log window for details.", "$act @args")
    )->pack(@p_iii);
  $sw->Show;
}

# pod help thing

sub pod_to_text {
  my $txt;
  eval { require IO::String; };
  if ($@) {
    $txt = "
The Perl Module IO::String is not available.
Without it the documentation cannot be shown. Please install it.

As an alternative use
  tlmgr help
on the command line.
";
  } else {
    my $io = IO::String->new($txt);
    my $parser = Pod::Text->new (sentence => 0, width => 78);
    $parser->parse_from_file("$Master/texmf/scripts/texlive/tlmgr.pl", $io);
  }
  my $sw = $mw->Toplevel(-title => __("Help"));
  $sw->transient($mw);
  my $t = $sw->Scrolled("ROText", -scrollbars => "e",
                                  -height => 40, -width => 80);
  $t->Contents($txt);
  $t->pack;
}

1;

__END__


### Local Variables:
### perl-indent-level: 2
### tab-width: 2
### indent-tabs-mode: nil
### End:
# vim:set tabstop=2 expandtab: #
