import { useState } from "react";
import { FaGooglePlusG, FaFacebookF, FaHome } from "react-icons/fa";
import { useNavigate } from "react-router-dom";

export default function SignUp() {
  const [isActive, setIsActive] = useState(false);
  const [userType, setUserType] = useState("athlete");
  const [coachRole, setCoachRole] = useState("");
  const [highestLevel, setHighestLevel] = useState("");
  const [state, setState] = useState("");

  const navigate = useNavigate();

  const competitionLevels = [
    "District Level", "State Level", "National Level", "International Level"
  ];

  const indianStatesAndUTs = [
    "Andhra Pradesh", "Arunachal Pradesh", "Assam", "Bihar", "Chhattisgarh",
    "Goa", "Gujarat", "Haryana", "Himachal Pradesh", "Jharkhand", "Karnataka",
    "Kerala", "Madhya Pradesh", "Maharashtra", "Manipur", "Meghalaya", "Mizoram",
    "Nagaland", "Odisha", "Punjab", "Rajasthan", "Sikkim", "Tamil Nadu",
    "Telangana", "Tripura", "Uttar Pradesh", "Uttarakhand", "West Bengal",
    "Andaman and Nicobar Islands", "Chandigarh", "Dadra and Nagar Haveli and Daman and Diu",
    "Lakshadweep", "Delhi", "Puducherry", "Ladakh", "Jammu and Kashmir"
  ];

  const handleSignUp = (e) => {
    e.preventDefault();
    if (userType === "athlete") navigate("/athlete-dashboard/:athleteName");
    else if (userType === "admin") navigate("/admin-dashboard");
    else if (userType === "sponsor") navigate("/sponsor-dashboard/:sponsorName/");
    else if (userType === "coach") {
      if (coachRole === "assistant-coach") navigate("/assistantcoach-dashboard/");
      else if (coachRole === "medical-staff") navigate("/medicalstaff-dashboard");
      else if (coachRole === "head-coach") navigate("/coach-dashboard/:coachName/");
      else if (coachRole === "gym-trainer") navigate("/gymtrainer-dashboard");
    }
  };

  const handleSignIn = (e) => {
    e.preventDefault();
    navigate("/dashboard"); 
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-r from-green-200 via-teal-200 to-blue-200">
      
      
      <div className="absolute top-4 left-4 cursor-pointer" onClick={() => navigate("/")}>
        <FaHome className="w-8 h-8 text-gray-700 hover:text-green-700 transition" />
      </div>

      <div className={`relative w-[880px] max-w-full min-h-[680px] bg-white rounded-3xl shadow-2xl overflow-hidden transition-all duration-1000 ${isActive ? "active" : ""}`}>

        
        <div className={`absolute top-0 left-0 w-1/2 h-full flex flex-col items-center justify-center px-10 transition-all duration-1000 ${isActive ? "translate-x-full opacity-100 z-10" : "opacity-0 z-[-1]"}`}>
          <h1 className="text-3xl font-semibold text-gray-800">Create Account</h1>
          <div className="flex gap-2 my-4">
            <FaGooglePlusG className="w-10 h-10 border p-2 rounded-full text-gray-700 cursor-pointer hover:bg-gray-100 transition" />
            <FaFacebookF className="w-10 h-10 border p-2 rounded-full text-gray-700 cursor-pointer hover:bg-gray-100 transition" />
          </div>
          <span className="text-sm text-gray-600">or use your email for registration</span>

          
          <select className="mt-5 p-2 w-full bg-gray-200 rounded-md outline-none focus:ring-2 focus:ring-green-500" value={userType} onChange={(e) => { setUserType(e.target.value); setCoachRole(""); }} required>
            <option value="athlete">Athlete</option>
            <option value="coach">Coach</option>
            <option value="admin">Admin</option>
            
          </select>

          
          <input type="text" placeholder="Name" className="mt-2 p-2 w-full bg-gray-200 rounded-md outline-none focus:ring-2 focus:ring-green-500" required />
          <input type="email" placeholder="Email" className="mt-2 p-2 w-full bg-gray-200 rounded-md outline-none focus:ring-2 focus:ring-green-500" required />
          <input type="date" placeholder="Date of Birth" className="mt-2 p-2 w-full bg-gray-200 rounded-md outline-none focus:ring-2 focus:ring-green-500" required />
          
          <select className="mt-2 p-2 w-full bg-gray-200 rounded-md outline-none focus:ring-2 focus:ring-green-500" value={state} onChange={(e) => setState(e.target.value)} required>
            <option value="">Select State/UT</option>
            {indianStatesAndUTs.map((state, index) => (
              <option key={index} value={state}>{state}</option>
            ))}
          </select>
          <input type="password" placeholder="Password" className="mt-2 p-2 w-full bg-gray-200 rounded-md outline-none focus:ring-2 focus:ring-green-500" required />
          
          {userType === "athlete" && (
            <select className="mt-2 p-2 w-full bg-gray-200 rounded-md outline-none focus:ring-2 focus:ring-green-500" value={highestLevel} onChange={(e) => setHighestLevel(e.target.value)} required>
              <option value="">Select Highest Level Played</option>
              {competitionLevels.map((level, index) => (
                <option key={index} value={level}>{level}</option>
              ))}
            </select>
          )}
          
          {userType === "coach" && (
            <>
              <select className="mt-2 p-2 w-full bg-gray-200 rounded-md outline-none focus:ring-2 focus:ring-green-500" value={coachRole} onChange={(e) => setCoachRole(e.target.value)} required>
                <option value="">Select Your Role</option>
                <option value="assistant-coach">Assistant Coach</option>
                <option value="medical-staff">Medical Staff</option>
                <option value="head-coach">Head Coach</option>
                <option value="gym-trainer">Gym Trainer</option>
              </select>

              
              {coachRole === "assistant-coach" && <input type="text" placeholder="Assistant Coach Experience" className="mt-2 p-2 w-full bg-gray-200 rounded-md outline-none focus:ring-2 focus:ring-green-500" required />}
              {coachRole === "medical-staff" && <input type="text" placeholder="Medical Staff Certification" className="mt-2 p-2 w-full bg-gray-200 rounded-md outline-none focus:ring-2 focus:ring-green-500" required />}
            </>
          )}

          
          <button onClick={handleSignUp} className="mt-6 px-6 py-2 bg-green-700 text-white rounded-md hover:bg-green-800 transition">
            Sign Up
          </button>
        </div>

        
        <div className={`absolute top-0 left-0 w-1/2 h-full flex flex-col items-center justify-center px-10 transition-all duration-1000 ${isActive ? "translate-x-full opacity-0 z-[-1]" : "opacity-100 z-10"}`}>
          <h1 className="text-3xl font-semibold text-gray-800">Sign In</h1>
          <div className="flex gap-2 my-4">
            <FaGooglePlusG className="w-10 h-10 border p-2 rounded-full text-gray-700 cursor-pointer hover:bg-gray-100 transition" />
            <FaFacebookF className="w-10 h-10 border p-2 rounded-full text-gray-700 cursor-pointer hover:bg-gray-100 transition" />
          </div>
          <span className="text-sm text-gray-600">or use your registered email</span>

          <input type="email" placeholder="Email" className="mt-10 p-2 w-full bg-gray-200 rounded-md outline-none focus:ring-2 focus:ring-green-500" required />
          <input type="password" placeholder="Password" className="mt-2 p-2 w-full bg-gray-200 rounded-md outline-none focus:ring-2 focus:ring-green-500" required />
          
          <a href="#" className="text-sm text-gray-600 mt-3">Forgot your password?</a>

          <button onClick={handleSignIn} className="mt-5 px-6 py-2 bg-green-700 text-white rounded-md hover:bg-green-800 transition">
            Sign In
          </button>
        </div>

        
        <div className={`absolute top-0 left-1/2 w-1/2 h-full flex items-center justify-center bg-green-700 text-white transition-all duration-1000 ${isActive ? "-translate-x-full rounded-tr-3xl rounded-br-3xl" : "rounded-tl-3xl rounded-bl-3xl"}`}>
          <div className="text-center">
            <h1 className="text-3xl font-semibold">{isActive ? "Welcome Back!" : "Hello There!"}</h1>
            <p className="mt-5">{isActive ? "Enter your details to sign in." : "Register with your details to sign up."}</p>
            <button onClick={() => setIsActive(!isActive)} className="mt-9 px-6 py-2 bg-transparent border border-white rounded-md hover:bg-white hover:text-gray-800 transition">
              {isActive ? "Sign In" : "Sign Up"}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
