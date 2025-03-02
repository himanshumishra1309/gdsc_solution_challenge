import React, { useState } from "react";
import { format, subWeeks } from "date-fns";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";



const athletes = [
  { id: 1, name: "Aarav Sharma" },
  { id: 2, name: "Neha Verma" },
  { id: 3, name: "Rohan Iyer" },
  { id: 4, name: "Priya Menon" },
];

function RPEManagement() {
  const [rpeData, setRpeData] = useState({});
  const [newRpe, setNewRpe] = useState({});
  const [filterAthlete, setFilterAthlete] = useState("");
  const [filterDate, setFilterDate] = useState("");

  const handleRpeChange = (id, value) => {
    setNewRpe((prev) => ({ ...prev, [id]: value }));
  };

  const saveRpe = (id) => {
    if (!newRpe[id]) return;

    setRpeData((prev) => ({
      ...prev,
      [id]: [...(prev[id] || []), { value: newRpe[id], date: format(new Date(), "yyyy-MM-dd") }],
    }));

    setNewRpe((prev) => ({ ...prev, [id]: "" }));
  };

  const weeklyTrends = athletes.map((athlete) => {
    const records = rpeData[athlete.id] || [];
    return { name: athlete.name, avgRPE: getAverage(records, new Date()) };
  });

  function getAverage(records, date) {
    const filtered = records.filter((r) => r.date >= format(subWeeks(date, 1), "yyyy-MM-dd"));
    if (filtered.length === 0) return 0;
    return filtered.reduce((sum, r) => sum + Number(r.value), 0) / filtered.length;
  }

  return (
    <div className="p-6 space-y-6 bg-gray-100 text-gray-900">
      <h1 className="text-3xl font-bold text-purple-600">RPE Management</h1>

      
      <Card className="bg-white shadow-lg border-l-4 border-purple-500">
        <CardContent className="p-4">
          <h2 className="text-lg font-semibold mb-4 text-purple-700">Update RPE Values</h2>
          {athletes.map((athlete) => (
            <div key={athlete.id} className="flex items-center space-x-4 mb-3">
              <span className="text-gray-700 font-medium w-40">{athlete.name}</span>
              <Input
                type="number"
                min="1"
                max="10"
                value={newRpe[athlete.id] || ""}
                onChange={(e) => handleRpeChange(athlete.id, e.target.value)}
                className="border-purple-400 w-24"
                placeholder="RP (1-10)"
              />
              <Button className="bg-purple-500 text-white" onClick={() => saveRpe(athlete.id)}>
                Save
              </Button>
            </div>
          ))}
        </CardContent>
      </Card>

      
      <Card className="bg-white shadow-lg border-l-4 border-blue-500">
        <CardContent className="p-4">
          <h2 className="text-lg font-semibold mb-4 text-blue-700">Filters</h2>
          <div className="flex space-x-4">
            <select
              onChange={(e) => setFilterAthlete(e.target.value)}
              className="border p-2 rounded"
            >
              <option value="">All Athletes</option>
              {athletes.map((athlete) => (
                <option key={athlete.id} value={athlete.id}>{athlete.name}</option>
              ))}
            </select>
            <Input
              type="date"
              onChange={(e) => setFilterDate(e.target.value)}
              className="border p-2 rounded"
            />
          </div>
        </CardContent>
      </Card>

      
      <Card className="bg-white shadow-lg border-l-4 border-green-500">
        <CardContent className="p-4">
          <h2 className="text-lg font-semibold mb-4 text-green-700">Weekly RP Trends</h2>
          {weeklyTrends.map((athlete) => (
            <p key={athlete.name} className="text-gray-700">
              {athlete.name}: Average RP (Last Week): {athlete.avgRPE.toFixed(2)}
            </p>
          ))}
        </CardContent>
      </Card>
    </div>
  );
}

export default RPEManagement;
