import React from "react";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { Activity, Heart, Stethoscope } from "lucide-react";
import { Link } from "react-router-dom";
import med from "@/assets/med.jpg";

const InjuryManagementPage = () => {
  return (
    <div className="min-h-screen bg-gray-100">
      {/* Adjusted the height of the top image */}
      <section className="relative text-center p-10 text-white bg-cover bg-center h-[35vh]" style={{ backgroundImage: `url(${med})` }}>
        <div className="absolute inset-0 bg-black opacity-50"></div>
        <div className="relative z-10">
          <h1 className="text-4xl font-extrabold">Injury Management</h1>
          <p className="mt-3 text-lg">Take control of your recovery with expert advice and tailored injury management strategies.</p>
        </div>
      </section>

      <section className="py-20 text-center">
        <h2 className="text-3xl font-bold text-yellow-600 mb-12">How We Help You</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8 container mx-auto px-4">
          {/* Injury Support Card */}
          <Card className="shadow-xl p-5 text-center border border-gray-300 rounded-xl hover:scale-105 hover:shadow-2xl transition-all duration-300 ease-in-out">
            <div className="flex justify-center items-center mb-4">
              <Activity className="h-12 w-12 text-green-600" />
            </div>
            <h3 className="text-xl font-bold mb-2">Injury Support</h3>
            <p className="text-gray-600">Receive personalized injury management plans, rehabilitation exercises, and access to medical experts.</p>
          </Card>

          {/* Recovery Tracking Card */}
          <Card className="shadow-xl p-5 text-center border border-gray-300 rounded-xl hover:scale-105 hover:shadow-2xl transition-all duration-300 ease-in-out">
            <div className="flex justify-center items-center mb-4">
              <Heart className="h-12 w-12 text-red-600" />
            </div>
            <h3 className="text-xl font-bold mb-2">Recovery Tracking</h3>
            <p className="text-gray-600">Track your recovery progress with data-driven insights and get real-time updates on your healing journey.</p>
          </Card>

          {/* Expert Consultation Card */}
          <Card className="shadow-xl p-5 text-center border border-gray-300 rounded-xl hover:scale-105 hover:shadow-2xl transition-all duration-300 ease-in-out">
            <div className="flex justify-center items-center mb-4">
              <Stethoscope className="h-12 w-12 text-blue-600" />
            </div>
            <h3 className="text-xl font-bold mb-2">Expert Consultation</h3>
            <p className="text-gray-600">Consult with top medical professionals and physiotherapists to get the best advice and treatment plans.</p>
          </Card>
        </div>

        {/* Join Now Button */}
        <Link to="/sign-up">
          <Button variant="secondary" className="mt-7 px-8 py-4 text-xl bg-green-600 text-white hover:bg-green-700 transition duration-300 ease-in-out">
            Join Now
          </Button>
        </Link>
      </section>

      <footer className="p-5 bg-gray-800 text-center text-white">
        <p>© 2025 Khel-INDIA. All Rights Reserved.</p>
      </footer>
    </div>
  );
};

export default InjuryManagementPage;
