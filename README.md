# iFit-Wolf4
Experimental iFit auto-speed and auto-incline control of treadmill for Zwift workouts via ADB and OCR

**Tested on the NordicTrack Commercial 2950 iFit Embedded Wifi Treadmill (2021 model)**

This repo builds on my previous iFit-Wolf3 repo and code at https://github.com/victorypoint/iFit-Wolf3 to provide capability to automatically control treadmill speed and incline (auto-speed and auto-incline) from a Zwift workout using OCR technology running on MS Windows. I've only tested this on the NordicTrack C2950 treadmill (2021 model).

Note: I have not included documentation here on how to configure the NT C2950 treadmill for ADB communication, but it involves accessing the machines "Privileged Mode", turning on "Developer Options" in Android settings, and enabling "USB Debugging" mode. Accessing Privileged Mode is well documented on many websites, dependent on the treadmill model, and version of Android and iFit. Refer to my previous iFit-Wolf and iFit-Wolf2 repos for technical details on how the treadmill incline is commmunicated and manually controlled via an ADB connection. The NT C2950 treadmills embedded iFit console runs Android (currently v9 on my model). Treadmill incline is controlled by moving it's on-screen incline slider control up and down.

### OCR Software Install and Setup: see my iFit-Wolf3 repo for installation instructions at https://github.com/victorypoint/iFit-Wolf3

### To Run iFit-Wolf4:

- This solution works on a Windows PC running iFit-Wolf4 and Zwift. Before running iFit-Wolf3:
  - Ensure tredmill is powered-up and connected to Windows PC via ADB connection. Run adb-connect.bat to establish an ADB connection to the treadmill via its IP address.
  - Ensure treadmill is in manual workout mode with onscreen speed and incline controls visible.
  - Ensure Zwift is launched in "Windowed mode", is "in game" in either Run or Bike mode, and has a Zwift workout loaded and ready to start. That is, your avatar is ready to run or bike, and the Zwift workout dashboard is displayed in the upper area of the screen. 

- Run iwolf4.bat. When executed, iFit-Wolf4 will:
  - Query the treadmill for it's current incline via ADB.
  - Query Zwift for the current workout instruction for speed and incline. It does this by taking a screenshot, and obtaining the workout instruction via OCR. Some examples of workout instructions are:
    - Warm up 7.4 kph for 6 min
    - Run at 14.0 kph for 30 secs
    - 3% Incline 12.4 kph for 1 min
    - Cool down 8.8 kph for 2 min
  - Once the workout instructions are obtained, the treadmill speed and incline will be adjusted automatically to the required values.

### Files included:
- **adb-connect.bat** (batch script to initiate an ADB connection with the treadmill. Enter the IP address of the treadmill)
- **iwolf4.vbs** (VBscript script to communicate with treadmill and launch process-image.py script for OCR)
- **iwolf4.bat** (batch script to launch iwolf3.vbs)
- **process-image.py** (Python script to take Zwift screenshot, OCR the workout speed and incline values, and output the result to file ocr-output.txt)
- **adb.exe, AdbWinApi.dll, AdbWinUsbApi.dll, grep.exe, and tail.exe** (required support files)
- **adb-screenshot.bat** (batch script to take a screenshot of the treadmill screen if needed)
- **onscreen-controls.png** (example screenshot of NT C2950 screen with on-screen speed and incline controls)

ADB stands for Android Debug Bridge used by developers to connect their development computer with an Android device via a USB cable (and over Wifi in this case). If you don't have Android SDK installed on your PC, ADB may not be recognized. It's recommended you download the latest version.
