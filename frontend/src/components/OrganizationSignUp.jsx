import { useState } from "react";
import { FaGooglePlusG, FaFacebookF, FaHome } from "react-icons/fa";
import { useNavigate } from "react-router-dom";
import { Select, SelectTrigger, SelectValue, SelectContent, SelectItem } from "@/components/ui/select";
import { Button } from "@/components/ui/button";

export default function OrganizationSignUp() {
  const [isActive, setIsActive] = useState(false);
  const [selectedRole, setSelectedRole] = useState(""); 
  const [selectedCoachRole, setSelectedCoachRole] = useState(""); 
  const [certificateId, setCertificateId] = useState(""); 
  const navigate = useNavigate();

  const handleSignUp = (e) => {
    e.preventDefault();

    if (!selectedRole) {
      alert("Please select a role before signing up.");
      return;
    }

    if (selectedRole === "Coach" && !selectedCoachRole) {
      alert("Please select a coach role before signing up.");
      return;
    }

    // Redirecting based on selection
    if (selectedRole === "Admin") navigate("/admin-dashboard");
    else if (selectedRole === "Athlete") navigate("/athlete-dashboard/:athleteName/");
    else if (selectedRole === "Coach") {
      if (selectedCoachRole === "Assistant Coach") navigate("/assistantcoach-dashboard/");
      else if (selectedCoachRole === "Head Coach") navigate("/coach-dashboard/:coachName");
      else if (selectedCoachRole === "Gym Trainer") navigate("/gymtrainer-dashboard");
      else if (selectedCoachRole === "Medical Staff") navigate("/medicalstaff-dashboard");
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-r from-green-200 via-teal-200 to-blue-200">
      <div className="absolute top-4 left-4 cursor-pointer" onClick={() => navigate("/")}>
        <FaHome className="w-8 h-8 text-gray-700 hover:text-green-700 transition" />
      </div>

      <div className="w-[1000px] max-w-full min-h-[750px] bg-white rounded-3xl shadow-2xl p-12">
        <h1 className="text-3xl font-semibold text-gray-800 text-center">Organization Sign Up</h1>

        <div className="flex gap-2 my-4 justify-center">
          <FaGooglePlusG className="w-10 h-10 border p-2 rounded-full text-gray-700 cursor-pointer hover:bg-gray-100 transition" />
          <FaFacebookF className="w-10 h-10 border p-2 rounded-full text-gray-700 cursor-pointer hover:bg-gray-100 transition" />
        </div>

        <span className="text-sm text-gray-600 text-center block">or use your email for registration</span>

        <form className="space-y-4 mt-4">
          <input type="text" placeholder="Organization Name" className="p-2 w-full bg-gray-200 rounded-md outline-none focus:ring-2 focus:ring-green-500" required />
          <input type="text" placeholder="Organization Type (Academy, Team, Federation)" className="p-2 w-full bg-gray-200 rounded-md outline-none focus:ring-2 focus:ring-green-500" required />
          <input type="text" placeholder="Primary Contact Name" className="p-2 w-full bg-gray-200 rounded-md outline-none focus:ring-2 focus:ring-green-500" required />
          <input type="email" placeholder="Email" className="p-2 w-full bg-gray-200 rounded-md outline-none focus:ring-2 focus:ring-green-500" required />
          <input type="text" placeholder="Organization Mission/Focus Areas" className="p-2 w-full bg-gray-200 rounded-md outline-none focus:ring-2 focus:ring-green-500" />
          <input type="text" placeholder="Sports/Athlete Categories Managed" className="p-2 w-full bg-gray-200 rounded-md outline-none focus:ring-2 focus:ring-green-500" required />

          {/* Role Selection Dropdown */}
          <div>
            <label className="text-gray-700 text-sm font-medium">Select Your Role</label>
            <Select value={selectedRole} onValueChange={(value) => { setSelectedRole(value); setSelectedCoachRole(""); }}>
              <SelectTrigger className="mt-1 w-full bg-gray-200">
                <SelectValue placeholder="Choose a role" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="Admin">Admin</SelectItem>
                <SelectItem value="Coach">Coach</SelectItem>
                <SelectItem value="Athlete">Athlete</SelectItem>
              </SelectContent>
            </Select>
          </div>

          
          {selectedRole === "Coach" && (
            <>
              <div>
                <label className="text-gray-700 text-sm font-medium">Select Coach Role</label>
                <Select value={selectedCoachRole} onValueChange={setSelectedCoachRole}>
                  <SelectTrigger className="mt-1 w-full bg-gray-200">
                    <SelectValue placeholder="Choose a coach role" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="Assistant Coach">Assistant Coach</SelectItem>
                    <SelectItem value="Head Coach">Head Coach</SelectItem>
                    <SelectItem value="Gym Trainer">Gym Trainer</SelectItem>
                    <SelectItem value="Medical Staff">Medical Staff</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              
              <input
                type="text"
                placeholder="Certificate ID"
                value={certificateId}
                onChange={(e) => setCertificateId(e.target.value)}
                className="p-2 w-full bg-gray-200 rounded-md outline-none focus:ring-2 focus:ring-green-500"
                required
              />
            </>
          )}

          <Button onClick={handleSignUp} className="mt-4 w-full bg-green-700 text-white rounded-md hover:bg-green-800 transition">
            Sign Up
          </Button>
        </form>
      </div>
    </div>
  );
}
