-- 
--  This is file `fontspec.lua',
--  generated with the docstrip utility.
-- 
--  The original source files were:
-- 
--  fontspec.dtx  (with options: `lua')
--  
--    _________________________________________
--    The fontspec package for XeLaTeX/LuaLaTeX
--    (C) 2004--2010    Will Robertson and Khaled Hosny
--  
--    License information appended.
--  
--  


fontspec          = { }
fontspec.module   = {
    name          = "fontspec",
    version       = 2.0,
    date          = "2009/12/04",
    description   = "Advanced font selection for LuaLaTeX.",
    author        = "Khaled Hosny",
    copyright     = "Khaled Hosny",
    license       = "LPPL"
}
luatexbase.provides_module(fontspec.module)
function fontspec.log    (...) luatexbase.module_log    (fontspec.module.name, string.format(...)) end
function fontspec.warning(...) luatexbase.module_warning(fontspec.module.name, string.format(...)) end
function fontspec.error  (...) luatexbase.module_error  (fontspec.module.name, string.format(...)) end
function fontspec.sprint (...) tex.sprint(luatexbase.catcodetables['latex-package'], ...) end
local function check_script(id, script)
    local s = string.lower(script)
    if id and id > 0 then
        local otfdata = fonts.ids[id].shared.otfdata
        if otfdata then
            local features = otfdata.luatex.features
            for i,_ in pairs(features) do
                for j,_ in pairs(features[i]) do
                    if features[i][j][s] then
                        fontspec.log("script '%s' exists in font '%s'",
                                      script, fonts.ids[id].fullname)
                        return true
                    end
                end
            end
        end
    end
end
local function check_language(id, language, script)
    local s = string.lower(script)
    local l = string.lower(language)
    if id and id > 0 then
        local otfdata = fonts.ids[id].shared.otfdata
        if otfdata then
            local features = otfdata.luatex.features
            for i,_ in pairs(features) do
                for j,_ in pairs(features[i]) do
                    if features[i][j][s] and features[i][j][s][l] then
                        fontspec.log("language '%s' for script '%s' exists in font '%s'",
                                      language, script, fonts.ids[id].fullname)
                        return true
                    end
                end
            end
        end
    end
end
local function check_feature(id, feature, language, script)
    local s = string.lower(script)
    local l = string.lower(language)
    local f = string.lower(feature:gsub("^[+-]", ""))
    if id and id > 0 then
        local otfdata = fonts.ids[id].shared.otfdata
        if otfdata then
            local features = otfdata.luatex.features
            for i,_ in pairs(features) do
                if features[i][f] and features[i][f][s] then
                    if features[i][f][s][l] == true then
                        fontspec.log("feature '%s' for language '%s' and script '%s' exists in font '%s'",
                                      feature, language, script, fonts.ids[id].fullname)
                        return true
                    end
                end
            end
        end
    end
end
local function tempswatrue()  fontspec.sprint([[\@tempswatrue]])  end
local function tempswafalse() fontspec.sprint([[\@tempswafalse]]) end
function fontspec.check_ot_script(fnt, script)
    if check_script(font.id(fnt), script) then
        tempswatrue()
    else
        tempswafalse()
    end
end
function fontspec.check_ot_lang(fnt, lang, script)
    if check_language(font.id(fnt), lang, script) then
        tempswatrue()
    else
        tempswafalse()
    end
end
function fontspec.check_ot_feat(fnt, feat, lang, script)
    for _, f in ipairs { "+trep", "+tlig", "+anum" } do
        if feat == f then
            tempswatrue()
            return
        end
    end
    if check_feature(font.id(fnt), feat, lang, script) then
        tempswatrue()
    else
        tempswafalse()
    end
end
function fontspec.mathfontdimen(fnt, str)
    local mathdimens = fonts.ids[font.id(fnt)].MathConstants
    if mathdimens then
        local m = mathdimens[str]
        if m then
            fontspec.sprint(mathdimens[str])
            fontspec.sprint("sp")
        else
            fontspec.sprint("0pt")
        end
    else
        fontspec.sprint("0pt")
    end
end
--  
--  Copyright 2004--2010 Will Robertson <wspr81@gmail.com>
--  Copyright 2009--2010 Khaled Hosny <khaledhosny@eglug.org>
--  
--  Distributable under the LaTeX Project Public License,
--  version 1.3c or higher (your choice). The latest version of
--  this license is at: http://www.latex-project.org/lppl.txt
--  
--  This work is "author-maintained" by Will Robertson.
--  
--  This work consists of this file fontspec.dtx
--            and the derived files fontspec.sty,
--                                  fontspec.lua,
--                                  fontspec.cfg,
--                                  fontspec-xetex.tex,
--                                  fontspec-luatex.tex,
--                              and fontspec.pdf.
--  
-- 
--  End of file `fontspec.lua'.
