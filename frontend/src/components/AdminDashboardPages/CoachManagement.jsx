import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { Select, SelectTrigger, SelectValue, SelectContent, SelectItem } from "@/components/ui/select";
import { Button } from "@/components/ui/button";

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

  // Filter coaches by sport
  const handleSportChange = (sport) => {
    setSelectedSport(sport);
    setFilteredCoaches(sport === "All" ? coaches : coaches.filter((coach) => coach.sport === sport));
  };

  // Navigate to Coach Dashboard
  const handleViewProfile = (coachName) => {
    navigate(`/coach-dashboard/${coachName}`);
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
