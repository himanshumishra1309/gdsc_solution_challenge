import { useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from "recharts";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";

// Function to map RPE value to description
const getRpeDescription = (rpe) => {
  if (rpe === 0) return "Rest";
  if (rpe >= 1 && rpe <= 2) return "Very Light";
  if (rpe >= 3 && rpe <= 4) return "Moderate";
  if (rpe >= 5 && rpe <= 6) return "Somewhat Hard";
  if (rpe >= 7 && rpe <= 8) return "Hard";
  if (rpe === 9) return "Very Hard";
  if (rpe === 10) return "Max Effort";
  return "Unknown";
};

// Sample performance data
const data = [
  { name: "Jan", speed: 4000, strength: 2400, endurance: 2400 },
  { name: "Feb", speed: 3000, strength: 1398, endurance: 2210 },
  { name: "Mar", speed: 2000, strength: 9800, endurance: 2290 },
  { name: "Apr", speed: 2780, strength: 3908, endurance: 2000 },
  { name: "May", speed: 1890, strength: 4800, endurance: 2181 },
  { name: "Jun", speed: 2390, strength: 3800, endurance: 2500 },
];

// Sample athlete data with Today's RPE
const athleteData = [
  { name: "Ravi Kumar", sport: "Kabaddi", speed: 4000, strength: 2400, endurance: 2300, rpe: 7 },
  { name: "Pooja Sharma", sport: "Cricket", speed: 3000, strength: 2200, endurance: 2400, rpe: 5 },
  { name: "Amit Singh", sport: "Hockey", speed: 2000, strength: 2100, endurance: 2000, rpe: 3 },
  { name: "Raj Singh", sport: "Football", speed: 2500, strength: 2300, endurance: 2100, rpe: 9 },
];

const PerformanceMonitoring = () => {
  const [selectedSport, setSelectedSport] = useState("All");
  const [selectedAthlete, setSelectedAthlete] = useState("All");
  const [selectedTimePeriod, setSelectedTimePeriod] = useState("All");

  // Filter
  const filteredAthleteData = athleteData.filter((athlete) => {
    const isSportMatch = selectedSport === "All" || athlete.sport === selectedSport;
    const isAthleteMatch = selectedAthlete === "All" || athlete.name === selectedAthlete;
    return isSportMatch && isAthleteMatch;
  });

  return (
    <Card>
      <CardHeader>
        <CardTitle>Performance Monitoring</CardTitle>
      </CardHeader>
      <CardContent>
        
        <div className="mb-4 flex space-x-4">
          {/* Sport Filter */}
          <Select onValueChange={setSelectedSport}>
            <SelectTrigger className="w-[200px]">
              <SelectValue placeholder="Filter by Sport" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="All">All Sports</SelectItem>
              <SelectItem value="Kabaddi">Kabaddi</SelectItem>
              <SelectItem value="Cricket">Cricket</SelectItem>
              <SelectItem value="Hockey">Hockey</SelectItem>
              <SelectItem value="Football">Football</SelectItem>
            </SelectContent>
          </Select>

          {/* Athlete Filter */}
          <Select onValueChange={setSelectedAthlete}>
            <SelectTrigger className="w-[200px]">
              <SelectValue placeholder="Filter by Athlete" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="All">All Athletes</SelectItem>
              {athleteData.map((athlete, idx) => (
                <SelectItem key={idx} value={athlete.name}>
                  {athlete.name}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>

          {/* Time Period Filter */}
          <Select onValueChange={setSelectedTimePeriod}>
            <SelectTrigger className="w-[200px]">
              <SelectValue placeholder="Filter by Time Period" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="All">All Time</SelectItem>
              <SelectItem value="Last 6 months">Last 6 months</SelectItem>
              <SelectItem value="Last 3 months">Last 3 months</SelectItem>
            </SelectContent>
          </Select>
        </div>

        {/* Performance Chart */}
        <ResponsiveContainer width="100%" height={400}>
          <LineChart data={data}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="name" />
            <YAxis />
            <Tooltip />
            <Legend />
            <Line type="monotone" dataKey="speed" stroke="#8884d8" />
            <Line type="monotone" dataKey="strength" stroke="#82ca9d" />
            <Line type="monotone" dataKey="endurance" stroke="#ffc658" />
          </LineChart>
        </ResponsiveContainer>

        {/* Progress Reports Table */}
        <div className="mt-6">
          <h3 className="text-lg font-semibold mb-4">Athlete Progress Reports</h3>
          <div className="overflow-x-auto">
            <table className="min-w-full table-auto">
              <thead>
                <tr>
                  <th className="px-4 py-2 border">Athlete</th>
                  <th className="px-4 py-2 border">Sport</th>
                  <th className="px-4 py-2 border">Speed</th>
                  <th className="px-4 py-2 border">Strength</th>
                  <th className="px-4 py-2 border">Endurance</th>
                  <th className="px-4 py-2 border">Today's RPE</th>
                </tr>
              </thead>
              <tbody>
                {filteredAthleteData.map((athlete, idx) => (
                  <tr key={idx}>
                    <td className="px-4 py-2 border">{athlete.name}</td>
                    <td className="px-4 py-2 border">{athlete.sport}</td>
                    <td className="px-4 py-2 border">{athlete.speed}</td>
                    <td className="px-4 py-2 border">{athlete.strength}</td>
                    <td className="px-4 py-2 border">{athlete.endurance}</td>
                    <td className="px-4 py-2 border font-semibold">
                      {athlete.rpe} - {getRpeDescription(athlete.rpe)}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </CardContent>
    </Card>
  );
};

export default PerformanceMonitoring;
