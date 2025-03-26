# 🚀 Project Setup Guide

Welcome to our complete project repository! This guide will walk you through setting up the **Backend**, **Frontend**, and **Flutter Mobile Application** in the most seamless way possible. Follow each step carefully to get up and running! 😎

---

## 📂 Repository Structure
```
root-directory/
│
├── backend/
├── frontend/
└── flutter-app/
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

The frontend should now be running on **http://localhost:5173** (or as specified).

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

## 💡 Contributing
We love contributions! Please fork the repo, make your changes, and raise a PR. 😄

---

## 📬 Contact
For any help, feel free to reach out to the development team.

---

Happy Coding! 🚀🎉

