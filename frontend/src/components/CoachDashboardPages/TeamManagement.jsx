import { useState, useEffect, useMemo } from "react";
import { useNavigate } from "react-router-dom";
import axios from "axios";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Loader2, Search, UserCircle, Shield, Filter } from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";

const TeamManagement = () => {
  const [athletes, setAthletes] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState(null);
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedSport, setSelectedSport] = useState("All");
  const [availableSports, setAvailableSports] = useState(["All"]);
  const navigate = useNavigate();

  // Fetch assigned athletes from the API
  useEffect(() => {
    const fetchAssignedAthletes = async () => {
      setIsLoading(true);
      try {
        const response = await axios.get(
          "http://localhost:8000/api/v1/coaches/assigned-athletes",
          { withCredentials: true }
        );
        
        if (response.data.success) {
          setAthletes(response.data.data || []);
          
          // Extract unique sports from athletes
          const sports = new Set();
          sports.add("All");
          response.data.data.forEach(athlete => {
            if (athlete.sports && athlete.sports.length) {
              athlete.sports.forEach(sport => sports.add(sport));
            }
          });
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

  // Filter athletes based on search query and selected sport
  const filteredAthletes = useMemo(() => {
    return athletes.filter((athlete) => {
      const matchesSearch = athlete.name.toLowerCase().includes(searchQuery.toLowerCase());
      const matchesSport = selectedSport === "All" || 
        (athlete.sports && athlete.sports.includes(selectedSport));
      
      return matchesSearch && matchesSport;
    });
  }, [athletes, searchQuery, selectedSport]);
  
  // Group athletes by skill level for the tabs view
  const athletesBySkill = useMemo(() => {
    const grouped = {
      Beginner: [],
      Intermediate: [],
      Advanced: [],
      Elite: []
    };
    
    filteredAthletes.forEach(athlete => {
      if (athlete.skillLevel) {
        grouped[athlete.skillLevel].push(athlete);
      } else {
        grouped.Beginner.push(athlete);
      }
    });
    
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
                        <AthleteCard key={athlete._id} athlete={athlete} navigate={navigate} getAgeFromDob={getAgeFromDob} />
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
                            <AthleteCard key={athlete._id} athlete={athlete} navigate={navigate} getAgeFromDob={getAgeFromDob} />
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
    </div>
  );
};

// Extracted AthleteCard component for better organization
const AthleteCard = ({ athlete, navigate, getAgeFromDob }) => {
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
          onClick={() => navigate(`/athlete-profile/${athlete._id}`)}
        >
          View Profile
        </Button>
      </div>
    </div>
  );
};

export default TeamManagement;