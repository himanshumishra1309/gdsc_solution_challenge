import React from "react";
import { Card } from "@/components/ui/card";
import { Mail, Phone, Briefcase, MapPin, Stethoscope } from "lucide-react";
import { useParams } from "react-router-dom";

const MProfile = () => {
  const { coachName } = useParams();

  // Sample data 
  const medicalStaff = {
    name: decodeURIComponent(coachName),
    email: "dr.abc@medcare.com",
    phone: "+91 98765 43211",
    role: "Senior Physiotherapist",
    location: "Delhi, India",
    experience: "12 years",
    specialties: ["Sports Injury Management", "Rehabilitation", "Preventive Care"],
  };

  return (
    <div className="p-6 max-w-4xl mx-auto">
      {/* Profile Card */}
      <Card className="p-8 shadow-lg rounded-xl bg-white border border-gray-200">
        <div className="flex flex-col items-center text-center mb-6">
          <Stethoscope className="w-20 h-20 text-blue-600" />
          <h2 className="text-2xl font-bold mt-5 text-gray-800">{medicalStaff.name}</h2>
          <p className="text-lg text-gray-600">{medicalStaff.role}</p>
        </div>
        <div className="space-y-4 text-gray-700 text-lg">
          <div className="flex items-center gap-3">
            <Mail className="w-6 h-6 text-gray-500" /> <span className="font-semibold">Email:</span> <span>{medicalStaff.email}</span>
          </div>
          <div className="flex items-center gap-3">
            <Phone className="w-6 h-6 text-gray-500" /> <span className="font-semibold">Phone:</span> <span>{medicalStaff.phone}</span>
          </div>
          <div className="flex items-center gap-3">
            <Briefcase className="w-6 h-6 text-gray-500" /> <span className="font-semibold">Experience:</span> <span>{medicalStaff.experience}</span>
          </div>
          <div className="flex items-center gap-3">
            <MapPin className="w-6 h-6 text-gray-500" /> <span className="font-semibold">Location:</span> <span>{medicalStaff.location}</span>
          </div>
        </div>
        {/* Specialties Section */}
        <div className="mt-6">
          <h3 className="text-xl font-semibold text-gray-800 mb-2">Specialties</h3>
          <ul className="list-disc pl-6 text-gray-700">
            {medicalStaff.specialties.map((specialty, index) => (
              <li key={index}>{specialty}</li>
            ))}
          </ul>
        </div>
      </Card>
    </div>
  );
};

export default MProfile;
