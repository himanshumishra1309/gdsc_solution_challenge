import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Trash2, PlusCircle } from "lucide-react";

const playerPositions = {
  Cricket: ["Batsman", "Bowler", "All-rounder", "Wicketkeeper"],
  Kabaddi: ["Raider", "Defender", "All-rounder"],
  Hockey: ["Forward", "Midfielder", "Defender", "Goalkeeper"],
  Football: ["Forward", "Midfielder", "Defender", "Goalkeeper"],
};

const initialSportsTeams = {
  Cricket: [
    { name: "Virat Sharma", position: "Batsman" },
    { name: "Rohit Mehta", position: "Bowler" },
    { name: "Sachin Verma", position: "All-rounder" },
    { name: "Rahul Iyer", position: "Wicketkeeper" },
    { name: "Suresh Nair", position: "Batsman" },
    { name: "Manish Tiwari", position: "Bowler" },
    { name: "Hardik Rao", position: "All-rounder" },
    { name: "Jasprit Kulkarni", position: "Bowler" },
    { name: "Mohammed Yadav", position: "Bowler" },
    { name: "Bhuvaneshwar Pillai", position: "Batsman" },
    { name: "Ishan Joshi", position: "Wicketkeeper" },
  ],
  Kabaddi: [
    { name: "Ajay Rathi", position: "Raider" },
    { name: "Pawan Desai", position: "Defender" },
    { name: "Manjeet Chauhan", position: "Raider" },
    { name: "Sandeep Patil", position: "Defender" },
    { name: "Surjeet Nair", position: "All-rounder" },
    { name: "Rohit Reddy", position: "Raider" },
    { name: "Vikas Saxena", position: "Defender" },
  ],
  Hockey: [
    { name: "Dhyan Thakur", position: "Forward" },
    { name: "Sandeep Bhalla", position: "Midfielder" },
    { name: "Harman Chawla", position: "Defender" },
    { name: "Rupinder Nayak", position: "Defender" },
    { name: "Birendra Kapoor", position: "Goalkeeper" },
    { name: "Varun Ahuja", position: "Midfielder" },
    { name: "Akash Singh", position: "Forward" },
    { name: "Amit Khurana", position: "Defender" },
    { name: "Mandeep Joshi", position: "Midfielder" },
    { name: "Simranjit Arora", position: "Forward" },
    { name: "Lalit Bhasin", position: "Goalkeeper" },
  ],
  Football: [
    { name: "Sunil Nair", position: "Forward" },
    { name: "Gurpreet Reddy", position: "Goalkeeper" },
    { name: "Sandesh Malik", position: "Defender" },
    { name: "Anirudh Das", position: "Midfielder" },
    { name: "Brandon Menon", position: "Midfielder" },
    { name: "Sahal Fernandes", position: "Midfielder" },
    { name: "Udanta Kumar", position: "Forward" },
    { name: "Manvir Shah", position: "Forward" },
    { name: "Rahul Gupta", position: "Defender" },
    { name: "Jeakson Paul", position: "Midfielder" },
    { name: "Liston Pinto", position: "Forward" },
  ],
};

const TeamManagement = () => {
  const [sportsTeams, setSportsTeams] = useState(initialSportsTeams);
  const [selectedSport, setSelectedSport] = useState("Cricket");
  const [newAthlete, setNewAthlete] = useState("");
  const navigate = useNavigate();

  // Function to add a new athlete
  const handleAddAthlete = () => {
    if (newAthlete.trim() === "") return;
    setSportsTeams((prevTeams) => ({
      ...prevTeams,
      [selectedSport]: [
        ...prevTeams[selectedSport],
        { name: newAthlete, position: playerPositions[selectedSport][0] },
      ],
    }));
    setNewAthlete(""); 
  };

  // Function to remove an athlete
  const handleRemoveAthlete = (athleteName) => {
    setSportsTeams((prevTeams) => ({
      ...prevTeams,
      [selectedSport]: prevTeams[selectedSport].filter(
        (athlete) => athlete.name !== athleteName
      ),
    }));
  };

  return (
    <div className="scale-90">
      <Card className="bg-gray-100 p-2 rounded-lg shadow-lg">
        <CardHeader className="flex justify-between items-center">
          <CardTitle className="text-blue-700 text-xl font-bold">Team Management</CardTitle>
          <Select value={selectedSport} onValueChange={setSelectedSport}>
            <SelectTrigger className="w-[200px] bg-white text-black">
              <SelectValue placeholder="Select Sport" />
            </SelectTrigger>
            <SelectContent>
              {Object.keys(sportsTeams).map((sport) => (
                <SelectItem key={sport} value={sport}>
                  {sport}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </CardHeader>

        <CardContent>
          <div className="flex gap-2 mb-4">
            <Input
              type="text"
              placeholder="Enter Athlete Name"
              value={newAthlete}
              onChange={(e) => setNewAthlete(e.target.value)}
              className="flex-1"
            />
            <Button onClick={handleAddAthlete} className="flex items-center gap-1">
              <PlusCircle className="h-5 w-5" /> Add
            </Button>
          </div>

          <div className="space-y-4">
            {sportsTeams[selectedSport].map((athlete, index) => (
              <div
                key={index}
                className="flex justify-between items-center p-4 bg-white rounded-lg shadow-md cursor-pointer hover:bg-gray-200 transition"
              >
                <span
                  className="text-lg font-semibold text-green-600 cursor-pointer"
                  onClick={() => navigate(`/athlete-dashboard/${athlete.name}`)}
                >
                  {athlete.name} ({athlete.position})
                </span>
                <div className="flex gap-2">
                  <Button size="sm" onClick={() => navigate(`/athlete-dashboard/${athlete.name}`)}>
                    View Profile
                  </Button>
                  <Button size="sm" variant="destructive" onClick={() => handleRemoveAthlete(athlete.name)}>
                    <Trash2 className="h-5 w-5" />
                  </Button>
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>
    </div>
  );
};

export default TeamManagement;
