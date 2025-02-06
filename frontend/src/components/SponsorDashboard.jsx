import { Users,Calendar, Clipboard, MessageSquare } from "lucide-react"; 
import { Routes, Route } from "react-router-dom";
import Analytics from "./SponsorDashboardPages/Analytics";
import Contact from "./SponsorDashboardPages/Contact";
import Events from "./SponsorDashboardPages/Events";
import InvestmentTracking from "./SponsorDashboardPages/InvestmentTracking";
import ViewMetrics from "./SponsorDashboardPages/ViewMetrics";
import SLayout from "./SponsorDashboardPages/SLayout";


const navItems = [
  { label: "View Metrics", icon: Users, path: "viewmetrics" },
  { label: "Analytics", icon: Clipboard, path: "analytics" },
  { label: "Events", icon: Calendar, path: "events" },
  { label: "Investment Tracking", icon: Clipboard, path: "investment" },
  { label: "Communication", icon: MessageSquare, path: "contact" },
  
];

function SponsorDashboard() {
  return (
    <SLayout userType="Sponsor" navItems={navItems}>
      <Routes>
       <Route path="viewmetrics" element={<ViewMetrics />} />
       <Route path="analytics" element={<Analytics />} />
       <Route path="events" element={<Events />} />
       <Route path="contact" element={<Contact/>} />
       <Route path="investment" element={<InvestmentTracking />} />
      </Routes>
    </SLayout>
  );
}

export default SponsorDashboard;
