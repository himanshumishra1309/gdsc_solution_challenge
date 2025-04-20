import { Users, Salad, Hospital, Clipboard, MessageSquare } from "lucide-react"; 
import { Routes, Route,useParams } from "react-router-dom";
import Announcements from "./MedicalStaffDashboardPages/Announcements";
import Diet from "./MedicalStaffDashboardPages/Diet";
import InjuryLogs from "./MedicalStaffDashboardPages/InjuryLogs";
import MedicalRecords from "./MedicalStaffDashboardPages/MedicalRecords";
import ViewPlayers from "./MedicalStaffDashboardPages/ViewPlayers";
import MLayout from "./MedicalStaffDashboardPages/MLayout";
import MProfile from "./MedicalStaffDashboardPages/MProfile";
import AthleteMedicalRecords from "./MedicalStaffDashboardPages/AthleteMedicalRecords";

const navItems = [
  { label: "View Athletes", icon: Users, path: "viewplayers" },
  { label: "Nutrition", icon: Salad, path: "diet" },
  { label: "Medical Records", icon: Hospital, path: "medicalrecords" },
  { label: "Injury Records", icon: Clipboard, path: "injurylogs" },
  { label: "Announcements", icon: MessageSquare, path: "announcements" },
  { label: "Profile", icon: Users, path: "mprofile" },
];

function MedicalStaffDashboard() {

  const { organizationId , coachName } = useParams();

  return (
    <MLayout userType="MedicalStaff" navItems={navItems} organizationId={organizationId} coachName={coachName}>
      <Routes>
       <Route path="diet" element={<Diet />} />
       <Route path="/" element={<ViewPlayers />} />
       <Route path="viewplayers" element={<ViewPlayers />} />
       <Route path="injurylogs" element={<InjuryLogs />} />
       <Route path="announcements" element={<Announcements/>} />
       <Route path="medicalrecords" element={<MedicalRecords />} />
       <Route path="mprofile" element={<MProfile />} />
       <Route path="athlete-records/:athleteId" element={<AthleteMedicalRecords />} />
      </Routes>
    </MLayout>
  );
}

export default MedicalStaffDashboard;
