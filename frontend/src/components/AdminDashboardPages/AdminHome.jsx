import React, { useState, useEffect } from "react";
import { Card, CardContent } from "@/components/ui/card";
import { User, Users, Briefcase, Calendar, AlertCircle, Loader } from "lucide-react";
import { format } from "date-fns";
import axios from "axios";

const AdminHome = () => {
  const currentDate = format(new Date(), "MMMM dd, yyyy");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [stats, setStats] = useState({
    athleteCount: 0,
    coachCount: 0,
    sponsorCount: 0,
    adminCount: 0
  });

  useEffect(() => {
    const fetchStats = async () => {
      try {
        setLoading(true);
        const token = localStorage.getItem('token');
        
        const response = await axios.get('http://localhost:8000/api/v1/admins/organization-stats', {
          headers: {
            Authorization: `Bearer ${token}`
          },
          withCredentials: true
        });
        
        if (response.data && response.data.data.stats) {
          setStats(response.data.data.stats);
        }
      } catch (err) {
        console.error("Error fetching organization stats:", err);
        setError("Failed to load organization statistics");
      } finally {
        setLoading(false);
      }
    };

    fetchStats();
  }, []);

  // Updated stats array to use API data
  const overviewStats = [
    { title: "Total Athletes", count: stats.athleteCount || 0, icon: <User className="w-6 h-6 text-blue-500" /> },
    { title: "Total Coaches", count: stats.coachCount || 0, icon: <Users className="w-6 h-6 text-green-500" /> },
    { title: "Total Sponsors", count: stats.sponsorCount || 0, icon: <Briefcase className="w-6 h-6 text-yellow-500" /> },
    { title: "Total Admins", count: stats.adminCount || 0, icon: <Calendar className="w-6 h-6 text-red-500" /> },
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
      
      {/* Error message if API fails */}
      {error && (
        <div className="bg-red-50 text-red-700 p-4 rounded-md border border-red-200 mb-4">
          <div className="flex items-center">
            <AlertCircle className="w-5 h-5 mr-2" />
            <span>{error}</span>
          </div>
        </div>
      )}
      
      {/* Overview Section */}
      <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-6">
        {loading ? (
          <div className="col-span-full flex justify-center items-center p-8">
            <Loader className="animate-spin w-6 h-6 mr-2 text-blue-500" />
            <span className="text-gray-600">Loading stats...</span>
          </div>
        ) : (
          overviewStats.map((stat, index) => (
            <Card key={index} className="p-4 flex items-center gap-4 shadow-md">
              {stat.icon}
              <div>
                <div className="text-lg font-semibold">{stat.count}</div>
                <div className="text-gray-500 text-sm">{stat.title}</div>
              </div>
            </Card>
          ))
        )}
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