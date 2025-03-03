import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { Select, SelectTrigger, SelectValue, SelectContent, SelectItem } from "@/components/ui/select";
import { Button } from "@/components/ui/button";
import { Dialog, DialogTrigger, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog"; // For Modal

const coaches = [
  { id: 1, name: "Ravi Kumar", sport: "Cricket", players: 10 },
  { id: 2, name: "Amit Mehra", sport: "Football", players: 8 },
  { id: 3, name: "Rahul Desai", sport: "Hockey", players: 12 },
];

const sportsList = ["All", "Cricket", "Football", "Hockey"];

const CoachManagement = () => {
  const navigate = useNavigate();
  const [selectedSport, setSelectedSport] = useState("All");
  const [filteredCoaches, setFilteredCoaches] = useState(coaches);
  const [newCoach, setNewCoach] = useState({
    name: "",
    email: "",
    dateOfBirth: "",
    age: "",
    gender: "",
    state: "",
    phone: "",
    yearsOfExperience: "",
    certificationsAndLicenses: "",
    previousOrganization: "",
  });

  // Filter coaches by sport
  const handleSportChange = (sport) => {
    setSelectedSport(sport);
    setFilteredCoaches(sport === "All" ? coaches : coaches.filter((coach) => coach.sport === sport));
  };

  
  const handleViewProfile = (coachName) => {
    navigate(`/coach-dashboard/${coachName}`);
  };

  // Add new coach
  const handleAddCoach = () => {
    setFilteredCoaches([...filteredCoaches, { ...newCoach, id: filteredCoaches.length + 1, sport: selectedSport }]);
    setNewCoach({
      name: "",
      email: "",
      dateOfBirth: "",
      age: "",
      gender: "",
      state: "",
      phone: "",
      yearsOfExperience: "",
      certificationsAndLicenses: "",
      previousOrganization: "",
    });
  };

  return (
    <div className="p-6 space-y-6">
      <h1 className="text-2xl font-bold">Coach Management</h1>

      {/* Filter by Sport */}
      <Select value={selectedSport} onValueChange={handleSportChange}>
        <SelectTrigger className="w-full">
          <SelectValue>{selectedSport}</SelectValue>
        </SelectTrigger>
        <SelectContent>
          {sportsList.map((sport) => (
            <SelectItem key={sport} value={sport}>{sport}</SelectItem>
          ))}
        </SelectContent>
      </Select>

      {/* Add New Coach Button */}
      <Dialog>
        <DialogTrigger asChild>
          <Button className="mt-6">Register New Coach</Button>
        </DialogTrigger>

        {/* Modal Content */}
        <DialogContent className="max-w-3xl p-8 rounded-lg bg-white shadow-lg">
          <DialogHeader>
            <DialogTitle className="text-2xl font-semibold text-gray-800">Register New Coach</DialogTitle>
          </DialogHeader>

          {/* Form Fields */}
          <div className="space-y-6">
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
              <input
                type="text"
                placeholder="Full Name"
                className="input p-4 text-lg"
                value={newCoach.name}
                onChange={(e) => setNewCoach({ ...newCoach, name: e.target.value })}
              />
              <input
                type="email"
                placeholder="Email Address"
                className="input p-4 text-lg"
                value={newCoach.email}
                onChange={(e) => setNewCoach({ ...newCoach, email: e.target.value })}
              />
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
              <input
                type="date"
                className="input p-4 text-lg"
                value={newCoach.dateOfBirth}
                onChange={(e) => setNewCoach({ ...newCoach, dateOfBirth: e.target.value })}
              />
              <input
                type="number"
                placeholder="Age"
                className="input p-4 text-lg"
                value={newCoach.age}
                onChange={(e) => setNewCoach({ ...newCoach, age: e.target.value })}
              />
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
              <Select value={newCoach.gender} onValueChange={(value) => setNewCoach({ ...newCoach, gender: value })}>
                <SelectTrigger className="w-full">
                  <SelectValue placeholder="Select Gender" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="Male">Male</SelectItem>
                  <SelectItem value="Female">Female</SelectItem>
                  <SelectItem value="Other">Other</SelectItem>
                </SelectContent>
              </Select>

              <input
                type="text"
                placeholder="State"
                className="input p-4 text-lg"
                value={newCoach.state}
                onChange={(e) => setNewCoach({ ...newCoach, state: e.target.value })}
              />
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
              <input
                type="text"
                placeholder="Phone Number"
                className="input p-4 text-lg"
                value={newCoach.phone}
                onChange={(e) => setNewCoach({ ...newCoach, phone: e.target.value })}
              />
              <input
                type="number"
                placeholder="Years of Experience"
                className="input p-4 text-lg"
                value={newCoach.yearsOfExperience}
                onChange={(e) => setNewCoach({ ...newCoach, yearsOfExperience: e.target.value })}
              />
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
              <input
                type="text"
                placeholder="Certifications & Licenses"
                className="input p-4 text-lg"
                value={newCoach.certificationsAndLicenses}
                onChange={(e) => setNewCoach({ ...newCoach, certificationsAndLicenses: e.target.value })}
              />
              <input
                type="text"
                placeholder="Previous Organization Worked With"
                className="input p-4 text-lg"
                value={newCoach.previousOrganization}
                onChange={(e) => setNewCoach({ ...newCoach, previousOrganization: e.target.value })}
              />
            </div>
          </div>

          
          <DialogFooter className="mt-6">
            <Button className="w-full py-4" onClick={handleAddCoach}>
              Register Coach
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Coach List */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {filteredCoaches.map((coach) => (
          <Card key={coach.id}>
            <CardHeader>
              <CardTitle
                className="cursor-pointer text-blue-600 hover:underline"
                onClick={() => handleViewProfile(coach.name)}
              >
                {coach.name}
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p>🏅 Sport: {coach.sport}</p>
              <p>👥 Players: {coach.players}</p>
              <Button className="mt-4" onClick={() => handleViewProfile(coach.name)}>
                View Profile
              </Button>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
};

export default CoachManagement;
