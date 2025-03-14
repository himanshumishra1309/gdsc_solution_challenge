import React, { useState } from "react";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
} from "@/components/ui/dialog";
import { LogIn, Users, UserPlus, TrendingUp, Activity, Star, Loader2 } from "lucide-react";
import { Link, useNavigate } from "react-router-dom";
import axios from "axios";
import athleteImage from "@/assets/stadium.jpeg";

const features = [
  { title: "Financial help", description: "Find and connect with athletes in your area or across India.", icon: <Users className="h-9 w-9 text-green-600" /> },
  { title: "Join Teams", description: "Discover local teams and join them for practice or competitions.", icon: <UserPlus className="h-9 w-9 text-green-600" /> },
  { title: "Track Progress", description: "Log your training and track your progress over time.", icon: <TrendingUp className="h-9 w-9 text-green-600" /> },
  { title: "Exclusive Content", description: "Access training videos, tips, and strategies from professionals.", icon: <Activity className="h-9 w-9 text-green-600" /> },
  { title: "Personalized Recommendations", description: "AI-powered suggestions for your training schedule and diet.", icon: <Star className="h-9 w-9 text-green-600" /> },
  { title: "Join Challenges", description: "Compete in sports challenges and win rewards.", icon: <TrendingUp className="h-9 w-9 text-green-600" /> }
];

const LandingPage = () => {
  const [open, setOpen] = useState(false);
  const [orgOptions, setOrgOptions] = useState(false);
  const [roleOptions, setRoleOptions] = useState(false);
  const [signInOpen, setSignInOpen] = useState(false);
  const [selectedRole, setSelectedRole] = useState(""); 
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [loginError, setLoginError] = useState("");
  const navigate = useNavigate();

  const handleRoleSelection = (role) => {
    if (role === "individual") {
      setOpen(false);
      navigate("athlete-signup");
    } else if (role === "sponsor") {
      setOpen(false);
      navigate("/sponsor-signup");
    } else if (role === "organization") {
      setOrgOptions(true);
    }
  };

  const handleRoleSelectionForOrganization = (role) => {
    setSelectedRole(role);
    setOpen(false);
    setSignInOpen(true); 
  };

  // Replace this part of your handleSignIn function
const handleSignIn = async () => {
  // Input validation
  if (!email || !password) {
    setLoginError("Please enter both email and password");
    return;
  }
  
  setIsLoading(true);
  setLoginError("");
  
  try {
    let endpoint = "";
    
    // Set the correct endpoint based on selected role
    if (selectedRole === "Admin") {
      endpoint = "http://localhost:8000/api/v1/auth/admin/login";
    } else if (selectedRole === "Coach") {
      endpoint = "http://localhost:8000/api/v1/auth/coach/login";
    } else if (selectedRole === "Athlete") {
      endpoint = "http://localhost:8000/api/v1/auth/athlete/login";
    } else {
      setLoginError("Invalid role selected");
      setIsLoading(false);
      return;
    }
    
    // Configure axios to include credentials (cookies)
    const response = await axios.post(endpoint, 
      { email, password },
      { 
        withCredentials: true,
        headers: {
          'Content-Type': 'application/json'
        }
      }
    );
    
    console.log("Login successful:", response.data);
    
    // Store user role in localStorage
    localStorage.setItem("userRole", selectedRole.toLowerCase());
    
    // Handle navigation based on role
    if (selectedRole === "Admin") {
      
      console.log("Admin data:", response.data);
      // Extract organization ID from response
      const organizationId = response.data.data.admin.organization;
      localStorage.setItem("userData", JSON.stringify(response.data.data.admin));
      
      // Navigate to admin dashboard with organization ID
      setSignInOpen(false);
      navigate(`/admin-dashboard/${organizationId}/admin`);
    } 
    else if (selectedRole === "Coach") {
      const organizationId = response.data.data.coach.organization;
      const coachName = response.data.data.coach.name.replace(/\s+/g, '-').toLowerCase();
      localStorage.setItem("userData", JSON.stringify(response.data.data.coach));
      
      setSignInOpen(false);
      navigate(`/coach-dashboard/${organizationId}/${coachName}/teammanagement`);
    } 
    else if (selectedRole === "Athlete") {
      const organizationId = response.data.data.athlete.organization;
      const athleteName = response.data.data.athlete.name.replace(/\s+/g, '-').toLowerCase();
      localStorage.setItem("userData", JSON.stringify(response.data.data.athlete));
      
      setSignInOpen(false);
      navigate(`/athlete-dashboard/${organizationId}/${athleteName}/home`);
    }
    
  } catch (err) {
    // Your existing error handling...
  } finally {
    setIsLoading(false);
  }
};

  return (
    <div className="min-h-screen bg-gray-100 font-sans">
      {/* Navbar */}
      <nav className="sticky top-0 z-50 flex justify-between items-center p-2 sm:p-3 bg-white shadow-lg">
        <h1 className="text-xl sm:text-2xl font-extrabold text-green-600">AthleTech</h1>
        <div className="flex space-x-3 sm:space-x-4 font-semibold text-sm sm:text-base text-gray-700">
          <Link to="/performance-tracking">
            <Button variant="link" className="hover:text-blue-600 text-xs sm:text-sm transition-all">Performance Tracking</Button>
          </Link>
          <Link to="/career-planning">
            <Button variant="link" className="hover:text-blue-600 text-xs sm:text-sm transition-all">Career Planning</Button>
          </Link>
          <Link to="/injury-management">
            <Button variant="link" className="hover:text-blue-600 text-xs sm:text-sm transition-all">Injury Management</Button>
          </Link>
          <Link to="/financial-support">
            <Button variant="link" className="hover:text-blue-600 text-xs sm:text-sm transition-all">Financial Support</Button>
          </Link>
        </div>
        <Button
          variant="outline"
          className="border-green-700 text-xs sm:text-sm text-green-700 hover:bg-green-700 hover:text-white"
          onClick={() => setOpen(true)}
        >
          <LogIn className="mr-1 sm:mr-2" size={14} /> Sign In / Sign Up
        </Button>
      </nav>

      {/* Hero Section */}
      <section className="relative text-center p-8 sm:p-14 text-white bg-cover bg-center h-[30vh] sm:h-[40vh]" style={{ backgroundImage: `url(${athleteImage})` }}>
        <div className="absolute inset-0 bg-black opacity-60"></div>
        <div className="relative z-10">
          <h1 className="text-2xl sm:text-3xl font-extrabold">Empowering Indian Athletes</h1>
          <p className="mt-2 text-base sm:text-lg">Join the best sports platform for athletes in India.</p>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-12 sm:py-14 bg-gray-50 text-center">
        <h2 className="text-xl sm:text-2xl font-bold text-green-600 mb-6 sm:mb-8">Why Choose AthleTech?</h2>
        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-5 sm:gap-6 container mx-auto px-12">
          {features.map(({ title, description, icon }) => (
            <Card key={title} className="shadow-md p-3 sm:p-8 text-center border border-gray-300 rounded-xl hover:bg-gray-50 hover:scale-105 hover:shadow-lg transition-all duration-300 ease-in-out">
              <div className="flex justify-center items-center mb-3">{icon}</div>
              <h3 className="text-sm sm:text-base font-bold mb-1">{title}</h3>
              <p className="text-gray-600 text-xs sm:text-sm">{description}</p>
            </Card>
          ))}
        </div>
      </section>

      {/* Role Selection Dialog */}
      <Dialog open={open} onOpenChange={setOpen}>
        <DialogContent className="p-4 sm:p-5 max-w-lg rounded-2xl bg-white shadow-lg border border-gray-200 transform transition-all scale-95">
          <DialogHeader>
            <DialogTitle className="text-lg sm:text-xl font-bold text-center text-gray-900">
              Choose Your Role
            </DialogTitle>
            <DialogDescription className="text-gray-600 text-center text-xs sm:text-sm">
              Select the type of account you want to create.
            </DialogDescription>
          </DialogHeader>
          {!orgOptions ? (
            <div className="grid grid-cols-1 gap-3 sm:gap-4 mt-4 sm:mt-5">
              <Button variant="outline" className="py-2 text-xs sm:text-sm rounded-xl border-green-600 text-green-600 hover:bg-green-600 hover:text-white transition-all" onClick={() => handleRoleSelection("individual")}>Individual</Button>
              <Button variant="outline" className="py-2 text-xs sm:text-sm rounded-xl border-blue-600 text-blue-600 hover:bg-blue-600 hover:text-white transition-all" onClick={() => handleRoleSelection("sponsor")}>Sponsor</Button>
              <Button variant="outline" className="py-2 text-xs sm:text-sm rounded-xl border-yellow-600 text-yellow-600 hover:bg-yellow-600 hover:text-white transition-all" onClick={() => setOrgOptions(true)}>Organization</Button>
            </div>
          ) : !roleOptions ? (
            <div className="grid grid-cols-1 gap-3 sm:gap-4 mt-4 sm:mt-5">
              <Button variant="outline" className="py-2 text-xs sm:text-sm rounded-xl border-purple-600 text-purple-600 hover:bg-purple-600 hover:text-white transition-all" onClick={() => setRoleOptions(true)}>Existing Organization</Button>
              <Button variant="outline" className="py-2 text-xs sm:text-sm rounded-xl border-red-600 text-red-600 hover:bg-red-600 hover:text-white transition-all" onClick={() => navigate("/organization-signup")}>New Organization</Button>
            </div>
          ) : (
            <div className="grid grid-cols-1 gap-3 sm:gap-4 mt-4 sm:mt-5">
              <Button variant="outline" className="py-2 text-xs sm:text-sm rounded-xl border-purple-600 text-purple-600 hover:bg-purple-600 hover:text-white transition-all" onClick={() => handleRoleSelectionForOrganization("Athlete")}>Athlete</Button>
              <Button variant="outline" className="py-2 text-xs sm:text-sm rounded-xl border-teal-600 text-teal-600 hover:bg-teal-600 hover:text-white transition-all" onClick={() => handleRoleSelectionForOrganization("Admin")}>Admin</Button>
              <Button variant="outline" className="py-2 text-xs sm:text-sm rounded-xl border-gray-700 text-gray-700 hover:bg-gray-700 hover:text-white transition-all" onClick={() => handleRoleSelectionForOrganization("Coach")}>Coach</Button>
            </div>
          )}
          <div className="mt-4 sm:mt-5 flex justify-center">
            <Button variant="ghost" className="text-gray-600 hover:text-red-500 transition-all" onClick={() => { setOpen(false); setOrgOptions(false); setRoleOptions(false); }}>Cancel</Button>
          </div>
        </DialogContent>
      </Dialog>

      {/* Sign-In Dialog */}
      <Dialog open={signInOpen} onOpenChange={(isOpen) => {
        if (!isLoading) {
          setSignInOpen(isOpen);
          if (!isOpen) {
            // Reset form when dialog closes
            setLoginError("");
            setEmail("");
            setPassword("");
          }
        }
      }}>
        <DialogContent className="p-4 sm:p-5 max-w-lg rounded-2xl bg-white shadow-lg border border-gray-200 transform transition-all scale-95">
          <DialogHeader>
            <DialogTitle className="text-lg sm:text-xl font-bold text-center text-gray-900">
              Sign In as {selectedRole}
            </DialogTitle>
            <DialogDescription className="text-gray-600 text-center text-xs sm:text-sm">
              Please enter your email and password to sign in as a {selectedRole}.
            </DialogDescription>
          </DialogHeader>
          
          {/* Error message */}
          {loginError && (
            <div className="bg-red-50 border border-red-400 text-red-700 px-4 py-2 rounded-lg text-xs sm:text-sm mb-4">
              {loginError}
            </div>
          )}
          
          <div className="grid grid-cols-1 gap-3 sm:gap-4 mt-4 sm:mt-5">
            <input
              type="email"
              placeholder="Email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              disabled={isLoading}
              className="py-2 px-4 text-sm rounded-xl border-2 border-gray-300 focus:border-blue-500 focus:outline-none w-full"
            />
            <input
              type="password"
              placeholder="Password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              disabled={isLoading}
              className="py-2 px-4 text-sm rounded-xl border-2 border-gray-300 focus:border-blue-500 focus:outline-none w-full"
              onKeyDown={(e) => {
                if (e.key === 'Enter' && !isLoading) {
                  handleSignIn();
                }
              }}
            />
          </div>
          <div className="mt-4 sm:mt-5 flex justify-center">
            <Button 
              variant="outline" 
              className="py-2 text-sm rounded-xl border-green-600 text-green-600 hover:bg-green-600 hover:text-white transition-all" 
              onClick={handleSignIn}
              disabled={isLoading}
            >
              {isLoading ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" /> Signing In...
                </>
              ) : "Sign In"}
            </Button>
          </div>
          <div className="mt-4 sm:mt-1 flex justify-center">
            <Button 
              variant="ghost" 
              className="text-gray-600 hover:text-red-500 transition-all" 
              onClick={() => {
                if (!isLoading) {
                  setSignInOpen(false);
                  setLoginError("");
                  setEmail("");
                  setPassword("");
                }
              }}
              disabled={isLoading}
            >
              Cancel
            </Button>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
};

export default LandingPage;