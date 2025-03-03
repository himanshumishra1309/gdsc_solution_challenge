import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { Select, SelectTrigger, SelectValue, SelectContent, SelectItem } from "@/components/ui/select";
import { Button } from "@/components/ui/button";
import { Dialog, DialogTrigger, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog";

const athletes = [
  { id: 1, name: "Virat Sharma", sport: "Cricket", coach: "Ravi Kumar", currentLevel: "Intermediate", primarySport: "Cricket", secondarySport: "Football", height: 175, weight: 70, bmi: 22.9, dominantHand: "Right", bloodGroup: "O+", allergies: "None", preExistingConditions: "None", school: "ABC School", grade: "10th", orgEmail: "virat@abc.com", orgWebsite: "www.abc.com" },
  { id: 2, name: "Sunil Yadav", sport: "Football", coach: "Amit Mehra", currentLevel: "Advanced", primarySport: "Football", secondarySport: "Cricket", height: 180, weight: 80, bmi: 24.7, dominantHand: "Left", bloodGroup: "A+", allergies: "Pollen", preExistingConditions: "Asthma", school: "XYZ School", grade: "12th", orgEmail: "sunil@xyz.com", orgWebsite: "www.xyz.com" },
  { id: 3, name: "Neeraj Sinha", sport: "Hockey", coach: "Rahul Desai", currentLevel: "Beginner", primarySport: "Hockey", secondarySport: "Football", height: 170, weight: 65, bmi: 22.5, dominantHand: "Right", bloodGroup: "B+", allergies: "None", preExistingConditions: "None", school: "LMN School", grade: "9th", orgEmail: "neeraj@lmn.com", orgWebsite: "www.lmn.com" },
];

const sportsList = ["Cricket", "Football", "Hockey"];
const trainersList = ["Ravi Kumar", "Amit Mehra", "Rahul Desai"];

const AthleteManagement = () => {
  const navigate = useNavigate();
  const [selectedSport, setSelectedSport] = useState("All");
  const [selectedTrainer, setSelectedTrainer] = useState(trainersList[0]);
  const [filteredAthletes, setFilteredAthletes] = useState(athletes);
  const [newAthlete, setNewAthlete] = useState({
    name: "",
    email: "",
    dateOfBirth: "",
    gender: "",
    phone: "",
    state: "",
    school: "",
    grade: "",
    primarySport: "",
    secondarySport: "",
    currentLevel: "",
    coach: selectedTrainer,
    height: "",
    weight: "",
    bmi: "",
    dominantHand: "",
    bloodGroup: "",
    allergies: "",
    preExistingConditions: "",
    orgEmail: "",
    orgWebsite: "",
  });

  // Filter athletes by sport
  const handleSportChange = (sport) => {
    setSelectedSport(sport);
    setFilteredAthletes(sport === "All" ? athletes : athletes.filter((a) => a.primarySport === sport || a.secondarySport === sport));
  };

  // Navigate to Athlete Dashboard
  const handleViewProfile = (athleteName) => {
    navigate(`/athlete-dashboard/${athleteName}`);
  };

  // Add new athlete
  const handleAddAthlete = () => {
    const newAthleteWithId = { ...newAthlete, id: filteredAthletes.length + 1 };
    setFilteredAthletes([...filteredAthletes, newAthleteWithId]);
    setNewAthlete({
      name: "",
      email: "",
      dateOfBirth: "",
      gender: "",
      phone: "",
      state: "",
      school: "",
      grade: "",
      primarySport: "",
      secondarySport: "",
      currentLevel: "",
      coach: selectedTrainer,
      height: "",
      weight: "",
      bmi: "",
      dominantHand: "",
      bloodGroup: "",
      allergies: "",
      preExistingConditions: "",
      orgEmail: "",
      orgWebsite: "",
    });
  };

  return (
    <div className="p-6 space-y-6">
      <h1 className="text-2xl font-bold">Athlete Management</h1>

      {/* Filter by Sport */}
      <Select value={selectedSport} onValueChange={handleSportChange}>
        <SelectTrigger className="w-full">
          <SelectValue placeholder="Select Sport">{selectedSport}</SelectValue>
        </SelectTrigger>
        <SelectContent>
          <SelectItem value="All">All</SelectItem>
          {sportsList.map((sport) => (
            <SelectItem key={sport} value={sport}>{sport}</SelectItem>
          ))}
        </SelectContent>
      </Select>

      {/* Assign Trainer */}
      <Select value={selectedTrainer} onValueChange={setSelectedTrainer}>
        <SelectTrigger className="w-full">
          <SelectValue placeholder="Select Trainer">{selectedTrainer}</SelectValue>
        </SelectTrigger>
        <SelectContent>
          {trainersList.map((trainer) => (
            <SelectItem key={trainer} value={trainer}>{trainer}</SelectItem>
          ))}
        </SelectContent>
      </Select>

      {/* Add New Athlete Button */}
      <Dialog>
        <DialogTrigger asChild>
          <Button className="mt-6">Register New Athlete</Button>
        </DialogTrigger>

        {/* Modal Content */}
        <DialogContent className="max-w-3xl p-8 rounded-lg bg-white shadow-lg overflow-y-auto max-h-[80vh]">
          <DialogHeader>
            <DialogTitle className="text-2xl font-semibold text-gray-800">Register New Athlete</DialogTitle>
          </DialogHeader>

          {/* Form Fields */}
          <div className="space-y-6">
            {/* Basic Information */}
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
              <input
                type="text"
                placeholder="Full Name"
                className="input p-4 text-lg"
                value={newAthlete.name}
                onChange={(e) => setNewAthlete({ ...newAthlete, name: e.target.value })}
              />
              <input
                type="email"
                placeholder="Email Address"
                className="input p-4 text-lg"
                value={newAthlete.email}
                onChange={(e) => setNewAthlete({ ...newAthlete, email: e.target.value })}
              />
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
              <input
                type="date"
                className="input p-4 text-lg"
                value={newAthlete.dateOfBirth}
                onChange={(e) => setNewAthlete({ ...newAthlete, dateOfBirth: e.target.value })}
              />
              <Select value={newAthlete.gender} onValueChange={(value) => setNewAthlete({ ...newAthlete, gender: value })}>
                <SelectTrigger className="w-full">
                  <SelectValue placeholder="Select Gender" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="Male">Male</SelectItem>
                  <SelectItem value="Female">Female</SelectItem>
                  <SelectItem value="Other">Other</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
              <input
                type="text"
                placeholder="Phone Number"
                className="input p-4 text-lg"
                value={newAthlete.phone}
                onChange={(e) => setNewAthlete({ ...newAthlete, phone: e.target.value })}
              />
              <input
                type="text"
                placeholder="State"
                className="input p-4 text-lg"
                value={newAthlete.state}
                onChange={(e) => setNewAthlete({ ...newAthlete, state: e.target.value })}
              />
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
              <input
                type="text"
                placeholder="School/College/Organization Name"
                className="input p-4 text-lg"
                value={newAthlete.school}
                onChange={(e) => setNewAthlete({ ...newAthlete, school: e.target.value })}
              />
              <input
                type="text"
                placeholder="Grade/Year"
                className="input p-4 text-lg"
                value={newAthlete.grade}
                onChange={(e) => setNewAthlete({ ...newAthlete, grade: e.target.value })}
              />
            </div>

            {/* Organization and ID Information */}
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
              <input
                type="text"
                placeholder="ID (if any)"
                className="input p-4 text-lg"
                value={newAthlete.id}
                onChange={(e) => setNewAthlete({ ...newAthlete, id: e.target.value })}
              />
              <input
                type="email"
                placeholder="Organization Email (if any)"
                className="input p-4 text-lg"
                value={newAthlete.orgEmail}
                onChange={(e) => setNewAthlete({ ...newAthlete, orgEmail: e.target.value })}
              />
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
              <input
                type="url"
                placeholder="Organization Website (if any)"
                className="input p-4 text-lg"
                value={newAthlete.orgWebsite}
                onChange={(e) => setNewAthlete({ ...newAthlete, orgWebsite: e.target.value })}
              />
            </div>

            {/* Physical Attributes */}
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
              <input
                type="number"
                placeholder="Height (cm)"
                className="input p-4 text-lg"
                value={newAthlete.height}
                onChange={(e) => setNewAthlete({ ...newAthlete, height: e.target.value })}
              />
              <input
                type="number"
                placeholder="Weight (kg)"
                className="input p-4 text-lg"
                value={newAthlete.weight}
                onChange={(e) => setNewAthlete({ ...newAthlete, weight: e.target.value })}
              />
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
              <input
                type="number"
                placeholder="BMI"
                className="input p-4 text-lg"
                value={newAthlete.bmi}
                onChange={(e) => setNewAthlete({ ...newAthlete, bmi: e.target.value })}
              />
              <Select value={newAthlete.dominantHand} onValueChange={(value) => setNewAthlete({ ...newAthlete, dominantHand: value })}>
                <SelectTrigger className="w-full">
                  <SelectValue placeholder="Dominant Hand" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="Left">Left</SelectItem>
                  <SelectItem value="Right">Right</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
              <input
                type="text"
                placeholder="Blood Group"
                className="input p-4 text-lg"
                value={newAthlete.bloodGroup}
                onChange={(e) => setNewAthlete({ ...newAthlete, bloodGroup: e.target.value })}
              />
              <input
                type="text"
                placeholder="Known Allergies"
                className="input p-4 text-lg"
                value={newAthlete.allergies}
                onChange={(e) => setNewAthlete({ ...newAthlete, allergies: e.target.value })}
              />
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
              <input
                type="text"
                placeholder="Pre-existing Conditions"
                className="input p-4 text-lg"
                value={newAthlete.preExistingConditions}
                onChange={(e) => setNewAthlete({ ...newAthlete, preExistingConditions: e.target.value })}
              />
            </div>
          </div>

          {/* Modal Footer with Action Button */}
          <DialogFooter className="mt-6">
            <Button className="w-full py-4" onClick={handleAddAthlete}>
              Register Athlete
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Athlete List */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {filteredAthletes.map((athlete) => (
          <Card key={athlete.id}>
            <CardHeader>
              <CardTitle
                className="cursor-pointer text-blue-600 hover:underline"
                onClick={() => handleViewProfile(athlete.name)}
              >
                {athlete.name}
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p>🏅 Primary Sport: {athlete.primarySport}</p>
              <p>⚽ Secondary Sport: {athlete.secondarySport}</p>
              <p>🧑‍🏫 Coach: {athlete.coach}</p>
              <p>📏 Height: {athlete.height} cm</p>
              <p>⚖️ Weight: {athlete.weight} kg</p>
              <Button className="mt-4" onClick={() => handleViewProfile(athlete.name)}>
                View Profile
              </Button>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
};

export default AthleteManagement;
