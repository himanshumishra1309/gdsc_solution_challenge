import { Users, LineChart, Calendar, Activity, MessageSquare, BarChart } from "lucide-react"; 

import { Routes, Route } from "react-router-dom";
import Alerts from "./GymTrainerDashboardPages/Alerts";
import Challenges from "./GymTrainerDashboardPages/Challenges";
import MedicalReports from "./GymTrainerDashboardPages/MedicalReports";
import RPEManagement from "./GymTrainerDashboardPages/RPEManagement";
import View from "./GymTrainerDashboardPages/View";
import WorkoutPlans from "./GymTrainerDashboardPages/WorkoutPlans";
import GLayout from "./GymTrainerDashboardPages/GLayout";


const navItems = [
  { label: "View Athletes", icon: Users, path: "view" },
  { label: "RPE", icon: LineChart, path: "rpe" },
  { label: "Workout Plans", icon: Calendar, path: "workout" },
  { label: "Challenges", icon: Activity, path: "challenges" },
  { label: "Announcements", icon: MessageSquare, path: "alerts" },
  { label: "Medical Reports", icon: BarChart, path: "medicalreports" },
];

function GymTrainerDashboard() {
  return (
    <GLayout userType="GymTrainer" navItems={navItems}>
      <Routes>
        <Route path="alerts" element={<Alerts />} />
        <Route path="challenges" element={<Challenges />} />
        <Route path="medicalreports" element={<MedicalReports />} />
        <Route path="rpe" element={<RPEManagement/>} />
        <Route path="/" element={<View />} />
        <Route path="view" element={<View />} />
        <Route path="workout" element={<WorkoutPlans />} />
      </Routes>
    </GLayout>
  );
}

export default GymTrainerDashboard;
