import React, { useState, useEffect } from "react";
import { useNavigate, useParams } from "react-router-dom";
import axios from "axios";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { Select, SelectTrigger, SelectValue, SelectContent, SelectItem } from "@/components/ui/select";
import { Button } from "@/components/ui/button";
import { Dialog, DialogTrigger, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Loader2, CheckCircle2, AlertCircle } from "lucide-react";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Textarea } from "@/components/ui/textarea";

const sportsEnum = ["Cricket", "Basketball", "Football", "Tennis", "Swimming", "Athletics", "Badminton", "Hockey", "Volleyball", "Table Tennis"];
const skillLevelEnum = ["Beginner", "Intermediate", "Advanced", "Elite"];
const bloodGroupEnum = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"];
const dominantHandEnum = ["Right", "Left", "Ambidextrous"];

const AthleteManagement = () => {
  const navigate = useNavigate();
  const [selectedSport, setSelectedSport] = useState("All");
  const [athletes, setAthletes] = useState([]);
  const [filteredAthletes, setFilteredAthletes] = useState([]);
  const [loading, setLoading] = useState(true);
  const [registering, setRegistering] = useState(false);
  const [successMessage, setSuccessMessage] = useState("");
  const [errorMessage, setErrorMessage] = useState("");
  const [coaches, setCoaches] = useState([]);
  const [gymTrainers, setGymTrainers] = useState([]);
  const [medicalStaff, setMedicalStaff] = useState([]);
  const [dialogOpen, setDialogOpen] = useState(false);
  const [activeTab, setActiveTab] = useState("basic");
  
  // Get organization ID from localStorage (admin should be logged in)
  const adminData = JSON.parse(localStorage.getItem('userData') || '{}');
  const {organizationId} = useParams();
  
  const defaultAthleteState = {
    // Basic Information
    name: "",
    email: "",
    password: "",
    dob: "",
    gender: "",
    nationality: "India",
    address: "",
    phoneNumber: "",
    
    // School Information
    schoolName: "",
    year: "",
    studentId: "",
    schoolEmail: "",
    schoolWebsite: "",
    sports: [],
    skillLevel: "",
    trainingStartDate: new Date().toISOString().split('T')[0],
    positions: {},
    dominantHand: "",
    headCoachAssigned: "none", // Changed from empty string to "none"
    gymTrainerAssigned: "none", // Changed from empty string to "none"
    medicalStaffAssigned: "none", // Changed from empty string to "none"
    
    // Medical Information
    height: "",
    weight: "",
    bloodGroup: "",
    allergies: "",
    medicalConditions: "",
    
    // Emergency Contact
    emergencyContactName: "",
    emergencyContactNumber: "",
    emergencyContactRelationship: "",
    
    // Files
    avatar: null,
    uploadSchoolId: null,
    latestMarksheet: null,
  };
  
  const [newAthlete, setNewAthlete] = useState({...defaultAthleteState});
  
  // Update the fetchData function in the useEffect hook
useEffect(() => {
  const fetchData = async () => {
    if (!organizationId) {
      setLoading(false);
      return;
    }
    
    try {
      // Fetch athletes using new endpoint with query parameters
      const athletesResponse = await axios.get(`http://localhost:8000/api/v1/admins/athletes`, {
        params: {
          organizationId: organizationId,
          limit: 50 // Adjust as needed
        },
        withCredentials: true
      });
      
      if (athletesResponse.data && athletesResponse.data.data) {
        // Update to match the new response structure
        setAthletes(athletesResponse.data.data.athletes || []);
        setFilteredAthletes(athletesResponse.data.data.athletes || []);
      }
      
      // Rest of the function remains the same...
      // Fetch coaches
      const coachesResponse = await axios.get(`/api/v1/admin/coaches/${organizationId}`, {
        withCredentials: true
      });
      
      if (coachesResponse.data && coachesResponse.data.data) {
        setCoaches(coachesResponse.data.data.coaches || []);
        
        // Filter for gym trainers (assuming they have a role property)
        setGymTrainers(
          coachesResponse.data.data.coaches.filter(c => c.specialization === "Fitness" || c.role === "trainer") || []
        );
      }
      
      // Fetch medical staff
      const medicalResponse = await axios.get(`/api/v1/admin/medical-staff/${organizationId}`, {
        withCredentials: true
      });
      
      if (medicalResponse.data && medicalResponse.data.data) {
        setMedicalStaff(medicalResponse.data.data.medicalStaff || []);
      }
    } catch (error) {
      console.error("Error fetching data:", error);
    } finally {
      setLoading(false);
    }
  };
  
  fetchData();
}, [organizationId]);
  
  // Filter athletes by sport
  const handleSportChange = (sport) => {
    setSelectedSport(sport);
    if (sport === "All") {
      setFilteredAthletes(athletes);
    } else {
      setFilteredAthletes(athletes.filter(athlete => athlete.sports.includes(sport)));
    }
  };

  // Handle sport selection (multiple sports possible)
  const handleSportSelection = (sportName) => {
    setNewAthlete(prev => {
      const sports = prev.sports.includes(sportName)
        ? prev.sports.filter(s => s !== sportName)
        : [...prev.sports, sportName];
      return { ...prev, sports };
    });
  };
  
  // Handle file uploads
  const handleFileChange = (e, fieldName) => {
    if (e.target.files && e.target.files[0]) {
      setNewAthlete(prev => ({
        ...prev,
        [fieldName]: e.target.files[0]
      }));
    }
  };
  
  // Calculate BMI automatically
  const calculateBMI = () => {
    if (newAthlete.height && newAthlete.weight) {
      const heightInMeters = Number(newAthlete.height) / 100;
      if (heightInMeters > 0) {
        const bmi = (Number(newAthlete.weight) / (heightInMeters * heightInMeters)).toFixed(1);
        return isNaN(bmi) ? "" : bmi;
      }
    }
    return "";
  };
  
  // Handle position selection for each sport
  const handlePositionChange = (sport, position) => {
    setNewAthlete(prev => ({
      ...prev,
      positions: {
        ...prev.positions,
        [sport]: position
      }
    }));
  };
  
  // Tab change handler
  const handleTabChange = (value) => {
    setActiveTab(value);
  };

  // View athlete profile
  const handleViewProfile = (athleteId) => {
    if (athleteId) {
      navigate(`/admin-dashboard/athlete/${athleteId}`);
    }
  };

  // Update the handleAddAthlete function with better error handling and form validation
  const handleAddAthlete = async () => {
    // Reset error message
    setErrorMessage("");
    
    // Perform tab-specific validation
    let isValid = true;
    let tabToFocus = activeTab;
    
    // Basic tab validation
    if (!newAthlete.name || !newAthlete.email || !newAthlete.password || !newAthlete.dob || 
        !newAthlete.gender || !newAthlete.nationality || !newAthlete.address || !newAthlete.phoneNumber) {
      isValid = false;
      tabToFocus = "basic";
      setErrorMessage("Please fill all required fields in the Basic Info tab");
    }
    
    // School tab validation - only check if basic was valid
    else if (!newAthlete.schoolName || !newAthlete.year || !newAthlete.studentId || 
             newAthlete.sports.length === 0 || !newAthlete.skillLevel || !newAthlete.trainingStartDate) {
      isValid = false;
      tabToFocus = "school";
      setErrorMessage("Please fill all required fields in the School & Sports tab");
    }
    
    // Medical tab validation - only check if school was valid
    else if (!newAthlete.height || !newAthlete.weight) {
      isValid = false;
      tabToFocus = "medical";
      setErrorMessage("Please enter height and weight in the Medical Info tab");
    }
    
    // Emergency tab validation - only check if medical was valid
    else if (!newAthlete.emergencyContactName || !newAthlete.emergencyContactNumber || 
             !newAthlete.emergencyContactRelationship) {
      isValid = false;
      tabToFocus = "emergency";
      setErrorMessage("Please complete all emergency contact fields");
    }
    
    // If validation failed, switch to the tab with errors
    if (!isValid) {
      setActiveTab(tabToFocus);
      return;
    }
    
    // If we reached here, all validation passed
    setRegistering(true);
    
    try {
      // Create FormData for file uploads
      const formData = new FormData();
      
      // Append basic information
      formData.append('name', newAthlete.name);
      formData.append('email', newAthlete.email);
      formData.append('password', newAthlete.password);
      formData.append('dob', newAthlete.dob);
      formData.append('gender', newAthlete.gender);
      formData.append('nationality', newAthlete.nationality);
      formData.append('address', newAthlete.address);
      formData.append('phoneNumber', newAthlete.phoneNumber);
      
      // Append school information
      formData.append('schoolName', newAthlete.schoolName);
      formData.append('year', newAthlete.year);
      formData.append('studentId', newAthlete.studentId);
      if (newAthlete.schoolEmail) formData.append('schoolEmail', newAthlete.schoolEmail);
      if (newAthlete.schoolWebsite) formData.append('schoolWebsite', newAthlete.schoolWebsite);
      
      // Append sports information
      newAthlete.sports.forEach(sport => {
        formData.append('sports', sport);
      });
      
      formData.append('skillLevel', newAthlete.skillLevel);
      formData.append('trainingStartDate', newAthlete.trainingStartDate);
      if (newAthlete.dominantHand) formData.append('dominantHand', newAthlete.dominantHand);
      
      // Convert positions object to JSON string
      if (Object.keys(newAthlete.positions).length > 0) {
        formData.append('positions', JSON.stringify(newAthlete.positions));
      }
      
      // Append staff assignments (if not "none")
      if (newAthlete.headCoachAssigned && newAthlete.headCoachAssigned !== "none") {
        formData.append('headCoachAssigned', newAthlete.headCoachAssigned);
      }
      
      if (newAthlete.gymTrainerAssigned && newAthlete.gymTrainerAssigned !== "none") {
        formData.append('gymTrainerAssigned', newAthlete.gymTrainerAssigned);
      }
      
      if (newAthlete.medicalStaffAssigned && newAthlete.medicalStaffAssigned !== "none") {
        formData.append('medicalStaffAssigned', newAthlete.medicalStaffAssigned);
      }
      
      // Append medical information
      formData.append('height', newAthlete.height);
      formData.append('weight', newAthlete.weight);
      if (newAthlete.bloodGroup) formData.append('bloodGroup', newAthlete.bloodGroup);
      
      // Process allergies and medical conditions - split comma-separated values into arrays
      if (newAthlete.allergies) {
        const allergyArray = newAthlete.allergies.split(',').map(item => item.trim()).filter(Boolean);
        allergyArray.forEach(allergy => {
          formData.append('allergies', allergy);
        });
      }
      
      if (newAthlete.medicalConditions) {
        const conditionsArray = newAthlete.medicalConditions.split(',').map(item => item.trim()).filter(Boolean);
        conditionsArray.forEach(condition => {
          formData.append('medicalConditions', condition);
        });
      }
      
      // Append emergency contact
      formData.append('emergencyContactName', newAthlete.emergencyContactName);
      formData.append('emergencyContactNumber', newAthlete.emergencyContactNumber);
      formData.append('emergencyContactRelationship', newAthlete.emergencyContactRelationship);
      
      // Add organization ID
      formData.append('organizationId', organizationId);
      
      // Append files if they exist
      if (newAthlete.avatar) {
        formData.append('avatar', newAthlete.avatar);
      }
      
      if (newAthlete.uploadSchoolId) {
        formData.append('uploadSchoolId', newAthlete.uploadSchoolId);
      }
      
      if (newAthlete.latestMarksheet) {
        formData.append('latestMarksheet', newAthlete.latestMarksheet);
      }
      
      // Make API call with 30s timeout
      const response = await axios.post('http://localhost:8000/api/v1/admins/register-organization-athlete', formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
        withCredentials: true,
        timeout: 30000
      });
      
      // In the handleAddAthlete function, after successful registration
if (response.data && response.data.data && response.data.data.athlete) {
  const newAthleteData = response.data.data.athlete;
  
  // Refresh the athlete list from API to get the most up-to-date data
  try {
    const params = {
      organizationId: organizationId,
      limit: 50
    };
    
    if (selectedSport !== "All") {
      params.sport = selectedSport;
    }
    
    const refreshResponse = await axios.get(`/api/v1/admin/athletes`, {
      params,
      withCredentials: true
    });
    
    if (refreshResponse.data && refreshResponse.data.data) {
      setAthletes(refreshResponse.data.data.athletes || []);
      setFilteredAthletes(refreshResponse.data.data.athletes || []);
    }
  } catch (refreshError) {
    console.error("Error refreshing athlete list:", refreshError);
    
    // Fallback to adding the new athlete to the existing list
    setAthletes(prev => [...prev, newAthleteData]);
    
    if (selectedSport === "All" || newAthleteData.sports.includes(selectedSport)) {
      setFilteredAthletes(prev => [...prev, newAthleteData]);
    }
  }
  
  // Show success message
  setSuccessMessage("Athlete registered successfully!");
  
  // Reset form and close dialog after short delay
  setTimeout(() => {
    setNewAthlete({...defaultAthleteState});
    setDialogOpen(false);
    setSuccessMessage("");
  }, 2000);
} else if (err.request) {
        setErrorMessage("No response from server. Please check your network connection.");
      } else {
        setErrorMessage(`Error: ${err.message}`);
      }
    } finally {
      setRegistering(false);
    }
  };

  // Calculate age from date of birth
  const calculateAge = (dob) => {
    const birthDate = new Date(dob);
    const today = new Date();
    let age = today.getFullYear() - birthDate.getFullYear();
    const m = today.getMonth() - birthDate.getMonth();
    if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
      age--;
    }
    return age;
  };
  
  return (
    <div className="p-6 space-y-6">
      <h1 className="text-2xl font-bold">Athlete Management</h1>

      {loading ? (
        <div className="flex justify-center items-center h-64">
          <Loader2 className="h-8 w-8 animate-spin text-green-600" />
          <span className="ml-2 text-lg">Loading athletes...</span>
        </div>
      ) : (
        <>
          <div className="flex gap-4 items-center">
            <span className="font-medium">Filter by Sport:</span>
            <Select value={selectedSport} onValueChange={handleSportChange}>
              <SelectTrigger className="w-[200px]">
                <SelectValue placeholder="Select Sport">{selectedSport}</SelectValue>
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="All">All</SelectItem>
                {sportsEnum.map((sport) => (
                  <SelectItem key={sport} value={sport}>{sport}</SelectItem>
                ))}
              </SelectContent>
            </Select>
            
            <span className="ml-auto">{filteredAthletes.length} athletes</span>
          </div>

          <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
            <DialogTrigger asChild>
              <Button className="bg-green-600 hover:bg-green-700">Register New Athlete</Button>
            </DialogTrigger>

            <DialogContent className="max-w-4xl p-6 rounded-lg bg-white shadow-lg overflow-y-auto max-h-[90vh]">
              <DialogHeader>
                <DialogTitle className="text-2xl font-semibold text-gray-800">Register New Athlete</DialogTitle>
              </DialogHeader>

              {errorMessage && (
                <Alert variant="destructive" className="mb-4">
                  <AlertCircle className="h-4 w-4" />
                  <AlertDescription>{errorMessage}</AlertDescription>
                </Alert>
              )}
              
              {successMessage && (
                <Alert variant="success" className="mb-4 bg-green-50 text-green-700 border-green-200">
                  <CheckCircle2 className="h-4 w-4" />
                  <AlertDescription>{successMessage}</AlertDescription>
                </Alert>
              )}

              <Tabs value={activeTab} onValueChange={handleTabChange}>
                <TabsList className="grid grid-cols-4 mb-4">
                  <TabsTrigger value="basic">Basic Info</TabsTrigger>
                  <TabsTrigger value="school">School & Sports</TabsTrigger>
                  <TabsTrigger value="medical">Medical Info</TabsTrigger>
                  <TabsTrigger value="emergency">Emergency Contact</TabsTrigger>
                </TabsList>
                
                <TabsContent value="basic" className="space-y-4">
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium mb-1">Full Name *</label>
                      <input
                        type="text"
                        className="w-full p-2 border rounded"
                        value={newAthlete.name}
                        onChange={(e) => setNewAthlete({...newAthlete, name: e.target.value})}
                        required
                      />
                    </div>
                    
                    <div>
                      <label className="block text-sm font-medium mb-1">Email *</label>
                      <input
                        type="email"
                        className="w-full p-2 border rounded"
                        value={newAthlete.email}
                        onChange={(e) => setNewAthlete({...newAthlete, email: e.target.value})}
                        required
                      />
                    </div>
                  </div>
                  
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium mb-1">Password *</label>
                      <input
                        type="password"
                        className="w-full p-2 border rounded"
                        value={newAthlete.password}
                        onChange={(e) => setNewAthlete({...newAthlete, password: e.target.value})}
                        required
                      />
                    </div>
                    
                    <div>
                      <label className="block text-sm font-medium mb-1">Date of Birth *</label>
                      <input
                        type="date"
                        className="w-full p-2 border rounded"
                        value={newAthlete.dob}
                        onChange={(e) => setNewAthlete({...newAthlete, dob: e.target.value})}
                        required
                      />
                    </div>
                  </div>
                  
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium mb-1">Gender *</label>
                      <Select 
                        value={newAthlete.gender} 
                        onValueChange={(value) => setNewAthlete({...newAthlete, gender: value})}
                      >
                        <SelectTrigger>
                          <SelectValue placeholder="Select Gender" />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="Male">Male</SelectItem>
                          <SelectItem value="Female">Female</SelectItem>
                          <SelectItem value="Other">Other</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>
                    
                    <div>
                      <label className="block text-sm font-medium mb-1">Nationality *</label>
                      <input
                        type="text"
                        className="w-full p-2 border rounded"
                        value={newAthlete.nationality}
                        onChange={(e) => setNewAthlete({...newAthlete, nationality: e.target.value})}
                        required
                      />
                    </div>
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium mb-1">Address *</label>
                    <input
                      type="text"
                      className="w-full p-2 border rounded"
                      value={newAthlete.address}
                      onChange={(e) => setNewAthlete({...newAthlete, address: e.target.value})}
                      required
                    />
                  </div>
                  
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium mb-1">Phone Number *</label>
                      <input
                        type="tel"
                        className="w-full p-2 border rounded"
                        value={newAthlete.phoneNumber}
                        onChange={(e) => setNewAthlete({...newAthlete, phoneNumber: e.target.value})}
                        required
                      />
                    </div>
                    
                    <div>
                      <label className="block text-sm font-medium mb-1">Profile Photo</label>
                      <input
                        type="file"
                        accept="image/*"
                        className="w-full p-2 border rounded"
                        onChange={(e) => handleFileChange(e, 'avatar')}
                      />
                    </div>
                  </div>
                </TabsContent>
                
                <TabsContent value="school" className="space-y-4">
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium mb-1">School/College Name *</label>
                      <input
                        type="text"
                        className="w-full p-2 border rounded"
                        value={newAthlete.schoolName}
                        onChange={(e) => setNewAthlete({...newAthlete, schoolName: e.target.value})}
                        required
                      />
                    </div>
                    
                    <div>
                      <label className="block text-sm font-medium mb-1">Year/Grade *</label>
                      <input
                        type="text"
                        className="w-full p-2 border rounded"
                        value={newAthlete.year}
                        onChange={(e) => setNewAthlete({...newAthlete, year: e.target.value})}
                        required
                      />
                    </div>
                  </div>
                  
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium mb-1">Student ID *</label>
                      <input
                        type="text"
                        className="w-full p-2 border rounded"
                        value={newAthlete.studentId}
                        onChange={(e) => setNewAthlete({...newAthlete, studentId: e.target.value})}
                        required
                      />
                    </div>
                    
                    <div>
                      <label className="block text-sm font-medium mb-1">School Email</label>
                      <input
                        type="email"
                        className="w-full p-2 border rounded"
                        value={newAthlete.schoolEmail}
                        onChange={(e) => setNewAthlete({...newAthlete, schoolEmail: e.target.value})}
                      />
                    </div>
                  </div>
                  
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium mb-1">School Website</label>
                      <input
                        type="url"
                        className="w-full p-2 border rounded"
                        value={newAthlete.schoolWebsite}
                        onChange={(e) => setNewAthlete({...newAthlete, schoolWebsite: e.target.value})}
                      />
                    </div>
                    
                    <div>
                      <label className="block text-sm font-medium mb-1">School ID Document</label>
                      <input
                        type="file"
                        className="w-full p-2 border rounded"
                        onChange={(e) => handleFileChange(e, 'uploadSchoolId')}
                      />
                    </div>
                  </div>
                  
                  <div className="mb-2">
                    <label className="block text-sm font-medium mb-1">Latest Marksheet</label>
                    <input
                      type="file"
                      className="w-full p-2 border rounded"
                      onChange={(e) => handleFileChange(e, 'latestMarksheet')}
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium mb-1">Sports (Select all that apply) *</label>
                    <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-5 gap-2 mt-1">
                      {sportsEnum.map(sport => (
                        <div 
                          key={sport}
                          className={`p-2 border rounded cursor-pointer text-center text-sm ${
                            newAthlete.sports.includes(sport) 
                              ? 'bg-green-600 text-white border-green-700' 
                              : 'bg-gray-50 hover:bg-gray-100'
                          }`}
                          onClick={() => handleSportSelection(sport)}
                        >
                          {sport}
                        </div>
                      ))}
                    </div>
                  </div>
                  
                  {newAthlete.sports.length > 0 && (
                    <div>
                      <label className="block text-sm font-medium mb-1">Positions</label>
                      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                        {newAthlete.sports.map(sport => (
                          <div key={sport} className="flex items-center">
                            <span className="w-1/3">{sport}:</span>
                            <input
                              type="text"
                              className="w-2/3 p-2 border rounded"
                              placeholder={`Position in ${sport}`}
                              value={newAthlete.positions[sport] || ''}
                              onChange={(e) => handlePositionChange(sport, e.target.value)}
                            />
                          </div>
                        ))}
                      </div>
                    </div>
                  )}
                  
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium mb-1">Skill Level *</label>
                      <Select 
                        value={newAthlete.skillLevel} 
                        onValueChange={(value) => setNewAthlete({...newAthlete, skillLevel: value})}
                      >
                        <SelectTrigger>
                          <SelectValue placeholder="Select Skill Level" />
                        </SelectTrigger>
                        <SelectContent>
                          {skillLevelEnum.map(level => (
                            <SelectItem key={level} value={level}>{level}</SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </div>
                    
                    <div>
                      <label className="block text-sm font-medium mb-1">Training Start Date *</label>
                      <input
                        type="date"
                        className="w-full p-2 border rounded"
                        value={newAthlete.trainingStartDate}
                        onChange={(e) => setNewAthlete({...newAthlete, trainingStartDate: e.target.value})}
                        required
                      />
                    </div>
                  </div>
                  
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium mb-1">Dominant Hand</label>
                      <Select 
                        value={newAthlete.dominantHand || undefined} 
                        onValueChange={(value) => setNewAthlete({...newAthlete, dominantHand: value})}
                      >
                        <SelectTrigger>
                          <SelectValue placeholder="Select Dominant Hand" />
                        </SelectTrigger>
                        <SelectContent>
                          {dominantHandEnum.map(hand => (
                            <SelectItem key={hand} value={hand}>{hand}</SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </div>
                  </div>
                  
                  {/* Staff Assignment Section */}
                  <div>
                    <h3 className="text-md font-medium mb-2">Staff Assignments</h3>
                    
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                      <div>
                        <label className="block text-sm font-medium mb-1">Head Coach</label>
                        <Select 
                          value={newAthlete.headCoachAssigned} 
                          onValueChange={(value) => setNewAthlete({...newAthlete, headCoachAssigned: value})}
                        >
                          <SelectTrigger>
                            <SelectValue placeholder="Select Coach" />
                          </SelectTrigger>
                          <SelectContent>
                            <SelectItem value="none">None</SelectItem>
                            {coaches.map((coach) => (
                              <SelectItem key={coach._id} value={coach._id}>{coach.name}</SelectItem>
                            ))}
                          </SelectContent>
                        </Select>
                      </div>
                      
                      <div>
                        <label className="block text-sm font-medium mb-1">Gym Trainer</label>
                        <Select 
                          value={newAthlete.gymTrainerAssigned} 
                          onValueChange={(value) => setNewAthlete({...newAthlete, gymTrainerAssigned: value})}
                        >
                          <SelectTrigger>
                            <SelectValue placeholder="Select Trainer" />
                          </SelectTrigger>
                          <SelectContent>
                            <SelectItem value="none">None</SelectItem>
                            {gymTrainers.map((trainer) => (
                              <SelectItem key={trainer._id} value={trainer._id}>{trainer.name}</SelectItem>
                            ))}
                          </SelectContent>
                        </Select>
                      </div>
                    </div>
                    
                    <div className="mt-4">
                      <label className="block text-sm font-medium mb-1">Medical Staff</label>
                      <Select 
                        value={newAthlete.medicalStaffAssigned} 
                        onValueChange={(value) => setNewAthlete({...newAthlete, medicalStaffAssigned: value})}
                      >
                        <SelectTrigger>
                          <SelectValue placeholder="Select Medical Staff" />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="none">None</SelectItem>
                          {medicalStaff.map((staff) => (
                            <SelectItem key={staff._id} value={staff._id}>{staff.name}</SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </div>
                  </div>
                </TabsContent>
                
                {/* Medical Info Tab */}
                <TabsContent value="medical" className="space-y-4">
                  <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                    <div>
                      <label className="block text-sm font-medium mb-1">Height (cm) *</label>
                      <input
                        type="number"
                        className="w-full p-2 border rounded"
                        value={newAthlete.height}
                        onChange={(e) => setNewAthlete({...newAthlete, height: e.target.value})}
                        required
                      />
                    </div>
                    
                    <div>
                      <label className="block text-sm font-medium mb-1">Weight (kg) *</label>
                      <input
                        type="number"
                        className="w-full p-2 border rounded"
                        value={newAthlete.weight}
                        onChange={(e) => setNewAthlete({...newAthlete, weight: e.target.value})}
                        required
                      />
                    </div>
                    
                    <div>
                      <label className="block text-sm font-medium mb-1">BMI</label>
                      <input
                        type="text"
                        className="w-full p-2 border rounded bg-gray-50"
                        value={calculateBMI()}
                        readOnly
                      />
                    </div>
                  </div>
                  
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium mb-1">Blood Group</label>
                      <Select 
                        value={newAthlete.bloodGroup || undefined} 
                        onValueChange={(value) => setNewAthlete({...newAthlete, bloodGroup: value})}
                      >
                        <SelectTrigger>
                          <SelectValue placeholder="Select Blood Group" />
                        </SelectTrigger>
                        <SelectContent>
                          {bloodGroupEnum.map(group => (
                            <SelectItem key={group} value={group}>{group}</SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </div>
                    
                    <div>
                      <label className="block text-sm font-medium mb-1">Allergies</label>
                      <Textarea
                        placeholder="List allergies, separated by commas"
                        className="w-full p-2 border rounded resize-none"
                        value={newAthlete.allergies}
                        onChange={(e) => setNewAthlete({...newAthlete, allergies: e.target.value})}
                      />
                    </div>
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium mb-1">Medical Conditions</label>
                    <Textarea
                      placeholder="List any medical conditions, separated by commas"
                      className="w-full p-2 border rounded resize-none"
                      value={newAthlete.medicalConditions}
                      onChange={(e) => setNewAthlete({...newAthlete, medicalConditions: e.target.value})}
                    />
                  </div>
                </TabsContent>
                
                {/* Emergency Contact Tab */}
                <TabsContent value="emergency" className="space-y-4">
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium mb-1">Emergency Contact Name *</label>
                      <input
                        type="text"
                        className="w-full p-2 border rounded"
                        value={newAthlete.emergencyContactName}
                        onChange={(e) => setNewAthlete({...newAthlete, emergencyContactName: e.target.value})}
                        required
                      />
                    </div>
                    
                    <div>
                      <label className="block text-sm font-medium mb-1">Emergency Contact Number *</label>
                      <input
                        type="tel"
                        className="w-full p-2 border rounded"
                        value={newAthlete.emergencyContactNumber}
                        onChange={(e) => setNewAthlete({...newAthlete, emergencyContactNumber: e.target.value})}
                        required
                      />
                    </div>
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium mb-1">Relationship to Athlete *</label>
                    <input
                      type="text"
                      className="w-full p-2 border rounded"
                      placeholder="e.g., Parent, Sibling, Guardian"
                      value={newAthlete.emergencyContactRelationship}
                      onChange={(e) => setNewAthlete({...newAthlete, emergencyContactRelationship: e.target.value})}
                      required
                    />
                  </div>
                </TabsContent>
              </Tabs>
              
              <DialogFooter className="mt-6">
                <Button 
                  variant="outline" 
                  onClick={() => setDialogOpen(false)}
                  disabled={registering}
                  className="border-gray-300"
                >
                  Cancel
                </Button>
                <Button 
                  onClick={handleAddAthlete} 
                  className="bg-green-600 hover:bg-green-700 ml-2"
                  disabled={registering}
                >
                  {registering ? (
                    <>
                      <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                      Registering...
                    </>
                  ) : "Register Athlete"}
                </Button>
              </DialogFooter>
            </DialogContent>
          </Dialog>

          {/* Athletes Grid */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {filteredAthletes.map((athlete) => (
              <Card 
                key={athlete._id} 
                className="overflow-hidden hover:shadow-lg transition-shadow duration-300 cursor-pointer"
                onClick={() => handleViewProfile(athlete._id)}
              >
                <CardHeader className="pb-2">
                  <CardTitle className="flex items-center gap-2">
                    {athlete.avatar ? (
                      <img 
                        src={athlete.avatar} 
                        alt={athlete.name} 
                        className="h-10 w-10 rounded-full object-cover"
                      />
                    ) : (
                      <div className="h-10 w-10 rounded-full bg-green-100 flex items-center justify-center text-green-600 font-bold">
                        {athlete.name.charAt(0).toUpperCase()}
                      </div>
                    )}
                    <div>
                      <p className="text-base font-semibold">{athlete.name}</p>
                      <p className="text-xs text-gray-500">ID: {athlete.athleteId}</p>
                    </div>
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="text-sm space-y-2">
                    <div className="flex justify-between">
                      <span className="text-gray-500">Sports:</span>
                      <span className="font-medium">{athlete.sports.join(", ")}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-gray-500">Skill Level:</span>
                      <span className="font-medium">{athlete.skillLevel}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-gray-500">Age:</span>
                      <span className="font-medium">{calculateAge(athlete.dob)} years</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-gray-500">Email:</span>
                      <span className="font-medium text-xs truncate">{athlete.email}</span>
                    </div>
                    <div className="mt-2 pt-2 border-t border-gray-100 text-center">
                      <span className="text-blue-600 text-xs hover:underline">View Full Profile</span>
                    </div>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>

          {/* Show message if no athletes found */}
          {filteredAthletes.length === 0 && (
            <div className="flex flex-col items-center justify-center p-10 bg-gray-50 rounded-lg border border-dashed border-gray-300">
              <p className="text-lg text-gray-500 mb-4">No athletes found{selectedSport !== "All" ? ` for ${selectedSport}` : ""}.</p>
              <Button 
                className="bg-green-600 hover:bg-green-700"
                onClick={() => setDialogOpen(true)}
              >
                Register New Athlete
              </Button>
            </div>
          )}
        </>
      )}
    </div>
  );
};

export default AthleteManagement;