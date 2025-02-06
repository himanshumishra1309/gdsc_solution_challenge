import { Routes, Route } from "react-router-dom";
import { BarChart, Dumbbell, Heart, Apple, PiggyBank, User } from "lucide-react";
import DashboardLayout from "./AthleteDashboardPages/DashboardLayout";
import Performance from "./AthleteDashboardPages/Performance";
import Training from "./AthleteDashboardPages/Training";
import Medical from "./AthleteDashboardPages/Medical";
import Nutrition from "./AthleteDashboardPages/Nutrition";
import Finance from "./AthleteDashboardPages/Finance";
import Profile from "./AthleteDashboardPages/Profile";
import Home from "./AthleteDashboardPages/Home"; // Import the Home Component

const navItems = [
  { name: "Performance", icon: BarChart, path: "performance" },
  { name: "Training", icon: Dumbbell, path: "training" },
  { name: "Medical", icon: Heart, path: "medical" },
  { name: "Nutrition", icon: Apple, path: "nutrition" },
  { name: "Finance", icon: PiggyBank, path: "finance" },
  { name: "Profile", icon: User, path: "profile" },
];

function AthleteDashboard() {
  return (
    <DashboardLayout userType="Athlete" navItems={navItems}>
      <Routes>
        
        <Route path="/" element={<Home />} /> 
        <Route path="performance" element={<Performance />} />
        <Route path="training" element={<Training />} />
        <Route path="medical" element={<Medical />} />
        <Route path="nutrition" element={<Nutrition />} />
        <Route path="finance" element={<Finance />} />
        <Route path="profile" element={<Profile />} />
      </Routes>
    </DashboardLayout>
  );
}

export default AthleteDashboard;
