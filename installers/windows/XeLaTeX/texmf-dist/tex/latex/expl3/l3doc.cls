%%
%% This is file `l3doc.cls',
%% generated with the docstrip utility.
%%
%% The original source files were:
%%
%% l3doc.dtx  (with options: `class')
%% 
%% 
%% EXPERIMENTAL CODE
%% 
%% Do not distribute this file without also distributing the
%% source files specified above.
%% 
%% Do not distribute a modified version of this file.
%% 
%% 
%% File: l3doc.dtx Copyright (C) 1990-2009 LaTeX3 project
%%
%% It may be distributed and/or modified under the conditions of the
%% LaTeX Project Public License (LPPL), either version 1.3c of this
%% license or (at your option) any later version.  The latest version
%% of this license is in the file
%%
%%    http://www.latex-project.org/lppl.txt
%%
%% This file is part of the ``expl3 bundle'' (The Work in LPPL)
%% and all files in that bundle must be distributed together.
%%
%% The released version of this bundle is available from CTAN.
%%
%% -----------------------------------------------------------------------
%%
%% The development version of the bundle can be found at
%%
%%    http://www.latex-project.org/svnroot/experimental/trunk/
%%
%% for those people who are interested.
%%
%%%%%%%%%%%
%% NOTE: %%
%%%%%%%%%%%
%%
%%   Snapshots taken from the repository represent work in progress and may
%%   not work or may contain conflicting material!  We therefore ask
%%   people _not_ to put them into distributions, archives, etc. without
%%   prior consultation with the LaTeX Project Team.
%%
%% -----------------------------------------------------------------------
\RequirePackage{l3names}
\let        \filenameOld        \filename
\let     \filenameextOld     \filenameext
\let        \filedateOld        \filedate
\let     \fileversionOld     \fileversion
\let \filedescriptionOld \filedescription
\GetIdInfo$Id: l3doc.dtx 2037 2010-09-20 21:22:45Z joseph $
          {L3 Experimental documentation class}
\ProvidesExplClass
  {\filename}{\filedate}{\fileversion}{\filedescription}
\RequirePackage{expl3}
\let        \filename        \filenameOld
\let     \filenameext     \filenameextOld
\let        \filedate        \filedateOld
\let     \fileversion     \fileversionOld
\let \filedescription \filedescriptionOld
\cs_new_nopar:Npn\Team{%
  The~\LaTeX3~Project\thanks{%
  Frank~Mittelbach,~Denys~Duchier,~Chris~Rowley,~
  Rainer~Sch\"opf,~Johannes~Braams,~Michael~Downes,~
  David~Carlisle,~Alan~Jeffrey,~Morten~H\o{}gholm,~Thomas~Lotze,~
  Javier~Bezos,~Will~Robertson,~Joseph~Wright}}
\DeclareOption{a5paper}{\@latexerr{Option not supported}{}}
\bool_new:N \g_doc_full_bool
\bool_new:N \g_doc_lmodern_bool
\bool_new:N \g_doc_checkfunc_bool
\DeclareOption{full}{ \bool_set_true:N \g_doc_full_bool }
\DeclareOption{onlydoc}{ \bool_set_false:N \g_doc_full_bool }
\DeclareOption{check}{ \bool_set_true:N \g_doc_checkfunc_bool }
\DeclareOption{nocheck}{ \bool_set_false:N \g_doc_checkfunc_bool }
\DeclareOption{cm-default}{ \bool_set_false:N \g_doc_lmodern_bool }
\DeclareOption{lm-default}{ \bool_set_true:N \g_doc_lmodern_bool }
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ExecuteOptions{full,a4paper,nocheck,lm-default}
\InputIfFileExists{l3doc.cfg}
  {
    \typeout{*************************************^^J
             *~Local~config~file~l3doc.cfg~used   ^^J
             *************************************}
  }
  { \@input{l3doc.ltx} }
\ProcessOptions
\LoadClass{article}
\RequirePackage{doc}
\RequirePackage{array,alphalph,booktabs,color,fixltx2e,enumitem,textcomp,trace,underscore}
\bool_if:NT \g_doc_lmodern_bool {
  \RequirePackage[T1]{fontenc}
  \RequirePackage{lmodern}
}
\RequirePackage{hypdoc}
\let\doc@verbatim\verbatim
\let\enddoc@verbatim\endverbatim
\let\doc@@verbatim\@verbatim
\RequirePackage{verbatim}
\AtBeginDocument{%
  \let\verbatim\doc@verbatim
  \let\endverbatim\enddoc@verbatim
  \let\@verbatim\doc@@verbatim
}
\cs_set_nopar:Npn \MakePrivateLetters {
  \char_make_letter:N \@
  \char_make_letter:N \_
  \char_make_letter:N \:
}
\setcounter{StandardModuleDepth}{1}
\@addtoreset{CodelineNo}{part}
\cs_set_nopar:Npn \theCodelineNo {
  \textcolor[gray]{0.5}{ \sffamily\tiny\arabic{CodelineNo} }
}
\setlength   \textwidth      { 385pt }
\addtolength \marginparwidth {  30pt }
\addtolength \oddsidemargin  {  20pt }
\addtolength \evensidemargin {  20pt }
\cs_set_eq:NN \@@oldlist\list
\cs_set_nopar:Npn \list#1#2{\@@oldlist{#1}{#2\listparindent\z@}}
\setlength \parindent  { 0pt }
\setlength \itemindent { 0pt }
\setlength \parskip    { \medskipamount }
\AtBeginDocument {
  \MakeShortVerb \"
  \MakeShortVerb \|
}
\providecommand*\eTeX{
  \if b\expandafter\@car\f@series\@nil\boldmath\fi
  $\m@th\varepsilon$-\TeX
}
\providecommand*\IniTeX{Ini\TeX}
\providecommand*\Lua{Lua}
\providecommand*\LuaTeX{\Lua\TeX}
\providecommand*\pdfTeX{pdf\TeX}
\RequirePackage{graphicx}
\cs_if_free:NT \XeTeX {
  \cs_new_protected_nopar:Npn \XeTeX
    {X\kern-.125em\lower.5ex\hbox{\reflectbox{E}}\kern-.1667em\TeX}
}
\cs_set_nopar:Npn \cmd #1 { \cs{\expandafter\cmd@to@cs\string#1} }
\cs_set_nopar:Npn \cmd@to@cs #1#2 { \char\number`#2\relax }
\DeclareRobustCommand \cs [1] { \texttt { \char`\\ #1 } }
\providecommand\marg[1]{ \texttt{\char`\{} \meta{#1} \texttt{\char`\}} }
\providecommand\oarg[1]{ \texttt[ \meta{#1} \texttt] }
\providecommand\parg[1]{ \texttt( \meta{#1} \texttt) }
\cs_set_eq:NN \m    \meta
\cs_set_eq:NN \file \nolinkurl
\DeclareRobustCommand \env {\texttt}
\DeclareRobustCommand \pkg {\textsf}
\DeclareRobustCommand \cls {\textsf}
\newenvironment{texnote}{
  \endgraf
  \vspace{3mm}
  \small\textbf{\TeX~hackers~note:}
}{
  \vspace{3mm}
}
\newcommand\tn[1]{
  \texttt{\bslash #1}
  \index{TeX~and~LaTeX2e~commands\actualchar
          \string\TeX{}~and~\string\LaTeXe{}~commands:\levelchar
          #1\actualchar{\string\ttfamily\string\bslash{}#1}}}
\newenvironment{documentation}{}{}
\newenvironment{implementation}{}{}
\newcommand\EnableDocumentation{%
  \renewenvironment{documentation}{}{}%
}
\newcommand\EnableImplementation{%
  \renewenvironment{implementation}{}{}%
}
\newcommand\DisableDocumentation{%
  \cs_set_eq:NN \documentation \comment
  \cs_set_eq:NN \enddocumentation \endcomment
}
\newcommand\DisableImplementation{%
  \cs_set_eq:NN \implementation \comment
  \cs_set_eq:NN \endimplementation \endcomment
}
\newenvironment{arguments}{
  \enumerate[
    nolistsep,
    label=\texttt{\#\arabic*}~:,
    labelsep=*,
  ]
}{
  \endenumerate
}
\group_begin:
\char_make_active:N \<
\cs_new_nopar:Npn \function {
  \char_make_active:N \<
  \cs_set_eq:NN < \doc_open_meta:n
  \group_begin:
    \MakePrivateLetters
    \char_make_other:N \|
    \char_make_other:N \\
    \char_make_space:N \~
    \char_make_ignore:N \ % space
    \char_make_ignore:N \^^M
    \char_make_ignore:N \^^I
    \function_aux:n
}
\group_end:
\cs_set_eq:NN \variable \function
\group_begin:
\char_make_other:N \|
\cs_gset_nopar:Npn \function_aux:n #1 {
    \cs_set_nopar:Npn \nextnewline{\cs_gset_nopar:Npn\nextnewline{\\}}
    \tl_gset_eq:NN \g_doc_macro_tl \c_empty_tl
    \bigskip\endgraf\noindent\ttfamily
    \tabular[b]{ | l @{} c | }
      \hline
      \doc_showmacro:w #1 | \q_stop \\
      \hline
    \endtabular
  \group_end:
}
\group_end:
\group_begin:
\char_make_other:N \|
\cs_gset_nopar:Npn \doc_showmacro:w #1 | {
  \tl_if_blank:nTF {#1} {
    \use_none:n
  }{
    \doc_showmacro_aux:w #1 / \q_stop
    \peek_meaning:NTF \q_stop { \use_none:n } { \doc_showmacro:w }
  }
}
\group_end:
\bool_new:N \l_doc_meta_TF_bool
\bool_new:N \l_doc_meta_EXP_bool
\cs_new_nopar:Npn \doc_showmacro_aux:w #1 / #2 \q_stop {

  \tl_if_in:nnTF {#2} { (TF)  } {
    \bool_gset_true:N \l_doc_meta_TF_bool
  }{
    \bool_gset_false:N \l_doc_meta_TF_bool
  }
  \tl_if_in:nnTF {#2} { (EXP) } {
    \bool_gset_true:N \l_doc_meta_EXP_bool
  }{
    \bool_gset_false:N \l_doc_meta_EXP_bool
  }

  \bool_if:NTF \l_doc_meta_TF_bool {
    \doc_special_main_index:o { #1 TF }
    \seq_gput_right:Nx \g_doc_functions_seq { \tl_to_str:n { #1 TF } }
    \seq_gput_right:Nx \g_doc_functions_seq { \tl_to_str:n { #1 T  } }
    \seq_gput_right:Nx \g_doc_functions_seq { \tl_to_str:n { #1  F } }
  }{
    \doc_special_main_index:o { #1 }
    \seq_gput_right:Nx \g_doc_functions_seq { \tl_to_str:n { #1    } }
  }

  \doc_showmacro_aux_ii:w #1::\q_stop
}
\cs_set_nopar:Npn \doc_showmacro_aux_ii:w #1:#2:#3 \q_stop {
  \nextnewline

  \str_if_eq:xxTF {#1} {\g_doc_macro_tl} {
    \doc_typeset_aux:n
  }{
    \tl_gset:Nn \g_doc_macro_tl {#1}
    \use:n
  }
  { \g_doc_macro_tl }
  #3
  #2
  \bool_if:NT \l_doc_meta_TF_bool { \doc_typeset_TF: }
  &
  \bool_if:NT \l_doc_meta_EXP_bool {
    \hspace{\tabcolsep}
    $\star$
  }
}
\dim_new:N \g_doc_syntax_dim
\dim_set:Nn \g_doc_syntax_dim {0.7\textwidth}
\newenvironment{syntax}{
  \minipage[b]{\g_doc_syntax_dim}
    \cs_set_nopar:Npn \meta@font@select{\rmfamily\itshape} % (Will: I HATE italic cmtt!)
    \small\ttfamily\raggedright
    \obeyspaces\obeylines
}{
  \endminipage
  \hfil\break
  \global\@ignoretrue
}
\tl_map_inline:nn {0123456789} { \cs_gset_eq:cN {char_other_#1} #1 }
\group_begin:
  \tl_map_inline:nn {0123456789} { \char_make_active:N #1 }
  \cs_new:Npn \doc_open_meta:n {
    \group_begin:
      \tl_map_function:nN {0123456789} \doc_assign_num:n
      \doc_close_meta:w
  }
  \cs_new:Npn \Arg {
    \texttt{ \char`\{ }
    \group_begin:
      \tl_map_function:nN {0123456789} \doc_assign_num:n
      \doc_close_Arg:n
  }
\group_end:
\cs_new_nopar:Npn \doc_close_meta:w #1> { \meta {#1} \group_end: }
\cs_new_nopar:Npn \doc_close_Arg:n #1 {
  \meta {#1}
  \group_end:
  \texttt{ \char`\} }
}
\cs_new_nopar:Npn \doc_assign_num:n #1 {
  \cs_set_eq:cc { \string #1 } { char_other_\string #1 }
  \char_make_active:N #1
  \cs_set_nopar:Npn #1 { \unskip \, $ {} \sb { \use:c { char_other_\string #1 } } $ }
}
\renewcommand \macro [1][] {
  \bool_set_false:N \l_doc_macro_aux_bool
  \bool_set_false:N \l_doc_macro_TF_bool
  \cs_set_eq:NN \doc_macroname_prefix:n \use:n
  \cs_set_eq:NN \doc_macroname_suffix: \c_empty_tl

  \cs_set_nopar:Npn \KV_key_no_value_elt:n ##1 { \use:c {doc_macro_opt_##1:} }
  \KV_parse_space_removal_sanitize:n {#1}

  \group_begin:
    \MakePrivateLetters
    \char_make_letter:N \\
    \char_make_ignore:N \ % space
    \char_make_ignore:N \^^M
    \char_make_ignore:N \^^I
    \doc_macro_aux:n
}
\cs_new_nopar:Npn \doc_macro_aux:n #1 {
  \group_end:
  \clist_map_inline:nn {#1} { \doc_macro_single {##1} }
}
\bool_new:N \l_doc_macro_aux_bool
\bool_new:N \l_doc_macro_TF_bool
\cs_set_nopar:Npn \doc_macro_opt_aux: { \bool_set_true:N \l_doc_macro_aux_bool }
\cs_set_nopar:Npn \doc_macro_opt_TF:  { \bool_set_true:N \l_doc_macro_TF_bool }
\cs_set_nopar:Npn \doc_macro_single #1 {
  \tl_set:Nx \saved@macroname { \token_to_str:N #1 }
  \topsep\MacroTopsep
  \trivlist
  \cs_set_nopar:Npn \makelabel ##1 { \llap{##1} }
  \if@inlabel
    \cs_set_eq:NN \@tempa \@empty
    \count@ \macro@cnt
    \loop \ifnum\count@>\z@
      \cs_set_nopar:Npx \@tempa{\@tempa\hbox{\strut}}
      \advance\count@\m@ne
    \repeat
    \cs_set_nopar:Npx \makelabel ##1 {
      \llap{\vtop to\baselineskip {\@tempa\hbox{##1}\vss}}
    }
    \advance \macro@cnt \@ne
  \else
    \macro@cnt \@ne
  \fi

  \bool_if:NT \l_doc_macro_aux_bool {
    \cs_set_eq:NN \doc_macroname_prefix:n \doc_typeset_aux:n
  }
  \bool_if:NT \l_doc_macro_TF_bool {
    \cs_set_eq:NN \doc_macroname_suffix: \doc_typeset_TF:
  }

  \cs_set_nopar:Npx \@tempa {
    \exp_not:N \item [ \exp_not:N \doc_print_macroname:n {
      \tl_to_str:n {#1}
    }]
  } \@tempa
  \global\advance \c@CodelineNo \@ne

  \bool_if:NF \l_doc_macro_aux_bool {
    \bool_if:NTF \l_doc_macro_TF_bool {
      \seq_gput_right:Nx \g_doc_macros_seq { \tl_to_str:n { #1 TF } }
      \seq_gput_right:Nx \g_doc_macros_seq { \tl_to_str:n { #1 T  } }
      \seq_gput_right:Nx \g_doc_macros_seq { \tl_to_str:n { #1 F  } }
    }{
      \seq_gput_right:Nx \g_doc_macros_seq { \tl_to_str:n {#1} }
    }
  }
  \bool_if:NTF \l_doc_macro_TF_bool {
    \SpecialMainIndex{#1 TF}\nobreak
    \DoNotIndex{#1 TF}
  }{
    \SpecialMainIndex{#1}\nobreak
    \DoNotIndex{#1}
  }

  \global\advance \c@CodelineNo \m@ne
  \ignorespaces
}
\cs_set_nopar:Npn \doc_print_macroname:n #1 {
  \strut \MacroFont
  \doc_macroname_prefix:n {#1} \doc_macroname_suffix: \ % space!
}
\cs_set_nopar:Npn \doc_typeset_TF: {
  \color[gray]{0.5}
  \underline { \color{black} \itshape TF \kern-0.1em }
}
\cs_set_nopar:Npn \doc_typeset_aux:n #1 {
  {\color[gray]{0.5} #1}
}
\newcommand*{\DescribeOption}{
 \leavevmode
 \@bsphack
 \begingroup
   \MakePrivateLetters
   \Describe@Option
}
\newcommand*{\Describe@Option}[1]{
 \endgroup
 \marginpar{
   \raggedleft
   \PrintDescribeEnv{#1}
 }
 \SpecialOptionIndex{#1}
 \@esphack
 \ignorespaces
}
\newcommand*{\SpecialOptionIndex}[1]{
 \@bsphack
 \begingroup
   \HD@target
   \let\HDorg@encapchar\encapchar
   \edef\encapchar usage{
     \HDorg@encapchar hdclindex{\the\c@HD@hypercount}{usage}
   }
   \index{
     #1\actualchar{\protect\ttfamily#1}~(option)
     \encapchar usage
   }
   \index{
     options:\levelchar#1\actualchar{\protect\ttfamily#1}
     \encapchar usage
   }
 \endgroup
 \@esphack
}
\font\manual=manfnt
\cs_set_nopar:Npn \dbend { {\manual\char127} }
\newenvironment {danger} {
  \begin{trivlist}\item[]\noindent
  \begingroup\hangindent=2pc\hangafter=-2
  \cs_set_nopar:Npn \par{\endgraf\endgroup}
  \hbox to0pt{\hskip-\hangindent\dbend\hfill}\ignorespaces
}{
  \par\end{trivlist}
}
\newenvironment {ddanger} {
  \begin{trivlist}\item[]\noindent
  \begingroup\hangindent=3.5pc\hangafter=-2
  \cs_set_nopar:Npn \par{\endgraf\endgroup}
  \hbox to0pt{\hskip-\hangindent\dbend\kern2pt\dbend\hfill}\ignorespaces
}{
  \par\end{trivlist}
}
\newenvironment{TemplateInterfaceDescription}[1]
  {\subsection{The~object~type~`#1'}%
   \begingroup
   \@beginparpenalty\@M
   \description
   \def\TemplateArgument##1##2{\item[Arg:~##1]##2\par}%
   \def\TemplateSemantics{\enddescription\endgroup
       \subsubsection*{Semantics:}}%
  }
  {\par\bigskip}
\newenvironment{TemplateDescription}[2]
  {\subsection{The~template~`#2'~(object~type~#1)}%
   \subsubsection*{Attributes:}%
   \begingroup
   \@beginparpenalty\@M
   \description
   \def\TemplateKey##1##2##3##4{\item[##1~(##2)]##3%
     \ifx\TemplateKey##4\TemplateKey\else
         \hfill\penalty500\hbox{}\hfill Default:~##4%
         \nobreak\hskip-\parfillskip\hskip0pt\relax
     \fi
     \par}%
   \def\TemplateSemantics{\enddescription\endgroup
       \subsubsection*{Semantics~\&~Comments:}}%
  }
  {\par\bigskip}
\newenvironment{InstanceDescription}[4][xxxxxxxxxxxxxxx]
  {\subsubsection{The~instance~`#3'~(template~#2/#4)}%
   \subsubsection*{Attribute~values:}%
   \begingroup
   \@beginparpenalty\@M
   \def\InstanceKey##1##2{\>\textbf{##1}\>##2\\}%
   \def\InstanceSemantics{\endtabbing\endgroup
       \vskip-30pt\vskip0pt
       \subsubsection*{Layout~description~\&~Comments:}}%
   \tabbing
   xxxx\=#1\=\kill
  }
  {\par\bigskip}
\bool_new:N \g_doc_implementation_bool
\cs_set_nopar:Npn \AlsoImplementation {
  \bool_set_true:N \g_doc_implementation_bool
  \cs_set:Npn \StopEventually ##1 {
    \@bsphack
    \cs_gset_nopar:Npn \Finale { ##1 \check@checksum }
    \init@checksum
    \@esphack
  }
}
\AlsoImplementation
\cs_set_nopar:Npn \OnlyDescription {
  \@bsphack
  \bool_set_false:N \g_doc_implementation_bool
  \cs_set:Npn \StopEventually ##1 { ##1 \endinput }
  \@esphack
}
\cs_set_eq:NN \Finale \relax
\cs_set_nopar:Npn \partname{File}
\clist_new:N \g_docinput_clist
\cs_set:Npn \DocInput #1 {
  \clist_map_inline:nn {#1} {
    \clist_put_right:Nn \g_docinput_clist {##1}
    \MakePercentIgnore
    \input{##1}
    \MakePercentComment
  }
}
\cs_set:Npn \DocInputAgain {
  \clist_map_inline:Nn \g_docinput_clist {
    \MakePercentIgnore
    \input{##1}
    \MakePercentComment
  }
}
\cs_set_nopar:Npn \partname{File}
\newcommand*{\DocInclude}[1]{%
  \relax\clearpage
  \docincludeaux
  \IfFileExists{#1.fdd}{
    \cs_set_nopar:Npn \currentfile{#1.fdd}
  }{
    \cs_set_nopar:Npn \currentfile{#1.dtx}
  }
  \ifnum\@auxout=\@partaux
    \@latexerr{\string\include\space cannot~be~nested}\@eha
  \else
    \@docinclude #1
  \fi
}
\cs_set_nopar:Npn \@docinclude #1 {
  \clearpage
  \immediate\write\@mainaux{\string\@input{#1.aux}}
  \@tempswatrue
  \if@partsw
    \@tempswafalse
    \cs_set_nopar:Npx \@tempb{#1}
    \@for\@tempa:=\@partlist\do{
      \ifx\@tempa\@tempb\@tempswatrue\fi
    }
  \fi
  \if@tempswa
    \cs_set_eq:NN \@auxout\@partaux
    \immediate\openout\@partaux #1.aux
    \immediate\write\@partaux{\relax}
    \cs_set_eq:NN \@ltxdoc@PrintIndex\PrintIndex
    \cs_set_eq:NN \PrintIndex\relax
    \cs_set_eq:NN \@ltxdoc@PrintChanges\PrintChanges
    \cs_set_eq:NN \PrintChanges\relax
    \cs_set_eq:NN \@ltxdoc@theglossary\theglossary
    \cs_set_eq:NN \@ltxdoc@endtheglossary\endtheglossary
    \part{\currentfile}
    {
      \cs_set_eq:NN \ttfamily\relax
      \cs_gset_nopar:Npx \filekey{\filekey, \thepart={\ttfamily\currentfile}}
    }
    \DocInput{\currentfile}
    \cs_set_eq:NN \PrintIndex\@ltxdoc@PrintIndex
    \cs_set_eq:NN \PrintChanges\@ltxdoc@PrintChanges
    \cs_set_eq:NN \theglossary\@ltxdoc@theglossary
    \cs_set_eq:NN \endtheglossary\@ltxdoc@endtheglossary
    \clearpage
    \@writeckpt{#1}
    \immediate\closeout\@partaux
  \else
    \@nameuse{cp@#1}
  \fi
  \cs_set_eq:NN \@auxout\@mainaux
}
\cs_gset_nopar:Npn \codeline@wrindex #1 {
  \immediate\write\@indexfile {
    \string\indexentry{#1}
    {\filesep\number\c@CodelineNo}
  }
}
\cs_set_eq:NN \filesep \@empty
\cs_set_nopar:Npn \docincludeaux {
  \cs_set_nopar:Npn \thepart {\alphalph{part}}
  \cs_set_nopar:Npn \filesep {\thepart-}
  \cs_set_eq:NN \filekey\@gobble
  \g@addto@macro\index@prologue{
    \cs_gset_nopar:Npn\@oddfoot{
      \parbox{\textwidth}{
        \strut\footnotesize
        \raggedright{\bfseries File~Key:}~\filekey
      }
    }
    \cs_set_eq:NN \@evenfoot\@oddfoot
  }
  \cs_gset_eq:NN \docincludeaux\relax
  \cs_gset_nopar:Npn\@oddfoot{
    \expandafter\ifx\csname ver@\currentfile\endcsname\relax
      File~\thepart :~{\ttfamily\currentfile}~
    \else
      \GetFileInfo{\currentfile}
      File~\thepart :~{\ttfamily\filename}~
      Date:~\filedate\ % space
      Version~\fileversion
    \fi
    \hfill\thepage
  }
  \cs_set_eq:NN \@evenfoot \@oddfoot
}
\seq_new:N \g_doc_functions_seq
\seq_new:N \g_doc_macros_seq
\iow_open:Nn \g_write_func_stream { \jobname.cmds }
\cs_new_nopar:Npn \doc_show_functions_defined: {
  \bool_if:nT { \g_doc_implementation_bool && \g_doc_checkfunc_bool } {
    \typeout{ ======================================== ^^J }

    \tl_clear:N \l_tmpa_tl
    \seq_map_inline:Nn \g_doc_functions_seq {
      \seq_if_in:NnT \g_doc_macros_seq {##1} {
        \tl_put_right:Nn \l_tmpa_tl { ##1 ^^J }
        \iow_now:Nn \g_write_func_stream { ##1 }
      }
    }
    \iow_close:N \g_write_func_stream
    \doc_functions_typeout:n {
      Functions~both~documented~and~defined:^^J (In~order~of~being~documented)
    }

    \seq_map_inline:Nn \g_doc_functions_seq {
      \seq_if_in:NnF \g_doc_macros_seq {##1} {
        \tl_put_right:Nn \l_tmpa_tl { ##1 ^^J }
      }
    }
    \doc_functions_typeout:n { Functions~documented~but~not~defined: }

    \seq_map_inline:Nn \g_doc_macros_seq {
      \seq_if_in:NnF \g_doc_functions_seq {##1} {
        \tl_put_right:Nn \l_tmpa_tl { ##1 ^^J }
      }
    }
    \doc_functions_typeout:n { Functions~defined~but~not~documented: }

    \typeout{ ======================================== }
  }
}
\AtEndDocument{ \doc_show_functions_defined: }
\cs_set_nopar:Npn \doc_functions_typeout:n #1 {
  \tl_if_empty:NF \l_tmpa_tl {
    \typeout{
      -------------------------------------- ^^J #1 ^^J
      -------------------------------------- ^^J \l_tmpa_tl
    }
    \tl_clear:N \l_tmpa_tl
  }
}
\g@addto@macro\theindex{\MakePrivateLetters}
\cs_set:Npn \verbatimchar {&}
\setcounter{IndexColumns}{2}
\IndexPrologue{
  \part*{Index}
  \markboth{Index}{Index}
  \addcontentsline{toc}{part}{Index}
  The~italic~numbers~denote~the~pages~where~the~
  corresponding~entry~is~described,~
  numbers~underlined~point~to~the~definition,~
  all~others~indicate~the~places~where~it~is~used.
}

\cs_set_nopar:Npn \doc_special_main_index:n #1 {
  \index{
    \@gobble#1
    \actualchar
    \string\verb\quotechar*\verbatimchar#1\verbatimchar
    \encapchar
    hdpgindex{\thepage}{usage}
  }
}
\cs_set_nopar:Npn \doc_special_main_index:o { \exp_args:No \doc_special_main_index:n }
\cs_set_nopar:Npn \hdpgindex #1#2#3 {
  \csname\ifx\\#2\\relax\else#2\fi\endcsname{
    \hyperlink{page.#1}{#3}
  }
}
\g@addto@macro \PrintIndex { \AtEndDocument{ \typeout{^^J
  ========================================^^J
  Generate~the~index~by~executing^^J
  \c_space_tl \c_space_tl \c_space_tl \c_space_tl
  makeindex~-s~l3doc.ist~-o~\jobname.ind~\jobname.idx^^J
  ========================================^^J
  }}
}
\GlossaryPrologue{
  \part*{Change~History}
  {\GlossaryParms\ttfamily\hyphenchar\font=`\-}
  \markboth{Change~History}{Change~History}
  \addcontentsline{toc}{part}{Change~History}
}
\g@addto@macro \PrintChanges { \AtEndDocument{ \typeout{^^J
  ========================================^^J
  Generate~the~change~list~by~executing^^J
  \c_space_tl \c_space_tl \c_space_tl \c_space_tl
   makeindex~-s~gglo.ist~~-o~\jobname.gls~\jobname.glo^^J
  ========================================^^J
  }}
}
\bool_if:NTF \g_doc_full_bool {
  \RecordChanges
  \CodelineIndex
  \EnableCrossrefs
  \AlsoImplementation
}{
  \CodelineNumbered
  \DisableCrossrefs
  \OnlyDescription
}
%% 
%%
%% End of file `l3doc.cls'.
