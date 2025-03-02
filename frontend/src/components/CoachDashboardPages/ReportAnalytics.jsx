import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from "recharts";
import { LineChart, Line } from "recharts"; 
import { useState } from "react";

const ReportsAnalytics = () => {
  const [data, setData] = useState([
    { name: "Team A", performance: 4000, injuries: 2400, trainingLoad: 2400, recoveryTime: 5 },
    { name: "Team B", performance: 3000, injuries: 1398, trainingLoad: 2210, recoveryTime: 3 },
    { name: "Team C", performance: 2000, injuries: 9800, trainingLoad: 2290, recoveryTime: 7 },
    { name: "Team D", performance: 2780, injuries: 3908, trainingLoad: 2000, recoveryTime: 6 },
  ]);

  const performanceData = [
    { name: "Jan", performance: 4000, injuries: 2400, trainingLoad: 2400 },
    { name: "Feb", performance: 3000, injuries: 1398, trainingLoad: 2210 },
    { name: "Mar", performance: 2000, injuries: 9800, trainingLoad: 2290 },
    { name: "Apr", performance: 2780, injuries: 3908, trainingLoad: 2000 },
  ];

  return (
    <Card>
      <CardHeader>
        <CardTitle>Reports and Analytics</CardTitle>
      </CardHeader>
      <CardContent>
        
        <h3 className="text-lg font-semibold mb-4">Team Performance Summary</h3>
        <ResponsiveContainer width="100%" height={400}>
          <BarChart data={data}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="name" />
            <YAxis />
            <Tooltip />
            <Legend />
            <Bar dataKey="performance" fill="#8884d8" />
            <Bar dataKey="injuries" fill="#82ca9d" />
            <Bar dataKey="trainingLoad" fill="#ffc658" />
          </BarChart>
        </ResponsiveContainer>

        
        <h3 className="text-lg font-semibold mt-8 mb-4">Injury and Recovery Trends</h3>
        <ResponsiveContainer width="100%" height={400}>
          <LineChart data={performanceData}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="name" />
            <YAxis />
            <Tooltip />
            <Legend />
            <Line type="monotone" dataKey="injuries" stroke="#82ca9d" />
            <Line type="monotone" dataKey="recoveryTime" stroke="#8884d8" />
          </LineChart>
        </ResponsiveContainer>

       
        <h3 className="text-lg font-semibold mt-8 mb-4">Training Load Analysis</h3>
        <ResponsiveContainer width="100%" height={400}>
          <LineChart data={performanceData}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="name" />
            <YAxis />
            <Tooltip />
            <Legend />
            <Line type="monotone" dataKey="trainingLoad" stroke="#ffc658" />
            <Line type="monotone" dataKey="performance" stroke="#8884d8" />
          </LineChart>
        </ResponsiveContainer>
      </CardContent>
    </Card>
  );
};

export default ReportsAnalytics;
