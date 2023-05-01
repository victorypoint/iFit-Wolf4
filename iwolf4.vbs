' iFit-Wolf4 - Auto-incline and auto-speed control of treadmill via ADB and OCR for Zwift workouts
' Author: Al Udell
' Revised: April 27, 2023

'to debug - enable wscript.echo and run by cscript in command line
'on error resume next 

'display startup message
createobject("wscript.shell").popup "Ensure treadmill is in manual workout mode with onscreen speed and incline controls visible. " _
  & vbCrLf & vbCrLf & "Also ensure Zwift is running in game with workout dashboard showing.", 10, "Warning", 64

'initialize
set wso = createobject("wscript.shell")

'treadmill tablet coordinates (ifit manual workout)
speedx1 = 1845     'x pixel position of middle of speed slider
inclinex1 = 75	   'x pixel position of middle of incline slider
bottomy = 807        'y pixel position of bottom of sliders

'pixel scaling factors
speedscale = 31.0
inclinescale = 31.1

'construct todays wolflog filename
dy = right(string(2,"0") & day(now), 2)
mo = right(string(2,"0") & month(now), 2)
yr = year(now)
infilename = yr & "-" & mo & "-" & dy & "_logs.txt"
infilename2 = "/sdcard/.wolflogs/" & infilename
'wscript.echo infilename2

'loop - process wolflog and Zwift screenshot
Do

  'query treadmill for speed
  cmdstring = "cmd /c adb shell tail -n5000 " & infilename2 & " | grep -a ""Changed KPH""" & " | tail -n1 | grep -oE ""[^ ]+$"""
  'wscript.echo cmdstring 
  'use synchronous Exec
  set oexec = wso.exec(cmdString)
  'wait for completion
  Do While oexec.Status = 0
    wscript.sleep 100
  Loop  
  sValue = oexec.stdout.readline
  If sValue <> "" then
    cSpeed = formatnumber(csng(sValue),1)
    wscript.echo "Treadmill speed: " & cSpeed
  Else
    wscript.echo "Waiting for treadmill to come online..." 
  End If

  'query treadmill for incline
  cmdString = "cmd /c adb shell tail -n5000 " & infilename2 & " | grep -a ""Changed Grade""" & " | tail -n1 | grep -oE ""[^ ]+$"""
  'wscript.echo cmdString 
  'use synchronous Exec
  set oexec = wso.exec(cmdString)
  'wait for completion
  Do While oexec.Status = 0
    wscript.sleep 100
  Loop
  sValue = oexec.stdout.readline
  if sValue <> "" then
    cIncline = formatnumber(csng(sValue),1)
    wscript.echo "Treadmill incline: " & cIncline
  else
    'wscript.echo "Waiting for treadmill to come online..."
  end if

  'query Zwift for workout speed and incline
  workout = GetZwiftWorkout()
  sSpeed = workout(0)
  sIncline = workout(1)
  wscript.echo sSpeed, sIncline

  'process zwift and treadmill speed
  If sSpeed <> "None" Then 

    nSpeed = csng(sSpeed)
    wscript.echo "Zwift speed: " & sSpeed

    'get y pixel position of speed slider from current speed
    speedy1 = bottomy - Round((cSpeed - 1.0) * speedscale)

    'set speed slider to target position
    speedy2 = speedy1 - Round((nSpeed - cSpeed) * speedscale)  'calculate vertical pixel position for new speed 
    cmdString = "cmd /c adb shell input swipe " & speedx1 & " " & speedy1 & " " & speedx1 & " " & speedy2 & " 200"  'simulate touch-swipe on speed slider
    'wscript.echo cmdString 
    'use synchronous Exec
    set oexec = wso.exec(cmdString)
    'wait for completion
    Do While oexec.Status = 0
      wscript.sleep 100
    Loop

    'report new speed and corresponding swipe
    'wscript.echo "New treadmill speed: " & formatnumber(nSpeed,1) & " - " & cmdString
    wscript.echo "New treadmill speed: " & formatnumber(nSpeed,1)

  Else
    wscript.echo "Waiting for Zwift to come online..."
  End If

  'process zwift and treadmill incline

  If sIncline <> "None" Then

    nIncline = csng(sIncline)
    wscript.echo "Zwift incline: " & sIncline

    'correct incline value for treadmill 
    if nIncline < -3 then nIncline = -3
    if nIncline > 15 then nIncline = 15

    'get y pixel position of incline slider from current incline
    incliney1 = bottomy - Round((cIncline + 3.0) * inclinescale)
    'set incline slider to target position
    incliney2 = incliney1 - Round((nIncline - cIncline) * inclinescale)  'calculate vertical pixel position for new incline 
    cmdString = "cmd /c adb shell input swipe " & inclinex1 & " " & incliney1 & " " & inclinex1 & " " & incliney2 & " 200"  'simulate touch-swipe on incline slider
    'wscript.echo cmdString 
    'use synchronous Exec
    set oexec = wso.exec(cmdString)
    'wait for completion
    Do While oexec.Status = 0
      wscript.sleep 100
    Loop

    'report new incline and corresponding swipe
    'wscript.echo "New treadmill incline: " & formatnumber(nIncline,1) & " - " & cmdString
    wscript.echo "New treadmill incline: " & formatnumber(nIncline,1)

  End If
  wscript.echo 

Loop 'process wolflog and Zwift screenshot

'--- Functions ---

Function GetZwiftWorkout()

  'take a screenshot of Zwift, save it to disk, then OCR image for workout info
  set wshShell = WScript.CreateObject("WScript.Shell")
  set fso = WScript.CreateObject("Scripting.FileSystemObject")
  strComputer = "."
  FindProc = "zwiftapp.exe"
  ocrOutput = "ocr-output.txt"

  'is Zwift running?
  set objWMIService = GetObject("winmgmts:" _
    & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
  set colProcessList = objWMIService.ExecQuery _
    ("Select Name from Win32_Process WHERE Name='" & FindProc & "'")

  if colProcessList.count > 0 then
    'wscript.echo "Zwift is running..."

    'use synchronous Exec
    cmdString = "cmd /c python process-image.py"
    set oexec = wshShell.exec(cmdString)
    'wait for completion
    Do While oexec.Status = 0
      wscript.sleep 100
    Loop
    'wscript.echo "Image processed..."

    'get speed and incline from file
    set objFile = fso.GetFile(ocrOutput)
    'file not empty
    if objFile.Size > 0 then
      Set ocrfile = fso.OpenTextFile(ocrOutput,1)
      inputString = ocrfile.ReadLine()        
      'wscript.echo inputString
      metrics = Split(inputString, ",")
      sSpeed = metrics(0)
      sIncline = metrics(1)
    end if

    'return array
    GetZwiftWorkout = array(sSpeed, sIncline)

  end if 'zwift is running

  Set objWMIService = Nothing
  Set colProcessList = Nothing

End Function









