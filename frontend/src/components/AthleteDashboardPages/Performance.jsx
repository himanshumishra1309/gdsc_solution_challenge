import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { LineChart, RadarChart, PolarGrid, PolarAngleAxis, PolarRadiusAxis, Radar, ResponsiveContainer, XAxis, YAxis, Tooltip, Legend, Line, Bar } from "recharts";

const rpeData = [
  { month: "Jan", rpe: 7 },
  { month: "Feb", rpe: 8 },
  { month: "Mar", rpe: 6 },
  { month: "Apr", rpe: 7 },
  { month: "May", rpe: 9 },
  { month: "Jun", rpe: 8 },
];

const rpData = [
  { month: "Jan", rp: 7.5 },
  { month: "Feb", rp: 8.0 },
  { month: "Mar", rp: 7.8 },
  { month: "Apr", rp: 8.5 },
  { month: "May", rp: 8.8 },
  { month: "Jun", rp: 9.0 },
];

const skillsData = [
  { skill: "Speed", value: 90 },
  { skill: "Strength", value: 78 },
  { skill: "Accuracy", value: 93 },
  { skill: "Endurance", value: 82 },
  { skill: "Agility", value: 88 },
  { skill: "Teamwork", value: 95 },
];

function Performance() {
  return (
    <div className="space-y-8 w-full h-full p-4">
      <h1 className="text-3xl font-bold">Performance Dashboard</h1>
      <Tabs defaultValue="overview" className="w-full">
        <TabsList className="flex justify-center">
          <TabsTrigger value="overview">Overview</TabsTrigger>
        </TabsList>

        <TabsContent value="overview">
          <Card>
            <CardHeader>
              <CardTitle>Performance Overview</CardTitle>
              <CardDescription>Your performance metrics over the last 6 months</CardDescription>
            </CardHeader>
            <CardContent className="space-y-8">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
               
                <ResponsiveContainer width="100%" height={300}>
                  <LineChart data={rpeData}>
                    <XAxis dataKey="month" />
                    <YAxis />
                    <Tooltip />
                    <Legend />
                    <Line type="monotone" dataKey="rpe" stroke="#fca5a5" />
                  </LineChart>
                </ResponsiveContainer>

                
                <ResponsiveContainer width="100%" height={300}>
                  <LineChart data={rpData}>
                    <XAxis dataKey="month" />
                    <YAxis domain={[0, 10]} />
                    <Tooltip />
                    <Legend />
                    <Line type="monotone" dataKey="rp" stroke="#93c5fd" />
                  </LineChart>
                </ResponsiveContainer>
              </div>

              
              <div className="flex gap-4">
                
                <ResponsiveContainer width="50%" height={300}>
                  <LineChart data={rpeData}>
                    <XAxis dataKey="month" />
                    <YAxis />
                    <Tooltip />
                    <Legend />
                    <Line type="monotone" dataKey="rpe" stroke="#fca5a5" />
                    <Bar dataKey="rp" fill="#93c5fd" />
                  </LineChart>
                </ResponsiveContainer>

                
                <ResponsiveContainer width="50%" height={400}>
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

export default Performance;
