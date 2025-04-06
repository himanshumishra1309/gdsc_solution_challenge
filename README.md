# 🚀 Project Setup Guide

Welcome to our complete project repository! This guide will walk you through setting up the **Backend**, **Frontend**, **Flutter Mobile Application**, **Player Tracking System**, **Video Analysis System**, and the **AI-Powered Workout, Diet, and Recovery Plan Generator**.

---

## 📂 Repository Structure
```
root-directory/
│
├── backend/
├── frontend/
├── gdg_app/
├── ML Models/
    └── planners.py/
    └── video_analysis.py/
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

> **Optional:** For live deployment and automatic updates from GitHub, consider setting up a CI/CD pipeline or using services like Render, Railway, or Google Cloud.

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

The frontend should now be running on **http://localhost:5173** (or as specified).

> **Optional:** For deployment on Vercel or Netlify, connect the repo and follow their auto-deployment guide.

---

## ✅ Flutter Mobile App Setup

### Pre-requisites:
- Install [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Install Android Studio (with SDK & device manager) or Visual Studio Code

### Check Flutter installation:
```bash
flutter doctor
```
Make sure all checks are ✅.

### Install Flutter dependencies:
Navigate to the `gdg_app` directory and run:
```bash
flutter pub get
```

### Setup Android Debug Bridge (ADB) & Device:
- Enable Developer Mode and USB Debugging on your phone.
- Connect your phone via USB and verify connection:
```bash
adb devices
```

### Run the Flutter App:
- Open `lib/main.dart` in your IDE.
- Click on **Run > Run Without Debugging**.
- Allow permissions on your device to install the APK.

### Setup ADB Port Forwarding:
```bash
adb reverse tcp:8000 tcp:8000
```

> ✅ You're ready to develop and test the app!

---

# Player Tracking & AI-Powered Workout Planner

This project consists of two modules:
1. *Player Tracking and Performance Analysis* - Uses the YOLOv8 model to track players in a video and analyze their movement, speed, and agility.
2. *AI-Powered Workout, Diet, and Recovery Plan Generator* - Uses the Gemini API to generate personalized plans for athletes based on their fitness goals.

---

## Prerequisites
Before running these codes, install the required dependencies.

### Install Python
1. Download and install Python (version 3.8 or later) from the official website: [Python Downloads](https://www.python.org/downloads/)
2. During installation, check the box *"Add Python to PATH"*.

### Install Dependencies
Run the following command in your terminal or command prompt:
bash
pip install ultralytics opencv-python numpy matplotlib supervision google-generativeai


---

## 1️⃣ Player Tracking & Performance Analysis

### Setting Up YOLOv8
1. Download the YOLOv8 model:
   - The model is automatically downloaded when you run the script, but you can also manually download it from: [YOLOv8 Model](https://github.com/ultralytics/ultralytics)
   - Place the yolov8l.pt file in the same directory as video_analysis.py.

### Setting Up the Project
1. *Create a project folder* and navigate into it:
   bash
   mkdir player_tracking
   cd player_tracking
   
2. *Save the code* as video_analysis.py in this folder.
3. *Prepare a video file*:
   - Place the video file in the same directory.
   - Update video_path in the code with the actual filename.

### Running the Code
To execute the script, run:
bash
python video_analysis.py

Press q to stop the video processing.

### Output Files
- *Processed video*: Saved in path_of_analyzed_video.
- *Performance metrics*: Graphs and a text report saved in path_for_output_metrices_folder.

### Understanding the Analysis
- *Speed (m/s)*: Measures player movement speed.
- *Endurance*: Tracks total distance covered.
- *Agility*: Counts sharp direction changes.
- *Performance Score (0-10)*: Combines all metrics.

### Troubleshooting
- If dependencies are missing, rerun:
  bash
  pip install ultralytics opencv-python numpy matplotlib supervision
  
- If cv2.imshow() fails, replace it with:
  python
  cv2.imwrite("output_frame.jpg", annotated_frame)
  

---

## 2️⃣ AI-Powered Workout, Diet & Recovery Planner

### Setting Up Gemini API
1. *Generate Your Own Gemini API Key*:
   - Visit [Google AI](https://ai.google.com/)
   - Sign in and generate a new API key.
   - Copy the API key for later use.

2. *Use the API Key in the Code*:
   - Open the planners.py file.
   - Locate the following line:
     python
     genai.configure(api_key="enter_your_gemini_api_key_here")
     
   - Replace enter_your_gemini_api_key_here with your actual API key.

### Setting Up the Project
1. *Create a project folder* and navigate into it:
   bash
   mkdir athlete_plan
   cd athlete_plan
   
2. *Save the code* as planners.py in this folder.
3. *Run the script* using:
   bash
   python planners.py
   

### Features
- *Workout Plan Generation*: Creates a 7-day workout plan based on weight, height, sport, and injuries.
- *Diet Plan Generation*: Provides a 7-day meal plan based on dietary preferences.
- *Rest & Recovery Suggestions*: Recommends sleep schedules and stress management strategies.
- *Feedback-Based Adjustments*: Users can provide feedback for plan improvements.

### Usage
- Enter your *weight (kg), **height (cm), **sport, and any **injuries*.
- Select a *fitness goal* (performance optimization, injury recovery, etc.).
- Choose your *dietary preference* (vegetarian, vegan, etc.).
- Get personalized plans and refine them with feedback.

### Troubleshooting
- If dependencies are missing, rerun:
  bash
  pip install google-generativeai
  
- Ensure you have a valid *Gemini API key*.

---

## Summary
### Player Tracking:
1. Install dependencies.
2. Save video_analysis.py.
3. Add a video file and run the script.

### AI-Powered Workout Planner:
1. Install dependencies.
2. Get a Gemini API key and update planners.py.
3. Run the script and get personalized plans!

Enjoy tracking and optimizing performance! 🚀
---

## 🔐 Developer Credentials (For Testing Only)
| Role                 | Email                         | Password   |
|----------------------|-------------------------------|------------|
| Admin                | mainadmin@gmail.com           | 1234       |
| Head/Assistant Coach | coachjohn@example.com         | John@123   |
| Athlete              | johndoe@example.com           | 1234       |
| Independent Athlete  | individualathlete@gmail.com   | 1234       |
| Sponsor              | sponsor@gmail.com             | 1234       |
| Medical Staff        | deepak@gmail.com              | 123456     |
| Trainer              | jay@gmail.com                 | 123456     |

> **Security Reminder:** Update all passwords for production environments.

---

## 💡 Troubleshooting
- Re-run `adb reverse` if ports change.
- Restart ADB if the device isn’t detected:
```bash
adb kill-server
adb start-server
```
- Ensure Python and Node dependencies are installed properly.
- Check if firewall or port conflicts exist.

---

## 📬 Contact Us
For assistance, raise an issue in the repository or contact the core development team.

---

Happy Building! 🚀✨

