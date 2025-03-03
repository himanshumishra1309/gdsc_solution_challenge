import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Trash2, PlusCircle } from "lucide-react";

const initialSportsTeams = {
  Cricket: [
    "Virat Sharma", "Rohit Mehta", "Sachin Verma", "Rahul Iyer", "Suresh Nair",
    "Manish Tiwari", "Hardik Rao", "Jasprit Kulkarni", "Mohammed Yadav", "Bhuvaneshwar Pillai", "Ishan Joshi"
  ],
  Kabaddi: [
    "Ajay Rathi", "Pawan Desai", "Manjeet Chauhan", "Sandeep Patil", "Surjeet Nair",
    "Rohit Reddy", "Vikas Saxena"
  ],
  Hockey: [
    "Dhyan Thakur", "Sandeep Bhalla", "Harman Chawla", "Rupinder Nayak", "Birendra Kapoor",
    "Varun Ahuja", "Akash Singh", "Amit Khurana", "Mandeep Joshi", "Simranjit Arora", "Lalit Bhasin"
  ],
  Football: [
    "Sunil Nair", "Gurpreet Reddy", "Sandesh Malik", "Anirudh Das", "Brandon Menon",
    "Sahal Fernandes", "Udanta Kumar", "Manvir Shah", "Rahul Gupta", "Jeakson Paul", "Liston Pinto"
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
      [selectedSport]: [...prevTeams[selectedSport], newAthlete],
    }));
    setNewAthlete(""); 
  };

  
  const handleRemoveAthlete = (athlete) => {
    setSportsTeams((prevTeams) => ({
      ...prevTeams,
      [selectedSport]: prevTeams[selectedSport].filter((a) => a !== athlete),
    }));
  };

  return (
    <Card className="bg-gray-100 p-6 rounded-lg shadow-lg">
      <CardHeader className="flex justify-between items-center">
        <CardTitle className="text-blue-700 text-xl font-bold">Team Management</CardTitle>
        <Select value={selectedSport} onValueChange={setSelectedSport}>
          <SelectTrigger className="w-[200px] bg-white text-black">
            <SelectValue placeholder="Select Sport" />
          </SelectTrigger>
          <SelectContent>
            {Object.keys(sportsTeams).map((sport) => (
              <SelectItem key={sport} value={sport}>{sport}</SelectItem>
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
                onClick={() => navigate(`/athlete-dashboard/${athlete}`)}
              >
                {athlete}
              </span>
              <div className="flex gap-2">
                <Button size="sm" onClick={() => navigate(`/athlete-dashboard/${athlete}`)}>
                  View Profile
                </Button>
                <Button size="sm" variant="destructive" onClick={() => handleRemoveAthlete(athlete)}>
                  <Trash2 className="h-5 w-5" />
                </Button>
              </div>
            </div>
          ))}
        </div>
      </CardContent>
    </Card>
  );
};

export default TeamManagement;
