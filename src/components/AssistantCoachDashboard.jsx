import { Users, LineChart, Calendar, Activity, MessageSquare, BarChart } from "lucide-react"; 
import { Routes, Route } from "react-router-dom";
import InjuryRecords from "./AssistantCoachDashboardPages/InjuryRecords";
import Communication from "./AssistantCoachDashboardPages/Comm";
import PerformanceMonitor from "./AssistantCoachDashboardPages/PerformanceMonitor";
import Reports from "./AssistantCoachDashboardPages/Reports";
import Team from "./AssistantCoachDashboardPages/Team";
import Training from "./AssistantCoachDashboardPages/TrainingPl";

import CLayout from "./AssistantCoachDashboardPages/CLayout";


const navItems = [
  { label: "Team Management", icon: Users, path: "team" },
  { label: "Performance Monitoring", icon: LineChart, path: "monitoring" },
  { label: "Training Plans", icon: Calendar, path: "training" },
  { label: "Injury Management", icon: Activity, path: "injury" },
  { label: "Communication", icon: MessageSquare, path: "chat" },
  { label: "Reports and Analytics", icon: BarChart, path: "report" },
];

function AssistantCoachDashboard() {
  return (
    <CLayout userType="AssistantCoach" navItems={navItems}>
      <Routes>
        <Route path="/" element={<Team/>} />
        <Route path="team" element={<Team/>} />
        <Route path="monitoring" element={<PerformanceMonitor />} />
        <Route path="training" element={<Training />} />
        <Route path="injury" element={<InjuryRecords />} />
        <Route path="chat" element={<Communication />} />
        <Route path="report" element={<Reports/>} />
      </Routes>
    </CLayout>
  );
}

export default AssistantCoachDashboard;
