import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { FaUserCircle, FaMoneyBillWave, FaEdit, FaSave, FaTimes } from "react-icons/fa";
import { useParams, useNavigate } from "react-router-dom";
import { useState, useEffect } from "react";
import { Input } from "@/components/ui/input";

const SProfile = () => {
  const { sponsorName } = useParams(); // Get sponsor name from URL
  const navigate = useNavigate();
  const [sponsor, setSponsor] = useState(null);
  const [isEditing, setIsEditing] = useState(false);
  const [editedSponsor, setEditedSponsor] = useState(null);

  useEffect(() => {
    // TODO: Replace this with an actual API call to fetch sponsor details
    setTimeout(() => {
      const fetchedSponsor = {
        name: sponsorName.replace(/-/g, " "), 
        email: `${sponsorName}@example.com`,
        phone: "+91 98765 43210",
        industry: "Sports & Youth Development",
        totalSponsorships: Math.floor(Math.random() * 20) + 1,
        totalAmount: `₹${(Math.random() * 50 + 1).toFixed(2)} Lakh`,
      };
      setSponsor(fetchedSponsor);
      setEditedSponsor(fetchedSponsor); // Initialize editedSponsor with fetched data
    }, 1000);
  }, [sponsorName]);

  const handleEditClick = () => {
    setIsEditing(true);
  };

  const handleSaveClick = () => {
    setSponsor(editedSponsor); // Update the main sponsor state with edited values
    setIsEditing(false);
    // Send updated data to backend API
  };

  const handleCancelEdit = () => {
    setEditedSponsor(sponsor); // ye to reset changes
    setIsEditing(false);
  };

  const handleChange = (e) => {
    setEditedSponsor({ ...editedSponsor, [e.target.name]: e.target.value });
  };

  if (!sponsor) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <p className="text-gray-600 text-lg">Loading sponsor details...</p>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-100 flex items-center justify-center p-4">
      <div className="w-full max-w-4xl">
        <Card className="bg-white shadow-lg rounded-2xl p-8">
          <CardHeader className="flex flex-col items-center">
            <FaUserCircle className="text-gray-600 w-20 h-20" />
            {isEditing ? (
              <Input 
                name="name"
                value={editedSponsor.name} 
                onChange={handleChange} 
                className="mt-2 text-center text-xl font-semibold capitalize"
              />
            ) : (
              <CardTitle className="text-xl font-semibold mt-3 capitalize">
                {sponsor.name}
              </CardTitle>
            )}
            {isEditing ? (
              <Input 
                name="industry"
                value={editedSponsor.industry} 
                onChange={handleChange} 
                className="mt-2 text-center"
              />
            ) : (
              <p className="text-gray-500">{sponsor.industry}</p>
            )}
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <p className="text-gray-500 text-sm">Email</p>
                {isEditing ? (
                  <Input name="email" value={editedSponsor.email} onChange={handleChange} />
                ) : (
                  <p className="font-medium">{sponsor.email}</p>
                )}
              </div>
              <div>
                <p className="text-gray-500 text-sm">Phone</p>
                {isEditing ? (
                  <Input name="phone" value={editedSponsor.phone} onChange={handleChange} />
                ) : (
                  <p className="font-medium">{sponsor.phone}</p>
                )}
              </div>
              <div>
                <p className="text-gray-500 text-sm">Total Sponsorships</p>
                <p className="font-medium">{sponsor.totalSponsorships}</p>
              </div>
              <div>
                <p className="text-gray-500 text-sm">Total Amount Sponsored</p>
                <p className="font-medium">{sponsor.totalAmount}</p>
              </div>
            </div>

            <div className="mt-6 flex justify-center gap-4">
              {isEditing ? (
                <>
                  <Button onClick={handleSaveClick} className="bg-blue-600 hover:bg-blue-700 flex items-center gap-2">
                    <FaSave />
                    Save
                  </Button>
                  <Button variant="outline" onClick={handleCancelEdit} className="flex items-center gap-2">
                    <FaTimes />
                    Cancel
                  </Button>
                </>
              ) : (
                <>
                  <Button variant="outline" onClick={handleEditClick} className="flex items-center gap-2">
                    <FaEdit />
                    Edit Profile
                  </Button>
                  <Button
                    className="bg-green-600 hover:bg-green-700 flex items-center gap-2"
                    onClick={() => navigate(`/sponsor-dashboard/${sponsorName}/findathlete`)}
                  >
                    <FaMoneyBillWave />
                    Sponsor More
                  </Button>
                </>
              )}
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
};

export default SProfile;
