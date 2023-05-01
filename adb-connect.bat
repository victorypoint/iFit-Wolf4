:: iFit-Workout - Auto-incline and auto-speed control of treadmill via ADB and OCR for Zwift workouts
:: Author: Al Udell
:: Revised: April 27, 2023

:: Assumes treadmill USB Debugging is turned on 

@echo off

set /p TMIP="Enter treadmill IP address: "

ping %TMIP%
timeout 5

adb disconnect
adb kill-server
adb connect %TMIP%
adb devices -l

timeout 5


