import React from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import LandingPage from "./components/ui/LandingPage";
import SignUp from "./components/SignUp";
import SelectSportsPage from "./components/SelectSportPage";
import SelectRolePage from "./components/SelectRolePage";
import AthleteDashboard from "./components/AthleteDashboard";
import PerformanceTracking from "./components/ui/PerformanceTracking";
import FinancialSupport from "./components/ui/FinancialSupport";
import InjuryManagement from "./components/ui/InjuryManagement";
import CareerPlanning from "./components/ui/CareerPlanning";


import Finance from "./components/AthleteDashboardPages/Finance";
import Medical from "./components/AthleteDashboardPages/Medical";
import Nutrition from "./components/AthleteDashboardPages/Nutrition";
import Training from "./components/AthleteDashboardPages/Training";
import Performance from "./components/AthleteDashboardPages/Performance";
import Profile from "./components/AthleteDashboardPages/Profile";
import Home from "./components/AthleteDashboardPages/Home";  


import CoachDashboard from "./components/CoachDashboard";
import TeamManagement from "./components/CoachDashboardPages/TeamManagement";
import PerformanceMonitoring from "./components/CoachDashboardPages/PerformanceMonitoring";
import TrainingPlans from "./components/CoachDashboardPages/TrainingPlans";
import Communication from "./components/CoachDashboardPages/Communication";
import ReportAnalytics from "./components/CoachDashboardPages/ReportAnalytics";
import InjuryManagementC from "./components/CoachDashboardPages/InjuryManagementC";

import AssistantCoachDashboard from "./components/AssistantCoachDashboard";
import InjuryRecords from "./components/AssistantCoachDashboardPages/InjuryRecords";
import Comm from "./components/AssistantCoachDashboardPages/Comm";
import PerformanceMonitor from "./components/AssistantCoachDashboardPages/PerformanceMonitor";
import Reports from "./components/AssistantCoachDashboardPages/Reports";
import Team from "./components/AssistantCoachDashboardPages/Team";
import TrainingPl from "./components/AssistantCoachDashboardPages/TrainingPl";

import MedicalStaffDashboard from "./components/MedicalStaffDashboard";
import Announcements from "./components/MedicalStaffDashboardPages/Announcements";
import Diet from "./components/MedicalStaffDashboardPages/Diet";
import InjuryLogs from "./components/MedicalStaffDashboardPages/InjuryLogs";
import MedicalRecords from "./components/MedicalStaffDashboardPages/MedicalRecords";
import ViewPlayers from "./components/MedicalStaffDashboardPages/ViewPlayers";

import GymTrainerDashboard from "./components/GymTrainerDashboard";
import Alerts from "./components/GymTrainerDashboardPages/Alerts";
import Challenges from "./components/GymTrainerDashboardPages/Challenges";
import MedicalReports from "./components/GymTrainerDashboardPages/MedicalReports";
import RPEManagement from "./components/GymTrainerDashboardPages/RPEManagement";
import View from "./components/GymTrainerDashboardPages/View";
import WorkoutPlans from "./components/GymTrainerDashboardPages/WorkoutPlans";

import  SponsorDashboard from "./components/SponsorDashboard";
import Analytics from "./components/SponsorDashboardPages/Analytics";
import Contact from "./components/SponsorDashboardPages/Contact";
import Events from "./components/SponsorDashboardPages/Events";
import InvestmentTracking from "./components/SponsorDashboardPages/InvestmentTracking";
import ViewMetrics from "./components/SponsorDashboardPages/ViewMetrics";



function App() {
  return (
    <Router>
      <Routes>
        
        <Route path="/" element={<LandingPage />} />
        <Route path="/sign-up" element={<SignUp />} />
        <Route path="/select-sports" element={<SelectSportsPage />} />
        <Route path="/select-role" element={<SelectRolePage />} />
        <Route path="/performance-tracking" element={<PerformanceTracking />} />
        <Route path="/financial-support" element={<FinancialSupport />} />
        <Route path="/injury-management" element={<InjuryManagement />} />
        <Route path="/career-planning" element={<CareerPlanning />} />

        <Route path="/athlete-dashboard/:athleteName/*" element={<AthleteDashboard />}>
          <Route path="home" element={<Home />} />
          <Route path="finance" element={<Finance />} />
          <Route path="medical" element={<Medical />} />
          <Route path="nutrition" element={<Nutrition />} />
          <Route path="training" element={<Training />} />
          <Route path="performance" element={<Performance />} />
          <Route path="profile" element={<Profile />} />
        </Route>
        <Route path="/coach-dashboard/*" element={<CoachDashboard />} >
          <Route path="teammanagement" element={<TeamManagement />} />
          <Route path="performance" element={<PerformanceMonitoring />} />
          <Route path="training" element={<TrainingPlans />} />
          <Route path="injury" element={<InjuryManagementC />} />
          <Route path="communication" element={<Communication />} />
          <Route path="reports" element={<ReportAnalytics />} />
        </Route>

        <Route path="/assistantcoach-dashboard/*" element={<AssistantCoachDashboard />} >
          <Route path="report" element={<Reports />} />
          <Route path="monitoring" element={<PerformanceMonitor />} />
          <Route path="training" element={<TrainingPl />} />
          <Route path="injury" element={<InjuryRecords />} />
          <Route path="chat" element={<Comm />} />
          <Route path="team" element={<Team />} />
        </Route>
        <Route path="/medicalstaff-dashboard/*" element={<MedicalStaffDashboard />} >
          <Route path="diet" element={<Diet />} />
          <Route path="viewplayers" element={<ViewPlayers />} />
          <Route path="injurylogs" element={<InjuryLogs />} />
          <Route path="announcements" element={<Announcements/>} />
          <Route path="medicalrecords" element={<MedicalRecords />} />
        </Route>
        <Route path="/gymtrainer-dashboard/*" element={<GymTrainerDashboard />} >
          <Route path="alerts" element={<Alerts />} />
          <Route path="challenges" element={<Challenges />} />
          <Route path="medicalreports" element={<MedicalReports />} />
          <Route path="rpe" element={<RPEManagement />} />
          <Route path="view" element={<View />} />
          <Route path="workout" element={<WorkoutPlans />} />
        </Route>
        <Route path="/sponsor-dashboard/*" element={<SponsorDashboard />} >
          <Route path="analytics" element={<Analytics />} />
          <Route path="contact" element={<Contact />} />
          <Route path="events" element={<Events />} />
          <Route path="investment" element={<InvestmentTracking />} />
          <Route path="viewmetrics" element={<ViewMetrics />} />
        </Route>

      </Routes>
    </Router>
  );
}

export default App;
