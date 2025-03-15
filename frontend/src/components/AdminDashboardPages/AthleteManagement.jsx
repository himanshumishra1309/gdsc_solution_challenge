import React, { useState, useEffect } from "react";
import { useNavigate, useParams } from "react-router-dom";
import axios from "axios";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { Select, SelectTrigger, SelectValue, SelectContent, SelectItem } from "@/components/ui/select";
import { Button } from "@/components/ui/button";
import { Dialog, DialogTrigger, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Loader2, CheckCircle2, AlertCircle, ArrowLeft, ArrowRight, ChevronLeft, ChevronRight } from "lucide-react";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Textarea } from "@/components/ui/textarea";
import { Input } from "@/components/ui/input";

const sportsEnum = ["Cricket", "Basketball", "Football", "Tennis", "Swimming", "Athletics", "Badminton", "Hockey", "Volleyball", "Table Tennis"];
const skillLevelEnum = ["Beginner", "Intermediate", "Advanced", "Elite"];
const bloodGroupEnum = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"];
const dominantHandEnum = ["Right", "Left", "Ambidextrous"];
const genderEnum = ["Male", "Female", "Other"];

const AthleteManagement = () => {
  const navigate = useNavigate();
  const [selectedSport, setSelectedSport] = useState("All");
  const [selectedGender, setSelectedGender] = useState("All");
  const [selectedSkillLevel, setSelectedSkillLevel] = useState("All");
  const [athletes, setAthletes] = useState([]);
  const [loading, setLoading] = useState(true);
  const [registering, setRegistering] = useState(false);
  const [successMessage, setSuccessMessage] = useState("");
  const [errorMessage, setErrorMessage] = useState("");
  const [coaches, setCoaches] = useState([]);
  const [gymTrainers, setGymTrainers] = useState([]);
  const [medicalStaff, setMedicalStaff] = useState([]);
  const [dialogOpen, setDialogOpen] = useState(false);
  const [activeTab, setActiveTab] = useState("basic");
  const [searchQuery, setSearchQuery] = useState("");
  
  // Pagination state
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [totalAthletes, setTotalAthletes] = useState(0);
  const [limit, setLimit] = useState(10);
  
  // Sorting state
  const [sortField, setSortField] = useState("name");
  const [sortOrder, setSortOrder] = useState("asc");
  
  // Get organization ID from params
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
    headCoachAssigned: "none",
    gymTrainerAssigned: "none",
    medicalStaffAssigned: "none",
    
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
  
  // Function to fetch athletes with filters and pagination
  const fetchAthletes = async () => {
    setLoading(true);
    
    try {
      // Build query parameters
      const params = {
        page: currentPage,
        limit: limit,
        sort: sortField,
        order: sortOrder,
        organizationId: organizationId
      };
      
      // Add filters if selected
      if (selectedSport !== "All") {
        params.sport = selectedSport;
      }
      
      if (selectedGender !== "All") {
        params.gender = selectedGender;
      }
      
      if (selectedSkillLevel !== "All") {
        params.skillLevel = selectedSkillLevel;
      }
      
      // Add search if present
      if (searchQuery) {
        params.search = searchQuery;
      }
      
      // Fetch athletes from API
      const athletesResponse = await axios.get(
        "http://localhost:8000/api/v1/admins/athletes", 
        {
          params: params,
          withCredentials: true
        }
      );
      
      if (athletesResponse.data && athletesResponse.data.data) {
        setAthletes(athletesResponse.data.data.athletes || []);
        
        // Update pagination state
        const pagination = athletesResponse.data.data.pagination;
        setTotalPages(pagination.totalPages);
        setTotalAthletes(pagination.totalAthletes);
        setCurrentPage(pagination.currentPage);
      }
    } catch (error) {
      console.error("Error fetching athletes:", error);
      setErrorMessage("Failed to load athletes. Please try again.");
    } finally {
      setLoading(false);
    }
  };
  
  // Function to fetch coaches and staff
  const fetchStaff = async () => {
    try {
      // Fetch coaches
      const coachesResponse = await axios.get(
        "http://localhost:8000/api/v1/admin/coaches", 
        {
          params: { organizationId },
          withCredentials: true
        }
      );
      
      if (coachesResponse.data && coachesResponse.data.data) {
        setCoaches(coachesResponse.data.data.coaches || []);
        
        // Filter for gym trainers (assuming they have a role property)
        setGymTrainers(
          coachesResponse.data.data.coaches.filter(c => c.specialization === "Fitness" || c.role === "trainer") || []
        );
      }
      
      // Fetch medical staff
      const medicalResponse = await axios.get(
        "http://localhost:8000/api/v1/admin/medical-staff", 
        {
          params: { organizationId },
          withCredentials: true
        }
      );
      
      if (medicalResponse.data && medicalResponse.data.data) {
        setMedicalStaff(medicalResponse.data.data.medicalStaff || []);
      }
    } catch (error) {
      console.error("Error fetching staff data:", error);
    }
  };
  
  // Initial data fetch
  useEffect(() => {
    if (organizationId) {
      fetchAthletes();
      fetchStaff();
    } else {
      setLoading(false);
    }
  }, [organizationId, currentPage, limit, sortField, sortOrder, selectedSport, selectedGender, selectedSkillLevel]);
  
  // Handle search with debounce
  useEffect(() => {
    const handler = setTimeout(() => {
      if (organizationId) {
        fetchAthletes();
      }
    }, 500);
    
    return () => {
      clearTimeout(handler);
    };
  }, [searchQuery]);
  
  // Filter handlers
  const handleSportChange = (sport) => {
    setSelectedSport(sport);
    setCurrentPage(1); // Reset to first page when filter changes
  };
  
  const handleGenderChange = (gender) => {
    setSelectedGender(gender);
    setCurrentPage(1);
  };
  
  const handleSkillLevelChange = (level) => {
    setSelectedSkillLevel(level);
    setCurrentPage(1);
  };
  
  // Pagination handlers
  const goToPage = (page) => {
    if (page >= 1 && page <= totalPages) {
      setCurrentPage(page);
    }
  };
  
  const goToPreviousPage = () => {
    if (currentPage > 1) {
      setCurrentPage(currentPage - 1);
    }
  };
  
  const goToNextPage = () => {
    if (currentPage < totalPages) {
      setCurrentPage(currentPage + 1);
    }
  };
  
  // Sorting handler
  const handleSortChange = (field) => {
    if (field === sortField) {
      setSortOrder(sortOrder === "asc" ? "desc" : "asc");
    } else {
      setSortField(field);
      setSortOrder("asc");
    }
    setCurrentPage(1);
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
      navigate(`/admin-dashboard/${organizationId}/athlete/${athleteId}`);
    }
  };

  // Handle adding new athlete
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
      const response = await axios.post(
        'http://localhost:8000/api/v1/admin/register-organization-athlete', 
        formData, 
        {
          headers: {
            'Content-Type': 'multipart/form-data',
          },
          withCredentials: true,
          timeout: 30000
        }
      );
      
      if (response.data && response.data.data && response.data.data.athlete) {
        // Show success message
        setSuccessMessage("Athlete registered successfully!");
        
        // Refresh the athlete list
        fetchAthletes();
        
        // Reset form and close dialog after short delay
        setTimeout(() => {
          setNewAthlete({...defaultAthleteState});
          setDialogOpen(false);
          setSuccessMessage("");
        }, 2000);
      }
    } catch (err) {
      console.error("Error registering athlete:", err);
      
      if (err.response) {
        setErrorMessage(err.response.data.message || "Failed to register athlete. Please check your inputs.");
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

      {loading && athletes.length === 0 ? (
        <div className="flex justify-center items-center h-64">
          <Loader2 className="h-8 w-8 animate-spin text-green-600" />
          <span className="ml-2 text-lg">Loading athletes...</span>
        </div>
      ) : (
        <>
          <div className="bg-white p-4 rounded-lg shadow-sm">
            {/* Search and Filters */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-4">
              <div>
                <label className="text-sm font-medium mb-1 block">Search</label>
                <Input
                  placeholder="Search by name, email, or ID"
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="w-full"
                />
              </div>
              
              <div>
                <label className="text-sm font-medium mb-1 block">Sport</label>
                <Select value={selectedSport} onValueChange={handleSportChange}>
                  <SelectTrigger>
                    <SelectValue placeholder="Select Sport">{selectedSport}</SelectValue>
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="All">All</SelectItem>
                    {sportsEnum.map((sport) => (
                      <SelectItem key={sport} value={sport}>{sport}</SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              
              <div>
                <label className="text-sm font-medium mb-1 block">Gender</label>
                <Select value={selectedGender} onValueChange={handleGenderChange}>
                  <SelectTrigger>
                    <SelectValue placeholder="Select Gender">{selectedGender}</SelectValue>
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="All">All</SelectItem>
                    {genderEnum.map((gender) => (
                      <SelectItem key={gender} value={gender}>{gender}</SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              
              <div>
                <label className="text-sm font-medium mb-1 block">Skill Level</label>
                <Select value={selectedSkillLevel} onValueChange={handleSkillLevelChange}>
                  <SelectTrigger>
                    <SelectValue placeholder="Select Skill Level">{selectedSkillLevel}</SelectValue>
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="All">All</SelectItem>
                    {skillLevelEnum.map((level) => (
                      <SelectItem key={level} value={level}>{level}</SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
            </div>
            
            {/* Results summary & actions row */}
            <div className="flex justify-between items-center mb-4">
              <div className="text-sm text-gray-600">
                Showing {athletes.length} of {totalAthletes} athletes
              </div>
              
              <div className="flex items-center gap-2">
                <Select value={limit.toString()} onValueChange={(val) => setLimit(Number(val))}>
                  <SelectTrigger className="w-[100px]">
                    <SelectValue placeholder="Per page" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="5">5</SelectItem>
                    <SelectItem value="10">10</SelectItem>
                    <SelectItem value="20">20</SelectItem>
                    <SelectItem value="50">50</SelectItem>
                  </SelectContent>
                </Select>
                
                <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
                  <DialogTrigger asChild>
                    <Button className="bg-green-600 hover:bg-green-700">Register New Athlete</Button>
                  </DialogTrigger>
                  
                  {/* Registration Dialog - Keep the existing dialog content */}
                  <DialogContent className="max-w-4xl p-6 rounded-lg bg-white shadow-lg overflow-y-auto max-h-[90vh]">
                    {/* Your existing dialog content - all the tabs, etc. */}
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
                      
                      {/* Keep all your existing TabsContent components here */}
                      {/* TabsContent for "basic" tab */}
                      <TabsContent value="basic" className="space-y-4">
                        {/* Your existing basic info tab content */}
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
                          
                          {/* ...rest of your basic tab fields... */}
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
                          
                          <div className="col-span-2">
                            <label className="block text-sm font-medium mb-1">Address *</label>
                            <input
                              type="text"
                              className="w-full p-2 border rounded"
                              value={newAthlete.address}
                              onChange={(e) => setNewAthlete({...newAthlete, address: e.target.value})}
                              required
                            />
                          </div>
                          
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
                      
                      {/* Include the remaining tabs (school, medical, emergency) here */}
                      {/* ... */}
                      <TabsContent value="school" className="space-y-4">
                        {/* School tab content here */}
                        {/* Keep your existing school tab UI */}
                      </TabsContent>

                      <TabsContent value="medical" className="space-y-4">
                        {/* Medical tab content here */}
                        {/* Keep your existing medical tab UI */}
                      </TabsContent>

                      <TabsContent value="emergency" className="space-y-4">
                        {/* Emergency contact tab content here */}
                        {/* Keep your existing emergency tab UI */}
                      </TabsContent>
                    </Tabs>
                    <DialogFooter className="mt-6">
                      <Button 
                        variant="outline"
                        type="button"
                        onClick={() => setDialogOpen(false)}
                        disabled={registering}
                      >
                        Cancel
                      </Button>
                      <Button 
                        type="button"
                        className="bg-green-600 hover:bg-green-700"
                        onClick={handleAddAthlete}
                        disabled={registering}
                      >
                        {registering ? (
                          <>
                            <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                            Registering...
                          </>
                        ) : (
                          'Register Athlete'
                        )}
                      </Button>
                    </DialogFooter>
                    </DialogContent>
                    </Dialog>
                    </div>
                    </div>
                                
                    {/* Athletes Table */}
                    <div className="overflow-x-auto rounded-lg border">
                      <table className="min-w-full divide-y divide-gray-200">
                        <thead className="bg-gray-50">
                          <tr>
                            <th 
                              scope="col" 
                              className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer"
                              onClick={() => handleSortChange('name')}
                            >
                              Name
                              {sortField === 'name' && (
                                <span className="ml-1">
                                  {sortOrder === 'asc' ? '↑' : '↓'}
                                </span>
                              )}
                            </th>
                            <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                              ID
                            </th>
                            <th 
                              scope="col" 
                              className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer"
                              onClick={() => handleSortChange('age')}
                            >
                              Age
                              {sortField === 'age' && (
                                <span className="ml-1">
                                  {sortOrder === 'asc' ? '↑' : '↓'}
                                </span>
                              )}
                            </th>
                            <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                              Gender
                            </th>
                            <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                              Sport
                            </th>
                            <th 
                              scope="col" 
                              className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer"
                              onClick={() => handleSortChange('skillLevel')}
                            >
                              Level
                              {sortField === 'skillLevel' && (
                                <span className="ml-1">
                                  {sortOrder === 'asc' ? '↑' : '↓'}
                                </span>
                              )}
                            </th>
                            <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                              Coach
                            </th>
                            <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                              Actions
                            </th>
                          </tr>
                        </thead>
                        <tbody className="bg-white divide-y divide-gray-200">
                          {athletes.length > 0 ? (
                            athletes.map((athlete) => (
                              <tr key={athlete._id} className="hover:bg-gray-50">
                                <td className="px-6 py-4 whitespace-nowrap">
                                  <div className="flex items-center">
                                    <div className="flex-shrink-0 h-10 w-10">
                                      <img 
                                        className="h-10 w-10 rounded-full object-cover" 
                                        src={athlete.avatar || "https://www.w3schools.com/howto/img_avatar.png"} 
                                        alt="" 
                                      />
                                    </div>
                                    <div className="ml-4">
                                      <div className="text-sm font-medium text-gray-900">{athlete.name}</div>
                                      <div className="text-sm text-gray-500">{athlete.email}</div>
                                    </div>
                                  </div>
                                </td>
                                <td className="px-6 py-4 whitespace-nowrap">
                                  <div className="text-sm text-gray-900">{athlete.studentId || '-'}</div>
                                </td>
                                <td className="px-6 py-4 whitespace-nowrap">
                                  <div className="text-sm text-gray-900">{athlete.age || calculateAge(athlete.dob)}</div>
                                </td>
                                <td className="px-6 py-4 whitespace-nowrap">
                                  <div className="text-sm text-gray-900">{athlete.gender}</div>
                                </td>
                                <td className="px-6 py-4 whitespace-nowrap">
                                  <div className="text-sm text-gray-900">
                                    {Array.isArray(athlete.sports) ? athlete.sports.join(', ') : (athlete.sports || '-')}
                                  </div>
                                </td>
                                <td className="px-6 py-4 whitespace-nowrap">
                                  <span 
                                    className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full 
                                      ${athlete.skillLevel === 'Elite' ? 'bg-purple-100 text-purple-800' : 
                                        athlete.skillLevel === 'Advanced' ? 'bg-green-100 text-green-800' :
                                        athlete.skillLevel === 'Intermediate' ? 'bg-blue-100 text-blue-800' :
                                        'bg-gray-100 text-gray-800'}`}
                                  >
                                    {athlete.skillLevel || 'N/A'}
                                  </span>
                                </td>
                                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                  {athlete.headCoachAssigned?.name || 'Not assigned'}
                                </td>
                                <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                                  <Button 
                                    onClick={() => handleViewProfile(athlete._id)}
                                    size="sm"
                                    className="text-indigo-600 hover:text-indigo-900 mr-2"
                                  >
                                    View
                                  </Button>
                                </td>
                              </tr>
                            ))
                          ) : (
                            <tr>
                              <td colSpan="8" className="px-6 py-4 text-center text-gray-500">
                                No athletes found matching your criteria.
                              </td>
                            </tr>
                          )}
                        </tbody>
                      </table>
                    </div>

                    {/* Pagination */}
                    <div className="flex items-center justify-between border-t border-gray-200 bg-white px-4 py-3 sm:px-6 mt-4">
                      <div className="flex flex-1 justify-between sm:hidden">
                        <Button 
                          onClick={goToPreviousPage} 
                          disabled={currentPage === 1} 
                          variant="outline"
                          size="sm"
                        >
                          Previous
                        </Button>
                        <Button 
                          onClick={goToNextPage} 
                          disabled={currentPage === totalPages} 
                          variant="outline"
                          size="sm"
                        >
                          Next
                        </Button>
                      </div>
                      <div className="hidden sm:flex sm:flex-1 sm:items-center sm:justify-between">
                        <div>
                          <p className="text-sm text-gray-700">
                            Showing <span className="font-medium">{athletes.length}</span> of{' '}
                            <span className="font-medium">{totalAthletes}</span> athletes
                          </p>
                        </div>
                        <div>
                          <nav className="isolate inline-flex -space-x-px rounded-md shadow-sm" aria-label="Pagination">
                            <Button 
                              variant="outline" 
                              size="icon" 
                              className="rounded-l-md" 
                              onClick={goToPreviousPage} 
                              disabled={currentPage === 1}
                            >
                              <ChevronLeft className="h-4 w-4" />
                            </Button>
                            {/* Generate page buttons */}
                            {Array.from({ length: Math.min(5, totalPages) }, (_, i) => {
                              let pageNum;
                              if (totalPages <= 5) {
                                // Show all pages if 5 or fewer
                                pageNum = i + 1;
                              } else if (currentPage <= 3) {
                                // Show first 5 pages
                                pageNum = i + 1;
                              } else if (currentPage >= totalPages - 2) {
                                // Show last 5 pages
                                pageNum = totalPages - 4 + i;
                              } else {
                                // Show current page and 2 before/after
                                pageNum = currentPage - 2 + i;
                              }
                              return (
                                <Button 
                                  key={pageNum} 
                                  variant={currentPage === pageNum ? "default" : "outline"}
                                  size="icon"
                                  className={`${currentPage === pageNum ? 'bg-blue-600 text-white' : ''}`}
                                  onClick={() => goToPage(pageNum)}
                                >
                                  {pageNum}
                                </Button>
                              );
                            })}
                            <Button 
                              variant="outline" 
                              size="icon" 
                              className="rounded-r-md" 
                              onClick={goToNextPage} 
                              disabled={currentPage === totalPages}
                            >
                              <ChevronRight className="h-4 w-4" />
                            </Button>
                          </nav>
                        </div>
                      </div>
                    </div>
                    </div>
                  </>
                )}
              </div>
            );
          };

export default AthleteManagement;