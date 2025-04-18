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
import toast from "react-hot-toast"; // Import without destructuring

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

  // Change this part in handleSaveProfile
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
      
      // Use POST instead of PATCH to avoid CORS issues
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
    <div className="p-4 md:p-6 overflow-x-hidden">
      <div className="max-w-6xl mx-auto">
        <h1 className="text-2xl md:text-3xl font-bold mb-6 text-gray-800">
          Sponsor Dashboard
        </h1>

        {/* Main content container */}
        <Tabs
          defaultValue="profile"
          value={activeTab}
          onValueChange={setActiveTab}
          className="w-full"
        >
          <TabsList className="grid w-full grid-cols-2 mb-6 overflow-hidden">
            <TabsTrigger value="profile" className="text-sm md:text-base py-2 md:py-3">
              <FaUserCircle className="mr-2" /> Profile Information
            </TabsTrigger>
            <TabsTrigger value="sports" className="text-sm md:text-base py-2 md:py-3">
              <FaRunning className="mr-2" /> Sports Interests
            </TabsTrigger>
          </TabsList>

          {/* Profile Tab Content */}
          <TabsContent value="profile" className="mt-0 space-y-4">
            <Card className="bg-white shadow-md overflow-hidden">
              <div className="bg-gradient-to-r from-blue-600 to-blue-800 h-24 md:h-32"></div>

              <div className="px-4 md:px-8 pb-6 pt-0 relative">
                <div className="absolute -top-12 md:-top-16 left-4 md:left-8">
                  <Avatar className="h-24 w-24 md:h-32 md:w-32 border-4 border-white">
                    {sponsor?.logo ? (
                      <AvatarImage
                        src={sponsor.logo}
                        alt={sponsor.companyName}
                      />
                    ) : (
                      <AvatarFallback className="bg-blue-100 text-blue-800 text-2xl md:text-4xl">
                        {getInitials(sponsor?.companyName)}
                      </AvatarFallback>
                    )}
                  </Avatar>
                </div>

                <div className="mt-16 md:mt-20 flex flex-col md:flex-row justify-between items-start gap-4">
                  <div>
                    <h2 className="text-xl md:text-2xl font-bold text-gray-800">
                      {sponsor?.companyName || "Your Company"}
                    </h2>
                    <p className="text-gray-500 flex items-center mt-1">
                      <FaBuilding className="mr-2" />
                      {sponsor?.industry || "Sports & Youth Development"}
                    </p>
                  </div>

                  {!isEditing ? (
                    <Button
                      variant="outline"
                      onClick={() => setIsEditing(true)}
                      className="flex items-center gap-2 mt-2 md:mt-0"
                    >
                      <FaEdit />
                      Edit Profile
                    </Button>
                  ) : (
                    <div className="flex gap-2 mt-2 md:mt-0">
                      <Button
                        onClick={handleSaveProfile}
                        className="bg-blue-600 hover:bg-blue-700 flex items-center gap-2"
                      >
                        <FaSave />
                        Save
                      </Button>
                      <Button
                        variant="outline"
                        onClick={handleCancelEdit}
                        className="flex items-center gap-2"
                      >
                        <FaTimes />
                        Cancel
                      </Button>
                    </div>
                  )}
                </div>

                <div className="mt-6 md:mt-8 grid grid-cols-1 md:grid-cols-2 gap-6">
                  {/* Contact Information */}
                  <div className="space-y-4 md:space-y-6">
                    <h3 className="text-lg md:text-xl font-semibold text-gray-800 border-b pb-2">
                      Contact Information
                    </h3>

                    <div className="space-y-4">
                      <div>
                        <Label
                          htmlFor="email"
                          className="text-gray-500 font-medium"
                        >
                          Email
                        </Label>
                        {isEditing ? (
                          <Input
                            id="email"
                            name="email"
                            value={editedSponsor?.email || ""}
                            onChange={handleChange}
                            className="mt-1"
                          />
                        ) : (
                          <p className="font-medium flex items-center text-gray-800 mt-1 break-words">
                            <FaEnvelope className="mr-2 text-blue-600 flex-shrink-0" />
                            <span className="break-all">{sponsor?.email || "Not provided"}</span>
                          </p>
                        )}
                      </div>

                      <div>
                        <Label
                          htmlFor="contactPerson"
                          className="text-gray-500 font-medium"
                        >
                          Contact Person
                        </Label>
                        {isEditing ? (
                          <Input
                            id="contactPerson"
                            name="contactPerson"
                            value={editedSponsor?.contactPerson || ""}
                            onChange={handleChange}
                            className="mt-1"
                          />
                        ) : (
                          <p className="font-medium flex items-center text-gray-800 mt-1">
                            <FaUserCircle className="mr-2 text-blue-600 flex-shrink-0" />
                            {sponsor?.contactPerson || "Not provided"}
                          </p>
                        )}
                      </div>

                      <div>
                        <Label
                          htmlFor="phone"
                          className="text-gray-500 font-medium"
                        >
                          Phone Number
                        </Label>
                        {isEditing ? (
                          <Input
                            id="phone"
                            name="phone"
                            value={editedSponsor?.phone || ""}
                            onChange={handleChange}
                            className="mt-1"
                          />
                        ) : (
                          <p className="font-medium flex items-center text-gray-800 mt-1">
                            <FaPhone className="mr-2 text-blue-600 flex-shrink-0" />
                            {sponsor?.phone || "Not provided"}
                          </p>
                        )}
                      </div>
                    </div>
                  </div>

                  {/* Location & Sponsorship Details */}
                  <div className="space-y-4 md:space-y-6">
                    <h3 className="text-lg md:text-xl font-semibold text-gray-800 border-b pb-2">
                      Address & Sponsorship
                    </h3>

                    <div className="space-y-4">
                      <div>
                        <Label
                          htmlFor="address"
                          className="text-gray-500 font-medium"
                        >
                          Address
                        </Label>
                        {isEditing ? (
                          <Textarea
                            id="address"
                            name="address"
                            value={editedSponsor?.address || ""}
                            onChange={handleChange}
                            className="mt-1"
                            rows={2}
                          />
                        ) : (
                          <p className="font-medium flex items-start text-gray-800 mt-1">
                            <FaMapMarkerAlt className="mr-2 text-blue-600 mt-1 flex-shrink-0" />
                            <span className="break-words">{sponsor?.address || "Not provided"}</span>
                          </p>
                        )}
                      </div>

                      <div>
                        <Label
                          htmlFor="state"
                          className="text-gray-500 font-medium"
                        >
                          State
                        </Label>
                        {isEditing ? (
                          <Input
                            id="state"
                            name="state"
                            value={editedSponsor?.state || ""}
                            onChange={handleChange}
                            className="mt-1"
                          />
                        ) : (
                          <p className="font-medium flex items-center text-gray-800 mt-1">
                            <FaMapMarkerAlt className="mr-2 text-blue-600 flex-shrink-0" />
                            {sponsor?.state || "Not provided"}
                          </p>
                        )}
                      </div>

                      {sponsor?.sponsorshipRange && (
                        <div>
                          <p className="text-gray-500 font-medium">
                            Sponsorship Range
                          </p>
                          <p className="font-medium flex items-center text-gray-800 mt-1">
                            <FaMoneyBillWave className="mr-2 text-green-600 flex-shrink-0" />₹
                            {sponsor.sponsorshipRange.start} - ₹
                            {sponsor.sponsorshipRange.end}
                          </p>
                        </div>
                      )}

                      {sponsor?.sponsorshipStartDate && (
                        <div>
                          <p className="text-gray-500 font-medium">
                            Started Sponsoring
                          </p>
                          <p className="font-medium flex items-center text-gray-800 mt-1">
                            <FaCalendarAlt className="mr-2 text-blue-600 flex-shrink-0" />
                            {new Date(
                              sponsor.sponsorshipStartDate
                            ).toLocaleDateString()}
                          </p>
                        </div>
                      )}
                    </div>
                  </div>
                </div>

                {/* Sponsorship Stats if available */}
                {(sponsor?.sponsoredAthletes?.length > 0 ||
                  sponsor?.sponsoredOrganizations?.length > 0) && (
                  <div className="mt-6 md:mt-8 pt-4 md:pt-6 border-t">
                    <h3 className="text-lg md:text-xl font-semibold text-gray-800 mb-4">
                      Sponsorship Statistics
                    </h3>

                    <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                      <Card className="bg-blue-50 border-blue-200">
                        <CardContent className="p-4">
                          <p className="text-blue-600 font-semibold">
                            Sponsored Athletes
                          </p>
                          <p className="text-2xl md:text-3xl font-bold mt-2 text-gray-800">
                            {sponsor?.sponsoredAthletes?.length || 0}
                          </p>
                        </CardContent>
                      </Card>

                      <Card className="bg-green-50 border-green-200">
                        <CardContent className="p-4">
                          <p className="text-green-600 font-semibold">
                            Sponsored Organizations
                          </p>
                          <p className="text-2xl md:text-3xl font-bold mt-2 text-gray-800">
                            {sponsor?.sponsoredOrganizations?.length || 0}
                          </p>
                        </CardContent>
                      </Card>

                      <Card className="bg-purple-50 border-purple-200">
                        <CardContent className="p-4">
                          <p className="text-purple-600 font-semibold">
                            Total Investment
                          </p>
                          <p className="text-2xl md:text-3xl font-bold mt-2 text-gray-800">
                            ₹{sponsor?.totalInvestment || "0"}
                          </p>
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
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
              {/* Selected Sports */}
              <Card className="shadow-md h-auto">
                <CardHeader className="pb-2">
                  <CardTitle className="text-lg md:text-xl flex items-center gap-2">
                    <FaCheck className="text-green-600" />
                    Your Selected Sports
                  </CardTitle>
                </CardHeader>
                <CardContent className="overflow-auto pb-6">
                  {selectedSports.length === 0 ? (
                    <div className="text-center py-8 text-gray-500">
                      <p>You haven't selected any sports yet.</p>
                      <p className="mt-2">
                        Select sports from the lists below to indicate your interests.
                      </p>
                    </div>
                  ) : (
                    <div className="space-y-4">
                      <div>
                        <h3 className="font-medium text-gray-600 mb-2">
                          Team Sports
                        </h3>
                        <div className="flex flex-wrap gap-2">
                          {selectedSports
                            .filter((sport) => sport.type === "Team")
                            .map((sport) => (
                              <Badge
                                key={sport.sport}
                                className="px-3 py-1 bg-blue-100 text-blue-800 border border-blue-200 hover:bg-blue-200 transition-colors group flex items-center"
                              >
                                {sport.sport}
                                <Button
                                  variant="ghost"
                                  size="sm"
                                  className="ml-2 h-4 w-4 p-0 text-blue-800 opacity-60 group-hover:opacity-100"
                                  onClick={() => handleRemoveSport(sport.sport)}
                                  disabled={sportLoading}
                                >
                                  <FaMinus size={10} />
                                </Button>
                              </Badge>
                            ))}
                            
                            {selectedSports.filter(sport => sport.type === "Team").length === 0 && (
                              <span className="text-sm text-gray-500">No team sports selected</span>
                            )}
                        </div>
                      </div>

                      <div>
                        <h3 className="font-medium text-gray-600 mb-2">
                          Individual Sports
                        </h3>
                        <div className="flex flex-wrap gap-2">
                          {selectedSports
                            .filter((sport) => sport.type === "Individual")
                            .map((sport) => (
                              <Badge
                                key={sport.sport}
                                className="px-3 py-1 bg-green-100 text-green-800 border border-green-200 hover:bg-green-200 transition-colors group flex items-center"
                              >
                                {sport.sport}
                                <Button
                                  variant="ghost"
                                  size="sm"
                                  className="ml-2 h-4 w-4 p-0 text-green-800 opacity-60 group-hover:opacity-100"
                                  onClick={() => handleRemoveSport(sport.sport)}
                                  disabled={sportLoading}
                                >
                                  <FaMinus size={10} />
                                </Button>
                              </Badge>
                            ))}
                            
                            {selectedSports.filter(sport => sport.type === "Individual").length === 0 && (
                              <span className="text-sm text-gray-500">No individual sports selected</span>
                            )}
                        </div>
                      </div>
                    </div>
                  )}
                </CardContent>
              </Card>

              {/* Available Sports */}
              <div className="space-y-6">
                {/* Team Sports */}
                <Card className="shadow-md">
                  <CardHeader className="pb-2">
                    <CardTitle className="text-lg md:text-xl flex items-center gap-2">
                      <FaUsers className="text-blue-600" />
                      Team Sports
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="pb-6">
                    <div className="flex flex-wrap gap-2">
                      {allSports.teamSports && allSports.teamSports.length > 0 ? (
                        allSports.teamSports.map((sport) => (
                          <Badge
                            key={sport.name}
                            className={`px-3 py-1 ${
                              isSportSelected(sport.name)
                                ? "bg-gray-100 text-gray-500 border border-gray-200"
                                : "bg-blue-100 text-blue-800 border border-blue-200 hover:bg-blue-200 cursor-pointer transition-colors"
                            } flex items-center`}
                            onClick={() => {
                              if (!isSportSelected(sport.name) && !sportLoading) {
                                handleAddSport(sport.name, "Team");
                              }
                            }}
                          >
                            {sport.name}
                            {isSportSelected(sport.name) ? (
                              <FaCheck className="ml-2 h-3 w-3 text-green-600" />
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
                <Card className="shadow-md">
                  <CardHeader className="pb-2">
                    <CardTitle className="text-lg md:text-xl flex items-center gap-2">
                      <FaRunning className="text-green-600" />
                      Individual Sports
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="pb-6">
                    <div className="flex flex-wrap gap-2">
                      {allSports.individualSports && allSports.individualSports.length > 0 ? (
                        allSports.individualSports.map((sport) => (
                          <Badge
                            key={sport.name}
                            className={`px-3 py-1 ${
                              isSportSelected(sport.name)
                                ? "bg-gray-100 text-gray-500 border border-gray-200"
                                : "bg-green-100 text-green-800 border border-green-200 hover:bg-green-200 cursor-pointer transition-colors"
                            } flex items-center`}
                            onClick={() => {
                              if (!isSportSelected(sport.name) && !sportLoading) {
                                handleAddSport(sport.name, "Individual");
                              }
                            }}
                          >
                            {sport.name}
                            {isSportSelected(sport.name) ? (
                              <FaCheck className="ml-2 h-3 w-3 text-green-600" />
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