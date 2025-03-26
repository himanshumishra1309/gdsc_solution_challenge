# 🚀 Project Setup Guide

Welcome to our complete project repository! This guide will walk you through setting up the **Backend**, **Frontend**, **Flutter Mobile Application**, and **Player Tracking System** using YOLOv8 and Supervision.

---

## 📂 Repository Structure
```
root-directory/
│
├── backend/
├── frontend/
├── flutter-app/
└── player-tracking/
```

---

## ✅ Backend Setup

### Navigate to the backend directory:
```bash
cd backend
```

### Install dependencies:
```bash
npm install
```

> If facing any issues, try clearing cache and reinstalling:
```bash
npm ci
```

### Start the backend server:
```bash
npm run dev
```

Your backend server should now be running on **http://localhost:8000**.

---

## ✅ Frontend Setup

### Navigate to the frontend directory:
```bash
cd frontend
```

### Install dependencies:
```bash
npm install
```
> If you face issues with dependencies:
```bash
npm install --force
```

### Start the frontend server:
```bash
npm run dev
```

The frontend should now be running on **http://localhost:3000** (or as specified).

---

## ✅ Flutter Mobile App Setup

### 1. Pre-requisites:
- Install [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Install Android Studio (with SDK & device manager) or Visual Studio Code

### 2. Check Flutter installation:
```bash
flutter doctor
```
Make sure all checks are ✅.

### 3. Setup Android Debug Bridge (ADB) & Device:
- Go to your **Android phone Settings > About phone > Tap on Build Number 7 times** to enable developer mode.
- Then go to **Settings > Developer options** and:
  - Enable **Developer mode**
  - Enable **USB Debugging**
  - Enable **USB Debugging (Security settings)**

### 4. Connect your phone:
- Plug your phone into your laptop using a USB cable.
- Ensure the phone is recognized by running:
```bash
adb devices
```

### 5. Run the Flutter App:
- Open the `flutter-app` folder in your IDE.
- Open `lib/main.dart`.
- In the IDE, click on **Run > Run Without Debugging**.
- Allow the popup on your phone screen to install the APK.

### 6. Setup ADB Port Forwarding:
After running the app, open a terminal and enter:
```bash
adb reverse tcp:8000 tcp:8000
```
This allows your phone to communicate with the local backend server.

> ✅ Now you're all set! Start working on the app with the credentials provided below.

---

## ✅ Player Tracking Setup using YOLOv8 and Supervision

### Overview
This project uses YOLOv8 for real-time detection and tracking of players in field sports such as hockey, basketball, football, and more. The system tracks player movements, calculates speed, distance covered, agility (direction changes), and generates performance metrics. The output includes an annotated video and graphs summarizing player performance.

### Features
- Detects and tracks players using YOLOv8 and ByteTrack.
- Calculates player speed, distance covered, and agility.
- Generates an annotated video with tracking information.
- Produces graphical and textual performance reports for analysis.

### Requirements
Ensure you have the following dependencies installed:
```bash
pip install ultralytics opencv-python numpy matplotlib supervision
```

### Usage
1. **Update Paths:** Edit the script to specify the correct paths:
   - `video_path` - Path to the input sports game video.
   - `output_folder` - Directory where performance metrics will be saved.
   - `output_path` - Path where the annotated video will be stored.

2. **Run the Script:**
```bash
python tracking_script.py
```

3. **Interact with Output:**
- Annotated video will be saved at `output_path`.
- Performance metrics (graphs and reports) will be stored in `output_folder`.

### Output Details
- **Annotated Video**: Shows tracked players with assigned IDs.
- **Performance Metrics**:
  - **Speed Graph** (m/s)
  - **Distance Covered Graph** (pixels)
  - **Agility (Direction Changes)**
  - **Performance Score** (derived from speed, distance, and agility)

### Notes
- The script is optimized for tracking up to 22 players.
- Ensure the YOLO model (`yolov8l.pt`) is available in your working directory.
- Press `q` during video processing to quit early.

### Future Improvements
- Add more refined tracking to avoid duplicate player IDs.
- Enhance performance calculations with real-world scale calibration.
- Integrate real-time dashboard for live analysis.

### License
This project is open-source and free to use for research and development purposes.

---

## 🔐 Developer Credentials:
| Role                 | Email                         | Password   |
|----------------------|-------------------------------|------------|
| Admin                | mainadmin@gmail.com           | 1234       |
| Coach                | coachjohn@example.com         | John@123   |
| Athlete              | johndoe@example.com           | 1234       |
| Independent Athlete  | individualathlete@gmail.com   | 1234       |
| Sponsor              | sponsor@gmail.com             | 1234       |

---

## 🎯 Troubleshooting Tips:
- If backend port changes, ensure you update the `adb reverse` command with the correct port.
- For device not showing in `adb devices`, try reconnecting USB cable or restarting ADB:
```bash
adb kill-server
adb start-server
```
- Make sure you have accepted all device permissions.

---

## 📬 Contact
For any help, feel free to reach out to the development team.

---

Happy Coding! 🚀🎉

