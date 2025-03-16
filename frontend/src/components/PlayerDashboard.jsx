import { Routes, Route, useParams, Navigate } from "react-router-dom";
import { BarChart, Dumbbell, Heart, Apple, MessageSquare, User } from "lucide-react";
import PlLayout from "./PlayerDashboardPages/Pllayout";
import FillInjuryForms from "./PlayerDashboardPages/FillInjuryForms";
import Graphs from "./PlayerDashboardPages/Graphs";
import ViewAnnouncements from "./PlayerDashboardPages/ViewAnnouncements";
import ViewCoaches from "./PlayerDashboardPages/ViewCoaches";
import ViewGymPlans from "./PlayerDashboardPages/ViewGymPlans";
import ViewMedicalReports from "./PlayerDashboardPages/ViewMedicalReports";
import ViewNutritionalPlans from "./PlayerDashboardPages/ViewNutritionalPlans";
import ViewStats from "./PlayerDashboardPages/ViewStats";

const navItems = [
  { name: "Graphs", icon: BarChart, path: "graphs" },
  { name: "View Coaches", icon: User, path: "viewcoaches" },
  { name: "View Training Plans", icon: Dumbbell, path: "viewgym" },
  { name: "View Medical Reports", icon: Heart, path: "viewmed" },
  { name: "Nutrition Plans", icon: Apple, path: "viewnutri" },
  { name: "Announcements", icon: MessageSquare, path: "viewannouncements" },
  { name: "Fill Injury forms", icon: BarChart, path: "injuryform" },
  { name: "View Stats", icon: User, path: "viewstats" },
];

function PlayerDashboard() {
  // Access URL parameters
  const { organizationId, playerName } = useParams();
  
  return (
    <PlLayout userType="Player" navItems={navItems} organizationId={organizationId} playerName={playerName}>
      <Routes>
        {/* Redirect root to home */}
        <Route path="/" element={<Graphs />} />
        <Route path="graphs" element={<Graphs />} />
        <Route path="viewcoaches" element={<ViewCoaches />} />
        <Route path="viewgym" element={<ViewGymPlans />} />
        <Route path="viewmed" element={<ViewMedicalReports />} />
        <Route path="viewnutri" element={<ViewNutritionalPlans />} />
        <Route path="viewannouncements" element={<ViewAnnouncements />} />
        <Route path="viewstats" element={<ViewStats />} />
        <Route path="injuryform" element={<FillInjuryForms />} />
      </Routes>
    </PlLayout>
  );
}

export default PlayerDashboard;