import React from "react";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { TrendingUp, DollarSign, Handshake } from "lucide-react";
import { Link } from "react-router-dom";
import finance from "@/assets/finance.jpg";

const FinancialSupportPage = () => {
  return (
    <div className="min-h-screen bg-gray-100">
      
      <section className="relative text-center p-10 text-white bg-cover bg-center h-[40vh]" style={{ backgroundImage: `url(${finance})` }}>
        <div className="absolute inset-0 bg-black opacity-50"></div>
        <div className="relative z-10">
          <h1 className="text-4xl font-extrabold">Financial Support</h1>
          <p className="mt-3 text-lg">Access financial aid and support to further your athletic career.</p>
        </div>
      </section>

      <section className="py-5 text-center">
        <h2 className="text-2xl font-bold text-yellow-600 mb-12">How We Help You</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-5 container mx-auto px-12">
          {/* Financial Assistance Card */}
          <Card className="shadow-xl p-5 text-center border border-gray-300 rounded-xl hover:scale-105 hover:shadow-2xl transition-all duration-300 ease-in-out">
            <div className="flex justify-center items-center mb-4">
              <TrendingUp className="h-12 w-12 text-green-600" />
            </div>
            <h3 className="text-xl font-bold mb-2">Financial Assistance</h3>
            <p className="text-gray-600">Find sponsorships, grants, and financial aid options to support your athletic journey.</p>
          </Card>

          {/* Sponsorship Opportunities Card */}
          <Card className="shadow-xl p-5 text-center border border-gray-300 rounded-xl hover:scale-105 hover:shadow-2xl transition-all duration-300 ease-in-out">
            <div className="flex justify-center items-center mb-4">
              <Handshake className="h-12 w-12 text-blue-600" />
            </div>
            <h3 className="text-xl font-bold mb-2">Sponsorship Opportunities</h3>
            <p className="text-gray-600">Explore a range of sponsorships from top brands that align with your athletic profile.</p>
          </Card>

          {/* Grants & Funding Card */}
          <Card className="shadow-xl p-5 text-center border border-gray-300 rounded-xl hover:scale-105 hover:shadow-2xl transition-all duration-300 ease-in-out">
            <div className="flex justify-center items-center mb-4">
              <DollarSign className="h-12 w-12 text-red-600" />
            </div>
            <h3 className="text-xl font-bold mb-2">Grants & Funding</h3>
            <p className="text-gray-600">Access various grants and funding options designed to help athletes at every stage of their career.</p>
          </Card>
        </div>

        {/* Join Now Button */}
        <Link to="/sign-up">
          <Button variant="secondary" className="mt-7 px-8 py-3 text-lg bg-green-600 text-white hover:bg-green-700 transition duration-300 ease-in-out">
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

export default FinancialSupportPage;
