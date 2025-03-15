import React from "react";
import { Card, CardContent } from "@/components/ui/card";
import { User, Users, Briefcase, Calendar } from "lucide-react";
import { format } from "date-fns";

const AdminHome = () => {
  const currentDate = format(new Date(), "MMMM dd, yyyy");

  const overviewStats = [
    { title: "Total Players", count: 120, icon: <User className="w-6 h-6 text-blue-500" /> },
    { title: "Total Coaches", count: 15, icon: <Users className="w-6 h-6 text-green-500" /> },
    { title: "Total Sponsors", count: 8, icon: <Briefcase className="w-6 h-6 text-yellow-500" /> },
    { title: "Total Events", count: 5, icon: <Calendar className="w-6 h-6 text-red-500" /> },
  ];

  const recentActivity = [
    { id: 1, message: "Rahul Sharma registered as a player", date: "March 14, 2025" },
    { id: 2, message: "Coach Priya Verma added to the system", date: "March 13, 2025" },
    { id: 3, message: "Event 'Summer Training Camp' created", date: "March 12, 2025" },
  ];

  return (
    <div className="p-6 space-y-6">
      {/* Welcome Section */}
      <div className="text-xl font-semibold">Welcome, Admin</div>
      <div className="text-gray-500">{currentDate}</div>
      
      {/* Overview Section */}
      <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-6">
        {overviewStats.map((stat, index) => (
          <Card key={index} className="p-4 flex items-center gap-4 shadow-md">
            {stat.icon}
            <div>
              <div className="text-lg font-semibold">{stat.count}</div>
              <div className="text-gray-500 text-sm">{stat.title}</div>
            </div>
          </Card>
        ))}
      </div>
      
      {/* Recent Activity Section */}
      <div>
        <h2 className="text-lg font-semibold mb-4">Recent Activity</h2>
        <div className="space-y-3">
          {recentActivity.map((activity) => (
            <Card key={activity.id} className="p-4 shadow-md">
              <div className="text-sm font-medium">{activity.message}</div>
              <div className="text-gray-500 text-xs">{activity.date}</div>
            </Card>
          ))}
        </div>
      </div>
    </div>
  );
};

export default AdminHome;
