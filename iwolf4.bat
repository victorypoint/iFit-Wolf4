:: iFit-Wolf4 - Auto-incline and auto-speed control of treadmill via ADB and OCR for Zwift workouts
:: Author: Al Udell
:: Revised: April 27, 2023

@echo off

@pushd %~dp0
if NOT ["%errorlevel%"]==["0"] pause

cmd.exe /k cscript iwolf4.vbs

