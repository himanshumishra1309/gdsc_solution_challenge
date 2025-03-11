import React from "react";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { Users, Briefcase, Target } from "lucide-react";
import { Link } from "react-router-dom";
import careerplanning from "@/assets/careerplanning.jpeg";

const CareerPlanningPage = () => {
  return (
    <div className="min-h-screen bg-gray-100">
      
      <section className="relative text-center p-12 text-white bg-cover bg-center h-[40vh]" style={{ backgroundImage: `url(${careerplanning})` }}>
        <div className="absolute inset-0 bg-black opacity-50"></div>
        <div className="relative z-10">
          <h1 className="text-4xl font-extrabold">Career Planning</h1>
          <p className="mt-5 text-lg">Plan your career and make informed decisions with the right guidance and support.</p>
        </div>
      </section>

      <section className="py-7 text-center">
        <h2 className="text-2xl font-bold text-green-600 mb-12">How We Help You</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 container mx-auto px-12">
          {/* Career Guidance Card */}
          <Card className="shadow-xl p-6 text-center border border-gray-300 rounded-xl hover:scale-105 hover:shadow-2xl transition-all duration-300 ease-in-out">
            <div className="flex justify-center items-center mb-4">
              <Users className="h-12 w-12 text-green-600" />
            </div>
            <h3 className="text-xl font-bold mb-2">Career Guidance</h3>
            <p className="text-gray-600">Get personalized career plans, advice from experts, and opportunities that align with your goals.</p>
          </Card>

          {/* Skill Development Card */}
          <Card className="shadow-xl p-4 text-center border border-gray-300 rounded-xl hover:scale-105 hover:shadow-2xl transition-all duration-300 ease-in-out">
            <div className="flex justify-center items-center mb-4">
              <Target className="h-12 w-12 text-blue-600" />
            </div>
            <h3 className="text-xl font-bold mb-2">Skill Development</h3>
            <p className="text-gray-600">Enhance your skill set with targeted training programs and resources designed to boost your career potential.</p>
          </Card>

          {/* Job Opportunities Card */}
          <Card className="shadow-xl p-4 text-center border border-gray-300 rounded-xl hover:scale-105 hover:shadow-2xl transition-all duration-300 ease-in-out">
            <div className="flex justify-center items-center mb-4">
              <Briefcase className="h-12 w-12 text-red-600" />
            </div>
            <h3 className="text-xl font-bold mb-2">Job Opportunities</h3>
            <p className="text-gray-600">Access a network of job listings and career opportunities that match your skills and interests.</p>
          </Card>
        </div>

        {/* Join Now Button */}
        <Link to="/sign-up">
          <Button variant="secondary" className="mt-9 px-8 py-3 text-lg bg-green-600 text-white hover:bg-green-700 transition duration-300 ease-in-out">
            Join Now
          </Button>
        </Link>
      </section>

      <footer className="p-3 bg-gray-800 text-center text-white">
        <p>© 2025 AthleTech. All Rights Reserved.</p>
      </footer>
    </div>
  );
};

export default CareerPlanningPage;
