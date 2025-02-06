import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from "recharts";

const performanceTrends = [
  { month: "Jan", performance: 80, investment: 50000 },
  { month: "Feb", performance: 85, investment: 52000 },
  { month: "Mar", performance: 87, investment: 53000 },
  { month: "Apr", performance: 90, investment: 55000 },
];

const organizationAchievements = [
  { name: "ProFit India", titlesWon: 5, sponsorships: 10 },
  { name: "Elite Athletes", titlesWon: 8, sponsorships: 15 },
];

const Analytics = () => {
  return (
    <div className="p-6 space-y-6">
      <h1 className="text-2xl font-bold">Analytics Dashboard</h1>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <Card>
          <CardHeader>
            <CardTitle>Performance Trends</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={performanceTrends}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="month" />
                <YAxis />
                <Tooltip />
                <Legend />
                <Line type="monotone" dataKey="performance" stroke="#8884d8" strokeWidth={2} />
              </LineChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle>Investment Trends</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={performanceTrends}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="month" />
                <YAxis />
                <Tooltip />
                <Legend />
                <Line type="monotone" dataKey="investment" stroke="#82ca9d" strokeWidth={2} />
              </LineChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
      </div>
      <Card>
        <CardHeader>
          <CardTitle>Organization Achievements</CardTitle>
        </CardHeader>
        <CardContent>
          <ul>
            {organizationAchievements.map((org, index) => (
              <li key={index} className="mb-2 text-lg font-medium">
                {org.name}: {org.titlesWon} Titles Won, {org.sponsorships} Sponsorships
              </li>
            ))}
          </ul>
        </CardContent>
      </Card>
    </div>
  );
};

export default Analytics;
