import { useEffect } from "react"; // Make sure to import useEffect
import { Users, LineChart, Calendar, Activity, MessageSquare, BarChart, User } from "lucide-react"; 
import { Routes, Route, useParams } from "react-router-dom";
import InjuryRecords from "./AssistantCoachDashboardPages/InjuryRecords";
import Communication from "./AssistantCoachDashboardPages/Comm";
import PerformanceMonitor from "./AssistantCoachDashboardPages/PerformanceMonitor";
import Reports from "./AssistantCoachDashboardPages/Reports";
import Team from "./AssistantCoachDashboardPages/Team";
import Training from "./AssistantCoachDashboardPages/TrainingPl";
import ACProfile from "./AssistantCoachDashboardPages/ACProfile";
import CLayout from "./AssistantCoachDashboardPages/CLayout";

const navItems = [
  { label: "Team Management", icon: Users, path: "team" },
  { label: "Performance Monitoring", icon: LineChart, path: "monitoring" },
  { label: "Training Plans", icon: Calendar, path: "training" },
  { label: "Injury Management", icon: Activity, path: "injury" },
  { label: "Communication", icon: MessageSquare, path: "chat" },
  { label: "Reports and Analytics", icon: BarChart, path: "report" },
  { label: "Profile", icon: User, path: "acprofile" },
];

function AssistantCoachDashboard() {
  const { organizationId, coachName } = useParams(); // Access both organizationId and coachName from URL parameters

  useEffect(() => {
    if (!organizationId || !coachName) {
      console.error("Missing organization ID or coach name in URL");
      const userData = localStorage.getItem("userData");
      if (userData) {
        try {
          const parsedData = JSON.parse(userData);
          if (parsedData.organization && parsedData.coachName) {
            window.location.href = `/assistantcoach-dashboard/${parsedData.organization}/${parsedData.coachName}/team`; // Redirect to the team management page
          }
        } catch (e) {
          console.error("Error parsing user data:", e);
        }
      }
    }
  }, [organizationId, coachName]); // Ensure that the effect runs whenever either parameter changes

  if (!organizationId || !coachName) {
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
    <CLayout userType="AssistantCoach" navItems={navItems} organizationId={organizationId} coachName={coachName}>
      <Routes>
        <Route path="/" element={<Team organizationId={organizationId} coachName={coachName} />} />
        <Route path="team" element={<Team organizationId={organizationId} coachName={coachName} />} />
        <Route path="monitoring" element={<PerformanceMonitor organizationId={organizationId} coachName={coachName} />} />
        <Route path="training" element={<Training organizationId={organizationId} coachName={coachName} />} />
        <Route path="injury" element={<InjuryRecords organizationId={organizationId} coachName={coachName} />} />
        <Route path="chat" element={<Communication organizationId={organizationId} coachName={coachName} />} />
        <Route path="report" element={<Reports organizationId={organizationId} coachName={coachName} />} />
        <Route path="acprofile" element={<ACProfile organizationId={organizationId} coachName={coachName} />} />
      </Routes>
    </CLayout>
  );
}

export default AssistantCoachDashboard;
