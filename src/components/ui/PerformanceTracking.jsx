import React from "react";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { TrendingUp, BarChart2, Target } from "lucide-react";
import { Link } from "react-router-dom";
import perftrack from "@/assets/perftrack.jpeg";

const PerformanceTrackingPage = () => {
  return (
    <div className="min-h-screen bg-gray-100">
      {/* Adjusted the height of the top image */}
      <section className="relative text-center p-10 text-white bg-cover bg-center h-[35vh]" style={{ backgroundImage: `url(${perftrack})` }}>
        <div className="absolute inset-0 bg-black opacity-50"></div>
        <div className="relative z-10">
          <h1 className="text-4xl font-extrabold">Performance Tracking</h1>
          <p className="mt-5 text-lg">Track your performance and improve over time with data-driven insights.</p>
        </div>
      </section>

      <section className="py-20 text-center">
        <h2 className="text-3xl font-bold text-green-600 mb-12">How We Help You</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 container mx-auto px-4">
          {/* Track Progress Card */}
          <Card className="shadow-xl p-5 text-center border border-gray-300 rounded-xl hover:scale-105 hover:shadow-2xl transition-all duration-300 ease-in-out">
            <div className="flex justify-center items-center mb-4">
              <TrendingUp className="h-12 w-12 text-green-600" />
            </div>
            <h3 className="text-xl font-bold mb-2">Track Progress</h3>
            <p className="text-gray-600">Log your training, monitor progress, and receive AI-powered suggestions for improvement.</p>
          </Card>

          {/* New Card 1: Advanced Analytics */}
          <Card className="shadow-xl p-5 text-center border border-gray-300 rounded-xl hover:scale-105 hover:shadow-2xl transition-all duration-300 ease-in-out">
            <div className="flex justify-center items-center mb-4">
              <BarChart2 className="h-12 w-12 text-blue-600" />
            </div>
            <h3 className="text-xl font-bold mb-2">Advanced Analytics</h3>
            <p className="text-gray-600">Dive deeper into your performance with detailed graphs, trends, and insights that help you improve.</p>
          </Card>

          {/* New Card 2: Goal Tracking */}
          <Card className="shadow-xl p-8 text-center border border-gray-300 rounded-xl hover:scale-105 hover:shadow-2xl transition-all duration-300 ease-in-out">
            <div className="flex justify-center items-center mb-4">
              <Target className="h-12 w-12 text-red-600" />
            </div>
            <h3 className="text-xl font-bold mb-2">Goal Tracking</h3>
            <p className="text-gray-600">Set and track your athletic goals, receive reminders, and get performance feedback to stay on track.</p>
          </Card>

        </div>
        {/* Updated the button style and size */}
        <Link to="/sign-up">
          <Button variant="secondary" className="mt-9 px-8 py-4 text-xl bg-green-600 text-white hover:bg-green-700 transition duration-300 ease-in-out">
            Join Now
          </Button>
        </Link>
      </section>

      <footer className="p-3 bg-gray-800 text-center text-white">
        <p>© 2025 Khel-INDIA. All Rights Reserved.</p>
      </footer>
    </div>
  );
};

export default PerformanceTrackingPage;
