import { useState, useEffect, useMemo } from "react";
import { useNavigate } from "react-router-dom";
import axios from "axios";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter
} from "@/components/ui/dialog";
import { Loader2, Search, UserCircle, Shield, Filter, ClipboardList, User, BarChart } from "lucide-react";

const TeamManagement = () => {
  const [athletes, setAthletes] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState(null);
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedSport, setSelectedSport] = useState("All");
  const [availableSports, setAvailableSports] = useState(["All"]);
  const [selectedAthlete, setSelectedAthlete] = useState(null);
const [profileDialogOpen, setProfileDialogOpen] = useState(false);
const [profileLoading, setProfileLoading] = useState(false);
const [athleteDetails, setAthleteDetails] = useState(null);
const [profileError, setProfileError] = useState(null);
const [performanceData, setPerformanceData] = useState({
  consistency: 70,
  technique: 65,
  stamina: 80
});
  const navigate = useNavigate();

  const handleViewProfile = async (athlete) => {
    setSelectedAthlete(athlete);
    setProfileDialogOpen(true);
    setProfileLoading(true);
    setProfileError(null);
    
    try {
      const response = await axios.get(
        `http://localhost:8000/api/v1/admins/coach-get-athletes/${athlete._id}/details`,
        {
          withCredentials: true
        }
      );
      
      if (response.data && response.data.data && response.data.data.athlete) {
        // Process the data before setting state
        const athleteData = response.data.data.athlete;
        
        // Ensure positions are properly parsed if they're a string
        if (typeof athleteData.sportsInfo?.positions === 'string') {
          try {
            athleteData.sportsInfo.positions = JSON.parse(athleteData.sportsInfo.positions);
          } catch (e) {
            console.error("Error parsing positions:", e);
            athleteData.sportsInfo.positions = {};
          }
        }
        
        // Process staff assignments for consistency
        if (athleteData.staffAssignments) {
          // Normalize staff data
          const normalizeStaff = (staff) => {
            if (!staff) return null;
            if (typeof staff === 'string') return { name: staff };
            return staff;
          };
          
          athleteData.staffAssignments.headCoach = normalizeStaff(athleteData.staffAssignments.headCoach);
          athleteData.staffAssignments.assistantCoach = normalizeStaff(athleteData.staffAssignments.assistantCoach);
          athleteData.staffAssignments.gymTrainer = normalizeStaff(athleteData.staffAssignments.gymTrainer);
          athleteData.staffAssignments.medicalStaff = normalizeStaff(athleteData.staffAssignments.medicalStaff);
        }
        
        setAthleteDetails(athleteData);
        
        // Set performance data
        if (athleteData.sportsInfo.stats && athleteData.sportsInfo.stats.length) {
          const primarySport = athleteData.sportsInfo.stats[0];
          const perfStats = {
            consistency: 70, // Default values
            technique: 65,
            stamina: 80
          };
          
          // Map stats to performance metrics if available
          if (primarySport.stats) {
            primarySport.stats.forEach(stat => {
              if (stat.statName === 'consistency') perfStats.consistency = parseInt(stat.value);
              if (stat.statName === 'technique') perfStats.technique = parseInt(stat.value);
              if (stat.statName === 'stamina') perfStats.stamina = parseInt(stat.value);
            });
          }
          
          setPerformanceData(perfStats);
        }
      } else {
        throw new Error("Invalid response format");
      }
    } catch (err) {
      console.error("Error fetching athlete details:", err);
      setProfileError(err.response?.data?.message || "Failed to load athlete details");
    } finally {
      setProfileLoading(false);
    }
  };

  // Fetch assigned athletes from the API

  useEffect(() => {
    // Update the fetchAssignedAthletes function
const fetchAssignedAthletes = async () => {
  setIsLoading(true);
  try {
    const response = await axios.get(
      "http://localhost:8000/api/v1/coaches/assigned-athletes",
      { withCredentials: true }
    );
    
    console.log("API Response:", response.data); // Debug the response
    
    // Check if response data is valid and handle different response formats
    if (response.data.success) {
      // Make sure athletes is always an array
      const athletesData = Array.isArray(response.data.data) 
        ? response.data.data 
        : response.data.data?.athletes || []; // Try to get athletes from nested object
      
      setAthletes(athletesData);
      
      // Extract unique sports safely
      const sports = new Set();
      sports.add("All");
      
      if (Array.isArray(athletesData)) {
        athletesData.forEach(athlete => {
          if (athlete.sports && Array.isArray(athlete.sports)) {
            athlete.sports.forEach(sport => sports.add(sport));
          }
        });
      }
      
      setAvailableSports(Array.from(sports));
    } else {
      setError("Failed to fetch athletes");
    }
  } catch (err) {
    console.error("Error fetching assigned athletes:", err);
    setError(err.response?.data?.message || "Failed to fetch assigned athletes");
  } finally {
    setIsLoading(false);
  }
};

    fetchAssignedAthletes();
  }, []);

  // Update the filteredAthletes useMemo
const filteredAthletes = useMemo(() => {
  // Make sure athletes is an array before filtering
  if (!Array.isArray(athletes)) {
    console.error("Athletes is not an array:", athletes);
    return [];
  }
  
  return athletes.filter((athlete) => {
    // Safely access athlete properties
    const athleteName = athlete?.name || "";
    const athleteSports = athlete?.sports || [];
    
    const matchesSearch = athleteName.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesSport = selectedSport === "All" || 
      (Array.isArray(athleteSports) && athleteSports.includes(selectedSport));
    
    return matchesSearch && matchesSport;
  });
}, [athletes, searchQuery, selectedSport]);
  
  // Update the athletesBySkill useMemo
const athletesBySkill = useMemo(() => {
  const grouped = {
    Beginner: [],
    Intermediate: [],
    Advanced: [],
    Elite: []
  };
  
  // Only proceed if filteredAthletes is an array
  if (Array.isArray(filteredAthletes)) {
    filteredAthletes.forEach(athlete => {
      if (athlete?.skillLevel && grouped[athlete.skillLevel]) {
        grouped[athlete.skillLevel].push(athlete);
      } else {
        grouped.Beginner.push(athlete);
      }
    });
  }
  
  return grouped;
}, [filteredAthletes]);

  const getAgeFromDob = (dob) => {
    if (!dob) return "N/A";
    const birthDate = new Date(dob);
    const diff = Date.now() - birthDate.getTime();
    return Math.floor(diff / (1000 * 60 * 60 * 24 * 365.25));
  };

  return (
    <div className="p-6 space-y-6">
      <h1 className="text-2xl font-bold text-gray-800">Team Management</h1>
      
      {isLoading ? (
        <div className="flex justify-center items-center h-64">
          <Loader2 className="h-8 w-8 animate-spin text-blue-600" />
          <span className="ml-2 text-lg">Loading athletes...</span>
        </div>
      ) : error ? (
        <div className="bg-red-50 p-4 rounded-md border border-red-200 text-red-700">
          <p>{error}</p>
        </div>
      ) : (
        <>
          <Card className="bg-white shadow-sm">
            <CardHeader className="pb-2">
              <div className="flex flex-col md:flex-row md:justify-between md:items-center gap-4">
                <CardTitle className="text-xl font-semibold">Assigned Athletes ({filteredAthletes.length})</CardTitle>
                
                <div className="flex flex-col sm:flex-row gap-2 sm:items-center">
                  <div className="relative">
                    <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-gray-500" />
                    <Input
                      type="text"
                      placeholder="Search athletes..."
                      className="pl-8 max-w-xs"
                      value={searchQuery}
                      onChange={(e) => setSearchQuery(e.target.value)}
                    />
                  </div>
                  
                  <div className="flex items-center gap-2">
                    <Filter className="h-4 w-4 text-gray-500" />
                    <Select value={selectedSport} onValueChange={setSelectedSport}>
                      <SelectTrigger className="w-[150px]">
                        <SelectValue placeholder="Sport" />
                      </SelectTrigger>
                      <SelectContent>
                        {availableSports.map((sport) => (
                          <SelectItem key={sport} value={sport}>
                            {sport}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                </div>
              </div>
            </CardHeader>
            
            <CardContent>
              {filteredAthletes.length === 0 ? (
                <div className="text-center py-10">
                  <UserCircle className="h-12 w-12 mx-auto text-gray-400" />
                  <h3 className="mt-4 text-lg font-medium text-gray-900">No Athletes Found</h3>
                  <p className="mt-1 text-sm text-gray-500">
                    {athletes.length === 0 
                      ? "You don't have any athletes assigned to you yet." 
                      : "No athletes match your current filters."}
                  </p>
                </div>
              ) : (
                <Tabs defaultValue="All" className="w-full mt-4">
                  <TabsList className="grid grid-cols-5 mb-6">
                    <TabsTrigger value="All">All</TabsTrigger>
                    <TabsTrigger value="Beginner">Beginner</TabsTrigger>
                    <TabsTrigger value="Intermediate">Intermediate</TabsTrigger>
                    <TabsTrigger value="Advanced">Advanced</TabsTrigger>
                    <TabsTrigger value="Elite">Elite</TabsTrigger>
                  </TabsList>
                  
                  <TabsContent value="All">
  <div className="grid gap-4">
    {filteredAthletes.map((athlete) => (
      <AthleteCard 
        key={athlete._id} 
        athlete={athlete} 
        navigate={navigate} 
        getAgeFromDob={getAgeFromDob}
        handleViewProfile={handleViewProfile}
      />
    ))}
  </div>
</TabsContent>

{["Beginner", "Intermediate", "Advanced", "Elite"].map((level) => (
  <TabsContent key={level} value={level}>
    <div className="grid gap-4">
      {athletesBySkill[level].length === 0 ? (
        <p className="text-center py-8 text-gray-500">No {level} level athletes found.</p>
      ) : (
        athletesBySkill[level].map((athlete) => (
          <AthleteCard 
            key={athlete._id} 
            athlete={athlete} 
            navigate={navigate} 
            getAgeFromDob={getAgeFromDob}
            handleViewProfile={handleViewProfile}
          />
        ))
      )}
    </div>
  </TabsContent>
))}
                </Tabs>
              )}
            </CardContent>
          </Card>
        </>
      )}
      {selectedAthlete && (
  <Dialog open={profileDialogOpen} onOpenChange={setProfileDialogOpen}>
    <DialogContent className="max-w-5xl p-8 rounded-lg bg-white shadow-lg overflow-y-auto max-h-[90vh]">
      <DialogHeader>
        <DialogTitle className="text-2xl font-bold">
          {selectedAthlete.name}
        </DialogTitle>
      </DialogHeader>

      {profileLoading ? (
        <div className="flex items-center justify-center py-12">
          <Loader2 className="h-8 w-8 animate-spin text-blue-600" />
          <span className="ml-3 text-gray-600">Loading athlete details...</span>
        </div>
      ) : profileError ? (
        <div className="bg-red-50 p-4 rounded-md border border-red-200 text-red-700">
          <p>{profileError}</p>
        </div>
      ) : athleteDetails ? (
        <div className="mt-6 grid grid-cols-1 md:grid-cols-3 gap-8">
          {/* Personal Information Column */}
          <div className="space-y-6">
            <div className="flex flex-col items-center">
              <div className="h-32 w-32 rounded-full overflow-hidden bg-gray-200 mb-4">
                {athleteDetails.basicInfo.avatar ? (
                  <img
                    src={athleteDetails.basicInfo.avatar}
                    alt={athleteDetails.basicInfo.name}
                    className="h-full w-full object-cover"
                  />
                ) : (
                  <div className="h-full w-full flex items-center justify-center">
                    <span className="text-gray-500 text-3xl font-medium">
                      {athleteDetails.basicInfo.name.charAt(0).toUpperCase()}
                    </span>
                  </div>
                )}
              </div>
              <h3 className="text-xl font-semibold">
                {athleteDetails.basicInfo.name}
              </h3>
              <p className="text-gray-500 text-sm">
                {athleteDetails.basicInfo.email}
              </p>
              <div className="mt-2 py-1 px-3 bg-blue-100 text-blue-800 rounded-full text-xs">
                Athlete ID: {athleteDetails.basicInfo.athleteId}
              </div>
            </div>

            <Card>
              <CardHeader className="pb-2">
                <CardTitle className="text-lg">Personal Information</CardTitle>
              </CardHeader>
              <CardContent className="pt-0 space-y-2">
                <div>
                  <p className="text-sm text-gray-500">Age</p>
                  <p className="font-medium">{athleteDetails.basicInfo.age} years</p>
                </div>
                <div>
                  <p className="text-sm text-gray-500">Gender</p>
                  <p className="font-medium">{athleteDetails.basicInfo.gender}</p>
                </div>
                <div>
                  <p className="text-sm text-gray-500">Nationality</p>
                  <p className="font-medium">{athleteDetails.basicInfo.nationality}</p>
                </div>
                <div>
                  <p className="text-sm text-gray-500">Phone</p>
                  <p className="font-medium">{athleteDetails.basicInfo.phoneNumber}</p>
                </div>
                <div>
                  <p className="text-sm text-gray-500">Address</p>
                  <p className="font-medium">{athleteDetails.basicInfo.address}</p>
                </div>
              </CardContent>
            </Card>
            
            <Card>
              <CardHeader className="pb-2">
                <CardTitle className="text-lg">Emergency Contact</CardTitle>
              </CardHeader>
              <CardContent className="pt-0 space-y-2">
                <div>
                  <p className="text-sm text-gray-500">Name</p>
                  <p className="font-medium">{athleteDetails.emergencyContact.name}</p>
                </div>
                <div>
                  <p className="text-sm text-gray-500">Phone</p>
                  <p className="font-medium">{athleteDetails.emergencyContact.number}</p>
                </div>
                <div>
                  <p className="text-sm text-gray-500">Relationship</p>
                  <p className="font-medium">{athleteDetails.emergencyContact.relationship}</p>
                </div>
              </CardContent>
            </Card>
          </div>

          {/* Academic & Sports Information Column */}
          <div className="space-y-6">
            <Card>
              <CardHeader className="pb-2">
                <CardTitle className="text-lg">Academic Information</CardTitle>
              </CardHeader>
              <CardContent className="pt-0 space-y-2">
                <div>
                  <p className="text-sm text-gray-500">School Name</p>
                  <p className="font-medium">{athleteDetails.schoolInfo.schoolName}</p>
                </div>
                <div>
                  <p className="text-sm text-gray-500">Grade/Year</p>
                  <p className="font-medium">{athleteDetails.schoolInfo.year}</p>
                </div>
                <div>
                  <p className="text-sm text-gray-500">Student ID</p>
                  <p className="font-medium">{athleteDetails.schoolInfo.studentId}</p>
                </div>
                <div>
                  <p className="text-sm text-gray-500">School Email</p>
                  <p className="font-medium">{athleteDetails.schoolInfo.schoolEmail}</p>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader className="pb-2">
                <CardTitle className="text-lg">Sports Information</CardTitle>
              </CardHeader>
              <CardContent className="pt-0 space-y-3">
                <div>
                  <p className="text-sm text-gray-500">Sports</p>
                  <div className="flex flex-wrap gap-1 mt-1">
                    {athleteDetails.sportsInfo.sports.map((sport, idx) => (
                      <span
                        key={idx}
                        className="px-2 py-1 text-xs rounded-full bg-blue-100 text-blue-800"
                      >
                        {sport}
                      </span>
                    ))}
                  </div>
                </div>
                <div>
                  <p className="text-sm text-gray-500">Skill Level</p>
                  <p className="font-medium">{athleteDetails.sportsInfo.skillLevel}</p>
                </div>
                <div>
                  <p className="text-sm text-gray-500">Training Duration</p>
                  <p className="font-medium">{athleteDetails.sportsInfo.trainingDuration}</p>
                </div>
                <div>
                  <p className="text-sm text-gray-500">Dominant Hand</p>
                  <p className="font-medium">{athleteDetails.sportsInfo.dominantHand}</p>
                </div>
              </CardContent>
            </Card>
            
            <Card>
              <CardHeader className="pb-2">
                <CardTitle className="text-lg">Staff Assignments</CardTitle>
              </CardHeader>
              <CardContent className="pt-0 space-y-3">
                <div>
                  <p className="text-sm text-gray-500">Head Coach</p>
                  <p className="font-medium">
                    {athleteDetails.staffAssignments.headCoach ? 
                      (typeof athleteDetails.staffAssignments.headCoach === 'object' 
                        ? athleteDetails.staffAssignments.headCoach.name 
                        : athleteDetails.staffAssignments.headCoach) : 
                      "Not assigned"}
                  </p>
                </div>
                <div>
                  <p className="text-sm text-gray-500">Assistant Coach</p>
                  <p className="font-medium">
                    {athleteDetails.staffAssignments.assistantCoach ? 
                      (typeof athleteDetails.staffAssignments.assistantCoach === 'object' 
                        ? athleteDetails.staffAssignments.assistantCoach.name 
                        : athleteDetails.staffAssignments.assistantCoach) : 
                      "Not assigned"}
                  </p>
                </div>
                <div>
                  <p className="text-sm text-gray-500">Gym Trainer</p>
                  <p className="font-medium">
                    {athleteDetails.staffAssignments.gymTrainer ? 
                      (typeof athleteDetails.staffAssignments.gymTrainer === 'object' 
                        ? athleteDetails.staffAssignments.gymTrainer.name 
                        : athleteDetails.staffAssignments.gymTrainer) : 
                      "Not assigned"}
                  </p>
                </div>
                <div>
                  <p className="text-sm text-gray-500">Medical Staff</p>
                  <p className="font-medium">
                    {athleteDetails.staffAssignments.medicalStaff ? 
                      (typeof athleteDetails.staffAssignments.medicalStaff === 'object' 
                        ? athleteDetails.staffAssignments.medicalStaff.name 
                        : athleteDetails.staffAssignments.medicalStaff) : 
                      "Not assigned"}
                  </p>
                </div>
              </CardContent>
            </Card>
          </div>

          {/* Medical & Performance Column */}
          <div className="space-y-6">
            <Card>
              <CardHeader className="pb-2">
                <CardTitle className="text-lg">Medical Information</CardTitle>
              </CardHeader>
              <CardContent className="pt-0 space-y-2">
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <p className="text-sm text-gray-500">Height</p>
                    <p className="font-medium">{athleteDetails.medicalInfo.height} cm</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-500">Weight</p>
                    <p className="font-medium">{athleteDetails.medicalInfo.weight} kg</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-500">BMI</p>
                    <p className="font-medium">{athleteDetails.medicalInfo.bmi}</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-500">Blood Group</p>
                    <p className="font-medium">{athleteDetails.medicalInfo.bloodGroup}</p>
                  </div>
                </div>

                <div>
                  <p className="text-sm text-gray-500">Allergies</p>
                  <p className="font-medium">
                    {athleteDetails.medicalInfo.allergies?.join(", ") || "None"}
                  </p>
                </div>

                <div>
                  <p className="text-sm text-gray-500">Medical Conditions</p>
                  <p className="font-medium">
                    {athleteDetails.medicalInfo.medicalConditions?.join(", ") || "None"}
                  </p>
                </div>
                
                <div className="mt-4">
                  <Button
                    onClick={() => {
                      setProfileDialogOpen(false);
                      navigate(`/coach-dashboard/medicalinfo/${selectedAthlete._id}`);
                    }}
                    className="w-full mt-2"
                  >
                    <ClipboardList className="h-4 w-4 mr-2" />
                    View Medical Records
                  </Button>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader className="pb-2">
                <CardTitle className="text-lg">Performance Summary</CardTitle>
              </CardHeader>
              <CardContent className="pt-0 space-y-4">
                <div className="flex flex-col items-center">
                  <div className="text-center mb-2">
                    <span className="text-3xl font-bold text-blue-600">
                      {selectedAthlete.overallRating || "N/A"}
                    </span>
                    <p className="text-sm text-gray-500">Overall Rating</p>
                  </div>
                  
                  <Button
                    onClick={() => {
                      setProfileDialogOpen(false);
                    }}
                    className="w-full mt-2"
                  >
                    <BarChart className="h-4 w-4 mr-2" />
                    View Performance Details
                  </Button>
                </div>
              </CardContent>
            </Card>
          </div>
        </div>
      ) : (
        <div className="py-12 text-center text-gray-500">
          No athlete details available
        </div>
      )}

      <DialogFooter className="mt-6">
        <Button
          variant="outline"
          onClick={() => setProfileDialogOpen(false)}
        >
          Close
        </Button>
      </DialogFooter>
    </DialogContent>
  </Dialog>
)}
    </div>
  );
};

// Extracted AthleteCard component for better organization
// Extracted AthleteCard component for better organization
const AthleteCard = ({ athlete, navigate, getAgeFromDob, handleViewProfile }) => {
  const getPositionBadgeColor = (position) => {
    const positions = {
      "Batsman": "bg-blue-100 text-blue-800",
      "Bowler": "bg-green-100 text-green-800",
      "All-rounder": "bg-purple-100 text-purple-800",
      "Wicketkeeper": "bg-yellow-100 text-yellow-800",
      "Raider": "bg-red-100 text-red-800",
      "Defender": "bg-indigo-100 text-indigo-800",
      "Forward": "bg-orange-100 text-orange-800",
      "Midfielder": "bg-teal-100 text-teal-800",
      "Goalkeeper": "bg-pink-100 text-pink-800",
    };
    
    return positions[position] || "bg-gray-100 text-gray-800";
  };

  return (
    <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 p-4 bg-white rounded-lg border border-gray-200 hover:shadow-md transition-shadow">
      <div className="flex items-center gap-4">
        {athlete.avatar ? (
          <img 
            src={athlete.avatar} 
            alt={athlete.name} 
            className="h-12 w-12 rounded-full object-cover border border-gray-200" 
          />
        ) : (
          <div className="h-12 w-12 rounded-full bg-blue-100 flex items-center justify-center">
            <span className="text-blue-700 font-bold">{athlete.name?.charAt(0).toUpperCase()}</span>
          </div>
        )}
        
        <div>
          <h3 className="font-medium text-gray-900">{athlete.name}</h3>
          <div className="flex flex-wrap gap-2 mt-1">
            {athlete.sports?.map((sport, idx) => (
              <Badge key={idx} variant="secondary" className="text-xs">
                {sport}
              </Badge>
            ))}
            <span className="text-xs text-gray-500">
              {athlete.gender}, {getAgeFromDob(athlete.dob)} yrs
            </span>
          </div>
        </div>
      </div>
      
      <div className="flex items-center gap-2 w-full sm:w-auto">
        <Badge variant="outline" className={`${athlete.skillLevel === "Advanced" || athlete.skillLevel === "Elite" ? "border-green-500 text-green-700" : "border-blue-500 text-blue-700"}`}>
          {athlete.skillLevel || "Beginner"}
        </Badge>
        
        <Button 
          size="sm" 
          className="ml-auto"
          onClick={() => handleViewProfile(athlete)}
        >
          <User className="h-4 w-4 mr-1" />
          View Profile
        </Button>
      </div>
    </div>
  );
};

export default TeamManagement;