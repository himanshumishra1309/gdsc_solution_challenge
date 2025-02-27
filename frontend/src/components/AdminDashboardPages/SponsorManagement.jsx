import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { Select, SelectTrigger, SelectValue, SelectContent, SelectItem } from "@/components/ui/select";
import { Button } from "@/components/ui/button";

const sponsors = [
  { id: 1, name: "Nike", contact: "nike@example.com", sport: "Cricket" },
  { id: 2, name: "Adidas", contact: "adidas@example.com", sport: "Football" },
  { id: 3, name: "Puma", contact: "puma@example.com", sport: "Hockey" },
];

const sportsList = ["All", "Cricket", "Football", "Hockey"];

const SponsorManagement = () => {
  const navigate = useNavigate();
  const [selectedSport, setSelectedSport] = useState("All");
  const [filteredSponsors, setFilteredSponsors] = useState(sponsors);

  const handleSportChange = (sport) => {
    setSelectedSport(sport);
    setFilteredSponsors(sport === "All" ? sponsors : sponsors.filter((sponsor) => sponsor.sport === sport));
  };

  // Navigate to Dynamic Sponsor Dashboard
  const handleViewDashboard = (sponsorName) => {
    navigate(`/sponsor-dashboard/${sponsorName}`);
  };

  return (
    <div className="p-6 space-y-6">
      <h1 className="text-2xl font-bold">Sponsorship Management</h1>

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

      {/* Sponsor List */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {filteredSponsors.map((sponsor) => (
          <Card key={sponsor.id}>
            <CardHeader>
              <CardTitle>{sponsor.name}</CardTitle>
            </CardHeader>
            <CardContent>
              <p>📧 Contact: {sponsor.contact}</p>
              <Button className="mt-4" onClick={() => handleViewDashboard(sponsor.name)}>
                View Dashboard
              </Button>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
};

export default SponsorManagement;
