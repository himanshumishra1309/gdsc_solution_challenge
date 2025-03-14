import React, { useState, useEffect } from "react";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { Select, SelectTrigger, SelectValue, SelectContent, SelectItem } from "@/components/ui/select";
import axios from "axios";

const sportsList = ["All", "Cricket", "Football", "Badminton", "Basketball", "Tennis", "Hockey", "Other"];

const ViewCoaches = () => {
  const [coaches, setCoaches] = useState([]);
  const [selectedSport, setSelectedSport] = useState("All");
  const [filteredCoaches, setFilteredCoaches] = useState([]);

  useEffect(() => {
    fetchCoaches();
  }, []);

  const fetchCoaches = async () => {
    try {
      // Simulated backend data
      const sampleCoaches = [
        { id: 1, name: "Rahul Sharma", email: "rahul@example.com", sport: "Cricket", experience: 10 },
        { id: 2, name: "Amit Verma", email: "amit@example.com", sport: "Football", experience: 8 },
        { id: 3, name: "Neha Gupta", email: "neha@example.com", sport: "Badminton", experience: 5 },
      ];
      setCoaches(sampleCoaches);
      setFilteredCoaches(sampleCoaches);
    } catch (error) {
      console.error("Error fetching coaches:", error);
    }
  };

  const handleSportChange = (sport) => {
    setSelectedSport(sport);
    setFilteredCoaches(sport === "All" ? coaches : coaches.filter(coach => coach.sport === sport));
  };

  return (
    <div className="p-6 space-y-6">
      <h1 className="text-2xl font-bold">Coach Management</h1>

      {/* Filter by Sport */}
      <div className="w-64">
        <Select value={selectedSport} onValueChange={handleSportChange}>
          <SelectTrigger>
            <SelectValue>{selectedSport}</SelectValue>
          </SelectTrigger>
          <SelectContent>
            {sportsList.map((sport) => (
              <SelectItem key={sport} value={sport}>{sport}</SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>

      {/* Coach Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {filteredCoaches.map((coach) => (
          <Card key={coach.id} className="p-4">
            <CardHeader>
              <CardTitle>{coach.name}</CardTitle>
            </CardHeader>
            <CardContent>
              <p><strong>Email:</strong> {coach.email}</p>
              <p><strong>Sport:</strong> {coach.sport}</p>
              <p><strong>Experience:</strong> {coach.experience} years</p>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
};

export default ViewCoaches;