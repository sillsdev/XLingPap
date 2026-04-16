!include LogicLib.nsh
!include WinMessages.nsh
 
!macro FontInstallHelper FontFileSrc FontFileDst FontInternalName Resource RegSuffix RegRoot
ClearErrors
!if "${FontFileSrc}" != ""
${IfNot} ${FileExists} "${FontFileDst}"
	File "/oname=${FontFileDst}" "${FontFileSrc}"
${EndIf}
!endif
${IfNot} ${Errors}
	Push $0
	Push "${Resource}"
	Exch $1
	Push "${FontInternalName}${RegSuffix}"
	Exch $2
	Push $9
	StrCpy $9 "Software\Microsoft\Windows NT\CurrentVersion\Fonts"
	!if "${NSIS_CHAR_SIZE}" < 2
	ReadRegStr $0 ${RegRoot} "SOFTWARE\Microsoft\Windows NT\CurrentVersion" "CurrentVersion"
	${IfThen} $0 == "" ${|} StrCpy $9 "Software\Microsoft\Windows\CurrentVersion\Fonts" ${|}
	!endif
	System::Call 'GDI32::AddFontResource(tr1)i.r0'
	${If} $0 <> 0
		WriteRegStr ${RegRoot} "$9" "$2" "$1"
	${Else}
		SetErrors
	${EndIf}
	Pop $9
	Pop $2
	Pop $1
	Pop $0
${Else}
	SetErrors
${EndIf}
!macroend
!macro FontInstallTTF FontFileSrc FontFileName FontInternalName
!insertmacro FontInstallHelper "${FontFileSrc}" "$Fonts\${FontFileName}" "${FontInternalName}" "${FontFileName}" " (TrueType)" HKLM
!macroend
 
!macro FontUninstallHelper FontFileDst FontInternalName Resource RegSuffix RegRoot
System::Call 'GDI32::RemoveFontResource(t"${Resource}")'
DeleteRegValue ${RegRoot} "Software\Microsoft\Windows NT\CurrentVersion\Fonts" "${FontInternalName}${RegSuffix}"
!if "${NSIS_CHAR_SIZE}" < 2
DeleteRegValue ${RegRoot} "Software\Microsoft\Windows\CurrentVersion\Fonts" "${FontInternalName}${RegSuffix}"
!endif
ClearErrors
Delete "${FontFileDst}"
!macroend
!macro FontUninstallTTF FontFileName FontInternalName
!insertmacro FontUninstallHelper "$Fonts\${FontFileName}" "${FontInternalName}" "${FontFileName}" " (TrueType)" HKLM
!macroend
