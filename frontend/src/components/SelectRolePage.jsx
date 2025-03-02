import React, { useState } from "react";
import { useNavigate } from "react-router-dom"; 
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

const SelectRolePage = () => {
  const [selectedRole, setSelectedRole] = useState("");
  const navigate = useNavigate(); 

  const roles = [
    {
      id: "athlete",
      emoji: "🏅",
      title: "Athlete",
      dashboardRoute: "/athlete-dashboard/:athleteName" 
    },
    {
      id: "coach",
      emoji: "📋",
      title: "Coach",
      dashboardRoute: "/coach-dashboard", 
    },
    {
      id: "sponsor",
      emoji: "💼",
      title: "Sponsor",
      dashboardRoute: "/sponsor-dashboard", 
    },
    {
      id: "admin",
      emoji: "👤",
      title: "Admin",
      dashboardRoute: "/admin-dashboard", 
    },
  ];

  const handleRoleSelect = (roleId) => {
    setSelectedRole(roleId); 
    console.log("Selected Role:", roleId);  
  };

  const handleNext = () => {
    
    const selectedRoleObj = roles.find(role => role.id === selectedRole);
    if (selectedRoleObj) {
      console.log("Navigating to", selectedRoleObj.dashboardRoute);
      navigate(selectedRoleObj.dashboardRoute);  
    }
  };

  const handleBack = () => {
    navigate("/select-sports");
  };

  return (
    <div className="h-[900px] p-5 bg-gray-100 flex flex-col">
      <header className="bg-white shadow-sm py-4">
        <div className="container mx-auto text-center">
          <h1 className="text-4xl font-bold text-green-600">Khel-INDIA</h1>
          <p className="text-gray-600">Empowering athletes, coaches, and sponsors.</p>
        </div>
      </header>

      
      <div className="text-center mt-8 mb-8">
        <h2 className="text-3xl font-semibold text-gray-700">Select Your Role</h2>
      </div>

      <main className="flex-grow flex items-center justify-center p-6">
        <div className="w-full max-w-6xl grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
          {roles.map((role) => (
            <Card
              key={role.id}
              className={`flex flex-col items-center p-12 cursor-pointer transition-all duration-300 ease-in-out transform hover:scale-105 ${
                selectedRole === role.id
                  ? "bg-blue-50 border-blue-500"
                  : "bg-white border-gray-200 hover:bg-gray-50"
              }`}
              onClick={() => handleRoleSelect(role.id)}
            >
              <div className="text-8xl mb-4">{role.emoji}</div>
              <h3 className="text-3xl font-semibold mb-2">{role.title}</h3>
            </Card>
          ))}
        </div>
      </main>

      <footer className="bg-white shadow-sm py-4 mt-6">
        <div className="container mx-auto flex justify-between px-6">
          <Button 
            variant="outline" 
            onClick={handleBack} 
            className="text-lg px-6 py-3"
          >
            Back
          </Button>
          <Button 
            onClick={handleNext} 
            disabled={!selectedRole} 
            className="text-lg px-6 py-3"
          >
            Next
          </Button>
        </div>
      </footer>
    </div>
  );
};

export default SelectRolePage;
