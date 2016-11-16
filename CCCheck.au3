#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=cccheck.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <string.au3>
#include <winhttp.au3>
#include <Inet.au3>

Global $oMyError = ObjEvent("AutoIt.Error", "MyErrFunc")
Global $oHTTP = ObjCreate("winhttp.winhttprequest.5.1")
Global $path = ""

Local $var = Ping("http://www.google.com/")
If @error = 1 Or @error = 2 Then
	MsgBox(0, "Error", "Your internet doesn't appear to be enabled. Code: [" & @error & "]")
	Exit
EndIf

detectCC()

$ver = FileGetVersion($path)
$verSplit = StringSplit($ver, ".")

If $verSplit[2] < 9 And StringLen($verSplit[2]) < 2 Then $verSplit[2] = "0" & $verSplit[2]

$ver = $verSplit[1] & "." & $verSplit[2] & "." & $verSplit[4]
$url = "http://www.piriform.com/ccleaner/update"

$source = _INetGetSource('http://www.piriform.com/ccleaner/update')
$webVer = _StringBetween($source, "version = '", "';")

If Not IsArray($webVer) Then
	MsgBox(16, "Error", "Unable to fetch newest version number.")
	runCC()
EndIf

If $webVer[0] = " " Or $webVer[0] = "" Then
	MsgBox(0, "Error", "Unable to retrieve version information.")
	runCC()
EndIf

If Number($webVer[0]) > Number($ver) Then
	$decision = MsgBox(36, "Update", "Installed: " & $ver & @CRLF & "Newest: " & $webVer[0] & @CRLF & "Update CCleaner?")
	If $decision = 6 Then
		updateCC()
	Else
		runCC()
	EndIf
ElseIf Number($webVer[0]) <= Number($ver) Then
	runCC()
Else
	MsgBox(16, "Error", "Unknown version mismatch.")
	Exit
EndIf

Func detectCC()
	If @CPUArch = "X86" Then
		$64 = False
	Else
		$64 = True
	EndIf

	If FileExists("C:\Program Files\CCleaner\CCleaner.exe") Then
		If $64 = True Then
			$path = "C:\Program Files\CCleaner\CCleaner64.exe"
		Else
			$path = "C:\Program Files\CCleaner\CCleaner.exe"
		EndIf
	ElseIf FileExists("C:\Program Files (x86)\CCleaner\CCleaner.exe") Then
		If $64 = True Then
			$path = "C:\Program Files\CCleaner\CCleaner64.exe"
		Else
			$path = "C:\Program Files\CCleaner\CCleaner.exe"
		EndIf
	Else
		MsgBox(0, "Error", "Unable to locate CCleaner.")
		Exit
	EndIf
EndFunc   ;==>detectCC

Func updateCC()
	$url = "http://www.piriform.com/ccleaner/download/standard"
	$source = _INetGetSource($url)
	$exeName = _StringBetween($source, 'http://download.piriform.com/ccsetup', '.exe"')
	$fileSize = InetGetSize("http://download.piriform.com/ccsetup" & $exeName[0] & ".exe")
	SplashTextOn("", "Downloading...", 200, 70, Default, Default, 1)
	Local $hDownload = InetGet("http://download.piriform.com/ccsetup" & $exeName[0] & ".exe", @TempDir & "\ccSetup" & $exeName[0] & ".exe", 1, 1)
	Do
		Local $aData = InetGetInfo($hDownload)
		ControlSetText("", "Downloading", "[CLASS:Static; INSTANCE:1]", "Downloading... " & @CRLF & Round(Round($aData[0] / 1024, 2) / 1024, 2) & "MB / " & Round(Round($fileSize / 1024, 2) / 1024, 2) & "MB")
		Sleep(50)
	Until InetGetInfo($hDownload, 2)
	Local $aData = InetGetInfo($hDownload)
	InetClose($hDownload)
	SplashOff()
	Sleep(5000)
	ShellExecuteWait(@TempDir & "\ccSetup" & $exeName[0] & ".exe")
	FileDelete(@TempDir & "\ccSetup" & $exeName[0] & ".exe")
	;runCC()
EndFunc   ;==>updateCC

Func runCC()
	Run($path)
	Exit
EndFunc   ;==>runCC

Func MyErrFunc()
	$HexNumber = Hex($oMyError.number, 8)
	MsgBox(0, "", "We intercepted a COM Error !" & @CRLF & "Number is: " & $HexNumber & @CRLF & "Windescription is: " & $oMyError.windescription)
	SetError(1)
EndFunc   ;==>MyErrFunc
