import React from "react";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { Separator } from "@/components/ui/separator";

const coachDetails = {
  fullName: "Arjun Patel",
  email: "abc@mail.com",
  dateOfBirth: "15th March 1985",
  gender: "Male",
  nationality: "Indian",
  phoneNumber: "+91 98765 43210",
  country: "India",
  state: "Maharashtra",
  address: "Bandra West, Mumbai, India",
  experience: "12 years",
  certifications: [
    "Certified Strength and Conditioning Specialist (CSCS)",
    "FIFA Coaching License Level B",
    "Diploma in Sports Science",
  ],
  previousOrganizations: [
    "Mumbai Warriors FC (2015-2019)",
    "Delhi Dynamos Academy (2019-2022)",
    "Indian National Youth Team (2022-Present)",
  ],
};

const ACProfile = () => {
  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-100 px-4">
      <Card className="w-full max-w-4xl shadow-lg p-10 bg-white">
        <CardHeader>
          {/* Remove the coach's name display */}
          <CardTitle className="text-3xl font-bold text-center">Coach Profile</CardTitle>
          <p className="text-gray-500 text-center">{coachDetails.email}</p>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6 text-gray-800">
            <p><strong>Date of Birth:</strong> {coachDetails.dateOfBirth}</p>
            <p><strong>Gender:</strong> {coachDetails.gender}</p>
            <p><strong>Nationality:</strong> {coachDetails.nationality}</p>
            <p><strong>Phone:</strong> {coachDetails.phoneNumber}</p>
            <p><strong>Country:</strong> {coachDetails.country}</p>
            <p><strong>State:</strong> {coachDetails.state}</p>
            <p><strong>Address:</strong> {coachDetails.address}</p>
            <p><strong>Years of Experience:</strong> {coachDetails.experience}</p>
          </div>

          <Separator className="my-6" />

          <div>
            <h2 className="text-xl font-semibold mb-3">Certifications & Licenses</h2>
            <ul className="list-disc list-inside text-gray-700 space-y-1">
              {coachDetails.certifications.map((cert, index) => (
                <li key={index}>{cert}</li>
              ))}
            </ul>
          </div>

          <Separator className="my-6" />

          <div>
            <h2 className="text-xl font-semibold mb-3">Previous Coaching Organizations</h2>
            <ul className="list-disc list-inside text-gray-700 space-y-1">
              {coachDetails.previousOrganizations.map((org, index) => (
                <li key={index}>{org}</li>
              ))}
            </ul>
          </div>
        </CardContent>
      </Card>
    </div>
  );
};

export default ACProfile;
