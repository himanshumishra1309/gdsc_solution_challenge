import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from "recharts";
import { useState } from "react";

const investmentData = [
  { month: "Jan", investment: 50000, earnings: 12000, roi: 24 },
  { month: "Feb", investment: 52000, earnings: 13000, roi: 25 },
  { month: "Mar", investment: 53000, earnings: 14000, roi: 26 },
  { month: "Apr", investment: 55000, earnings: 15000, roi: 27 },
];

const InvestmentTracking = () => {
  return (
    <div className="p-6 space-y-6">
      <h1 className="text-2xl font-bold">Investment Tracking</h1>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <Card>
          <CardHeader>
            <CardTitle>Total Investment</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-2xl font-semibold">₹2,10,000</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle>Total Earnings</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-2xl font-semibold">₹54,000</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle>ROI</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-2xl font-semibold">25.7%</p>
          </CardContent>
        </Card>
      </div>
      <Card>
        <CardHeader>
          <CardTitle>Financial Performance</CardTitle>
        </CardHeader>
        <CardContent>
          <ResponsiveContainer width="100%" height={300}>
            <LineChart data={investmentData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="month" />
              <YAxis />
              <Tooltip />
              <Legend />
              <Line type="monotone" dataKey="investment" stroke="#8884d8" strokeWidth={2} />
              <Line type="monotone" dataKey="earnings" stroke="#82ca9d" strokeWidth={2} />
              <Line type="monotone" dataKey="roi" stroke="#ff7300" strokeWidth={2} />
            </LineChart>
          </ResponsiveContainer>
        </CardContent>
      </Card>
    </div>
  );
};

export default InvestmentTracking;
