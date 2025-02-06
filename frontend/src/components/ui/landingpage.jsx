import React from "react";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { Download, LogIn, MessageCircle, Users, UserPlus, TrendingUp, Activity, Star } from "lucide-react";
import { Link } from "react-router-dom";
import athleteImage from "@/assets/stadium.jpeg";
import appStore from "@/assets/appstore.png";
import playStore from "@/assets/playstore.png";

const features = [
  { title: "Financial help", description: "Find and connect with athletes in your area or across India.", icon: <Users className="h-12 w-12 text-green-600" /> },
  { title: "Join Teams", description: "Discover local teams and join them for practice or competitions.", icon: <UserPlus className="h-12 w-12 text-green-600" /> },
  { title: "Track Progress", description: "Log your training and track your progress over time.", icon: <TrendingUp className="h-12 w-12 text-green-600" /> },
  { title: "Exclusive Content", description: "Access training videos, tips, and strategies from professionals.", icon: <Activity className="h-12 w-12 text-green-600" /> },
  { title: "Personalized Recommendations", description: "AI-powered suggestions for your training schedule and diet.", icon: <Star className="h-12 w-12 text-green-600" /> },
  { title: "Join Challenges", description: "Compete in sports challenges and win rewards.", icon: <TrendingUp className="h-12 w-12 text-green-600" /> }
];

const LandingPage = () => {
  return (
    <div className="min-h-screen bg-gray-100 font-sans">
      {/* Navbar */}
      <nav className="sticky top-0 z-50 flex justify-between items-center p-5 bg-white shadow-lg transition-all ease-in-out">
        <h1 className="text-3xl font-extrabold text-green-600 hover:text-green-700 transition-colors">Khel-INDIA</h1>
        <div className="flex space-x-8 font-semibold text-lg text-gray-700">
          {/* Linking each feature to their respective pages */}
          <Link to="/performance-tracking">
            <Button variant="link" className="hover:text-blue-600 transition-all">Performance Tracking</Button>
          </Link>
          <Link to="/career-planning">
            <Button variant="link" className="hover:text-blue-600 transition-all">Career Planning</Button>
          </Link>
          <Link to="/injury-management">
            <Button variant="link" className="hover:text-blue-600 transition-all">Injury Management</Button>
          </Link>
          <Link to="/financial-support">
            <Button variant="link" className="hover:text-blue-600 transition-all">Financial Support</Button>
          </Link>
        </div>
        <Link to="/sign-up">
          <Button variant="outline" className="border-green-700 text-green-700 hover:bg-green-700 hover:text-white transition-all">
            <LogIn className="mr-2" size={16} /> Sign In / Sign Up
          </Button>
        </Link>
      </nav>

      {/* Hero Section */}
      <section className="relative text-center p-16 text-white bg-cover bg-center h-[45vh]" style={{ backgroundImage: `url(${athleteImage})` }}>
        <div className="absolute inset-0 bg-black opacity-60"></div>
        <div className="relative z-10">
          <h1 className="text-5xl font-extrabold animate__animated animate__fadeIn animate__delay-1s">Empowering Indian Athletes</h1>
          <p className="mt-3 text-xl animate__animated animate__fadeIn animate__delay-2s">Join the best sports platform for athletes in India.</p>
          <p className="mt-1 text-xl animate__animated animate__fadeIn animate__delay-2s">Train, Track, and Thrive!</p>
          <div className="flex justify-center mt-5 gap-4">
            {[{ img: appStore, link: "https://apps.apple.com/us/app/your-app-id" }, { img: playStore, link: "https://play.google.com/store/apps/details?id=com.yourapp" }].map(({ img, link }) => (
              <a key={link} href={link} target="_blank" rel="noopener noreferrer">
                <img src={img} alt="App Store" className="h-14 cursor-pointer hover:opacity-80 transition-all" />
              </a>
            ))}
          </div>
          <Button variant="secondary" className="mt-5 text-xl bg-green-600 text-white hover:bg-green-700 transition-all">Download Now</Button>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-20 bg-gray-50 text-center">
        <h2 className="text-3xl font-bold text-yellow-600 mb-12">Why Choose Khel-INDIA?</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8 container mx-auto px-4">
          {features.map(({ title, description, icon }) => (
            <FeatureCard key={title} title={title} description={description} icon={icon} />
          ))}
        </div>
      </section>

      {/* Footer */}
      <footer className="p-5 bg-gray-800 text-center text-white">
        <p>© 2025 Khel-INDIA. All Rights Reserved.</p>
      </footer>

      {/* Chatbot */}
      <div className="fixed bottom-5 right-5 bg-green-600 text-white p-4 rounded-full shadow-xl cursor-pointer animate__animated animate__fadeIn animate__delay-3s hover:bg-green-700 transition-all">
        <MessageCircle size={30} />
      </div>
    </div>
  );
};

// Feature Card Component
const FeatureCard = ({ title, description, icon }) => (
  <Card className="shadow-xl p-5 text-center border border-gray-300 rounded-xl hover:bg-gray-50 hover:scale-105 hover:shadow-2xl transition-all duration-300 ease-in-out">
    <div className="flex justify-center items-center mb-4">{icon}</div>
    <h3 className="text-xl font-bold mb-2">{title}</h3>
    <p className="text-gray-600">{description}</p>
  </Card>
);

export default LandingPage;
