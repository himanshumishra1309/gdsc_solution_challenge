🏆 AthleTech
<p align="center"> <img src="https://i.imgur.com/pUznfNl.png" alt="AthleteConnect Logo" width="200"/> </p> <p align="center"> <b>A comprehensive athlete management system for sports organizations</b> </p> <p align="center"> <a href="#-features">Features</a> • <a href="#-tech-stack">Tech Stack</a> • <a href="#-setup-instructions">Setup Instructions</a> • <a href="#-mobile-app-setup">Mobile App Setup</a> • <a href="#-test-credentials">Test Credentials</a> • <a href="#-contributing">Contributing</a> </p>
✨ Features
Organization Management: Create and manage sports organizations
User Roles: Support for admin, coach, athlete, and sponsor roles
Performance Tracking: Monitor and analyze athlete progress
Financial Management: Track financial transactions for athletes
Medical Records: Manage injuries and recovery plans
Team Collaboration: Facilitate communication between all stakeholders
🛠 Tech Stack
Backend: Node.js, Express, MongoDB
Web Frontend: React.js, Next.js
Mobile App: Flutter, Dart
Authentication: JWT
Database: MongoDB Atlas
File Storage: AWS S3
🚀 Setup Instructions
Backend Setup
# Navigate to backend directory
cd backend

# Install dependencies
npm install

# Start development server
npm run dev
The server will start running at http://localhost:8000

Frontend Setup
# Navigate to frontend directory
cd frontend

# Install dependencies (use --force if needed for dependency conflicts)
npm install
# or
npm install --force

# Start development server
npm run dev
The frontend will be available at http://localhost:5173

📱 Mobile App Setup
Prerequisites
Install Flutter SDK

Visit Flutter Installation Guide
Add Flutter to your PATH
Run flutter doctor to verify installation
Set up an IDE

Install VS Code or Android Studio
Install Flutter and Dart plugins for your IDE
Setting up ADB (Android Debug Bridge)
Install Android SDK

Either through Android Studio or standalone SDK tools
Ensure SDK Platform Tools are installed
Add ADB to Path

Add <Android SDK location>/platform-tools to your PATH
Verify by running adb version in terminal
Connect your Android Device
Enable Developer Mode on your Android phone:

Go to Settings > About Phone > Tap "Build Number" 7 times
You'll see a message that you're now a developer
Enable USB Debugging:

Go to Settings > System > Developer Options
Enable "USB debugging"
Enable "USB debugging (Security settings)"
Connect your device:

Connect your phone to your computer using a USB cable
Allow USB debugging when prompted on your phone
Running the App
# Navigate to Flutter app directory
cd gdg_app

# Get dependencies
flutter pub get

# Set up port forwarding to backend
adb reverse tcp:8000 tcp:8000

# Run the app in debug mode
flutter run
Alternatively, in VS Code:

Open the project
Go to Run > Run Without Debugging
Accept the installation prompt on your phone
🔑 Test Credentials
Admin Account
Email: admin@test.com
Password: Password@123
Coach Account
Email: coach@test.com
Password: Password@123
Athlete Account
Email: athlete@test.com
Password: Password@123
Sponsor Account
Email: sponsor@test.com
Password: Password@123
🤝 Contributing
Fork the repository
Create a feature branch (git checkout -b feature/amazing-feature)
Commit your changes (git commit -m 'Add some amazing feature')
Push to the branch (git push origin feature/amazing-feature)
Open a Pull Request
📝 License
This project is licensed under the MIT License - see the LICENSE file for details.

🙏 Acknowledgements
Google Developer Student Clubs
Google Solution Challenge 2024
All contributors and testers
<p align="center"> Made with ❤️ for Google Solution Challenge 2024 </p>