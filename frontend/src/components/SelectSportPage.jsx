import React, { useState, useEffect } from "react";
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { useNavigate } from "react-router-dom";

const sportsList = [
  { id: 1, name: "Football", icon: "⚽" },
  { id: 2, name: "Basketball", icon: "🏀" },
  { id: 3, name: "Tennis", icon: "🎾" },
  { id: 4, name: "Cricket", icon: "🏏" },
  { id: 5, name: "Swimming", icon: "🏊" },
  { id: 6, name: "Hockey", icon: "🏑" },
  { id: 7, name: "Volleyball", icon: "🏐" },
  { id: 8, name: "Boxing", icon: "🥊" },
  { id: 9, name: "Cycling", icon: "🚴" },
  { id: 10, name: "Golf", icon: "⛳" },
  { id: 11, name: "Badminton", icon: "🏸" },
  { id: 12, name: "Athletics", icon: "👟" },
];

const SelectSportsPage = () => {
  const [selectedSport, setSelectedSport] = useState(null);
  const [searchQuery, setSearchQuery] = useState("");
  const [progress, setProgress] = useState(33);

  const navigate = useNavigate();

  useEffect(() => {
    if (selectedSport) {
      setProgress(66);
    } else {
      setProgress(33);
    }
  }, [selectedSport]);

  const handleSportSelect = (sportId) => {
    setSelectedSport(sportId === selectedSport ? null : sportId);
  };

  const filteredSports = sportsList.filter((sport) =>
    sport.name.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const handleBack = () => {
    navigate("/sign-up");
  };

  const handleNext = () => {
    navigate("/select-role");
  };

  return (
    <div className="min-h-screen bg-gray-100 p-6 flex items-center justify-center">
      <div className="w-full max-w-4xl">
        <div className="mb-4">
          <div className="text-lg font-medium mb-2">Step Progress</div>
          <div className="relative pt-1">
            <div className="flex mb-2 items-center justify-between">
              <span className="text-xs font-medium">Sign Up</span>
              <span className="text-xs font-medium">Select Sports</span>
              <span className="text-xs font-medium">Profile</span>
            </div>
            <div className="flex mb-2">
              <div
                className="h-2 bg-green-500 rounded-full"
                style={{ width: `${progress}%` }}
              ></div>
            </div>
          </div>
        </div>

        <Card>
          <CardHeader>
            <CardTitle className="text-2xl font-bold">Select Your Sports</CardTitle>
            <CardDescription>Choose the sport you are interested in.</CardDescription>
          </CardHeader>
          <CardContent>
            <Input
              type="text"
              placeholder="Search for a sport..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="mb-6"
            />

            <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
              {filteredSports.length > 0 ? (
                filteredSports.map((sport) => (
                  <Card
                    key={sport.id}
                    className={`flex flex-col items-center p-4 cursor-pointer transition-all ${
                      selectedSport === sport.id
                        ? "bg-blue-50 border-blue-500"
                        : "bg-white border-gray-200 hover:bg-gray-50"
                    }`}
                    onClick={() => handleSportSelect(sport.id)}
                  >
                    <div className="text-4xl mb-2">{sport.icon}</div>
                    <div className="text-lg font-medium">{sport.name}</div>
                  </Card>
                ))
              ) : (
                <div className="col-span-full text-center text-gray-500">
                  No sports found.
                </div>
              )}
            </div>

            <div className="mt-8 flex justify-between">
              <Button variant="outline" onClick={handleBack}>
                Back
              </Button>
              <Button onClick={handleNext} disabled={!selectedSport}>
                Next
              </Button>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
};

export default SelectSportsPage;
