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
import { LogIn, Users, UserPlus, TrendingUp, Activity, Star } from "lucide-react";
import { Link, useNavigate } from "react-router-dom";
import athleteImage from "@/assets/stadium.jpeg";

const features = [
  { title: "Financial help", description: "Find and connect with athletes in your area or across India.", icon: <Users className="h-12 w-12 text-green-600" /> },
  { title: "Join Teams", description: "Discover local teams and join them for practice or competitions.", icon: <UserPlus className="h-12 w-12 text-green-600" /> },
  { title: "Track Progress", description: "Log your training and track your progress over time.", icon: <TrendingUp className="h-12 w-12 text-green-600" /> },
  { title: "Exclusive Content", description: "Access training videos, tips, and strategies from professionals.", icon: <Activity className="h-12 w-12 text-green-600" /> },
  { title: "Personalized Recommendations", description: "AI-powered suggestions for your training schedule and diet.", icon: <Star className="h-12 w-12 text-green-600" /> },
  { title: "Join Challenges", description: "Compete in sports challenges and win rewards.", icon: <TrendingUp className="h-12 w-12 text-green-600" /> }
];

const LandingPage = () => {
  const [open, setOpen] = useState(false);
  const [orgOptions, setOrgOptions] = useState(false);
  const [roleOptions, setRoleOptions] = useState(false);
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

  return (
    <div className="min-h-screen bg-gray-100 font-sans">
      {/* Navbar */}
      <nav className="sticky top-0 z-50 flex justify-between items-center p-5 bg-white shadow-lg">
        <h1 className="text-3xl font-extrabold text-green-600">Khel-INDIA</h1>
        <div className="flex space-x-8 font-semibold text-lg text-gray-700">
          <Link to="/performance-tracking">
            <Button variant="link" className="hover:text-blue-600 text-lg transition-all">Performance Tracking</Button>
          </Link>
          <Link to="/career-planning">
            <Button variant="link" className="hover:text-blue-600 text-lg transition-all">Career Planning</Button>
          </Link>
          <Link to="/injury-management">
            <Button variant="link" className="hover:text-blue-600 text-lg transition-all">Injury Management</Button>
          </Link>
          <Link to="/financial-support">
            <Button variant="link" className="hover:text-blue-600 text-lg transition-all">Financial Support</Button>
          </Link>
        </div>
        <Button
          variant="outline"
          className="border-green-700 text-lg text-green-700 hover:bg-green-700 hover:text-white"
          onClick={() => setOpen(true)}
        >
          <LogIn className="mr-2" size={16} /> Sign In / Sign Up
        </Button>
      </nav>

      {/* Hero Section */}
      <section className="relative text-center p-16 text-white bg-cover bg-center h-[45vh]" style={{ backgroundImage: `url(${athleteImage})` }}>
        <div className="absolute inset-0 bg-black opacity-60"></div>
        <div className="relative z-10">
          <h1 className="text-5xl font-extrabold">Empowering Indian Athletes</h1>
          <p className="mt-4 text-2xl">Join the best sports platform for athletes in India.</p>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-20 bg-gray-50 text-center">
        <h2 className="text-3xl font-bold text-green-600 mb-12">Why Choose Khel-INDIA?</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8 container mx-auto px-4">
          {features.map(({ title, description, icon }) => (
            <Card key={title} className="shadow-xl p-5 text-center border border-gray-300 rounded-xl hover:bg-gray-50 hover:scale-105 hover:shadow-2xl transition-all duration-300 ease-in-out">
              <div className="flex justify-center items-center mb-4">{icon}</div>
              <h3 className="text-xl font-bold mb-2">{title}</h3>
              <p className="text-gray-600">{description}</p>
            </Card>
          ))}
        </div>
      </section>

      {/* Dialog with Coach Option Restored */}
      <Dialog open={open} onOpenChange={setOpen}>
        <DialogContent className="p-8 max-w-lg rounded-2xl bg-white shadow-2xl border border-gray-200 transform transition-all scale-105">
          <DialogHeader>
            <DialogTitle className="text-2xl font-bold text-center text-gray-900">
              Choose Your Role
            </DialogTitle>
            <DialogDescription className="text-gray-600 text-center">
              Select the type of account you want to create.
            </DialogDescription>
          </DialogHeader>
          {!orgOptions ? (
            <div className="grid grid-cols-1 gap-4 mt-6">
              <Button variant="outline" className="py-3 text-lg rounded-xl border-green-600 text-green-600 hover:bg-green-600 hover:text-white transition-all" onClick={() => handleRoleSelection("individual")}>Individual</Button>
              <Button variant="outline" className="py-3 text-lg rounded-xl border-blue-600 text-blue-600 hover:bg-blue-600 hover:text-white transition-all" onClick={() => handleRoleSelection("sponsor")}>Sponsor</Button>
              <Button variant="outline" className="py-3 text-lg rounded-xl border-yellow-600 text-yellow-600 hover:bg-yellow-600 hover:text-white transition-all" onClick={() => setOrgOptions(true)}>Organization</Button>
            </div>
          ) : !roleOptions ? (
            <div className="grid grid-cols-1 gap-4 mt-6">
              <Button variant="outline" className="py-3 text-lg rounded-xl border-purple-600 text-purple-600 hover:bg-purple-600 hover:text-white transition-all" onClick={() => setRoleOptions(true)}>Existing Organization</Button>
              <Button variant="outline" className="py-3 text-lg rounded-xl border-red-600 text-red-600 hover:bg-red-600 hover:text-white transition-all" onClick={() => navigate("/organization-signup")}>New Organization</Button>
            </div>
          ) : (
            <div className="grid grid-cols-1 gap-4 mt-6">
              <Button variant="outline" className="py-3 text-lg rounded-xl border-indigo-600 text-indigo-600 hover:bg-indigo-600 hover:text-white transition-all" onClick={() => navigate("/athlete-signup")}>Athlete</Button>
              <Button variant="outline" className="py-3 text-lg rounded-xl border-teal-600 text-teal-600 hover:bg-teal-600 hover:text-white transition-all" onClick={() => navigate("/admin-signup")}>Admin</Button>
              <Button variant="outline" className="py-3 text-lg rounded-xl border-gray-700 text-gray-700 hover:bg-gray-700 hover:text-white transition-all" onClick={() => navigate("/coach-signup")}>Coach</Button>
            </div>
          )}
          <div className="mt-6 flex justify-center">
            <Button variant="ghost" className="text-gray-600 hover:text-red-500 transition-all" onClick={() => { setOpen(false); setOrgOptions(false); setRoleOptions(false); }}>Cancel</Button>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
};

export default LandingPage;
