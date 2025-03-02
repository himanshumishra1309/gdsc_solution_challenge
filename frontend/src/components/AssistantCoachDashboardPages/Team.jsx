import { useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Input } from "@/components/ui/input";

const Team = () => {
  const [teams, setTeams] = useState([
    { id: 1, name: "Team A", sport: "Kabaddi", members: [{ name: "Ravi Kumar", performance: "Excellent" }], gymTrainer: "Coach Raj" },
    { id: 2, name: "Team B", sport: "Cricket", members: [{ name: "Pooja Sharma", performance: "Good" }], gymTrainer: "Coach Ananya" },
    { id: 3, name: "Team C", sport: "Hockey", members: [{ name: "Amit Singh", performance: "Average" }], gymTrainer: "Coach Vikram" },
    { id: 4, name: "Team D", sport: "Football", members: [{ name: "Sanjay Gupta", performance: "Excellent" }], gymTrainer: "Coach Raj" },
  ]);
  const [selectedTeam, setSelectedTeam] = useState(null);
  const [newAthlete, setNewAthlete] = useState("");
  const [newPerformance, setNewPerformance] = useState("");
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedGymTrainer, setSelectedGymTrainer] = useState("Coach Raj"); // Assuming assistant coach is "Coach Raj"

  const gymTrainers = ["Coach Raj", "Coach Ananya", "Coach Vikram"];

  const addAthlete = (teamId) => {
    if (!newAthlete || !newPerformance) return;
    setTeams((prevTeams) =>
      prevTeams.map((team) =>
        team.id === teamId ? { ...team, members: [...team.members, { name: newAthlete, performance: newPerformance }] } : team
      )
    );
    setNewAthlete("");
    setNewPerformance("");
  };

  const removeAthlete = (teamId, memberIndex) => {
    setTeams((prevTeams) =>
      prevTeams.map((team) =>
        team.id === teamId ? { ...team, members: team.members.filter((_, idx) => idx !== memberIndex) } : team
      )
    );
  };

  
  const filteredTeams = teams
    .filter((team) => {
      const matchesSearchQuery =
        team.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
        team.sport.toLowerCase().includes(searchQuery.toLowerCase()) ||
        team.members.some((member) => member.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
          member.performance.toLowerCase().includes(searchQuery.toLowerCase()));

      const matchesGymTrainerFilter =
        selectedGymTrainer === "All" || team.gymTrainer === selectedGymTrainer;

      return matchesSearchQuery && matchesGymTrainerFilter;
    })
    .filter((team) => team.gymTrainer === selectedGymTrainer); 

  return (
    <Card className="bg-gray-100 p-6 rounded-lg shadow-lg">
      <CardHeader>
        <CardTitle className="text-blue-700 text-xl font-bold">Team Management</CardTitle>
      </CardHeader>
      <CardContent>
        
        <div className="flex justify-between mb-4">
          <div className="flex space-x-2">
            <Input
              placeholder="Search by name, sport, or performance"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
            />
            <Select onValueChange={setSelectedGymTrainer}>
              <SelectTrigger className="w-[200px]">
                <SelectValue placeholder="Filter by Gym Trainer" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="All">All Trainers</SelectItem>
                {gymTrainers.map((trainer, index) => (
                  <SelectItem key={index} value={trainer}>{trainer}</SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
        </div>

       
        <div className="space-y-4">
          {filteredTeams.map((team) => (
            <div key={team.id} className="border p-4 rounded-lg shadow-md bg-white">
              <div className="flex justify-between items-center">
                <h2
                  className="text-lg font-semibold text-green-600 cursor-pointer"
                  onClick={() => setSelectedTeam(selectedTeam === team.id ? null : team.id)}
                >
                  {team.name} ({team.sport})
                </h2>
                
                <span className="text-sm text-gray-600">Assigned Gym Trainer: {team.gymTrainer}</span>
              </div>
              {selectedTeam === team.id && (
                <div className="mt-4">
                  <Table>
                    <TableHeader>
                      <TableRow>
                        <TableHead>Team Members</TableHead>
                        <TableHead>Performance</TableHead>
                        <TableHead>Actions</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {team.members.map((member, idx) => (
                        <TableRow key={idx}>
                          <TableCell>{member.name}</TableCell>
                          <TableCell>{member.performance}</TableCell>
                          <TableCell>
                            <Button variant="destructive" size="sm" onClick={() => removeAthlete(team.id, idx)}>
                              Remove
                            </Button>
                          </TableCell>
                        </TableRow>
                      ))}
                    </TableBody>
                  </Table>
                  <div className="mt-4 flex space-x-2">
                    <Input
                      placeholder="Athlete Name"
                      value={newAthlete}
                      onChange={(e) => setNewAthlete(e.target.value)}
                    />
                    <Input
                      placeholder="Performance"
                      value={newPerformance}
                      onChange={(e) => setNewPerformance(e.target.value)}
                    />
                    <Button onClick={() => addAthlete(team.id)}>Add</Button>
                  </div>
                </div>
              )}
            </div>
          ))}
        </div>
      </CardContent>
    </Card>
  );
};

export default Team;
