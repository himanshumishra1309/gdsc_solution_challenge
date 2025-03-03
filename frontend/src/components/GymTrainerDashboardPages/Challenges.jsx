import React, { useState } from "react";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";


const mockAthletes = [
  { id: 1, name: "Arjun Kumar", completedChallenges: [] },
  { id: 2, name: "Priya Gupta", completedChallenges: [] },
  { id: 3, name: "Vikram Reddy", completedChallenges: [] },
  { id: 4, name: "Neha Desai", completedChallenges: [] },
  { id: 5, name: "Saurabh Mehta", completedChallenges: [] },
  { id: 6, name: "Aarti Shah", completedChallenges: [] },
];


const mockChallenges = [
  { id: 1, challenge: "100m Sprint", time: 15 },
  { id: 2, challenge: "Push-ups", time: 5 },
  { id: 3, challenge: "Squats", time: 10 },
];

const Challenges = () => {
  const [challenge, setChallenge] = useState("");
  const [time, setTime] = useState("");
  const [challenges, setChallenges] = useState(mockChallenges); 
  const [athletes, setAthletes] = useState(mockAthletes); 

  const handleSubmit = (e) => {
    e.preventDefault();
    if (challenge && time) {
      setChallenges([
        ...challenges,
        { id: Date.now(), challenge, time: parseInt(time, 10) },
      ]);
      setChallenge("");
      setTime("");
    }
  };

 
  const handleChallengeCompletion = (athleteId, challengeId) => {
    setAthletes(athletes.map((athlete) => {
      if (athlete.id === athleteId) {
        if (!athlete.completedChallenges.includes(challengeId)) {
          athlete.completedChallenges.push(challengeId);
        }
      }
      return athlete;
    }));
  };

  return (
    <div className="min-h-screen bg-gray-50 flex flex-col items-center p-6 space-y-6">
      <h1 className="text-3xl font-bold text-blue-600">Athlete Challenges</h1>

      
      <Card className="w-full lg:w-3/4 xl:w-1/2 shadow-lg border-l-4 border-blue-500">
        <CardContent className="p-6">
          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-gray-700 text-sm font-bold mb-2">
                Challenge
              </label>
              <Input
                type="text"
                value={challenge}
                onChange={(e) => setChallenge(e.target.value)}
                placeholder="Enter challenge"
                required
              />
            </div>
            <div>
              <label className="block text-gray-700 text-sm font-bold mb-2">
                Time Limit (in minutes)
              </label>
              <Input
                type="number"
                value={time}
                onChange={(e) => setTime(e.target.value)}
                placeholder="Enter time limit"
                required
              />
            </div>
            <Button type="submit" className="bg-blue-500 w-full text-white">
              Add Challenge
            </Button>
          </form>
        </CardContent>
      </Card>

      
      <Card className="w-full lg:w-3/4 xl:w-1/2 shadow-lg border-l-4 border-green-500">
        <CardContent className="p-6">
          <h2 className="text-2xl font-semibold text-green-700">Current Challenges</h2>
          {challenges.length > 0 ? (
            <ul className="mt-4 space-y-2">
              {challenges.map((item) => (
                <li key={item.id} className="p-3 bg-green-100 rounded-lg shadow-sm">
                  <span className="font-semibold text-green-800">{item.challenge}</span> - {item.time} minutes

                  
                  <div className="mt-2">
                    <span className="font-semibold">Athletes who completed this challenge:</span>
                    <ul className="ml-4">
                      {athletes
                        .filter((athlete) => athlete.completedChallenges.includes(item.id))
                        .map((athlete) => (
                          <li key={athlete.id}>{athlete.name}</li>
                        ))}
                    </ul>
                  </div>

                  
                  <div className="mt-4">
                    <h3 className="text-sm font-semibold text-gray-700">Mark athlete as completed:</h3>
                    <select
                      className="mt-2 p-2 border rounded"
                      onChange={(e) => handleChallengeCompletion(Number(e.target.value), item.id)}
                    >
                      <option value="">Select Athlete</option>
                      {athletes.map((athlete) => (
                        <option key={athlete.id} value={athlete.id}>
                          {athlete.name}
                        </option>
                      ))}
                    </select>
                  </div>
                </li>
              ))}
            </ul>
          ) : (
            <p className="text-gray-500 mt-2">No challenges added yet.</p>
          )}
        </CardContent>
      </Card>
    </div>
  );
};

export default Challenges;
