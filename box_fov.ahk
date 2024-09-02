MsgBox FOV Toogle - f5
#Singleinstance, Force
Gui, Color, EEAA99
Gui, Font, S37, Arial Black

Gui, Add, GroupBox, w170 h190 cFFB10F BackgroundTrans,
Gui +LastFound +AlwaysOnTop +ToolWindow
WinSet, TransColor, EEAA99
Gui -Caption
Gui, Show
Return

;-------------------------------------------toggle

F5::

	Toggle := !Toggle

	If Toggle

		Gui, Show, Hide

	else

		Gui, Show

Return
;------------------------------------------end
Z::ExitApp