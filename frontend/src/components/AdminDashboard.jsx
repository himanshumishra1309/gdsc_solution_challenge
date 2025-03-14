import { useParams, Routes, Route, Navigate } from "react-router-dom";
import { BarChart, Dumbbell, Heart, Users, PiggyBank, User } from "lucide-react";
import { useEffect } from "react";
import ALayout from "./AdminDashboardPages/ALayout";
import AdminManagement from "./AdminDashboardPages/AdminManagement";
import CoachManagement from "./AdminDashboardPages/CoachManagement";
import AthleteManagement from "./AdminDashboardPages/AthleteManagement";
import VideoAnalysis from "./AdminDashboardPages/VideoAnalysis";
import SponsorManagement from "./AdminDashboardPages/SponsorManagement";
import FormManagement from "./AdminDashboardPages/FormManagement";

const navItems = [
  { name: "Athlete Management", icon: User, path: "athlete" },
  { name: "Coach Management", icon: Dumbbell, path: "coach" },
  { name: "Video Analysis", icon: Heart, path: "video" },
  { name: "Admin Management", icon: Users, path: "admin" },
  { name: "Sponsor Management", icon: PiggyBank, path: "sponsor" },
  { name: "Form Management", icon: BarChart, path: "form" },
];

function AdminDashboard() {
  // Get organizationId from URL params
  const { organizationId } = useParams();
  
  // Check if organizationId is present
  useEffect(() => {
    if (!organizationId) {
      console.error("No organization ID found in URL");
      // Try to get organization ID from local storage as fallback
      const userData = localStorage.getItem("userData");
      if (userData) {
        try {
          const parsedData = JSON.parse(userData);
          if (parsedData.organization) {
            // Redirect to the correct URL with organization ID
            window.location.href = `/admin-dashboard/${parsedData.organization}/admin`;
          }
        } catch (e) {
          console.error("Error parsing user data:", e);
        }
      }
    }
  }, [organizationId]);

  // If no organizationId and not redirecting yet, show loading
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
        {/* Default route - redirect to admin management */}
        <Route path="/" element={<Navigate to="admin" replace />} />
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