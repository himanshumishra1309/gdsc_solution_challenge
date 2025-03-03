import { Routes, Route } from "react-router-dom";
import { BarChart, Dumbbell, Heart, Users, PiggyBank, User } from "lucide-react";
import AdminManagement from "./AdminDashboardPages/AdminManagement";
import AthleteManagement from "./AdminDashboardPages/AthleteManagement";
import CoachManagement from "./AdminDashboardPages/CoachManagement";
import FormManagement from "./AdminDashboardPages/FormManagement";
import SponsorManagement from "./AdminDashboardPages/SponsorManagement";
import VideoAnalysis from "./AdminDashboardPages/VideoAnalysis";
import ALayout from "./AdminDashboardPages/ALayout";

const navItems = [
  { name: "Athlete Management", icon: User, path: "/" },
  { name: "Coach Management", icon: Dumbbell, path: "coach" },
  { name: "Video Analysis", icon: Heart, path: "video" },
  { name: "Admin Management", icon: Users , path: "admin" },
  { name: "Sponsor Management", icon: PiggyBank, path: "sponsor" },
  { name: "Form Management", icon: BarChart, path: "form" },
];

function AdminDashboard() {
  return (
    <ALayout userType="Admin" navItems={navItems}>
      <Routes>
        
        <Route path="/" element={<AthleteManagement />} /> 
        <Route path="admin" element={<AdminManagement />} />
        <Route path="coach" element={<CoachManagement />} />
        <Route path="form" element={<FormManagement />} />
        <Route path="sponsor" element={<SponsorManagement />} />
        <Route path="video" element={<VideoAnalysis />} />
        
      </Routes>
    </ALayout>
  );
}

export default AdminDashboard;
