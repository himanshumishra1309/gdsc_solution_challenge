import { useState } from "react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { LineChart, RadarChart, PolarGrid, PolarAngleAxis, PolarRadiusAxis, Radar, ResponsiveContainer, XAxis, YAxis, Tooltip, Legend, Line } from "recharts";

// Generate Sample Data 
const generatePerformanceData = () => {
  const months = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];

  let data = {};
  months.forEach((month) => {
    data[month] = {
      "Week 1": [],
      "Week 2": [],
      "Week 3": [],
      "Week 4": [],
    };

    for (let week = 1; week <= 4; week++) {
      data[month][`Week ${week}`] = [
        { day: "Monday", rpe: Math.random() * 4 + 5, rp: Math.random() * 4 + 5 },
        { day: "Tuesday", rpe: Math.random() * 4 + 5, rp: Math.random() * 4 + 5 },
        { day: "Wednesday", rpe: Math.random() * 4 + 5, rp: Math.random() * 4 + 5 },
        { day: "Thursday", rpe: Math.random() * 4 + 5, rp: Math.random() * 4 + 5 },
        { day: "Friday", rpe: Math.random() * 4 + 5, rp: Math.random() * 4 + 5 },
        { day: "Saturday", rpe: Math.random() * 4 + 5, rp: Math.random() * 4 + 5 },
        { day: "Sunday", rpe: Math.random() * 4 + 5, rp: Math.random() * 4 + 5 },
      ];
    }
  });

  return data;
};

const performanceData = generatePerformanceData();

const skillsData = [
  { skill: "Speed", value: 90 },
  { skill: "Strength", value: 78 },
  { skill: "Accuracy", value: 93 },
  { skill: "Endurance", value: 82 },
  { skill: "Agility", value: 88 },
  { skill: "Teamwork", value: 95 },
];

function Graphs() {
  const [selectedMonth, setSelectedMonth] = useState("January");
  const [selectedWeek, setSelectedWeek] = useState("Week 1");

  return (
    <div className="space-y-2 w-full h-full p-1">
      <h1 className="text-2xl font-bold">Performance Dashboard</h1>
      <Tabs defaultValue="overview" className="w-full">
        <TabsList className="flex justify-center">
          <TabsTrigger value="overview">Overview</TabsTrigger>
        </TabsList>

        <TabsContent value="overview">
          <Card>
            <CardHeader>
              <CardTitle>Performance Overview</CardTitle>
              <CardDescription>Track your performance with RPE & RP graphs</CardDescription>
            </CardHeader>
            <CardContent className="space-y-7">
              
              {/* Month and Week Selection Dropdowns */}
              <div className="flex justify-center gap-6">
                <div>
                  <p className="text-lg font-semibold">Select Month:</p>
                  <Select onValueChange={setSelectedMonth}>
                    <SelectTrigger className="w-40">
                      <SelectValue placeholder={selectedMonth} />
                    </SelectTrigger>
                    <SelectContent>
                      {Object.keys(performanceData).map((month) => (
                        <SelectItem key={month} value={month}>
                          {month}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>

                <div>
                  <p className="text-lg font-semibold">Select Week:</p>
                  <Select onValueChange={setSelectedWeek}>
                    <SelectTrigger className="w-40">
                      <SelectValue placeholder={selectedWeek} />
                    </SelectTrigger>
                    <SelectContent>
                      {Object.keys(performanceData[selectedMonth]).map((week) => (
                        <SelectItem key={week} value={week}>
                          {week}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
              </div>

              {/* RPE and RP Graphs - Day-wise */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <ResponsiveContainer width="100%" height={300}>
                  <LineChart data={performanceData[selectedMonth][selectedWeek]}>
                    <XAxis dataKey="day" />
                    <YAxis />
                    <Tooltip />
                    <Legend />
                    <Line type="monotone" dataKey="rpe" stroke="#fca5a5" />
                  </LineChart>
                </ResponsiveContainer>

                <ResponsiveContainer width="100%" height={300}>
                  <LineChart data={performanceData[selectedMonth][selectedWeek]}>
                    <XAxis dataKey="day" />
                    <YAxis />
                    <Tooltip />
                    <Legend />
                    <Line type="monotone" dataKey="rp" stroke="#93c5fd" />
                  </LineChart>
                </ResponsiveContainer>
              </div>

              {/* RPE vs RP Line Graph & Radar Graph */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <ResponsiveContainer width="100%" height={300}>
                  <LineChart data={performanceData[selectedMonth][selectedWeek]}>
                    <XAxis dataKey="day" />
                    <YAxis />
                    <Tooltip />
                    <Legend />
                    <Line type="monotone" dataKey="rpe" stroke="#fca5a5" name="RPE" />
                    <Line type="monotone" dataKey="rp" stroke="#93c5fd" name="RP" />
                  </LineChart>
                </ResponsiveContainer>

                <ResponsiveContainer width="100%" height={300}>
                  <RadarChart data={skillsData}>
                    <PolarGrid />
                    <PolarAngleAxis dataKey="skill" />
                    <PolarRadiusAxis />
                    <Radar name="Skill Level" dataKey="value" stroke="#93c5fd" fill="#93c5fd" fillOpacity={0.6} />
                    <Tooltip />
                  </RadarChart>
                </ResponsiveContainer>
              </div>

            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
}

export default Graphs;
