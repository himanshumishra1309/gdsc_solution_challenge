import { useParams, Routes, Route, Navigate } from "react-router-dom";
import { BarChart, Dumbbell, Heart, Users, PiggyBank, User,House } from "lucide-react";
import { useEffect } from "react";
import ALayout from "./AdminDashboardPages/ALayout";
import AdminManagement from "./AdminDashboardPages/AdminManagement";
import CoachManagement from "./AdminDashboardPages/CoachManagement";
import AthleteManagement from "./AdminDashboardPages/AthleteManagement";
import VideoAnalysis from "./AdminDashboardPages/VideoAnalysis";
import SponsorManagement from "./AdminDashboardPages/SponsorManagement";
import FormManagement from "./AdminDashboardPages/FormManagement";
import AdminHome from "./AdminDashboardPages/AdminHome";

const navItems = [
  { name: "Admin Home", icon: House, path: "adminhome" },
  { name: "Athlete Management", icon: User, path: "athlete" },
  { name: "Coach Management", icon: Dumbbell, path: "coach" },
  { name: "Video Analysis", icon: Heart, path: "video" },
  { name: "Admin Management", icon: Users, path: "admin" },
  { name: "Sponsor Management", icon: PiggyBank, path: "sponsor" },
  { name: "Form Management", icon: BarChart, path: "form" },
  
];

function AdminDashboard() {
  const { organizationId } = useParams();

  useEffect(() => {
    if (!organizationId) {
      console.error("No organization ID found in URL");
      const userData = localStorage.getItem("userData");
      if (userData) {
        try {
          const parsedData = JSON.parse(userData);
          if (parsedData.organization) {
            window.location.href = `/admin-dashboard/${parsedData.organization}/admin`;
          }
        } catch (e) {
          console.error("Error parsing user data:", e);
        }
      }
    }
  }, [organizationId]);

  if (!organizationId) {
    return (
      <div className="flex h-screen items-center justify-center">
        <div className="text-center">
          <h2 className="text-xl font-semibold mb-2">Loading Dashboard...</h2>
          <p>If nothing happens, please log in again.</p>
        </div>
      </div>
    );
  }

  return (
    <ALayout userType="Admin" navItems={navItems} organizationId={organizationId}>
      <Routes>
        <Route path="/" element={<Navigate to="adminhome" replace />} />
        <Route path="adminhome" element={<AdminHome organizationId={organizationId} />} />
        <Route path="admin" element={<AdminManagement organizationId={organizationId} />} />
        <Route path="athlete" element={<AthleteManagement organizationId={organizationId} />} />
        <Route path="coach" element={<CoachManagement organizationId={organizationId} />} />
        <Route path="video" element={<VideoAnalysis organizationId={organizationId} />} />
        <Route path="sponsor" element={<SponsorManagement organizationId={organizationId} />} />
        <Route path="form" element={<FormManagement organizationId={organizationId} />} />
      </Routes>
    </ALayout>
  );
}

export default AdminDashboard;
