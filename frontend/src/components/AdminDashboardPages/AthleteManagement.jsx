import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { Select, SelectTrigger, SelectValue, SelectContent, SelectItem } from "@/components/ui/select";
import { Button } from "@/components/ui/button";

const athletes = [
  { id: 1, name: "Virat Sharma", sport: "Cricket", coach: "Ravi Kumar" },
  { id: 2, name: "Sunil Yadav", sport: "Football", coach: "Amit Mehra" },
  { id: 3, name: "Neeraj Sinha", sport: "Hockey", coach: "Rahul Desai" },
];

const sportsList = ["Cricket", "Football", "Hockey"];
const trainersList = ["Rahul Sharma", "Amit Verma", "Sandeep Rao"];

const AthleteManagement = () => {
  const navigate = useNavigate();
  const [selectedSport, setSelectedSport] = useState("All");
  const [selectedTrainer, setSelectedTrainer] = useState(trainersList[0]);
  const [filteredAthletes, setFilteredAthletes] = useState(athletes);

  // Filter athletes by sport
  const handleSportChange = (sport) => {
    setSelectedSport(sport);
    setFilteredAthletes(sport === "All" ? athletes : athletes.filter((a) => a.sport === sport));
  };

  // Navigate to Athlete Dashboard
  const handleViewProfile = (athleteName) => {
    navigate(`/athlete-dashboard/${athleteName}`);
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

      {/* Athlete List */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {filteredAthletes.map((athlete) => (
          <Card key={athlete.id}>
            <CardHeader>
              <CardTitle 
                className="cursor-pointer text-blue-600 hover:underline"
                onClick={() => handleViewProfile(athlete.name)} // Clicking Name
              >
                {athlete.name}
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p>🏅 Sport: {athlete.sport}</p>
              <p>🧑‍🏫 Coach: {athlete.coach}</p>
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
