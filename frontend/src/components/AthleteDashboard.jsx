import { Routes, Route, useParams, Navigate, Outlet } from "react-router-dom";
import { BarChart, Dumbbell, Heart, Apple, PiggyBank, User } from "lucide-react";
import DashboardLayout from "./AthleteDashboardPages/DashboardLayout";
import Performance from "./AthleteDashboardPages/Performance";
import Training from "./AthleteDashboardPages/Training";
import Medical from "./AthleteDashboardPages/Medical";
import Nutrition from "./AthleteDashboardPages/Nutrition";
import Finance from "./AthleteDashboardPages/Finance";
import Profile from "./AthleteDashboardPages/Profile";
import Home from "./AthleteDashboardPages/Home";

function AthleteDashboard() {
  // Access URL parameters
  const { athleteId, athleteName } = useParams();
  
  // Define the base path for all navigation links
  const basePath = `/athlete-dashboard/${athleteId}/${athleteName}`;
  
  // Define navigation items with ABSOLUTE paths
  const navItems = [
    { name: "Home", icon: User, path: `${basePath}/home` },
    { name: "Performance", icon: BarChart, path: `${basePath}/performance` },
    { name: "Training", icon: Dumbbell, path: `${basePath}/training` },
    { name: "Medical", icon: Heart, path: `${basePath}/medical` },
    { name: "Nutrition", icon: Apple, path: `${basePath}/nutrition` },
    { name: "Finance", icon: PiggyBank, path: `${basePath}/finance` },
    { name: "Profile", icon: User, path: `${basePath}/profile` },
  ];

  return (
    <DashboardLayout 
      userType="Athlete" 
      navItems={navItems} 
      athleteId={athleteId} 
      athleteName={athleteName}
    >
      <Routes>
        <Route index element={<Navigate to="home" replace />} />
        <Route path="home" element={<Home />} />
        <Route path="performance" element={<Performance />} />
        <Route path="training" element={<Training />} />
        <Route path="medical" element={<Medical />} />
        <Route path="nutrition" element={<Nutrition />} />
        <Route path="finance" element={<Finance />} />
        <Route path="profile" element={<Profile />} />
        <Route path="*" element={<Navigate to="home" replace />} />
      </Routes>
    </DashboardLayout>
  );
}

export default AthleteDashboard;