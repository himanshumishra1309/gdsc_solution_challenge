import React from "react";
import { Card } from "@/components/ui/card";
import { User, Mail, Phone, Briefcase, MapPin, Dumbbell } from "lucide-react";
import { useParams } from "react-router-dom";

const GProfile = () => {
  const { coachName } = useParams();

  // Sample data (to be replaced with backend data later)
  const trainer = {
    name: decodeURIComponent(coachName),
    email: "abc@gymfit.com",
    phone: "+91 98765 43210",
    role: "Head Trainer",
    location: "Mumbai, India",
    experience: "10 years",
    specialties: ["Strength Training", "Cardio", "Nutrition Guidance"],
  };

  return (
    <div className="p-6 max-w-4xl mx-auto">
      {/* Profile Card */}
      <Card className="p-8 shadow-lg rounded-xl bg-white border border-gray-200">
        <div className="flex flex-col items-center text-center mb-6">
          <Dumbbell className="w-20 h-20 text-blue-600" />
          <h2 className="text-2xl font-bold mt-5 text-gray-800">{trainer.name}</h2>
          <p className="text-lg text-gray-600">{trainer.role}</p>
        </div>
        <div className="space-y-4 text-gray-700 text-lg">
          <div className="flex items-center gap-3">
            <Mail className="w-6 h-6 text-gray-500" /> <span className="font-semibold">Email:</span> <span>{trainer.email}</span>
          </div>
          <div className="flex items-center gap-3">
            <Phone className="w-6 h-6 text-gray-500" /> <span className="font-semibold">Phone:</span> <span>{trainer.phone}</span>
          </div>
          <div className="flex items-center gap-3">
            <Briefcase className="w-6 h-6 text-gray-500" /> <span className="font-semibold">Experience:</span> <span>{trainer.experience}</span>
          </div>
          <div className="flex items-center gap-3">
            <MapPin className="w-6 h-6 text-gray-500" /> <span className="font-semibold">Location:</span> <span>{trainer.location}</span>
          </div>
        </div>
        {/* Specialties Section */}
        <div className="mt-6">
          <h3 className="text-xl font-semibold text-gray-800 mb-2">Specialties</h3>
          <ul className="list-disc pl-6 text-gray-700">
            {trainer.specialties.map((specialty, index) => (
              <li key={index}>{specialty}</li>
            ))}
          </ul>
        </div>
      </Card>
    </div>
  );
};

export default GProfile;
