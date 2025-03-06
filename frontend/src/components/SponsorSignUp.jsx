import { useState } from "react";
import { FaGooglePlusG, FaFacebookF, FaHome } from "react-icons/fa";
import { useNavigate } from "react-router-dom";

export default function SponsorSignUp() {
  const [isActive, setIsActive] = useState(false);
  const [organizationType, setOrganizationType] = useState("");
  const [sector, setSector] = useState("");
  const navigate = useNavigate();

  const handleSignUp = (e) => {
    e.preventDefault();
    navigate("/sponsor-dashboard/:sponsorName/"); 
  };

  const handleSignIn = (e) => {
    e.preventDefault();
    navigate("/sponsor-dashboard/:sponsorName/"); 
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-r from-green-200 via-teal-200 to-blue-200">

      {/* Home Button */}
      <div className="absolute top-4 left-4 cursor-pointer" onClick={() => navigate("/")}>
        <FaHome className="w-8 h-8 text-gray-700 hover:text-green-700 transition" />
      </div>

      <div className={`relative w-[880px] max-w-full min-h-[680px] bg-white rounded-3xl shadow-2xl overflow-hidden transition-all duration-1000 ${isActive ? "active" : ""}`}>

        {/* Form Container */}
        <div className="absolute top-0 left-0 w-full h-full flex items-center justify-center">

          {/* Sign In Form */}
          <div className={`w-1/2 h-full flex flex-col items-center justify-center px-10 transition-all duration-1000 ${isActive ? "opacity-0" : "opacity-100"}`}>
            <h1 className="text-3xl font-semibold text-gray-800">Sponsor Sign In</h1>
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

          {/* Sign Up Form */}
          <div className={`w-1/2 h-full flex flex-col items-center justify-center px-10 transition-all duration-1000 ${isActive ? "opacity-100" : "opacity-0"}`}>
            <h1 className="text-3xl font-semibold text-gray-800">Sponsor Sign Up</h1>
            <div className="flex gap-2 my-4">
              <FaGooglePlusG className="w-10 h-10 border p-2 rounded-full text-gray-700 cursor-pointer hover:bg-gray-100 transition" />
              <FaFacebookF className="w-10 h-10 border p-2 rounded-full text-gray-700 cursor-pointer hover:bg-gray-100 transition" />
            </div>
            <span className="text-sm text-gray-600">or use your email for registration</span>

            <input type="text" placeholder="Organization Name" className="mt-2 p-2 w-full bg-gray-200 rounded-md outline-none focus:ring-2 focus:ring-green-500" required />
            <input type="text" placeholder="Contact Name" className="mt-2 p-2 w-full bg-gray-200 rounded-md outline-none focus:ring-2 focus:ring-green-500" required />
            <input type="email" placeholder="Email" className="mt-2 p-2 w-full bg-gray-200 rounded-md outline-none focus:ring-2 focus:ring-green-500" required />
            <input type="text" placeholder="Phone Number" className="mt-2 p-2 w-full bg-gray-200 rounded-md outline-none focus:ring-2 focus:ring-green-500" required />
            
            <input type="text" placeholder="Brand Preferences (e.g., sport, region, gender)" className="mt-2 p-2 w-full bg-gray-200 rounded-md outline-none focus:ring-2 focus:ring-green-500" />
            <input type="text" placeholder="Organization/Company ID" className="mt-2 p-2 w-full bg-gray-200 rounded-md outline-none focus:ring-2 focus:ring-green-500" required />

            <button onClick={handleSignUp} className="mt-6 px-6 py-2 bg-green-700 text-white rounded-md hover:bg-green-800 transition">
              Sign Up
            </button>
          </div>

        </div>

        {/* Overlay Panel */}
        <div className={`absolute top-0 left-1/2 w-1/2 h-full flex items-center justify-center bg-green-700 text-white transition-all duration-1000 ${isActive ? "-translate-x-full rounded-tr-3xl rounded-br-3xl" : "rounded-tl-3xl rounded-bl-3xl"}`}>
          <div className="text-center">
            <h1 className="text-3xl font-semibold">{isActive ? "Welcome Back!" : "Hello Sponsor!"}</h1>
            <p className="mt-5">{isActive ? "Enter your details to sign in." : "Register to start your journey."}</p>
            <button onClick={() => setIsActive(!isActive)} className="mt-9 px-6 py-2 bg-transparent border border-white rounded-md hover:bg-white hover:text-gray-800 transition">
              {isActive ? "Sign In" : "Sign Up"}
            </button>
          </div>
        </div>

      </div>
    </div>
  );
}
