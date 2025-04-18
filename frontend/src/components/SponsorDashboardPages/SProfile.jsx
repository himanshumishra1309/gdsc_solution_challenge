import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Avatar, AvatarImage, AvatarFallback } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { Label } from "@/components/ui/label";
import { Alert, AlertDescription } from "@/components/ui/alert";
import {
  FaUserCircle,
  FaMoneyBillWave,
  FaEdit,
  FaSave,
  FaTimes,
  FaBuilding,
  FaPhone,
  FaEnvelope,
  FaMapMarkerAlt,
  FaCalendarAlt,
  FaPlus,
  FaMinus,
  FaCheck,
  FaRunning,
  FaUsers,
  FaSpinner,
} from "react-icons/fa";
import { useState, useEffect } from "react";
import axios from "axios";
import toast from "react-hot-toast";

// Fallback sports in case API fails
const fallbackSports = {
  teamSports: [
    { name: "Cricket", type: "Team" },
    { name: "Football", type: "Team" },
    { name: "Basketball", type: "Team" },
    { name: "Hockey", type: "Team" },
    { name: "Volleyball", type: "Team" }
  ],
  individualSports: [
    { name: "Tennis", type: "Individual" },
    { name: "Badminton", type: "Individual" },
    { name: "Swimming", type: "Individual" },
    { name: "Athletics", type: "Individual" },
    { name: "Boxing", type: "Individual" }
  ]
};

const SProfile = () => {
  // State variables
  const [activeTab, setActiveTab] = useState("profile");
  const [sponsor, setSponsor] = useState(null);
  const [isEditing, setIsEditing] = useState(false);
  const [editedSponsor, setEditedSponsor] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Sports-related state
  const [allSports, setAllSports] = useState({
    teamSports: [],
    individualSports: [],
  });
  const [selectedSports, setSelectedSports] = useState([]);
  const [sportLoading, setSportLoading] = useState(false);

  // Fetch sponsor profile data on component mount
  useEffect(() => {
    fetchSponsorProfile();
    fetchSportsList();
    fetchSelectedSports();
  }, []);

  const fetchSponsorProfile = async () => {
    setLoading(true);
    setError(null);
    try {
      const accessToken = sessionStorage.getItem("sponsorAccessToken");
      
      if (!accessToken) {
        setError("Authentication token missing. Please login again.");
        setLoading(false);
        return;
      }
      
      const response = await axios.get(
        "http://localhost:8000/api/v1/sponsors/profile",
        {
          headers: {
            Authorization: `Bearer ${accessToken}`,
          },
          withCredentials: true,
        }
      );
  
      const sponsorData = response.data.data.sponsor;
      console.log("Sponsor data:", sponsorData);
      
      // Map backend field names to frontend field names
      const mappedSponsor = {
        ...sponsorData,
        companyName: sponsorData.name,
        contactPerson: sponsorData.contactName,
        phone: sponsorData.contactNo,
      };
      
      setSponsor(mappedSponsor);
      setEditedSponsor(mappedSponsor);
      setLoading(false);
    } catch (err) {
      console.error("Error fetching profile:", err);
      setError(err?.response?.data?.message || "Failed to load profile");
      setLoading(false);
      
      // Set dummy data for testing
      const dummyData = {
        email: "sponsor@example.com",
        companyName: "Test Company",
        contactPerson: "John Doe",
        phone: "1234567890",
        address: "123 Test Street",
        state: "Test State"
      };
      setSponsor(dummyData);
      setEditedSponsor(dummyData);
    }
  };

  // Fetch all sports categories
  const fetchSportsList = async () => {
    try {
      const response = await axios.get(
        "http://localhost:8000/api/v1/sponsors/sports",
        {
          headers: {
            Authorization: `Bearer ${sessionStorage.getItem("sponsorAccessToken")}`,
          },
          withCredentials: true,
        }
      );

      console.log("Sports data:", response.data);
      
      // Check if the API returned the expected format
      if (response.data.data && 
          (response.data.data.teamSports || response.data.data.individualSports)) {
        setAllSports({
          teamSports: response.data.data.teamSports || [],
          individualSports: response.data.data.individualSports || [],
        });
      } else {
        console.warn("API returned unexpected format, using fallback sports");
        setAllSports(fallbackSports);
      }
    } catch (err) {
      console.error("Error fetching sports:", err);
      toast.error("Failed to load sports list");
      // Use fallback sports data
      setAllSports(fallbackSports);
    }
  };

  // Fetch sponsor's selected sports
  const fetchSelectedSports = async () => {
    try {
      const response = await axios.get(
        "http://localhost:8000/api/v1/sponsors/selected-sports",
        {
          headers: {
            Authorization: `Bearer ${sessionStorage.getItem("sponsorAccessToken")}`,
          },
          withCredentials: true,
        }
      );
      
      console.log("Selected sports:", response.data);
      setSelectedSports(response.data.data?.selectedSports || []);
    } catch (err) {
      console.error("Error fetching selected sports:", err);
      // For testing, add some default selected sports
      setSelectedSports([
        { sport: "Cricket", type: "Team" },
        { sport: "Tennis", type: "Individual" }
      ]);
    }
  };

  const handleSaveProfile = async () => {
    try {
      const accessToken = sessionStorage.getItem("sponsorAccessToken");
      
      if (!accessToken) {
        toast.error("Authentication token missing. Please login again.");
        return;
      }
      
      console.log("Saving profile with data:", editedSponsor);
      
      // Map frontend field names to backend field names
      const backendData = {
        name: editedSponsor.companyName,
        email: editedSponsor.email,
        contactName: editedSponsor.contactPerson,
        contactNo: editedSponsor.phone,
        address: editedSponsor.address,
        state: editedSponsor.state,
      };
      
      console.log("Sending to API:", backendData);
      
      const response = await axios.patch(
        "http://localhost:8000/api/v1/sponsors/profile",
        backendData,
        {
          headers: {
            Authorization: `Bearer ${accessToken}`,
          },
          withCredentials: true,
        }
      );
  
      console.log("API response:", response.data);
      const updatedSponsor = response.data.data.sponsor;
      
      // Map the response data back to frontend field names
      const mappedSponsor = {
        ...updatedSponsor,
        companyName: updatedSponsor.name,
        contactPerson: updatedSponsor.contactName,
        phone: updatedSponsor.contactNo,
      };
      
      // Update both state variables with the mapped data
      setSponsor(mappedSponsor);
      setEditedSponsor(mappedSponsor);
      setIsEditing(false);
      toast.success("Profile updated successfully");
    } catch (err) {
      console.error("Error updating profile:", err);
      
      if (err.message === 'Network Error') {
        toast.error("Network error occurred. This may be a CORS issue.");
      } else {
        toast.error(err?.response?.data?.message || "Failed to update profile");
      }
    }
  };

  // Handle adding a sport to selection
  const handleAddSport = async (sport, type) => {
    setSportLoading(true);
    try {
      await axios.post(
        "http://localhost:8000/api/v1/sponsors/select-sport",
        { sport, type },
        {
          headers: {
            Authorization: `Bearer ${sessionStorage.getItem("sponsorAccessToken")}`,
          },
          withCredentials: true,
        }
      );

      // Update local state
      setSelectedSports([...selectedSports, { sport, type }]);
      toast.success(`Added ${sport} to your interests`);
    } catch (err) {
      console.error("Error adding sport:", err);
      // Add anyway for testing
      setSelectedSports([...selectedSports, { sport, type }]);
      toast.error(err?.response?.data?.message || "Failed to add sport");
    } finally {
      setSportLoading(false);
    }
  };

  // Handle removing a sport from selection
  const handleRemoveSport = async (sport) => {
    setSportLoading(true);
    try {
      await axios.post(
        "http://localhost:8000/api/v1/sponsors/remove-sport",
        { sport },
        {
          headers: {
            Authorization: `Bearer ${sessionStorage.getItem("sponsorAccessToken")}`,
          },
          withCredentials: true,
        }
      );

      // Update local state
      setSelectedSports(selectedSports.filter((s) => s.sport !== sport));
      toast.success(`Removed ${sport} from your interests`);
    } catch (err) {
      console.error("Error removing sport:", err);
      // Remove anyway for testing
      setSelectedSports(selectedSports.filter((s) => s.sport !== sport));
      toast.error(err?.response?.data?.message || "Failed to remove sport");
    } finally {
      setSportLoading(false);
    }
  };

  // Handle input changes in edit mode
  const handleChange = (e) => {
    const { name, value } = e.target;
    setEditedSponsor({
      ...editedSponsor,
      [name]: value,
    });
  };

  // Cancel editing and revert changes
  const handleCancelEdit = () => {
    setEditedSponsor(sponsor);
    setIsEditing(false);
  };

  // Check if a sport is already selected
  const isSportSelected = (sportName) => {
    return selectedSports.some((s) => s.sport === sportName);
  };

  // Get initials for avatar
  const getInitials = (name) => {
    if (!name) return "SP";
    return name
      .split(" ")
      .map((word) => word[0])
      .join("")
      .toUpperCase();
  };

  if (loading) {
    return (
      <div className="h-full flex items-center justify-center py-20">
        <div className="flex flex-col items-center">
          <FaSpinner className="animate-spin text-blue-600 h-10 w-10 mb-4" />
          <p className="text-gray-600 text-lg">Loading sponsor details...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="h-full flex items-center justify-center p-4 py-20">
        <Alert variant="destructive" className="max-w-md">
          <AlertDescription>{error}</AlertDescription>
          <Button className="mt-4" onClick={fetchSponsorProfile}>
            Try Again
          </Button>
        </Alert>
      </div>
    );
  }

  return (
    <div className="p-2 md:p-6 bg-gray-50 min-h-screen">
      <div className="max-w-6xl mx-auto">
        <div className="flex justify-between items-center mb-6">
          <h1 className="text-2xl md:text-3xl font-bold text-gray-800">
            Sponsor Dashboard
          </h1>
          <div className="text-sm text-gray-500">
            Last updated: {new Date().toLocaleDateString()}
          </div>
        </div>

        {/* Main content container */}
        <Tabs
          defaultValue="profile"
          value={activeTab}
          onValueChange={setActiveTab}
          className="w-full"
        >
          <TabsList className="grid w-full grid-cols-2 mb-6 bg-gray-100 p-1 rounded-lg">
            <TabsTrigger 
              value="profile" 
              className="px-4 py-2 md:py-2 transition-all data-[state=active]:bg-white data-[state=active]:shadow-sm rounded-md "
            >
              <FaUserCircle className="mr-2" /> Profile Information
            </TabsTrigger>
            <TabsTrigger 
              value="sports" 
              className=" px-4 py-2 md:py-2 transition-all data-[state=active]:bg-white data-[state=active]:shadow-sm rounded-md "
            >
              <FaRunning className="mr-2" /> Sports Interests
            </TabsTrigger>
          </TabsList>

          {/* Profile Tab Content */}
          <TabsContent value="profile" className="mt-0">
            <Card className="bg-white shadow-sm rounded-xl border border-gray-200 overflow-hidden">
              {/* Header with gradient background */}
              <div className="bg-gradient-to-r from-blue-600 to-blue-800 h-16 md:h-24 relative">
                <div className="absolute bottom-4 left-4 md:left-8">
                  <h2 className="text-xl md:text-2xl font-bold text-white">
                    Company Profile
                  </h2>
                </div>
              </div>

              {/* Avatar positioned over the header */}
              <div className="px-6 md:px-8 pb-6 mt-4 md:mt-6 relative z-10">
                <div className="flex justify-center">
                  <Avatar className="h-24 w-24 md:h-32 md:w-32 border-4 border-white shadow-md">
                    {sponsor?.logo ? (
                      <AvatarImage
                        src={sponsor.logo}
                        alt={sponsor.companyName}
                        className="object-cover"
                      />
                    ) : (
                      <AvatarFallback className="bg-blue-100 text-blue-800 text-2xl md:text-4xl font-medium">
                        {getInitials(sponsor?.companyName)}
                      </AvatarFallback>
                    )}
                  </Avatar>
                </div>

                {/* Profile content with proper spacing */}
                <div className="mt-4 md:mt-6 flex flex-col md:flex-row justify-between items-start gap-4">
                  <div className="space-y-1">
                    <h2 className="text-xl md:text-2xl font-bold text-gray-800">
                      {sponsor?.companyName || "Your Company"}
                    </h2>
                    <p className="text-gray-500 flex items-center">
                      <FaBuilding className="mr-2 text-blue-500" />
                      {sponsor?.industry || "Sports & Youth Development"}
                    </p>
                  </div>

                  {!isEditing ? (
                    <Button
                      variant="outline"
                      onClick={() => setIsEditing(true)}
                      className="flex items-center gap-2 border-gray-300 hover:bg-gray-50"
                    >
                      <FaEdit className="text-blue-600" />
                      <span>Edit Profile</span>
                    </Button>
                  ) : (
                    <div className="flex gap-2">
                      <Button
                        onClick={handleSaveProfile}
                        className="bg-blue-600 hover:bg-blue-700 flex items-center gap-2"
                      >
                        <FaSave />
                        Save Changes
                      </Button>
                      <Button
                        variant="outline"
                        onClick={handleCancelEdit}
                        className="flex items-center gap-2 border-gray-300 hover:bg-gray-50"
                      >
                        <FaTimes className="text-gray-600" />
                        Cancel
                      </Button>
                    </div>
                  )}
                </div>

                {/* Main content grid */}
                <div className="mt-8 grid grid-cols-1 md:grid-cols-2 gap-8">
                  {/* Contact Information */}
                  <div className="space-y-6">
                    <h3 className="text-lg font-semibold text-gray-800 border-b pb-2">
                      Contact Information
                    </h3>

                    <div className="space-y-4">
                      <div>
                        <Label htmlFor="email" className="text-gray-600 mb-1">
                          Email Address
                        </Label>
                        {isEditing ? (
                          <Input
                            id="email"
                            name="email"
                            value={editedSponsor?.email || ""}
                            onChange={handleChange}
                            className="mt-1 bg-gray-50 border-gray-300"
                          />
                        ) : (
                          <div className="flex items-start mt-1">
                            <FaEnvelope className="text-blue-500 mt-1 mr-3 flex-shrink-0" />
                            <p className="text-gray-800 break-all">
                              {sponsor?.email || "Not provided"}
                            </p>
                          </div>
                        )}
                      </div>

                      <div>
                        <Label htmlFor="contactPerson" className="text-gray-600 mb-1">
                          Contact Person
                        </Label>
                        {isEditing ? (
                          <Input
                            id="contactPerson"
                            name="contactPerson"
                            value={editedSponsor?.contactPerson || ""}
                            onChange={handleChange}
                            className="mt-1 bg-gray-50 border-gray-300"
                          />
                        ) : (
                          <div className="flex items-center mt-1">
                            <FaUserCircle className="text-blue-500 mr-3" />
                            <p className="text-gray-800">
                              {sponsor?.contactPerson || "Not provided"}
                            </p>
                          </div>
                        )}
                      </div>

                      <div>
                        <Label htmlFor="phone" className="text-gray-600 mb-1">
                          Phone Number
                        </Label>
                        {isEditing ? (
                          <Input
                            id="phone"
                            name="phone"
                            value={editedSponsor?.phone || ""}
                            onChange={handleChange}
                            className="mt-1 bg-gray-50 border-gray-300"
                          />
                        ) : (
                          <div className="flex items-center mt-1">
                            <FaPhone className="text-blue-500 mr-3" />
                            <p className="text-gray-800">
                              {sponsor?.phone || "Not provided"}
                            </p>
                          </div>
                        )}
                      </div>
                    </div>
                  </div>

                  {/* Location & Sponsorship Details */}
                  <div className="space-y-6">
                    <h3 className="text-lg font-semibold text-gray-800 border-b pb-2">
                      Company Details
                    </h3>

                    <div className="space-y-4">
                      <div>
                        <Label htmlFor="address" className="text-gray-600 mb-1">
                          Company Address
                        </Label>
                        {isEditing ? (
                          <Textarea
                            id="address"
                            name="address"
                            value={editedSponsor?.address || ""}
                            onChange={handleChange}
                            className="mt-1 bg-gray-50 border-gray-300"
                            rows={3}
                          />
                        ) : (
                          <div className="flex items-start mt-1">
                            <FaMapMarkerAlt className="text-blue-500 mt-1 mr-3 flex-shrink-0" />
                            <p className="text-gray-800">
                              {sponsor?.address || "Not provided"}
                            </p>
                          </div>
                        )}
                      </div>

                      <div>
                        <Label htmlFor="state" className="text-gray-600 mb-1">
                          State/Region
                        </Label>
                        {isEditing ? (
                          <Input
                            id="state"
                            name="state"
                            value={editedSponsor?.state || ""}
                            onChange={handleChange}
                            className="mt-1 bg-gray-50 border-gray-300"
                          />
                        ) : (
                          <div className="flex items-center mt-1">
                            <FaMapMarkerAlt className="text-blue-500 mr-3" />
                            <p className="text-gray-800">
                              {sponsor?.state || "Not provided"}
                            </p>
                          </div>
                        )}
                      </div>

                      {sponsor?.sponsorshipRange && (
                        <div>
                          <Label className="text-gray-600 mb-1">
                            Sponsorship Range
                          </Label>
                          <div className="flex items-center mt-1">
                            <FaMoneyBillWave className="text-green-500 mr-3" />
                            <p className="text-gray-800">
                              ₹{sponsor.sponsorshipRange.start} - ₹{sponsor.sponsorshipRange.end}
                            </p>
                          </div>
                        </div>
                      )}
                    </div>
                  </div>
                </div>

                {/* Sponsorship Stats if available */}
                {(sponsor?.sponsoredAthletes?.length > 0 ||
                  sponsor?.sponsoredOrganizations?.length > 0) && (
                  <div className="mt-8 pt-6 border-t">
                    <h3 className="text-lg font-semibold text-gray-800 mb-4">
                      Sponsorship Statistics
                    </h3>

                    <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                      <Card className="bg-blue-50 border-blue-100 rounded-lg">
                        <CardContent className="p-4">
                          <div className="flex items-center space-x-3">
                            <div className="p-2 rounded-full bg-blue-100">
                              <FaUserCircle className="text-blue-600" />
                            </div>
                            <div>
                              <p className="text-sm text-blue-600 font-medium">
                                Sponsored Athletes
                              </p>
                              <p className="text-2xl font-bold text-gray-800">
                                {sponsor?.sponsoredAthletes?.length || 0}
                              </p>
                            </div>
                          </div>
                        </CardContent>
                      </Card>

                      <Card className="bg-green-50 border-green-100 rounded-lg">
                        <CardContent className="p-4">
                          <div className="flex items-center space-x-3">
                            <div className="p-2 rounded-full bg-green-100">
                              <FaUsers className="text-green-600" />
                            </div>
                            <div>
                              <p className="text-sm text-green-600 font-medium">
                                Sponsored Organizations
                              </p>
                              <p className="text-2xl font-bold text-gray-800">
                                {sponsor?.sponsoredOrganizations?.length || 0}
                              </p>
                            </div>
                          </div>
                        </CardContent>
                      </Card>

                      <Card className="bg-purple-50 border-purple-100 rounded-lg">
                        <CardContent className="p-4">
                          <div className="flex items-center space-x-3">
                            <div className="p-2 rounded-full bg-purple-100">
                              <FaMoneyBillWave className="text-purple-600" />
                            </div>
                            <div>
                              <p className="text-sm text-purple-600 font-medium">
                                Total Investment
                              </p>
                              <p className="text-2xl font-bold text-gray-800">
                                ₹{sponsor?.totalInvestment || "0"}
                              </p>
                            </div>
                          </div>
                        </CardContent>
                      </Card>
                    </div>
                  </div>
                )}
              </div>
            </Card>
          </TabsContent>

          {/* Sports Interests Tab Content */}
          <TabsContent value="sports" className="mt-0">
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
              {/* Selected Sports - Full width on mobile, 1/3 on desktop */}
              <div className="lg:col-span-1">
                <Card className="shadow-sm rounded-xl h-full">
                  <CardHeader className="pb-3">
                    <CardTitle className="text-lg flex items-center gap-2">
                      <FaCheck className="text-green-500" />
                      <span>Your Selected Sports</span>
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    {selectedSports.length === 0 ? (
                      <div className="text-center py-8 text-gray-500">
                        <p>You haven't selected any sports yet.</p>
                        <p className="mt-2 text-sm">
                          Select sports from the lists to indicate your interests.
                        </p>
                      </div>
                    ) : (
                      <div className="space-y-5">
                        <div>
                          <h3 className="font-medium text-gray-600 mb-3 text-sm uppercase tracking-wider">
                            Team Sports ({selectedSports.filter(sport => sport.type === "Team").length})
                          </h3>
                          <div className="flex flex-wrap gap-2">
                            {selectedSports
                              .filter((sport) => sport.type === "Team")
                              .map((sport) => (
                                <Badge
                                  key={sport.sport}
                                  className="px-3 py-1.5 bg-blue-50 text-blue-700 border border-blue-100 hover:bg-blue-100 transition-colors group flex items-center rounded-lg"
                                >
                                  {sport.sport}
                                  <Button
                                    variant="ghost"
                                    size="sm"
                                    className="ml-2 h-5 w-5 p-0 text-blue-700 opacity-60 group-hover:opacity-100 hover:bg-transparent"
                                    onClick={() => handleRemoveSport(sport.sport)}
                                    disabled={sportLoading}
                                  >
                                    <FaMinus size={10} />
                                  </Button>
                                </Badge>
                              ))}
                            
                            {selectedSports.filter(sport => sport.type === "Team").length === 0 && (
                              <p className="text-sm text-gray-500">No team sports selected</p>
                            )}
                          </div>
                        </div>

                        <div>
                          <h3 className="font-medium text-gray-600 mb-3 text-sm uppercase tracking-wider">
                            Individual Sports ({selectedSports.filter(sport => sport.type === "Individual").length})
                          </h3>
                          <div className="flex flex-wrap gap-2">
                            {selectedSports
                              .filter((sport) => sport.type === "Individual")
                              .map((sport) => (
                                <Badge
                                  key={sport.sport}
                                  className="px-3 py-1.5 bg-green-50 text-green-700 border border-green-100 hover:bg-green-100 transition-colors group flex items-center rounded-lg"
                                >
                                  {sport.sport}
                                  <Button
                                    variant="ghost"
                                    size="sm"
                                    className="ml-2 h-5 w-5 p-0 text-green-700 opacity-60 group-hover:opacity-100 hover:bg-transparent"
                                    onClick={() => handleRemoveSport(sport.sport)}
                                    disabled={sportLoading}
                                  >
                                    <FaMinus size={10} />
                                  </Button>
                                </Badge>
                              ))}
                            
                            {selectedSports.filter(sport => sport.type === "Individual").length === 0 && (
                              <p className="text-sm text-gray-500">No individual sports selected</p>
                            )}
                          </div>
                        </div>
                      </div>
                    )}
                  </CardContent>
                </Card>
              </div>

              {/* Available Sports - Full width on mobile, 2/3 on desktop */}
              <div className="lg:col-span-2 space-y-6">
                {/* Team Sports */}
                <Card className="shadow-sm rounded-xl">
                  <CardHeader className="pb-3">
                    <CardTitle className="text-lg flex items-center gap-2">
                      <FaUsers className="text-blue-500" />
                      <span>Team Sports</span>
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="flex flex-wrap gap-2">
                      {allSports.teamSports && allSports.teamSports.length > 0 ? (
                        allSports.teamSports.map((sport) => (
                          <Badge
                            key={sport.name}
                            variant={isSportSelected(sport.name) ? "secondary" : "default"}
                            className={`px-3 py-1.5 rounded-lg transition-all ${
                              isSportSelected(sport.name)
                                ? "bg-gray-100 text-gray-500 cursor-default"
                                : "bg-blue-50 text-blue-700 hover:bg-blue-100 cursor-pointer"
                            } flex items-center`}
                            onClick={() => {
                              if (!isSportSelected(sport.name) && !sportLoading) {
                                handleAddSport(sport.name, "Team");
                              }
                            }}
                          >
                            {sport.name}
                            {isSportSelected(sport.name) ? (
                              <FaCheck className="ml-2 h-3 w-3 text-green-500" />
                            ) : (
                              <FaPlus className="ml-2 h-3 w-3" />
                            )}
                          </Badge>
                        ))
                      ) : (
                        <p className="text-gray-500">No team sports available</p>
                      )}
                    </div>
                  </CardContent>
                </Card>

                {/* Individual Sports */}
                <Card className="shadow-sm rounded-xl">
                  <CardHeader className="pb-3">
                    <CardTitle className="text-lg flex items-center gap-2">
                      <FaRunning className="text-green-500" />
                      <span>Individual Sports</span>
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="flex flex-wrap gap-2">
                      {allSports.individualSports && allSports.individualSports.length > 0 ? (
                        allSports.individualSports.map((sport) => (
                          <Badge
                            key={sport.name}
                            variant={isSportSelected(sport.name) ? "secondary" : "default"}
                            className={`px-3 py-1.5 rounded-lg transition-all ${
                              isSportSelected(sport.name)
                                ? "bg-gray-100 text-gray-500 cursor-default"
                                : "bg-green-50 text-green-700 hover:bg-green-100 cursor-pointer"
                            } flex items-center`}
                            onClick={() => {
                              if (!isSportSelected(sport.name) && !sportLoading) {
                                handleAddSport(sport.name, "Individual");
                              }
                            }}
                          >
                            {sport.name}
                            {isSportSelected(sport.name) ? (
                              <FaCheck className="ml-2 h-3 w-3 text-green-500" />
                            ) : (
                              <FaPlus className="ml-2 h-3 w-3" />
                            )}
                          </Badge>
                        ))
                      ) : (
                        <p className="text-gray-500">No individual sports available</p>
                      )}
                    </div>
                  </CardContent>
                </Card>
              </div>
            </div>
          </TabsContent>
        </Tabs>
      </div>
    </div>
  );
};

export default SProfile;