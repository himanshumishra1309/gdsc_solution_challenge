import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import axios from "axios";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { useParams } from 'react-router-dom';
import { Loader2, Search, ClipboardList, User, Calendar, AlertCircle } from "lucide-react";
import { Alert, AlertDescription } from "@/components/ui/alert";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from "@/components/ui/dialog";

function ViewPlayers() {
  const { organizationId, coachName } = useParams();
  const [athletes, setAthletes] = useState([]);
  const [filteredAthletes, setFilteredAthletes] = useState([]);
  const [searchTerm, setSearchTerm] = useState("");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const navigate = useNavigate();
  
  // Profile dialog state
  const [profileDialogOpen, setProfileDialogOpen] = useState(false);
  const [selectedAthlete, setSelectedAthlete] = useState(null);
  const [profileLoading, setProfileLoading] = useState(false);
  const [profileError, setProfileError] = useState(null);
  const [athleteDetails, setAthleteDetails] = useState(null);
  
  // Performance data state
  const [performanceData, setPerformanceData] = useState({
    consistency: 0,
    technique: 0,
    stamina: 0,
  });

  // Fetch assigned athletes from the API
  useEffect(() => {
    const fetchAssignedAthletes = async () => {
      setLoading(true);
      try {
        const response = await axios.get(
          "http://localhost:8000/api/v1/coaches/assigned-athletes",
          { withCredentials: true }
        );
        
        if (response.data.success) {
          // Check if the response has the new structure with athletes property
          const athletesData = response.data.data.athletes || response.data.data || [];
          setAthletes(athletesData);
          setFilteredAthletes(athletesData);
        } else {
          setError("Failed to fetch athletes");
        }
      } catch (err) {
        console.error("Error fetching assigned athletes:", err);
        setError(err.response?.data?.message || "Failed to fetch assigned athletes");
      } finally {
        setLoading(false);
      }
    };
  
    fetchAssignedAthletes();
  }, []);

  // Filter athletes when search term changes
  useEffect(() => {
    if (!searchTerm.trim()) {
      setFilteredAthletes(athletes);
      return;
    }
    
    const filtered = athletes.filter(
      (athlete) =>
        athlete.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        (athlete.sports && athlete.sports.some(sport => 
          sport.toLowerCase().includes(searchTerm.toLowerCase())
        ))
    );
    setFilteredAthletes(filtered);
  }, [searchTerm, athletes]);

  const handleSearch = (event) => {
    setSearchTerm(event.target.value);
  };

  // Handle view profile function (similar to admin dashboard)
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

  const handleViewMedicalInfo = (athleteId) => {
    navigate(`../athlete-records/${athleteId}`);
  };

  // Calculate overall rating from performance metrics
  const consistency = performanceData.consistency || 0;
  const technique = performanceData.technique || 0;
  const stamina = performanceData.stamina || 0;
  const overallRating =
    consistency && technique && stamina
      ? Math.round((consistency + technique + stamina) / 3)
      : "N/A";

  return (
    <div className="p-6 space-y-6">
      <h1 className="text-2xl font-bold mb-4">Athlete Management</h1>
      
      <div className="bg-white p-4 rounded-lg shadow-sm">
        <div className="flex flex-col sm:flex-row justify-between items-center gap-4 mb-6">
          <div className="relative w-full sm:w-auto">
            <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-gray-500" />
            <Input
              type="text"
              placeholder="Search athletes or sports..."
              value={searchTerm}
              onChange={handleSearch}
              className="pl-8 max-w-sm w-full"
            />
          </div>
        </div>

        {loading ? (
          <div className="flex justify-center items-center h-64">
            <Loader2 className="h-8 w-8 animate-spin text-blue-600" />
            <span className="ml-2 text-lg">Loading athletes...</span>
          </div>
        ) : error ? (
          <Alert variant="destructive" className="mb-4">
            <AlertDescription>{error}</AlertDescription>
          </Alert>
        ) : filteredAthletes.length === 0 ? (
          <div className="text-center py-10 bg-gray-50 rounded-lg">
            <p className="text-gray-500 mb-4">
              No athletes found matching your criteria.
            </p>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {filteredAthletes.map((athlete) => (
              <Card key={athlete._id} className="overflow-hidden hover:shadow-md transition-shadow">
                <CardHeader className="bg-gray-50 pb-2">
                  <CardTitle className="flex items-center justify-between">
                    <span>{athlete.name}</span>
                    <Badge 
                      className={athlete.medicalStatus === "Injured" 
                        ? "bg-red-100 text-red-800" 
                        : "bg-green-100 text-green-800"
                      }
                    >
                      {athlete.medicalStatus || "Active"}
                    </Badge>
                  </CardTitle>
                </CardHeader>
                
                <CardContent className="p-4">
                  <div className="space-y-3 mb-4">
                    {/* Sports */}
                    <div>
                      <p className="text-sm text-gray-500 font-medium">Sports</p>
                      <div className="flex flex-wrap gap-1 mt-1">
                        {athlete.sports?.map((sport, idx) => (
                          <Badge key={idx} variant="secondary" className="text-xs">
                            {sport}
                          </Badge>
                        ))}
                      </div>
                    </div>
                    
                    {/* Coaching Staff */}
                    <div className="grid grid-cols-1 gap-2">
                      <div>
                        <p className="text-sm text-gray-500 font-medium">Head Coach</p>
                        <p className="text-sm">
                          {athlete.headCoachName || (athlete.headCoachAssigned ? 
                            (typeof athlete.headCoachAssigned === 'object' ? 
                              athlete.headCoachAssigned.name : 'Assigned') : 
                            'Not Assigned')}
                        </p>
                      </div>
                      
                      <div>
                        <p className="text-sm text-gray-500 font-medium">Assistant Coach</p>
                        <p className="text-sm">
                          {athlete.assistantCoachName || (athlete.assistantCoachAssigned ? 
                            (typeof athlete.assistantCoachAssigned === 'object' ? 
                              athlete.assistantCoachAssigned.name : 'Assigned') : 
                            'Not Assigned')}
                        </p>
                      </div>
                      
                      <div>
                        <p className="text-sm text-gray-500 font-medium">Trainer</p>
                        <p className="text-sm">
                          {athlete.gymTrainerName || (athlete.gymTrainerAssigned ? 
                            (typeof athlete.gymTrainerAssigned === 'object' ? 
                              athlete.gymTrainerAssigned.name : 'Assigned') : 
                            'Not Assigned')}
                        </p>
                      </div>
                    </div>
                  </div>
                  
                  <div className="grid grid-cols-2 gap-2 mt-4">
                    <Button 
                      variant="outline"
                      size="sm"
                      onClick={() => handleViewProfile(athlete)}
                      className="flex items-center justify-center"
                    >
                      <User className="h-4 w-4 mr-1" />
                      View Profile
                    </Button>
                    
                    <Button 
                      size="sm"
                      onClick={() => handleViewMedicalInfo(athlete._id)}
                      className="flex items-center justify-center"
                    >
                      <ClipboardList className="h-4 w-4 mr-1" />
                      Medical Info
                    </Button>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        )}
      </div>

      {/* Athlete Profile Dialog - Similar to Admin Dashboard */}
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
              <Alert variant="destructive" className="my-4">
                <AlertCircle className="h-4 w-4" />
                <AlertDescription>{profileError}</AlertDescription>
              </Alert>
            ) : athleteDetails ? (
              <div className="mt-6 grid grid-cols-1 md:grid-cols-3 gap-8">
                {/* Left column - Basic info */}
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

                {/* Middle column - School & Sports */}
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
                      
                      {/* Positions display component */}
                      {athleteDetails.sportsInfo.positions && (
                        <div>
                          <p className="text-sm text-gray-500">Positions</p>
                          <div className="mt-1 space-y-1">
                            {(() => {
                              try {
                                // Get positions data safely
                                let posData = athleteDetails.sportsInfo.positions;
                                let posObj = {};
                                
                                // Handle various formats
                                if (typeof posData === 'string') {
                                  try {
                                    posObj = JSON.parse(posData);
                                  } catch (e) { /* Silent fail */ }
                                } else if (typeof posData === 'object') {
                                  // Check if it's the character-by-character format
                                  if (Object.keys(posData).every(k => !isNaN(parseInt(k)))) {
                                    try {
                                      posObj = JSON.parse(Object.values(posData).join(''));
                                    } catch (e) { /* Silent fail */ }
                                  } else {
                                    posObj = posData;
                                  }
                                }
                                
                                // Render each position
                                return Object.entries(posObj).map(([sport, position], idx) => (
                                  <div key={idx} className="flex items-center justify-between">
                                    <span className="text-xs font-medium">{sport}:</span>
                                    <span className="text-xs bg-gray-100 px-2 py-1 rounded">{position}</span>
                                  </div>
                                ));
                              } catch (err) {
                                console.error("Error displaying positions:", err);
                                return <p className="text-xs text-gray-500">No positions available</p>;
                              }
                            })()}
                          </div>
                        </div>
                      )}
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

                {/* Right column - Medical & Performance */}
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
                          onClick={() => handleViewMedicalInfo(selectedAthlete._id)}
                          className="w-full mt-2"
                        >
                          <ClipboardList className="h-4 w-4 mr-2" />
                          Go to Medical Records
                        </Button>
                      </div>
                    </CardContent>
                  </Card>

                  <Card>
                    <CardHeader className="pb-2">
                      <CardTitle className="text-lg">Performance Metrics</CardTitle>
                    </CardHeader>
                    <CardContent className="pt-0 space-y-4">
                      <div className="text-center mb-2">
                        <span className="text-3xl font-bold text-blue-600">
                          {overallRating}
                        </span>
                        <p className="text-sm text-gray-500">Overall Rating</p>
                      </div>

                      <div>
                        <div className="flex justify-between mb-1">
                          <span className="text-sm">Consistency</span>
                          <span className="text-sm font-medium">{consistency}%</span>
                        </div>
                        <div className="w-full bg-gray-200 rounded-full h-2">
                          <div
                            className="bg-green-600 h-2 rounded-full"
                            style={{ width: `${consistency}%` }}
                          ></div>
                        </div>
                      </div>

                      <div>
                        <div className="flex justify-between mb-1">
                          <span className="text-sm">Technique</span>
                          <span className="text-sm font-medium">{technique}%</span>
                        </div>
                        <div className="w-full bg-gray-200 rounded-full h-2">
                          <div
                            className="bg-blue-600 h-2 rounded-full"
                            style={{ width: `${technique}%` }}
                          ></div>
                        </div>
                      </div>

                      <div>
                        <div className="flex justify-between mb-1">
                          <span className="text-sm">Stamina</span>
                          <span className="text-sm font-medium">{stamina}%</span>
                        </div>
                        <div className="w-full bg-gray-200 rounded-full h-2">
                          <div
                            className="bg-purple-600 h-2 rounded-full"
                            style={{ width: `${stamina}%` }}
                          ></div>
                        </div>
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
}

export default ViewPlayers;