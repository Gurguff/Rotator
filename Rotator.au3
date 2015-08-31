;;;;Rotator

; Rotator is a script to ensure following output of Ovale.
; The main purposes are:
; 1) Enable singlerotation
; 2) Enable multirotation
; 3) Stop rotation
; 4) Log how well the script could be followed.

; Load a specific character
; Config a specific character
; Save a specific character

; Optional purposes are:
; A) Statistics
; B) Autobail
; C) Evasive patterns
; D) Target macro definer (helpful target changer)

; == Simple dialog for Control
; [Simple][Multi][Stop][Quit]
; [Config] => [Learn??]
$DESKTOP=0
$AGATE=1
$computer =  $DESKTOP
;$computer = 1

if $computer=$DESKTOP then
  global $win_pos_x = 190
  global $win_pos_y = 0
  global $win_size_x = 1726
  global $win_size_y = 1108

Else
  global $win_pos_x = 120
  global $win_pos_y = 0
  global $win_size_x = 1470
  global $win_size_y = 860
EndIf

Opt( "MustDeclareVars", 1 )

#include <GUIConstantsEx.au3>
#include <GuiComboBox.au3>
#include <Date.au3>

HotKeySet( "¨", "StartAttack" )
HotKeySet( "'", "StopAttack" )
HotKeySet("{F10}", "FindPressed")
HotKeySet("-", "MultiPressed")


global $mode = 0
global $xC = 0
global $yC = 0
global $txt
global $flash=0
global $singleaoe = 0 ;Single=0, Multi=1, Both = 2, None=3 (BOTH and NONE NOT USED)

global $_SPELLACT=0
global $_SPELLNAME=1
global $_SPELLSPOT=2
global $_SPELLPOS1=3
global $_SPELLPOS2=4
global $_SPELLPOS3=5
global $_SPELLPOS4=6


; Here , Horisontal Offset=0 and Vertical Offset=-246 in the Ovale positioning!!! (Margin=4)

global $ax = 974 ; left edge of the button
global $ay = 798 ; top edge of the buttons
global $bd = 40  ; distance between buttons
global $sd = 12  ; distance between samples
global $os = 6	 ; offset from button corner for first sample point
global $1x = $ax+$os, $2x = $1x+$sd
global $1y = $ay+$os, $2y = $1y+$sd

global $spot1x[] = [ $1x,$2x,$1x,$2x ]
global $spot1y[] = [ $1y,$1y,$2y,$2y ]
$1x += $bd
$2x += $bd
global $spot2x[] = [ $1x,$2x,$1x,$2x ]
global $spot2y[] = [ $1y,$1y,$2y,$2y ]
$1x += $bd
$2x += $bd
global $spot3x[] = [ $1x,$2x,$1x,$2x ]
global $spot3y[] = [ $1y,$1y,$2y,$2y ]
$1x += $bd
$2x += $bd
global $spot4x[] = [ $1x,$2x,$1x,$2x ]
global $spot4y[] = [ $1y,$1y,$2y,$2y ]

global $aVal[4]
global $aVal1[4]
global $aVal2[4]
global $aVal3[4]
global $aVal4[4]

global $char = -1
global $charname[] = [ "Gurguff-SV", "Eralina", "Sesamina-C", "Sesamina-A", "Ozulman-B", "Ozulman-C", "Gurguff-MM", "Irsimijas-R", "Gurguff-BM", "Epinea-R", "Sykoss","IceBrick", "IceBrick2" ]
global $Spell[1]

global $ComboBoxList = ""
For $i = 0 To UBound($charname) -1
    $ComboBoxList &= "|" & $charname[$i]
Next

global $SpellActivator[1] ;= [ "1", "2", "3", "4", "{F4}" ]
   global $SpellName[1] ;= [ "Aimed Shot", "Chimera Shot", "Steady Shot", "Glaive Toss", "Kill Shot" ]
   global $SpellSpot[1] ;= [ 1,1,1,1,1 ]
   global $tbl1[1] ;= [ 0,        12258047,  14080990,   11445882, 6753794 ]
   global $tbl2[1] ;= [ 10467010,  8231356,  14076574, 5725274,    11079942 ]
   global $tbl3[1] ;= [ 8156515,    263688,  12231541, 529436,  6315111 ]
   global $tbl4[1] ;= [ 8361888,   7307918,  12301190,  6773824,  7277060 ]

global $hWOW, $client = "World of Warcraft"

global $idLbl, $btnChar, $btnMode, $filename, $toonname, $filepath, $sActivator, $cbxChar,$match=-2


Main()

Func GetCharSel($hCombo, $asDataLines)

    Local $sSelectedText = GUICtrlRead($hCombo)
    Local $iEntryId = -1 ;; zero based.

    For $i = 0 To UBound($asDataLines, 1) - 1
        If Not ($asDataLines[$i] == $sSelectedText) Then ContinueLoop ;; case sensitve.

        $iEntryId = $i
        ExitLoop
    Next

    If $iEntryId < 0 Then SetError(1)
    Return $iEntryId
EndFunc

Func Main()
	Opt("GUICoordMode", 2)
	Opt("GUIResizeMode", 1)
	Opt("GUIOnEventMode", 1)

	Local $aPos
	local $step=0
	local $a[4]

	$hWOW = WinGetHandle( $client )
	if not @error = 0 Then
	  MsgBox( $MB_OK, "Error!","Cant find World of Warcraft window exiting!!", 10 )
	  ;Exit
	EndIf

	;$a = WinGetPos( $hWOW )
	;MsgBox( $MB_OK, "Info","WoW Pos " & $a[0] & " " & $a[1] & " " & $a[2] & " " & $a[3], 10 )

	WinMove( $hWOW, "", $win_pos_x,$win_pos_y,$win_size_x,$win_size_y )

	$a = WinGetPos( $hWOW )
	;MsgBox( $MB_OK, "Info","WoW Pos " & $a[0] & " " & $a[1] & " " & $a[2] & " " & $a[3], 10 )

	GUICreate("Rotator",120,200,0,0)
	GUISetOnEvent($GUI_EVENT_CLOSE, "SpecialEvents")
	GUISetOnEvent($GUI_EVENT_MINIMIZE, "SpecialEvents")
	GUISetOnEvent($GUI_EVENT_RESTORE, "SpecialEvents")

	GUICtrlCreateButton("Reset", 5, 5, 90)
	GUICtrlSetOnEvent(-1, "ResetPressed")

	$cbxChar = GUICtrlCreateCombo("", -1, 0)
	GUICtrlSetData($cbxChar, $comboBoxList)

	$btnChar = GUICtrlCreateButton("", -1, 0)
	GUICtrlSetOnEvent(-1, "CharPressed")

	GUICtrlCreateButton("Mouse", -1, 0 )
	GUICtrlSetOnEvent(-1, "MousePressed")

	GUICtrlCreateButton("Find", -1, 0 )
	GUICtrlSetOnEvent(-1, "FindPressed")

	$btnMode = GUICtrlCreateButton("Mode", -1, 0)
	GUICtrlSetOnEvent(-1, "ModePressed")

	$idLbl = GUICtrlCreateLabel("Label", -1, 0, 100, 80)
	$Txt = ""
	GUISetState(@SW_SHOW)

    GUISetIcon( "go1.ico" )
	TraySetIcon( "go1.ico" )

    CharPressed()



	WinActivate( $hWOW )
	; Just idle around
	While 1
		Sleep(50)
		if $mode = 3 Then
			GUICtrlSetData( $btnMode, "Mouse"  )
			$aPos = MouseGetPos()
			local $cX = $aPos[0]
			local $cY = $aPos[1]
			$Txt = "" & $cX & " : " &  $cY
			GUICtrlSetData( $idLbl, "Pos : " & $Txt)
		 ElseIf $mode = 4 Then
			GUICtrlSetData( $btnMode, "Vals"  )
			$aVal[0] = PixelGetColor($spot1x[0],$spot1y[0])
			$aVal[1] = PixelGetColor($spot1x[1],$spot1y[1])
			$aVal[2] = PixelGetColor($spot1x[2],$spot1y[2])
			$aVal[3] = PixelGetColor($spot1x[3],$spot1y[3])
			$txt = "Spot1: " & @CRLF & $aVal[0] & "," & $aVal[1] & "," & $aVal[2] & "," & $aVal[3] & @CRLF & @CRLF
			$aVal[0] = PixelGetColor($spot2x[0],$spot2y[0])
			$aVal[1] = PixelGetColor($spot2x[1],$spot2y[1])
			$aVal[2] = PixelGetColor($spot2x[2],$spot2y[2])
			$aVal[3] = PixelGetColor($spot2x[3],$spot2y[3])
			$txt = $txt & "Spot2: " & @CRLF & $aVal[0] & "," & $aVal[1] & "," & $aVal[2] & "," & $aVal[3] & @CRLF & @CRLF
			GUICtrlSetData( $idLbl, $txt )
		 Elseif $mode = 1 Then
			HandleRotation()

		 Else
			if ($match=-2) Then
			   GUICtrlSetData( $btnMode, "#GO!#"  )
			   GUISetIcon( "go1.ico" )
			   TraySetIcon( "go1.ico" )
			endif
			$match = -3
			$step = 0
		 EndIf
	WEnd
EndFunc   ;==>Example

Func ResetPressed()
	$hWOW = WinGetHandle( $client )
	;if not @error = 0 Then
	;	MsgBox( $MB_OK, "Error!","Cant find World of Warcraft window!!", 10 )
	;EndIf
	WinMove( $hWOW, "", $win_pos_x,$win_pos_y,$win_size_x,$win_size_y )
	local $tPos = WinGetPos( $hWOW )
	;if not ( $tPos[0] = $win_pos_x and $tPos[1] = $win_pos_y and $tPos[2] = $win_size_x and $tPos[3] = $win_size_y ) Then
	;	MsgBox($MB_OK, "Warning", "Wow win not at correct pos/size: " & @CRLF & $win_pos_x & ":" & $win_pos_y & "/" & $win_size_x & ":" & $win_size_x & " # " & $tPos[0] & " " & $tPos[1] & " " & $tPos[2] & " " & $tPos[3])
	;EndIf
    WinActivate($hWOW)
EndFunc   ;==>ResetPressed

Func MousePressed()
	local $aPos = MouseGetPos()
	local $cX = $aPos[0]
	local $cY = $aPos[1]
	$Txt = "" & $cX & " : " &  $cY
	GUICtrlSetData( $idLbl, "Pos : " & $Txt)
    WinActivate($hWOW)
EndFunc

Func CharPressed()

   $char=GetCharSel($cbxChar, $charname)
   _GUICtrlComboBox_SetCurSel($cbxChar,-1)
   if $char=-1 Then
     $char=0
   EndIf
    if $char=UBound($charname) then
	   $char=0
    endif

If $computer =  $AGATE then
   If $char=0 Then
   global $Spelly[][] = [ _
		[ "{F6}",	"Coin",		1,	16776933,	8595456,	10769732,	16230196 	], _
		[ "{F2}",	"BlackArr",	2,	5374100,	5701776,	4653182,	6358419 	], _
		[ "{F1}",	"Trink1",	4,	8884629,	1601423,	7368855,	4637927		], _
		[ "{F6}",	"ExplTrap",	1,	16776933,	0,			10769732,	16230196	], _
		[ "4",		"Barrage",	1,	750777,		0,			10208442,	550816 		], _
		[ "5",		"Crows",	1,	1580324,	0,			3554374,	1053196 	], _
		[ "3",		"FocusShtS",2,	2825236,	4661525,	7617319,	7356204 	], _
		[ "3",		"FocusShtM",3,	2891028,	4661525,	7617575,	7356204 	], _
		[ "{F3}",	"AgiPot",	4,	10256188,	341290,		9082236,	3166269 	], _
		[ "1",		"Arcane",	2,	2424932,	12171695,	9479512,	5657946 	], _
		[ "2",		"Explosive",2,	7751176,	8932114,	16505133,	13289021 	], _
		[ "3",		"Cobra",	2,	3766528,	3950893,	2760728,	5663598 	], _
		[ "3"		,"Focus",	2,5341205,		2237723,		7195139,		8492688], _
		[ "3"		,"Focus",	3,5341461,		2369309,		7195139,		8558480], _
		 [ "4",		"Glaive To",2,	11445882,	5725274,	529436,		6773824 	], _
		[ "{F4}",	"KillShot",	2,	6753794,	11079942,	6315111,	7277060 	], _
		[ "4",		"Glaive",	3,	11511675,	5725274,	529436,		6905409 	], _
		[ "{F2}",	"BlackArr",	3,	5374100,	5701776,	4587645,	6358419 	], _
		[ "2",		"Expl",		3,	7751176,	8866322,	16505133,	13289021 	], _
		[ "1",		"Arcane",	3,	2424932,	12171695,	9545048,	5657690 	], _
		[ "3",		"Cobra",	3,	3766528,	4016686,	2760985,	5663598 	], _
		[ "7",		"Multi",	3,	3538998,	11359108,	4784713,	4866860 	] _
   ]

;Eralina-Arcane
   ElseIf $char=1 Then
   global $Spelly[][] = [ _
		["{F7}"		,"PresMind",	1,	3487285,		0,				7300178,		12627845], _
		["{F2}"		,"ArcPower",	1,	16,				10066329,		1649,			726], _
		["7"		,"Evocation",	4,	14603263,		3478281,		13542143,		11306653], _
	    ["1"		,"ArcMissS",	2,	7552688,		12865244,		1577566,		16776703], _
		["1"		,"ArcMissM",	3,	7552688,		12930781,		1577566,		16776703], _
		["2"		,"ArcBlastS",	2,	9596401,		4334748,		4597940,		1050665], _
		["2"		,"ArcBlastM",	3,	9596658,		4334748,		4597940,		1050665], _
		["2"		,"ArcBlastS",	2,	10782157,		12825836,		14140668,		5912251], _
		["2"		,"ArcBlastM",	3,	10782157,		12760043,		14074876,		5911995], _
		["3"		,"ArcBarrS",	2,	1707860,		11248124,		11195646,		6778367], _
		["3"		,"ArcBarrM",	3,	1707861,		11248124,		11129598,		6778367], _
		["6"		,"ArcBrill",	2,	15022,			50411,			145063,			34274], _
   ]

   ;Sesamina-Combat
   Elseif $char=2 Then
   global $Spelly[][] = [ _
		[ "0",		"Vanish",	 1,	5397091,	0,			7108485,	6317680 ], _
		[ "6",		"Spree",	 1, 2565169,	4475475,	7239812,	7042692], _
		[ "{F4}",	"Stealth",	 2,	1588248,	2759692,	7422218,	11503951 ], _
	    [ "1",		"Sinister",	 2,	5786424,	15117667,	13397043,	7761264], _
	    [ "1",		"Sinister St",2,9208468,	2949201,	6622122,	12040631 ], _
		[ "4"		,"NN",		 2, 4261893,	2098179,	13202176,	15703296], _
		[ "4"		,"NN",		 3, 4261893,	2098179,	13202176,	15703296], _
	    [ "3"		,"NN",		 2, 10786177,	0,			10128505,	11312782], _
		[ "3"		,"NN",		 3, 10851970,	0,			10128505,	11312782], _
		[ "{F5}",	"Eviscerate",2,	14987909,	9634566,	11567187,	3548439 ] _
   ]

   ;Sesamina-Assasin
   Elseif $char=3 Then
   global $Spelly[][] = [ _
		[ "{F4}",	"Stealth",	2,	1588248,	1445638,	7422218,	11503951 ], _
		[ "1",		"Mutilate",	2,	1091035,	961760,		2376367,	1386607 ], _
		[ "3",		"Rupture",	2,	131072,		16776191,	3223601,	5263184 ], _
		[ "2",		"Envenom",	2,	3072,		13027772,	7436901,	9471333 ], _
		[ "4",		"Dispatch",	2,	1182730,	9461051,	7474190,	2693398 ], _
		[ "{F5}",	"Eviscerate",2,	14987909,	9634566,	11567187,	3548439 ] _
   ]

   ;Ozulman Tank/Bear
   Elseif $char=4 Then
   global $Spelly[][] = [ _
		[ "{F6}",	"Barkskin",	4,	15366400,	5586204,	9064474,	6700053 ], _
		[ "{F4}",	"FrenziedGen",1,4602672,	0,			9852738,	2951172 ], _
		[ "6",		"SavageDef",1,	14241576,	0,			67080,		15699037 ], _
		[ "{F5}",	"CenarionWard",2,14541517,	9739882,	11714700,	657926 ], _
		[ "3",		"Lacerate",	2,	13215644,	14061956,	4008505,	3738382 ], _
		[ "1",		"Trash",	2,	10976607,	9008491,	8882055,	4736836 ], _
		[ "2",		"Mangle",	2,	9568256,	917504,		0,			14327901 ], _
		[ "4",		"Maul",		2,	10976607,	9008491,	8882055,	4736836 ] _
   ]
   ;Ozulman Cat/Dps
   Elseif $char=5 Then
   global $Spelly[][] = [ _
		[ "{F4}",	"Catform",	2,	65535,		0,			28562,		37291 ], _
		[ "{F2}",	"Berserk",	4,	7100742,	4000000,	6234123,	655616 ], _
		[ "{F1}",	"FrenziGen",1,	16776925,	8746842,	12030524,	5391925 ], _
		[ "1",		"Rake",		2,	6029568,	2695184,	14924422,	851968 ], _
		[ "{F5}",	"HealingT",	2,	11587813,	3321412,	2202657,	5948765 ], _
		[ "4",		"Ferosius",	2,	9467779,	6968921,	2886676,	13044753 ], _
		[ "5",		"SavagRoar",2,	3217424,	4989204,	10584159,	13015153 ], _
		[ "2",		"Shred",	2,	16738584,	12347737,	9517325,	6363657 ], _
		[ "0",		"Prowl",	2,	332170,		1808,		2965,		1069758 ], _
		[ "3",		"Rip",		2,	4263683,	3607812,	14342106,	2955284 ], _
		[ "1",		"Rake",		3,	6029568,	2695184,	14924422,	851968 ], _
		[ "2",		"Shred",	3,	16738584,	12347480,	9451789,	6232585 ], _
		[ "3",		"Rip",		3,	3217424,	4989460,	10584159,	13015409 ], _
		[ "7",		"Multi",	3,	10976607,	8876905,	8882055,	4802886 ], _
		[ "8",		"Multi",	3,	8943931,	2036485,	15706681,	525832 ], _
		[ ".",		"MotWild",	2,	13854664,	10908041,	16235222,	14113246 ], _
		[ ".",		"MotWild",	3,	13788870,	10842249,	16235222,	14178784 ] _
   ]

   ;Gurguff MM
   ElseIf $char=6 Then
   global $Spelly[][] = [ _
		[ "{F1}",	"RapidF",	4,	2883584,	16711680,	0,			9175040 ], _
		[ "1",		"AimedShot",2,	0,			10467010,	8156515,	8361888 ], _
		[ "2",		"Chimera S",2,	12258047,	8231356,	263688,		7307918 ], _
		[ "3",		"Steady Sh",2,	14080990,	14076574,	12231541,	12301190 ], _
		[ "4",		"Glaive To",2,	11445882,	5725274,	529436,		6773824 ], _
		[ "{F4}",	"Kill Shot",2,	6753794,	11079942,	6315111,	7277060 ] _
   ]

   ;Irsimijas-Ret
   ElseIf $char=7 Then
   global $Spelly[][] = [ _
		[ "{F2}",	"BlessKing",2,	8804970,	9265523,	1315340,	4861869 ], _
		[ "{F2}",	"BlessKing",3,	9133676,	9331058,	921351,		4927406 ], _
		[ "{F4}",	"BlessMigt",2,	9265269,	9527929,	10066329,	2766924 ], _
		[ "{F6}",	"AvengWrat",4,	12037006,	14799480,	6511184,	7946004 ], _
		[ "{F6}",	"avengWrat",4,	15194995,		8937004,		7616273,		4332296], _
		[ "5",		"ExSent",	1,	9466669,	16641647,	6443813,	16102725 ], _
		[ "5",		"exSent",	1,	16574831,		0,		15177786,		11705674], _
		[ "6",		"HammerWrt",2,	2391428,	2499091,	7709062,	4500393], _
		[ "6",		"HammerWrt",3,	2457220,	2499091,	7643013,	4500393], _
		[ "2",		"CrusaderS",2,	16757043,		16046170,		11048495,		15455363], _
		[ "2",		"CrusaderM",3,	16757043,		16045914,		11114288,		15455619], _
		[ "4",		"TemplarsV",2,	1314572,	2692129,	1315340,	13815946 ], _
		[ "4",		"templarsV",2,	2166808,	5060408,	15196561,	3685684], _
		[ "7",		"CrusaderS",2,	1314572,	16642745,	1315340,	16776693 ], _
		[ "1",		"Judgement",2,	14069313,		8618371,		13406748,		10835490], _
		[ "1",		"Judgement",3,	14069313,		8618371,		13406748,		10769954] _
  ]

;Eralina-Frost
   ElseIf $char=8 Then
   global $Spelly[][] = [ _
		[ "5",		"Waterjet",	1,	0,			0,			0,			0 			], _
		[ "7",		"IcyVeins",	4,	4117503,	134480,		7522290,	1801437 	], _
		[ "{F3}",	"Arc Brill",2,	20932,		16050,		14266,		343498 		], _
		[ "4",		"FrozeOrb",	1,	3735551,	0,			2467833,	23406 		], _
		[ "8",		"Sum WE",	1,	10875333,	4172383,	11064240,	4297580 	], _
		[ "1",		"Frostbolt",2,	13485299,	1969713,	6706049,	6382527 	], _
		[ "{F2}",	"Ice Nova",	2,	1913431,	990018,		1915261,	262 		], _
		[ "2",		"Ice Lance",2,	15792895,	5875425,	1849480,	12508914 	], _
		[ "3",		"Frostfire",2,	9510940,	7523306,	690155,		15525297 	], _
		[ "N/A",	"N/A",		2,	11445882,	5725274,	529436,		6773824 	], _
		[ "N/A",	"Kill Shot",2,	6753794,	11079942,	6315111,	7277060 	] _
   ]
   Endif ;<== Char
   Else ;  $DESKTOP
   If $char=0 Then
   global $Spelly[][] = [ _
		[ "{F6}",	"Coin",		1,	16776933,	8595456,	10769732,	16230196 	], _
		[ "{F2}",	"BlackArr",	2,	5505166,		10066329,		5767316,		8], _
		[ "{F1}",	"Trink1",	4,1062228,		10066329,		534602,		2320501], _
		[ "{F6}",	"ExplTrap",	1,	398110,		10066329,		16777215,		795945], _
		[ "4",		"Barrage",	1,	6138061,		1403551,		10074557,		7384542], _
		[ "5",		"Crows",	1,	5404044,		1053720,		6931153,		2169889], _
		[ "3",		"FocusShtS",2,	4984576,	7023648,	3739138,	10788251	], _ ;fixed
		[ "3",		"FocusShtM",2,	4984576,	7023648,	3739138,	10788251	], _ ;fixed
		[ "{F3}",	"AgiPot",	4,	10256188,	341290,		9082236,	3166269 	], _
		[ "1",		"Arcane",	2,	1441853,		1120537,		984627,		11243342], _
		[ "2",		"Explosive",2,	590080,		4333320,		13994522,		9201295], _
		[ "3",		"Cobra",	2,	3766528,	3950893,	2760728,	5663598 	], _
		[ "4",		"Glaive To",2,	11445882,	5725274,	529436,		6773824 	], _
		[ "{F4}",	"KillShot",	2,	6753794,	11079942,	6315111,	7277060 	], _
		[ "4",		"Glaive",	3,	11511675,	5725274,	529436,		6905409 	], _
		[ "{F2}",	"BlackArr",	3,	5505166,		10066329,		5767316,		8], _
		[ "2",		"Expl",		3,	590080,		4333320,		13994522,		9201295], _
		[ "1",		"Arcane",	3,	1441853,		1120537,		919091,		11308878], _
		[ "3",		"Cobra",	3,	3766528,	4016686,	2760985,	5663598 	], _
		[ "7",		"Multi",	3,	3538998,	11359108,	4784713,	4866860 	] _
   ]
   ElseIf $char=1 Then ; Eralina
   global $Spelly[][] = [ _
	    ["{F7}"	,	"PresMind",	1,	136754,			10066329,		1068444,		6842216], _
		["{F2}",	"ArcPower",	1,	16,				10066329,		1649,			726], _
		["7",		"Evocation",4,	14603263,		3478281,		13542143,		11306653], _
		["1"		,"ArcMissS",2,	3215707,		0,		0,		16776191], _
		["1"		,"ArcMissM",3,	3215706,		0,		0,		16776191], _
		["2",		"ArcBlastS",2,	9596401,		4334748,		4597940,		1050665], _
		["2",		"ArcBlastM",3,	9596658,		4334748,		4597940,		1050665], _
		["3",		"ArcBarrS",	2,	1378083,		1183064,		2364821,		2956453], _
		["3",		"ArcBarrM",	3,	1378084,		1248601,		2364821,		2956453], _
	    ["7",		"Evocation",4,	4796522,		11504127,		9199558,		14389371], _
		["6",		"ArcBrill",	2,	15022,			50411,			145063,			34274] _
   ]

   ;Sesamina-Combat
   Elseif $char=2 Then
   global $Spelly[][] = [ _
		[ "0",		"Vanish",	1,	2565169,		4475475,		7239812,		7042692], _
		[ "6",		"Spree",	4,	2964327,		1121601,		1783630,		1519946], _
		[ "{F4}",	"StealthS",	2,	4743293,		10066329,		656646,		8540704], _
		[ "{F4}",	"StealthM",	3,	4677501,		10066329,		656646,		8474912], _
		[ "1",		"SinisStS",	2,	5786424,		15117667,		13397043,		7761264], _
		[ "1",		"SinisStM",	3,	5786424,		15117667,		13396787,		7695727], _
		["1"		,"NN",	2,14474207,		6359460,		8816521,		10922150], _
		["1"		,"NN",	3,14605537,		6359459,		8816265,		10856357], _
		[ "4",		"SnDS",		2,	4261893,		2098179,		13202176,		15703296], _
		[ "4",		"SnDM",		3,	4261893,		2098179,		13202176,		15703296], _
		[ "3",		"RevStrikS",2,	10786177,		0,		10128505,		11312782], _
		[ "3",		"RevStrikM",3,	10851970,		0,		10128505,		11312782], _
		[ "{F5}",	"Eviscerat",2,	12686185,		10066329,		5913641,		10129037], _
		[ "{F5}",	"Eviscerat",3,	12686185,		10066329,		5913641,		10063500], _
		[ "{F12}",	"Prepare",	4,	3151896,	7427918,		2163720,		7594740] _
   ]

   ;Ozulman Cat/Dps
   Elseif $char=5 Then
   global $Spelly[][] = [ _
		[ "{F2}",	"Berserk",	4,	16372922,		10066329,		14592643,		14595666], _
		[ "{F1}",	"FrenziGen",1,	14468002,		0,		16706712,		13417070], _
	    [ "1",		"RakeS",	2,	524288,		2958357,		5373952,		6684672], _
		[ "1",		"RakeM",	3,	524288,		2958357,		5373952,		6684672], _
		[ "4",		"Ferosius",	2,  8084839,		8481665,		3677732,		10233897], _
		[ "4",		"FerosiusM",	3,  8084839,		8547714,		3677731,		10233897], _
	    [ "5",		"SavagRoar",2,	3020048,		11091464,		4334625,		3679012], _
		[ "5",		"SavagRoarM",3,	3020048,		11025928,		4334625,		3679012], _
		[ "2",		"Shred",	2,	853249,		14141865,		525312,		9766664], _
		[ "2",		"ShredM",	3,	787457,		14141866,		525312,		9832200], _
		[ "0",		"Prowl",	2,	1087,		2400931,		3502,		4043], _
		[ "0",		"ProwlM",	3,	1087,		2400931,		3503,		4043], _
		[ "3",		"Rip",		2,	0,		5970442,		4666675,		721410], _
		[ "3",		"RipM",		3,	0,		5970442,		4666932,		721410], _
		[ "1",		"Rake",		3,	6029568,	2695184,	14924422,	851968 ], _
		[ "2",		"Shred",	3,	16738584,	12347480,	9451789,	6232585 ], _
		[ "3",		"Rip",		3,	3217424,	4989460,	10584159,	13015409 ], _
		[ "7",		"Multi",	3,	10976607,	8876905,	8882055,	4802886 ], _
		[ "8",		"Multi",	3,	8943931,	2036485,	15706681,	525832 ], _
		[ "{F4}",	"CatForm",	2,	35508,		10066329,		56811,		40639], _
		[ "{F4}",	"CatForm",	3,	35765,		10066329,		57325,		40895], _
		[ "{F5}",	"HealingT",	2,	2641784,		10066329,		14281968,		2074403], _
		[ "{F5}",	"HealingT",	3,	2641784,		10066329,		14347505,		2074403], _
		[ ".",		"MotWild",	2,	11225234,		7942778,		10831777,		16738815], _
		[ ".",		"MotWild",	3,	11225234,		7942778,		10831777,		16738815] _
   ]
   ;Irsimijas-Ret
   ElseIf $char=7 Then
   global $Spelly[][] = [ _
		[ "{F2}",	"BlessKing",2,	8804970,	9265523,	1315340,	4861869 ], _
		[ "{F2}",	"BlessKing",3,	9133676,	9331058,	921351,		4927406 ], _
		[ "{F4}",	"BlessMigt",2,	9265269,	9527929,	10066329,	2766924 ], _
		[ "{F6}",	"AvengWrat",4,	14663288,		10066329,		14060098,		9195040], _
		[ "5",		"ExSent",	1,	1051656,		16169027,		3550740,		2954257], _
		[ "6",		"HammerWrt",2,	532264,		9150349,		3753265,		4876643], _
		[ "6",		"HammerWrt",3,	532264,		9150349,		3753265,		4876643], _
		["2"		,"NN",	2,16757043,		16046170,		11048495,		15455363], _
		["2"		,"NN",	3,16757043,		16045914,		11114288,		15455619], _
		[ "2",		"CrusaderS",2,	16757043,		16046170,		11048495,		15455363], _
		[ "2",		"CrusaderM",3,	16757043,		16045914,		11114288,		15455619], _
		["F11"		,"RightFur",	3,9935461,		590869,		10850157,		2165768], _
		["F11"		,"RightFur",	3,9935461,		1050664,		10850157,		2165768], _
		["4"		,"NN",	2,6041641,		10644513,		15131471,		14997817], _
		["4"		,"NN",	3,6107433,		10644513,		15131471,		14866233], _
		["3"		,"DivStorm",	2,15591894,		16774827,		13146161,		11642760], _
		["3"		,"DivStorm",	3,15657687,		16774827,		13146160,		11708553], _
		[ "7",		"CrusaderS",2,	1314572,	16642745,	1315340,	16776693 ], _
		[ "7",		"CrusaderS",2,	15630848,		15899673,		16306836,		15169792], _
		[ "7",		"CrusaderS",3,	15630848,		15899673,		16306579,		15169792], _
	    [ "1",		"Judgement",2,	7745541,		9934742,		15848781,		11886860], _
		[ "1",		"Judgement",3,	7745797,		9868949,		15849037,		11886860] _
  ]
   ElseIf $char=8 Then
   global $Spelly[][] = [ _
		["{F12}",	"TrHeart",	4,	1062228,		2499363,		534602,			2320501], _
		["{F5}",	"BeastW",	1,	8150632,		10066329,		3743524,		10233897], _
		["{F6}",	"MirrorT",	4,	0,				10066329,		2245411,		1919774], _
		["4",		"Barrage",	1,	6138061,		1403551,		10074557,		7384542], _
		[ "4",		"Barrage",	2,	6072269,		1337500,		10074557,		7384542], _
		[ "4",		"Barrage",	3,	6006733,		1337242,		10074557,		7384542], _
		["5",		"Stampede",	4,	4864000,		6382177,		5726535,		16776960], _
		["2",		"Focus",	1,	8084736,		7623168,		9861169,		14733462], _
		[ "{F4}",	"KillShS",	2,	0,				10066329,		14296615,		5924211], _
		[ "{F4}",	"KillShM",	3,	0,				10066329,		14362151,		5924211], _
		["4",		"GlaiveS",	2,	9149083,		257,			8638689,		4800539], _
		["4",		"GlaiveM",	3,	9214876,		257,			8638689,		4800539], _
		["6",		"KillCmd",	2,	7538696,		2099200,		65792,			2164744], _
		["6",		"KillCmd",	3,	7538696,		2099200,		65792,			2164744], _
		["3",		"Cobra",	2,	5341205,		2237723,		7195139,		8492688], _
		["3",		"Cobra",	3,	5341461,		2369309,		7195139,		8558480], _
		[ "7",		"NN",		3,	2162721,		2031647,		11363691,		0], _
		[ "5",		"Crows",	1,	5404044,		1053720,		6931153,		2169889], _
		[ "1",		"ArcaneS",	2,	1441853,		1120537,		984627,			11243342], _
		[ "1",		"ArcaneM",	3,	1441853,		1120537,		919091,			11308878], _
		["{F12}",	"NN",		4,	1062228,		2499363,		534602,			2320501] _
]
   ElseIf $char=9 Then ; Epinea-Dreanor-Ret
   global $Spelly[][] = [ _
		[ "0",		"ArcTorr#",		4,	2345,			530747,			2377088,		16776191], _
		[ "8",		"HolyAvg#",		4,	1908232,		12369531,		11509603,		8881471], _
		[ "{F9}",	"ShdRigt",		1,	3743012,		10066329,		5253645,		16773937], _
		[ "{F8}",	"DivProt#",		4,	12750693,		10066329,		16049037,		15436804], _
		[ "{F2}",	"GuardAK#",		4,	9913153,		10066329,		6696750,		15526260], _
		[ "7",		"ArdnDef#",		4,	13546389,		6833697,		16577993,		15185515], _
	    [ "8",		"HammWrtS",		2,	4211007,		4210495,		3808019,		3279875], _
		[ "8",		"HammWrtM",		3,	4211007,		4210495,		5450009,		4989205], _
		[ "8",		"NN",		2,	532264,		9150349,		3753265,		4876643], _
		[ "8",		"NN",		3,	532264,		9150349,		3753265,		4876643], _
		[ "8",		"NN",		2,	1861227,		4076837,		7576962,		7967627], _
		[ "8",		"NN",		3,	1861227,		4077093,		7576962,		7901834], _
		[ "6",		"HammRgtM",		3,	9935461,		1050664,		10850157,		2165768], _
	    [ "{F1}",		"NN",		4,	14663288,		10066329,		14060098,		9195040], _
		[ "4",		"AvgShldS",		2,	15058736,		14074691,		6695936,		12225062], _
		[ "4",		"AvgShldM",		3,	15058736,		14074691,		6630144,		12225062], _
		[ "1",		"CrsadrSS",		2,	16757043,		16046170,		11048495,		15455363], _
		[ "1",		"CrsadrSM",		3,	16757043,		16045914,		11114288,		15455619], _
		[ "2",		"JudgemtS",		2,	7745541,		9934742,		15848781,		11886860], _
		[ "2",		"JudgemtM",		3,	7745797,		9868949,		15849037,		11886860], _
		[ "3",		"TmpVerdS",		2,	7822157,		11119006,		7167077,		10987386], _
		[ "3",		"TmpVerdM",		3,	7756365,		11184798,		7101284,		10987129], _
		[ "7",		"ExorcsmS",		2,	15630848,		15899673,		16306836,		15169792], _
		[ "7",		"ExorcsmM",		3,	15630848,		15899673,		16306579,		15169792], _
		[ "{F8}",	"BlessKgS",		2,	7887812,		10066329,		10316586,		14394929], _
		[ "{F8}",	"BlessKgM",		3,	7953861,		10066329,		10250792,		14394929], _
	    ["F1",		"PoisonAmM",3,	14149589,		10066329,		3228957,		4542496] _
]
   ElseIf $char=10 Then ; Sykoss
   global $Spelly[][] = [ _
		[ "{F2}",	"ShieldS",		2,	7989759,		10066329,		3111377,		198664], _
		[ "{F2}",	"Shieldm",		3,	7989759,		10066329,		3111634,		198664], _
		[ "{F1}",	"FerSpirt",		4,	7521772,		10066329,		460558,		5917314], _
		[ "9",		"FireElem",		4,	16643723,		16777043,		16227608,		14106114], _
		[ "0",		"Acendanc",		4,	15124414,		9457765,		16179927,		8797535], _
        [ "{F7}",	"UnleashS",		2,	12676850,		10066329,		13005486,		12156705], _
		[ "{F7}",	"UnleashM",		3,	12677107,		10066329,		13005485,		12156449], _
		[ "4",		"FrostShS",		2,	43734,		7255524,		16382457,		16447226], _
		[ "4",		"FrostShM",		3,	43991,		7189732,		16382457,		16447226], _
		[ "2",		"LavaLshS",		2,	656392,		9176320,		7945260,		10370602], _
		[ "2",		"LavaLshM",		3,	656392,		9176320,		7945516,		10370859], _
		[ "1",		"FlmShokS",		2,	16492069,		9273868,		2432008,		1182472], _
		[ "1",		"FlmShokM",		3,	16492325,		9405452,		2431752,		1182472], _
		[ "3",		"FireTotS",		2,	5374976,		16767547,		12533255,		16562215], _
		[ "3",		"FireTotM",		3,	5374976,		16767547,		12533511,		16562215], _
		[ "{F3}",	"LboltS",		2,	16,		10066329,		1649,		726], _
		[ "{F3}",	"LBoltM",		3,	16,		10066329,		1649,		726], _
		[ "5",		"WndStrkS",		2,	1124386,		1122602,		9617099,		6792133], _
		[ "5",		"WndStrkM",		3,	1124386,		1122602,		9617099,		6792133], _
	    [ "5",		"StormstS",		2,	12304843,		8099252,		7121342,		5592666], _
		[ "5",		"StormstM",		3,	12304843,		8099252,		7121085,		5526873], _
		[ "{F4}",	"MagmaToM",		3,	11220482,		10066329,		9248515,		4326400], _
		[ "{F5}",	"ChLigtnM",		3,	15395071,		10066329,		611489,		8107148], _
		[ "{F8}",	"FireNvaM",		3,	11545358,		10066329,		0,		16761661], _
	    ["F1",		"PoisonAmM",3,	14149589,		10066329,		3228957,		4542496] _
]
   ElseIf $char=11 Then ; Icebrick
   global $Spelly[][] = [ _
   		[ "0",		"ArcPresn",		4,	2345,		530747,		2377088,		16776191], _
		[ "9",		"NN",		4,	16643723,		16777043,		16227608,		14106114], _
	    [ "3",		"Expl",		2,	590080,		4333320,		13994522,		9201295], _
		[ "3",		"Expl",		3,	590080,		4333320,		14060314,		9201552], _
		[ "{F3}",	"BlackArS",		2,	5505166,		10066329,		5767316,		8], _
		[ "{F3}",	"BlackArS",		3,	5505166,		10066329,		5767316,		8], _
		[ "1",		"Arc",		2,	1441853,		1120537,		984627,		11243342], _
		[ "1",		"Arc",		3,	1441853,		1120537,		919091,		11308878], _
		[ "5",		"MultiShM",		3,	2162721,		2031647,		11363691,		0], _
		[ "{F3}",	"BlackArS",		2,	5505166,		10066329,		5767316,		8], _
		[ "{F3}",	"BlackArS",		3,	5505166,		10066329,		5767316,		8], _
	    [ "2",		"LavaLshS",		2,	656392,		9176320,		7945260,		10370602], _
		[ "2",		"LavaLshM",		3,	656392,		9176320,		7945516,		10370859], _
		[ "1",		"FlmShokS",		2,	16492069,		9273868,		2432008,		1182472], _
		[ "1",		"FlmShokM",		3,	16492325,		9405452,		2431752,		1182472], _
		[ "3",		"FireTotS",		2,	5374976,		16767547,		12533255,		16562215], _
		[ "3",		"FireTotM",		3,	5374976,		16767547,		12533511,		16562215], _
	    ["F1",		"PoisonAmM",3,	14149589,		10066329,		3228957,		4542496] _
]
   ElseIf $char=12 Then ; Icebrick2
   global $Spelly[][] = [ _
		[ "0",		"ArcTorr",		4,	2345,		530747,		2377088,		16776191], _
		[ "2",		"FocusFir",		1,	8084736,		7623168,		9861169,		14733462], _
		[ "{F3}",	"DireBest",		1,	527376,		10066329,		4351347,		529432], _
		[ "{F5}",	"BeastWra",		1,	2892069,		10066329,		1313549,		10233897], _
		[ "{F5}",	"BeastWra",		1,	8150632,		10066329,		3743524,		10233897], _		; Seems to work on both of these???
		[ "{F4}",	"KillShtS",		2,	0,		10066329,		14296615,		5924211], _
		[ "{F4}",	"KillShtM",		3,	0,		10066329,		14362151,		5924211], _
		[ "3",		"CobraS",		2,	2956837,		4927284,		3417397,		2695731], _
		[ "3",		"CobraM",		3,	2562849,		3022628,		2497059,		2234400], _
		[ "4",		"BarrageS",		2,	6072269,		1337500,		10074557,		7384542], _
		[ "4",		"BarrageM",		3,	6006733,		1337242,		10074557,		7384542], _
		[ "3",		"CFocusS",		2,	5341205,		2237723,		7195139,		8492688], _
		[ "3",		"CFocusM",		3,	5341461,		2369309,		7195139,		8558480], _
	    [ "6",		"KillCmdS",		2,	7538696,		2099200,		65792,		2164744], _
		[ "6",		"KillCmdM",		3,	7538696,		2099200,		65792,		2164744], _
		[ "1",		"ArcaneS",		2,	1441853,		1120537,		984627,		11243342], _
		[ "1",		"ArcaneM",		3,	1441853,		1120537,		919091,		11308878], _
		[ "7",		"MultiShM",		3,	1509647,		3083303,		4204072,		0], _
		[ "7",		"MltiSh2M",		3,	2162721,		2031647,		11363691,		0], _
	    ["F1",		"PoisonAmM",3,	14149589,		10066329,		3228957,		4542496] _
]
   Endif ;char

   Endif ;comp




   ;for $i=0 to UBound($SpellActivator)-1
   ;  $txt = @TAB & @TAB & "[ """ & $SpellActivator[$i] & """,""" & $SpellName[$i] & """," & $SpellSpot[$i] & "," & _
   ;        $tbl1[$i] & "," & $tbl2[$i] & "," & $tbl3[$i] & "," & $tbl4[$i] & " ], _" & @CRLF
   ;   ConsoleWrite( $txt )
   ;Next

    GUICtrlSetData( $btnChar, $charName[$char] )
    WinActivate($hWOW)

EndFunc

Func MultiPressed()
   $singleaoe = $singleaoe +1
   if $singleaoe=2 Then
	  $singleaoe=0
   EndIf
   ConsoleWrite("SingleAoe  now: " & $singleaoe & @CRLF )
EndFunc

Func FindPressed()

	  $aVal[0] = PixelGetColor($spot1x[0],$spot1y[0])
	  $aVal[1] = PixelGetColor($spot1x[1],$spot1y[1])
	  $aVal[2] = PixelGetColor($spot1x[2],$spot1y[2])
	  $aVal[3] = PixelGetColor($spot1x[3],$spot1y[3])
	  $txt = 	"		[ ""_"",		""NN"",		1,	" & $aVal[0] & ",		" & $aVal[1] & ",		" & $aVal[2] & ",		" & $aVal[3] & "], _" & @CRLF
	  $aVal[0] = PixelGetColor($spot2x[0],$spot2y[0])
	  $aVal[1] = PixelGetColor($spot2x[1],$spot2y[1])
	  $aVal[2] = PixelGetColor($spot2x[2],$spot2y[2])
	  $aVal[3] = PixelGetColor($spot2x[3],$spot2y[3])
	  $txt &= 	"		[ ""_"",		""NN"",		2,	" & $aVal[0] & ",		" & $aVal[1] & ",		" & $aVal[2] & ",		" & $aVal[3] & "], _" & @CRLF
	  $aVal[0] = PixelGetColor($spot3x[0],$spot3y[0])
	  $aVal[1] = PixelGetColor($spot3x[1],$spot3y[1])
	  $aVal[2] = PixelGetColor($spot3x[2],$spot3y[2])
	  $aVal[3] = PixelGetColor($spot3x[3],$spot3y[3])
	  $txt &= 	"		[ ""_"",		""NN"",		3,	" & $aVal[0] & ",		" & $aVal[1] & ",		" & $aVal[2] & ",		" & $aVal[3] & "], _" & @CRLF
	  $aVal[0] = PixelGetColor($spot4x[0],$spot4y[0])
	  $aVal[1] = PixelGetColor($spot4x[1],$spot4y[1])
	  $aVal[2] = PixelGetColor($spot4x[2],$spot4y[2])
	  $aVal[3] = PixelGetColor($spot4x[3],$spot4y[3])
	  $txt &= 	"		[ ""_"",		""NN"",		4,	" & $aVal[0] & ",		" & $aVal[1] & ",		" & $aVal[2] & ",		" & $aVal[3] & "], _" & @CRLF

    #cs
	local $xx
    local $yy
	$txt = ""

    ConsoleWrite( "AT: " & $spot2x[0] & "," & $spot2y[0] )

    for $yy = 0 to 10
	  for $xx = 0 to 10
	    $aVal[0] = PixelGetColor($spot2x[0]+$xx,$spot2y[0]+$yy)
	    $aVal[1] = PixelGetColor($spot2x[1]+$xx,$spot2y[1]+$yy)
	    $aVal[2] = PixelGetColor($spot2x[2]+$xx,$spot2y[2]+$yy)
	    $aVal[3] = PixelGetColor($spot2x[3]+$xx,$spot2y[3]+$yy)
	    $txt &= 	"		[""_""		,""NN""," & $xx & $yy &	"," & $aVal[0] & ",		" & $aVal[1] & ",		" & $aVal[2] & ",		" & $aVal[3] & "], _" & @CRLF
	 Next
    Next
    #ce
	  GUICtrlSetData( $idLbl, "Captured!" )
	ConsoleWrite( $txt )
    WinActivate($hWOW)
EndFunc

Func ModePressed()
   if $mode=1 Then
	  $mode = 0
   Else
	  $mode = 1
   EndIf
   WinActivate($hWOW)
EndFunc   ;==>ModePressed

Func StartAttack()
   $singleaoe=0
   $match=-1
   ;if $mode = 88 then
   ConsoleWrite("SM: " & $singleaoe & @CRLF )
   $mode = 1
   WinActivate($hWOW)
   GUISetIcon( "on1.ico" )
   TraySetIcon( "on1.ico" )
EndFunc

Func StopAttack()
   $mode = 0
   $match=-2
   WinActivate($hWOW)
EndFunc

Func HandleRotation()
   $flash = $flash +1

   if $flash=2 Then
	  GUICtrlSetData( $idLbl, "" )
	  GUICtrlSetData( $btnMode, "Pause" )
	  if $singleaoe=1 then
		 GUISetIcon( "on1.ico" )
		 TraySetIcon( "on1.ico" )
	  Else
		 GUISetIcon( "on21.ico" )
		 TraySetIcon( "on21.ico" )
      endif
   ElseIf $flash=4 then
	  if $singleaoe=1 then
		 GUICtrlSetData( $btnMode, "# Pause #" )
		 GUISetIcon( "on2.ico" )
		 TraySetIcon( "on2.ico" )
	  Else
		 GUICtrlSetData( $btnMode, "**Pause**" )
		 GUISetIcon( "on22.ico" )
		 TraySetIcon( "on22.ico" )
	  endif
	  $flash = 0
   endif

   $aVal1[0] = PixelGetColor($spot1x[0],$spot1y[0])
   $aVal1[1] = PixelGetColor($spot1x[1],$spot1y[1])
   $aVal1[2] = PixelGetColor($spot1x[2],$spot1y[2])
   $aVal1[3] = PixelGetColor($spot1x[3],$spot1y[3])

   $aVal2[0] = PixelGetColor($spot2x[0],$spot2y[0])
   $aVal2[1] = PixelGetColor($spot2x[1],$spot2y[1])
   $aVal2[2] = PixelGetColor($spot2x[2],$spot2y[2])
   $aVal2[3] = PixelGetColor($spot2x[3],$spot2y[3])

   $aVal3[0] = PixelGetColor($spot3x[0],$spot3y[0])
   $aVal3[1] = PixelGetColor($spot3x[1],$spot3y[1])
   $aVal3[2] = PixelGetColor($spot3x[2],$spot3y[2])
   $aVal3[3] = PixelGetColor($spot3x[3],$spot3y[3])

   $aVal4[0] = PixelGetColor($spot4x[0],$spot4y[0])
   $aVal4[1] = PixelGetColor($spot4x[1],$spot4y[1])
   $aVal4[2] = PixelGetColor($spot4x[2],$spot4y[2])
   $aVal4[3] = PixelGetColor($spot4x[3],$spot4y[3])

   local $found = -1

   for $i = 0 to UBound($Spelly)-1
	  if $Spelly[$i][$_SPELLSPOT]=1 Then
		 if $aVal1[0] = $Spelly[$i][$_SPELLPOS1] and $aVal1[1] = $Spelly[$i][$_SPELLPOS2] and $aVal1[2] = $Spelly[$i][$_SPELLPOS3] and $aVal1[3] = $Spelly[$i][$_SPELLPOS4] Then
			$found=$i
			ExitLoop
		 EndIf

	  elseif $Spelly[$i][$_SPELLSPOT]=2 and $singleaoe=0 Then
		 if $aVal2[0] = $Spelly[$i][$_SPELLPOS1] and $aVal2[1] = $Spelly[$i][$_SPELLPOS2] and $aVal2[2] = $Spelly[$i][$_SPELLPOS3] and $aVal2[3] = $Spelly[$i][$_SPELLPOS4] Then
			$found=$i
			ExitLoop
		 EndIf

	  ElseIf $Spelly[$i][$_SPELLSPOT]=3 and $singleaoe=1 Then
		 if $aVal3[0] = $Spelly[$i][$_SPELLPOS1] and $aVal3[1] = $Spelly[$i][$_SPELLPOS2] and $aVal3[2] = $Spelly[$i][$_SPELLPOS3] and $aVal3[3] = $Spelly[$i][$_SPELLPOS4] Then
			$found=$i
			ExitLoop
		 EndIf

	  elseif $Spelly[$i][$_SPELLSPOT]=4 Then
		 if $aVal4[0] = $Spelly[$i][$_SPELLPOS1] and $aVal4[1] = $Spelly[$i][$_SPELLPOS2] and $aVal4[2] = $Spelly[$i][$_SPELLPOS3] and $aVal4[3] = $Spelly[$i][$_SPELLPOS4] Then
			$found=$i
			ExitLoop
		 EndIf
	  EndIf
   Next

   if $found = -1 then
	  ;GUICtrlSetData( $idLbl, "NoCast! " & @CRLF  )
   else
	  ;ConsoleWrite( "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] Casting: " )
	  $txt = $Spelly[$found][$_SPELLACT] & " :" & $Spelly[$found][$_SPELLNAME]
	  ConsoleWrite( $txt & @CRLF )
	  ;GUICtrlSetData( $idLbl, "Cast: " & @CRLF & $txt  )
	  ControlSend($hWOW, "", "", "" & $Spelly[$found][$_SPELLACT] )
	  if ($char=100 and $Spelly[$found][$_SPELLACT]="{F6}") Then
		 Sleep(4)
		 ConsoleWrite( "--Setting trap!" & @CRLF )
		 MouseMove( 853, 285, 2 )
		 Sleep(7)
		 MouseClick( "left" )
	  endif
   endif

EndFunc

Func SpecialEvents()
	Select
		Case @GUI_CtrlId = $GUI_EVENT_CLOSE
			;MsgBox($MB_SYSTEMMODAL, "Close Pressed", "ID=" & @GUI_CtrlId & " WinHandle=" & @GUI_WinHandle)

			GUIDelete()
			Exit

		Case @GUI_CtrlId = $GUI_EVENT_MINIMIZE
			;MsgBox($MB_SYSTEMMODAL, "Window Minimized", "ID=" & @GUI_CtrlId & " WinHandle=" & @GUI_WinHandle)

		Case @GUI_CtrlId = $GUI_EVENT_RESTORE
			;MsgBox($MB_SYSTEMMODAL, "Window Restored", "ID=" & @GUI_CtrlId & " WinHandle=" & @GUI_WinHandle)

	EndSelect
EndFunc   ;==>SpecialEvents
