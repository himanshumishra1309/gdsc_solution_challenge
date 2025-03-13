import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";

const athletes = [
  { name: "Rahul Sharma", sport: "Cricket", age: 22, location: "Mumbai", organization: "Mumbai Warriors" },
  { name: "Priya Verma", sport: "Badminton", age: 19, location: "Bangalore", organization: "Indian Smashers Academy" },
  { name: "Amit Patel", sport: "Football", age: 24, location: "Kolkata", organization: "Bengal Tigers FC" },
  { name: "Sneha Iyer", sport: "Tennis", age: 21, location: "Chennai", organization: "Chennai Tennis Club" },
  { name: "Vikram Singh", sport: "Hockey", age: 26, location: "Delhi", organization: "Delhi Lions" },
];

const organizations = [
  { name: "Mumbai Warriors", location: "Mumbai" },
  { name: "Indian Smashers Academy", location: "Bangalore" },
  { name: "Bengal Tigers FC", location: "Kolkata" },
  { name: "Chennai Tennis Club", location: "Chennai" },
  { name: "Delhi Lions", location: "Delhi" },
];

const sportsList = ["Cricket", "Badminton", "Football", "Tennis", "Hockey"];

const FindAthlete = () => {
  const [selectedSport, setSelectedSport] = useState("all");
  const [selectedCategory, setSelectedCategory] = useState("athletes"); // New state to toggle between 'athletes' and 'organizations'
  const [searchTerm, setSearchTerm] = useState("");
  const navigate = useNavigate();

  const filteredAthletes = athletes.filter(
    (athlete) =>
      (selectedSport === "all" || athlete.sport === selectedSport) &&
      (athlete.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        athlete.sport.toLowerCase().includes(searchTerm.toLowerCase()) ||
        athlete.organization.toLowerCase().includes(searchTerm.toLowerCase()))
  );

  const filteredOrganizations = organizations.filter(
    (organization) =>
      organization.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      organization.location.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const handleSponsorClick = (athlete) => {
    const dashboardPath = `/athlete-dashboard/${athlete.name.replace(/\s+/g, " ").toLowerCase()}`;
    navigate(dashboardPath);
  };

  const handleOrganizationClick = (organization) => {
    const dashboardPath = `/organization-dashboard/${organization.name.replace(/\s+/g, "-").toLowerCase()}`;
    navigate(dashboardPath);
  };

  return (
    <div className="container mx-auto py-1 px-1">
      <h1 className="text-2xl font-bold text-center mb-6">Find Athletes & Organizations to Sponsor</h1>

      <div className="flex flex-col md:flex-row gap-4 items-center justify-center mb-6">
        {/* Category Select: Athletes or Organizations */}
        <Select onValueChange={setSelectedCategory} value={selectedCategory}>
          <SelectTrigger className="w-[200px]">
            <SelectValue placeholder="Filter by Category" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="athletes">Athletes</SelectItem>
            <SelectItem value="organizations">Organizations</SelectItem>
          </SelectContent>
        </Select>

        {/* Sport Select */}
        {selectedCategory === "athletes" && (
          <Select onValueChange={setSelectedSport} value={selectedSport}>
            <SelectTrigger className="w-[200px]">
              <SelectValue placeholder="Filter by Sport" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Sports</SelectItem>
              {sportsList.map((sport) => (
                <SelectItem key={sport} value={sport}>
                  {sport}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        )}

        {/* Search Input */}
        <Input
          type="text"
          placeholder="Search by Name, Sport, or Organization"
          className="w-[300px]"
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
        />
      </div>

      {/* Display Results */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {selectedCategory === "athletes" && filteredAthletes.length > 0 ? (
          filteredAthletes.map((athlete, index) => (
            <Card key={index} className="shadow-lg p-5">
              <CardHeader>
                <CardTitle className="text-xl">{athlete.name}</CardTitle>
              </CardHeader>
              <CardContent>
                <p><strong>Sport:</strong> {athlete.sport}</p>
                <p><strong>Age:</strong> {athlete.age}</p>
                <p><strong>Location:</strong> {athlete.location}</p>
                <p><strong>Organization:</strong> {athlete.organization}</p>
                <Button className="mt-4 w-full" onClick={() => handleSponsorClick(athlete)}>Sponsor</Button>
              </CardContent>
            </Card>
          ))
        ) : selectedCategory === "athletes" && filteredAthletes.length === 0 ? (
          <p className="text-center text-gray-500 col-span-3">No matching athletes found.</p>
        ) : selectedCategory === "organizations" && filteredOrganizations.length > 0 ? (
          filteredOrganizations.map((organization, index) => (
            <Card key={index} className="shadow-lg p-4">
              <CardHeader>
                <CardTitle className="text-xl">{organization.name}</CardTitle>
              </CardHeader>
              <CardContent>
                <p><strong>Location:</strong> {organization.location}</p>
                <Button className="mt-4 w-full" onClick={() => handleOrganizationClick(organization)}>Visit Organization</Button>
              </CardContent>
            </Card>
          ))
        ) : selectedCategory === "organizations" && filteredOrganizations.length === 0 ? (
          <p className="text-center text-gray-500 col-span-3">No matching organizations found.</p>
        ) : null}
      </div>
    </div>
  );
};

export default FindAthlete;
