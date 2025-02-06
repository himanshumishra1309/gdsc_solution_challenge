import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from "recharts";
import { useState } from "react";

const athleteData = [
  { name: "Aarav", organization: "ProFit India", sport: "Cricket", timePeriod: "Q1", bio: "A seasoned cricketer with multiple national titles.", color: "#FF5733", performance: [
    { month: "Jan", score: 85 },
    { month: "Feb", score: 90 },
    { month: "Mar", score: 88 },
    { month: "Apr", score: 92 },
  ] },
  { name: "Neha", organization: "Elite Athletes", sport: "Badminton", timePeriod: "Q1", bio: "An emerging star in badminton with international experience.", color: "#33FF57", performance: [
    { month: "Jan", score: 78 },
    { month: "Feb", score: 82 },
    { month: "Mar", score: 85 },
    { month: "Apr", score: 87 },
  ] }
];

const ViewMetrics = () => {
  const [search, setSearch] = useState("");
  const [filterSport, setFilterSport] = useState("");
  const [filterTimePeriod, setFilterTimePeriod] = useState("");

  const filteredAthletes = athleteData.filter(athlete => 
    (search === "" || athlete.name.toLowerCase().includes(search.toLowerCase())) &&
    (filterSport === "" || athlete.sport === filterSport) &&
    (filterTimePeriod === "" || athlete.timePeriod === filterTimePeriod)
  );

  return (
    <div className="p-6 space-y-6">
      <h1 className="text-2xl font-bold">Sponsored Athletes Metrics</h1>
      <div className="flex space-x-4">
        <Input placeholder="Search Athlete" value={search} onChange={(e) => setSearch(e.target.value)} />
        <Select onValueChange={setFilterSport}>
          <SelectTrigger><SelectValue placeholder="Filter by Sport" /></SelectTrigger>
          <SelectContent>
            <SelectItem value="Cricket">Cricket</SelectItem>
            <SelectItem value="Badminton">Badminton</SelectItem>
          </SelectContent>
        </Select>
        <Select onValueChange={setFilterTimePeriod}>
          <SelectTrigger><SelectValue placeholder="Filter by Time Period" /></SelectTrigger>
          <SelectContent>
            <SelectItem value="Q1">Q1</SelectItem>
            <SelectItem value="Q2">Q2</SelectItem>
          </SelectContent>
        </Select>
      </div>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {filteredAthletes.map((athlete) => (
          <Card key={athlete.name} className="border-l-4" style={{ borderColor: athlete.color }}>
            <CardHeader>
              <CardTitle>{athlete.name} - {athlete.organization}</CardTitle>
              <p className="text-gray-500">{athlete.sport} | {athlete.bio}</p>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={300}>
                <LineChart data={athlete.performance}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="month" />
                  <YAxis />
                  <Tooltip />
                  <Legend />
                  <Line type="monotone" dataKey="score" stroke={athlete.color} strokeWidth={2} />
                </LineChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
};

export default ViewMetrics;
