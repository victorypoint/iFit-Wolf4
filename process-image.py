# iFit-Workout - Auto-incline and auto-speed control of treadmill via ADB and OCR for Zwift workouts
# Author: Al Udell
# Revised: April 27, 2023

# process-image.py - take Zwift screenshot, crop speed/incline instruction, OCR speed/incline

# imports
import cv2
import numpy as np
import win32gui
import re
from datetime import datetime
from paddleocr import PaddleOCR
from PIL import Image, ImageGrab

# File paths
ocrfileName = 'ocr-output.txt'
ocrlogFile = 'ocr-logfile.txt'

# Take Zwift screenshot
hwnd = win32gui.FindWindow(None,'Zwift') 
win32gui.SetForegroundWindow(hwnd)
screenshot = ImageGrab.grab()

# Scale image to 3000 x 2000
screenshot = screenshot.resize((3000, 2000))

# Convert screenshot to a numpy array
screenshot_np = np.array(screenshot)

# Convert numpy array to a cv2 RGB image
screenshot_cv2 = cv2.cvtColor(screenshot_np, cv2.COLOR_BGR2RGB)

# Crop image to workout instruction area
screenwidth, screenheight = screenshot.size
col1 = int(screenwidth/3000 * 1010)
row1 = int(screenheight/2000 * 260)
col2 = int(screenwidth/3000 * 1285)
row2 = int(screenheight/2000 * 480)
cropped_cv2 = screenshot_cv2[row1:row2, col1:col2]

# OCR image
ocr = PaddleOCR(lang='en', use_gpu=False, show_log=False)
result = ocr.ocr(cropped_cv2, cls=False)

# Extract OCR text
ocr_text = ''
for line in result:
    for word in line:
        ocr_text += f"{word[1][0]} "

# Write OCR text to log file
dt = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
#print("Timestamp: ", dt)
with open(ocrlogFile, "a") as file:
   file.write(f"{dt}, {ocr_text}" + "\n")

# Find the speed number
num_pattern = r'\d+(\.\d+)?'  # Regular expression pattern to match numbers with optional decimal places
unit_pattern = r'\s+(kph|mph)'  # Regular expression pattern to match "kph" or "mph" units
speed_match = re.search(num_pattern + unit_pattern, ocr_text)
if speed_match:
    speed = speed_match.group(0)
    pattern = r'\d+\.\d+'
    speed = re.findall(pattern, speed)[0]
else:
    speed = 'None'

# Find the incline number
incline_pattern = r'\d+\s*%'  # Regular expression pattern to match numbers with "%"
incline_match = re.search(incline_pattern, ocr_text)
if incline_match:
    incline = incline_match.group(0)
    pattern = r'\d+'
    incline = re.findall(pattern, incline)[0]
else:
    incline = 'None'

# Write speed and incline to file
with open(ocrfileName, "w") as file:
    file.write(f"{speed},{incline}")

