import { Users, LineChart, Calendar, Activity, MessageSquare, BarChart } from "lucide-react"; // Add this import statement

import { Routes, Route } from "react-router-dom";
import TeamManagement from "./CoachDashboardPages/TeamManagement";
import PerformanceMonitoring from "./CoachDashboardPages/PerformanceMonitoring";
import TrainingPlans from "./CoachDashboardPages/TrainingPlans";
import Communication from "./CoachDashboardPages/Communication";
import ReportAnalytics from "./CoachDashboardPages/ReportAnalytics";
import InjuryManagementC from "./CoachDashboardPages/InjuryManagementC";

import Layout from "./CoachDashboardPages/Layout";


const navItems = [
  { label: "Team Management", icon: Users, path: "teammanagement" },
  { label: "Performance Monitoring", icon: LineChart, path: "performance" },
  { label: "Training Plans", icon: Calendar, path: "training" },
  { label: "Injury Management", icon: Activity, path: "injury" },
  { label: "Communication", icon: MessageSquare, path: "communication" },
  { label: "Reports and Analytics", icon: BarChart, path: "reports" },
];

function CoachDashboard() {
  return (
    <Layout userType="Coach" navItems={navItems}>
      <Routes>
        <Route path="/" element={<TeamManagement />} />
        <Route path="performance" element={<PerformanceMonitoring />} />
        <Route path="training" element={<TrainingPlans />} />
        <Route path="injury" element={<InjuryManagementC />} />
        <Route path="communication" element={<Communication />} />
        <Route path="reports" element={<ReportAnalytics />} />
      </Routes>
    </Layout>
  );
}

export default CoachDashboard;
