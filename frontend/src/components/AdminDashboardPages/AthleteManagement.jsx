import React, { useState, useEffect } from "react";
import { useNavigate, useParams } from "react-router-dom";
import axios from "axios";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import {
  Select,
  SelectTrigger,
  SelectValue,
  SelectContent,
  SelectItem,
} from "@/components/ui/select";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogTrigger,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from "@/components/ui/dialog";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  Loader2,
  CheckCircle2,
  AlertCircle,
  ArrowLeft,
  ArrowRight,
  ChevronLeft,
  ChevronRight,
} from "lucide-react";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Textarea } from "@/components/ui/textarea";
import { Input } from "@/components/ui/input";
import { Loader } from "lucide-react";

const sportsEnum = [
  "Cricket",
  "Basketball",
  "Football",
  "Tennis",
  "Swimming",
  "Athletics",
  "Badminton",
  "Hockey",
  "Volleyball",
  "Table Tennis",
];
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

  const [profileDialogOpen, setProfileDialogOpen] = useState(false);
  const [selectedAthlete, setSelectedAthlete] = useState(null);
  const [profileLoading, setProfileLoading] = useState(false);
const [profileError, setProfileError] = useState(null);
const [athleteDetails, setAthleteDetails] = useState(null);


  // Performance data for athlete profile
  const [performanceData, setPerformanceData] = useState({
    consistency: 0,
    technique: 0,
    stamina: 0,
  });

  // Pagination state
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [totalAthletes, setTotalAthletes] = useState(0);
  const [limit, setLimit] = useState(10);

  // Sorting state
  const [sortField, setSortField] = useState("name");
  const [sortOrder, setSortOrder] = useState("asc");

  // Get organization ID from params
  const { organizationId } = useParams();

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
    trainingStartDate: new Date().toISOString().split("T")[0],
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

  const [newAthlete, setNewAthlete] = useState({ ...defaultAthleteState });

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
        organizationId: organizationId,
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
          withCredentials: true,
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
      setAthletes([]); // Set empty array as fallback
    } finally {
      setLoading(false);
    }
  };

  // Fetch staff (coaches, trainers, medical staff)
  const fetchStaff = async () => {
    try {
      // Fetch coaches - use a single API call for all staff types
      const coachesResponse = await axios.get(
        "http://localhost:8000/api/v1/admins/coaches",
        {
          params: { organizationId },
          withCredentials: true,
        }
      );

      if (coachesResponse.data && coachesResponse.data.data) {
        // Set all coaches
        setCoaches(coachesResponse.data.data.coaches || []);

        // Filter for gym trainers - staff with fitness-related roles
        setGymTrainers(
          coachesResponse.data.data.coaches.filter(
            (c) =>
              c.specialization === "Fitness" ||
              c.designation === "Gym Trainer" ||
              c.role === "trainer"
          ) || []
        );

        // Filter for medical staff - staff with medical-related roles
        setMedicalStaff(
          coachesResponse.data.data.coaches.filter(
            (c) =>
              c.specialization === "Medical" ||
              c.designation === "Team Doctor" ||
              c.designation === "Physiotherapist" ||
              c.role === "medical"
          ) || []
        );
      }
    } catch (error) {
      console.error("Error fetching staff data:", error);
      // Set empty arrays as fallback
      setCoaches([]);
      setGymTrainers([]);
      setMedicalStaff([]);
    }
  };

  // Initial data fetch
  useEffect(() => {
    if (organizationId) {
      fetchAthletes();
      fetchStaff().catch((err) => {
        console.error("Failed to fetch staff:", err);
        setCoaches([]);
        setGymTrainers([]);
        setMedicalStaff([]);
      });
    } else {
      setLoading(false);
    }
  }, [
    organizationId,
    currentPage,
    limit,
    sortField,
    sortOrder,
    selectedSport,
    selectedGender,
    selectedSkillLevel,
  ]);

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

  // Update performance data when selected athlete changes
  useEffect(() => {
    if (selectedAthlete) {
      setPerformanceData({
        consistency: selectedAthlete.consistency || 70, // Default values for demonstration
        technique: selectedAthlete.technique || 65,
        stamina: selectedAthlete.stamina || 80,
      });
    }
  }, [selectedAthlete]);

  // Calculate performance metrics
  const consistency = performanceData.consistency || 0;
  const technique = performanceData.technique || 0;
  const stamina = performanceData.stamina || 0;
  const overallRating =
    consistency && technique && stamina
      ? Math.round((consistency + technique + stamina) / 3)
      : "N/A";

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
    setNewAthlete((prev) => {
      const sports = prev.sports.includes(sportName)
        ? prev.sports.filter((s) => s !== sportName)
        : [...prev.sports, sportName];
      return { ...prev, sports };
    });
  };

  // Handle file uploads
  const handleFileChange = (e, fieldName) => {
    if (e.target.files && e.target.files[0]) {
      setNewAthlete((prev) => ({
        ...prev,
        [fieldName]: e.target.files[0],
      }));
    }
  };

  // Calculate BMI automatically
  const calculateBMI = () => {
    if (newAthlete.height && newAthlete.weight) {
      const heightInMeters = Number(newAthlete.height) / 100;
      if (heightInMeters > 0) {
        const bmi = (
          Number(newAthlete.weight) /
          (heightInMeters * heightInMeters)
        ).toFixed(1);
        return isNaN(bmi) ? "" : bmi;
      }
    }
    return "";
  };

  // Handle position selection for each sport
  const handlePositionChange = (sport, position) => {
    setNewAthlete((prev) => ({
      ...prev,
      positions: {
        ...prev.positions,
        [sport]: position,
      },
    }));
  };

  // Tab change handler
  const handleTabChange = (value) => {
    setActiveTab(value);
  };

  // View athlete profile
  const handleViewProfile = async (athlete) => {
    setSelectedAthlete(athlete);
    setProfileDialogOpen(true);
    setProfileLoading(true);
    setProfileError(null);
    
    try {
      const response = await axios.get(
        `http://localhost:8000/api/v1/admins/athletes/${athlete._id}/details`,
        {
          headers: {
            Authorization: `Bearer ${localStorage.getItem('token')}`
          },
          withCredentials: true
        }
      );
      
      if (response.data && response.data.data && response.data.data.athlete) {
        setAthleteDetails(response.data.data.athlete);
        
        // Set performance data if available in the response
        if (response.data.data.athlete.sportsInfo.stats && 
            response.data.data.athlete.sportsInfo.stats.length) {
          // Find the primary sport's stats or use the first one
          const primarySport = response.data.data.athlete.sportsInfo.stats[0];
          const perfStats = {};
          
          // Map stats to performance metrics
          primarySport.stats.forEach(stat => {
            if (stat.statName === 'consistency') perfStats.consistency = stat.value;
            if (stat.statName === 'technique') perfStats.technique = stat.value;
            if (stat.statName === 'stamina') perfStats.stamina = stat.value;
          });
          
          setPerformanceData({
            consistency: perfStats.consistency || 70,
            technique: perfStats.technique || 65,
            stamina: perfStats.stamina || 80
          });
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

  // Handle adding new athlete
  const handleAddAthlete = async () => {
    // Reset error message
    setErrorMessage("");

    // Perform tab-specific validation
    let isValid = true;
    let tabToFocus = activeTab;

    // Basic tab validation
    if (
      !newAthlete.name ||
      !newAthlete.email ||
      !newAthlete.password ||
      !newAthlete.dob ||
      !newAthlete.gender ||
      !newAthlete.nationality ||
      !newAthlete.address ||
      !newAthlete.phoneNumber
    ) {
      isValid = false;
      tabToFocus = "basic";
      setErrorMessage("Please fill all required fields in the Basic Info tab");
    }

    // School tab validation - only check if basic was valid
    else if (
      !newAthlete.schoolName ||
      !newAthlete.year ||
      !newAthlete.studentId ||
      newAthlete.sports.length === 0 ||
      !newAthlete.skillLevel ||
      !newAthlete.trainingStartDate
    ) {
      isValid = false;
      tabToFocus = "school";
      setErrorMessage(
        "Please fill all required fields in the School & Sports tab"
      );
    }

    // Medical tab validation - only check if school was valid
    else if (!newAthlete.height || !newAthlete.weight) {
      isValid = false;
      tabToFocus = "medical";
      setErrorMessage("Please enter height and weight in the Medical Info tab");
    }

    // Emergency tab validation - only check if medical was valid
    else if (
      !newAthlete.emergencyContactName ||
      !newAthlete.emergencyContactNumber ||
      !newAthlete.emergencyContactRelationship
    ) {
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
      formData.append("name", newAthlete.name);
      formData.append("email", newAthlete.email);
      formData.append("password", newAthlete.password);
      formData.append("dob", newAthlete.dob);
      formData.append("gender", newAthlete.gender);
      formData.append("nationality", newAthlete.nationality);
      formData.append("address", newAthlete.address);
      formData.append("phoneNumber", newAthlete.phoneNumber);

      // Append school information
      formData.append("schoolName", newAthlete.schoolName);
      formData.append("year", newAthlete.year);
      formData.append("studentId", newAthlete.studentId);
      if (newAthlete.schoolEmail)
        formData.append("schoolEmail", newAthlete.schoolEmail);
      if (newAthlete.schoolWebsite)
        formData.append("schoolWebsite", newAthlete.schoolWebsite);

      // Append sports information
      newAthlete.sports.forEach((sport) => {
        formData.append("sports", sport);
      });

      formData.append("skillLevel", newAthlete.skillLevel);
      formData.append("trainingStartDate", newAthlete.trainingStartDate);
      if (newAthlete.dominantHand)
        formData.append("dominantHand", newAthlete.dominantHand);

      // Convert positions object to JSON string
      if (Object.keys(newAthlete.positions).length > 0) {
        formData.append("positions", JSON.stringify(newAthlete.positions));
      }

      // Append staff assignments (if not "none")
      if (
        newAthlete.headCoachAssigned &&
        newAthlete.headCoachAssigned !== "none"
      ) {
        formData.append("headCoachAssigned", newAthlete.headCoachAssigned);
      }

      if (
        newAthlete.gymTrainerAssigned &&
        newAthlete.gymTrainerAssigned !== "none"
      ) {
        formData.append("gymTrainerAssigned", newAthlete.gymTrainerAssigned);
      }

      if (
        newAthlete.medicalStaffAssigned &&
        newAthlete.medicalStaffAssigned !== "none"
      ) {
        formData.append(
          "medicalStaffAssigned",
          newAthlete.medicalStaffAssigned
        );
      }

      // Append medical information
      formData.append("height", newAthlete.height);
      formData.append("weight", newAthlete.weight);
      if (newAthlete.bloodGroup)
        formData.append("bloodGroup", newAthlete.bloodGroup);

      // Process allergies and medical conditions - split comma-separated values into arrays
      if (newAthlete.allergies) {
        const allergyArray = newAthlete.allergies
          .split(",")
          .map((item) => item.trim())
          .filter(Boolean);
        allergyArray.forEach((allergy) => {
          formData.append("allergies", allergy);
        });
      }

      if (newAthlete.medicalConditions) {
        const conditionsArray = newAthlete.medicalConditions
          .split(",")
          .map((item) => item.trim())
          .filter(Boolean);
        conditionsArray.forEach((condition) => {
          formData.append("medicalConditions", condition);
        });
      }

      // Append emergency contact
      formData.append("emergencyContactName", newAthlete.emergencyContactName);
      formData.append(
        "emergencyContactNumber",
        newAthlete.emergencyContactNumber
      );
      formData.append(
        "emergencyContactRelationship",
        newAthlete.emergencyContactRelationship
      );

      // Add organization ID
      formData.append("organizationId", organizationId);

      // Append files if they exist
      if (newAthlete.avatar) {
        formData.append("avatar", newAthlete.avatar);
      }

      if (newAthlete.uploadSchoolId) {
        formData.append("uploadSchoolId", newAthlete.uploadSchoolId);
      }

      if (newAthlete.latestMarksheet) {
        formData.append("latestMarksheet", newAthlete.latestMarksheet);
      }

      // Make API call with 30s timeout - UPDATED ENDPOINT
      const response = await axios.post(
        "http://localhost:8000/api/v1/admins/register-organization-athlete",
        formData,
        {
          headers: {
            "Content-Type": "multipart/form-data",
          },
          withCredentials: true,
          timeout: 30000,
        }
      );

      if (response.data && response.data.data && response.data.data.athlete) {
        // Show success message
        setSuccessMessage("Athlete registered successfully!");

        // Refresh the athlete list
        fetchAthletes();

        // Reset form and close dialog after short delay
        setTimeout(() => {
          setNewAthlete({ ...defaultAthleteState });
          setDialogOpen(false);
          setSuccessMessage("");
        }, 2000);
      }
    } catch (err) {
      console.error("Error registering athlete:", err);

      if (err.response) {
        setErrorMessage(
          err.response.data.message ||
            "Failed to register athlete. Please check your inputs."
        );
      } else if (err.request) {
        setErrorMessage(
          "No response from server. Please check your network connection."
        );
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
                    <SelectValue placeholder="Select Sport">
                      {selectedSport}
                    </SelectValue>
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="All">All</SelectItem>
                    {sportsEnum.map((sport) => (
                      <SelectItem key={sport} value={sport}>
                        {sport}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              <div>
                <label className="text-sm font-medium mb-1 block">Gender</label>
                <Select
                  value={selectedGender}
                  onValueChange={handleGenderChange}
                >
                  <SelectTrigger>
                    <SelectValue placeholder="Select Gender">
                      {selectedGender}
                    </SelectValue>
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="All">All</SelectItem>
                    {genderEnum.map((gender) => (
                      <SelectItem key={gender} value={gender}>
                        {gender}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              <div>
                <label className="text-sm font-medium mb-1 block">
                  Skill Level
                </label>
                <Select
                  value={selectedSkillLevel}
                  onValueChange={handleSkillLevelChange}
                >
                  <SelectTrigger>
                    <SelectValue placeholder="Select Skill Level">
                      {selectedSkillLevel}
                    </SelectValue>
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="All">All</SelectItem>
                    {skillLevelEnum.map((level) => (
                      <SelectItem key={level} value={level}>
                        {level}
                      </SelectItem>
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
                <Select
                  value={limit.toString()}
                  onValueChange={(val) => setLimit(Number(val))}
                >
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
                    <Button className="bg-green-600 hover:bg-green-700">
                      Register New Athlete
                    </Button>
                  </DialogTrigger>

                  <DialogContent className="max-w-4xl p-6 rounded-lg bg-white shadow-lg overflow-y-auto max-h-[90vh]">
                    <DialogHeader>
                      <DialogTitle className="text-2xl font-semibold text-gray-800">
                        Register New Athlete
                      </DialogTitle>
                    </DialogHeader>

                    {errorMessage && (
                      <Alert variant="destructive" className="mb-4">
                        <AlertCircle className="h-4 w-4" />
                        <AlertDescription>{errorMessage}</AlertDescription>
                      </Alert>
                    )}

                    {successMessage && (
                      <Alert
                        variant="success"
                        className="mb-4 bg-green-50 text-green-700 border-green-200"
                      >
                        <CheckCircle2 className="h-4 w-4" />
                        <AlertDescription>{successMessage}</AlertDescription>
                      </Alert>
                    )}

                    <Tabs value={activeTab} onValueChange={handleTabChange}>
                      <TabsList className="grid grid-cols-4 mb-4">
                        <TabsTrigger value="basic">Basic Info</TabsTrigger>
                        <TabsTrigger value="school">
                          School & Sports
                        </TabsTrigger>
                        <TabsTrigger value="medical">Medical Info</TabsTrigger>
                        <TabsTrigger value="emergency">
                          Emergency Contact
                        </TabsTrigger>
                      </TabsList>

                      <TabsContent value="basic" className="space-y-4">
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                          <div>
                            <label className="block text-sm font-medium mb-1">
                              Full Name *
                            </label>
                            <input
                              type="text"
                              className="w-full p-2 border rounded"
                              value={newAthlete.name}
                              onChange={(e) =>
                                setNewAthlete({
                                  ...newAthlete,
                                  name: e.target.value,
                                })
                              }
                              required
                            />
                          </div>

                          <div>
                            <label className="block text-sm font-medium mb-1">
                              Email *
                            </label>
                            <input
                              type="email"
                              className="w-full p-2 border rounded"
                              value={newAthlete.email}
                              onChange={(e) =>
                                setNewAthlete({
                                  ...newAthlete,
                                  email: e.target.value,
                                })
                              }
                              required
                            />
                          </div>

                          <div>
                            <label className="block text-sm font-medium mb-1">
                              Password *
                            </label>
                            <input
                              type="password"
                              className="w-full p-2 border rounded"
                              value={newAthlete.password}
                              onChange={(e) =>
                                setNewAthlete({
                                  ...newAthlete,
                                  password: e.target.value,
                                })
                              }
                              required
                            />
                          </div>

                          <div>
                            <label className="block text-sm font-medium mb-1">
                              Date of Birth *
                            </label>
                            <input
                              type="date"
                              className="w-full p-2 border rounded"
                              value={newAthlete.dob}
                              onChange={(e) =>
                                setNewAthlete({
                                  ...newAthlete,
                                  dob: e.target.value,
                                })
                              }
                              required
                            />
                          </div>

                          <div>
                            <label className="block text-sm font-medium mb-1">
                              Gender *
                            </label>
                            <Select
                              value={newAthlete.gender}
                              onValueChange={(value) =>
                                setNewAthlete({ ...newAthlete, gender: value })
                              }
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
                            <label className="block text-sm font-medium mb-1">
                              Nationality *
                            </label>
                            <input
                              type="text"
                              className="w-full p-2 border rounded"
                              value={newAthlete.nationality}
                              onChange={(e) =>
                                setNewAthlete({
                                  ...newAthlete,
                                  nationality: e.target.value,
                                })
                              }
                              required
                            />
                          </div>

                          <div className="col-span-2">
                            <label className="block text-sm font-medium mb-1">
                              Address *
                            </label>
                            <input
                              type="text"
                              className="w-full p-2 border rounded"
                              value={newAthlete.address}
                              onChange={(e) =>
                                setNewAthlete({
                                  ...newAthlete,
                                  address: e.target.value,
                                })
                              }
                              required
                            />
                          </div>

                          <div className="col-span-2">
                            <label className="block text-sm font-medium mb-1">
                              Phone Number *
                            </label>
                            <input
                              type="tel"
                              className="w-full p-2 border rounded"
                              value={newAthlete.phoneNumber}
                              onChange={(e) =>
                                setNewAthlete({
                                  ...newAthlete,
                                  phoneNumber: e.target.value,
                                })
                              }
                              required
                            />
                          </div>

                          <div className="col-span-2">
                            <label className="block text-sm font-medium mb-1">
                              Profile Photo
                            </label>
                            <div className="mt-1 flex items-center">
                              <div className="flex-shrink-0">
                                {newAthlete.avatar ? (
                                  <div className="h-20 w-20 rounded-full overflow-hidden bg-gray-100">
                                    <img
                                      src={URL.createObjectURL(
                                        newAthlete.avatar
                                      )}
                                      alt="Preview"
                                      className="h-full w-full object-cover"
                                    />
                                  </div>
                                ) : (
                                  <div className="h-20 w-20 rounded-full overflow-hidden bg-gray-100 flex items-center justify-center text-gray-400">
                                    <svg
                                      className="h-12 w-12"
                                      fill="currentColor"
                                      viewBox="0 0 24 24"
                                    >
                                      <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z" />
                                    </svg>
                                  </div>
                                )}
                              </div>
                              <div className="ml-5 flex items-center gap-2">
                                <label
                                  htmlFor="avatar-upload"
                                  className="cursor-pointer px-3 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none"
                                >
                                  Upload
                                </label>
                                <input
                                  id="avatar-upload"
                                  name="avatar"
                                  type="file"
                                  className="sr-only"
                                  accept="image/*"
                                  onChange={(e) =>
                                    handleFileChange(e, "avatar")
                                  }
                                />
                                {newAthlete.avatar && (
                                  <button
                                    type="button"
                                    onClick={() =>
                                      setNewAthlete({
                                        ...newAthlete,
                                        avatar: null,
                                      })
                                    }
                                    className="px-3 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-red-600 bg-white hover:bg-gray-50 focus:outline-none"
                                  >
                                    Remove
                                  </button>
                                )}
                              </div>
                            </div>
                          </div>
                        </div>

                        <div className="flex justify-end mt-4">
                          <Button
                            onClick={() => setActiveTab("school")}
                            className="bg-blue-600 hover:bg-blue-700"
                          >
                            Next: School & Sports
                            <ArrowRight className="ml-2 h-4 w-4" />
                          </Button>
                        </div>
                      </TabsContent>

                      <TabsContent value="school" className="space-y-4">
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                          <div>
                            <label className="block text-sm font-medium mb-1">
                              School Name *
                            </label>
                            <input
                              type="text"
                              className="w-full p-2 border rounded"
                              value={newAthlete.schoolName}
                              onChange={(e) =>
                                setNewAthlete({
                                  ...newAthlete,
                                  schoolName: e.target.value,
                                })
                              }
                              required
                            />
                          </div>

                          <div>
                            <label className="block text-sm font-medium mb-1">
                              Grade/Year *
                            </label>
                            <input
                              type="text"
                              className="w-full p-2 border rounded"
                              value={newAthlete.year}
                              onChange={(e) =>
                                setNewAthlete({
                                  ...newAthlete,
                                  year: e.target.value,
                                })
                              }
                              required
                            />
                          </div>

                          <div>
                            <label className="block text-sm font-medium mb-1">
                              Student ID *
                            </label>
                            <input
                              type="text"
                              className="w-full p-2 border rounded"
                              value={newAthlete.studentId}
                              onChange={(e) =>
                                setNewAthlete({
                                  ...newAthlete,
                                  studentId: e.target.value,
                                })
                              }
                              required
                            />
                          </div>

                          <div>
                            <label className="block text-sm font-medium mb-1">
                              School Email (Optional)
                            </label>
                            <input
                              type="email"
                              className="w-full p-2 border rounded"
                              value={newAthlete.schoolEmail}
                              onChange={(e) =>
                                setNewAthlete({
                                  ...newAthlete,
                                  schoolEmail: e.target.value,
                                })
                              }
                            />
                          </div>

                          <div>
                            <label className="block text-sm font-medium mb-1">
                              School Website (Optional)
                            </label>
                            <input
                              type="url"
                              className="w-full p-2 border rounded"
                              value={newAthlete.schoolWebsite}
                              onChange={(e) =>
                                setNewAthlete({
                                  ...newAthlete,
                                  schoolWebsite: e.target.value,
                                })
                              }
                            />
                          </div>

                          <div>
                            <label className="block text-sm font-medium mb-1">
                              Training Start Date *
                            </label>
                            <input
                              type="date"
                              className="w-full p-2 border rounded"
                              value={newAthlete.trainingStartDate}
                              onChange={(e) =>
                                setNewAthlete({
                                  ...newAthlete,
                                  trainingStartDate: e.target.value,
                                })
                              }
                              required
                            />
                          </div>

                          <div className="col-span-2 mt-4">
                            <label className="block text-sm font-medium mb-2">
                              School Documents
                            </label>
                            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                              {/* School ID Upload Component */}
                              <div className="border border-dashed border-gray-300 rounded-lg p-4 bg-gray-50">
                                <div className="flex flex-col items-center">
                                  <div className="mb-2 text-center">
                                    <h4 className="font-medium text-gray-700">
                                      School ID Card
                                    </h4>
                                    <p className="text-xs text-gray-500 mt-1">
                                      Upload student ID card or document
                                    </p>
                                  </div>

                                  {newAthlete.uploadSchoolId ? (
                                    <div className="w-full">
                                      <div className="flex items-center justify-between bg-blue-50 p-2 rounded-md mb-2">
                                        <div className="flex items-center">
                                          <div className="p-1 bg-blue-100 rounded mr-2">
                                            <svg
                                              className="h-4 w-4 text-blue-700"
                                              fill="none"
                                              stroke="currentColor"
                                              viewBox="0 0 24 24"
                                              xmlns="http://www.w3.org/2000/svg"
                                            >
                                              <path
                                                strokeLinecap="round"
                                                strokeLinejoin="round"
                                                strokeWidth={2}
                                                d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
                                              />
                                            </svg>
                                          </div>
                                          <span className="text-xs text-gray-700 truncate max-w-[120px]">
                                            {newAthlete.uploadSchoolId.name}
                                          </span>
                                        </div>
                                        <button
                                          type="button"
                                          onClick={() =>
                                            setNewAthlete({
                                              ...newAthlete,
                                              uploadSchoolId: null,
                                            })
                                          }
                                          className="text-red-500 hover:text-red-700 text-xs"
                                        >
                                          Remove
                                        </button>
                                      </div>
                                    </div>
                                  ) : (
                                    <div className="flex items-center justify-center w-full">
                                      <label
                                        htmlFor="school-id-upload"
                                        className="flex flex-col items-center justify-center w-full h-24 cursor-pointer"
                                      >
                                        <div className="flex flex-col items-center justify-center pt-5 pb-6">
                                          <svg
                                            className="w-8 h-8 text-gray-400"
                                            fill="none"
                                            stroke="currentColor"
                                            viewBox="0 0 24 24"
                                            xmlns="http://www.w3.org/2000/svg"
                                          >
                                            <path
                                              strokeLinecap="round"
                                              strokeLinejoin="round"
                                              strokeWidth={2}
                                              d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12"
                                            />
                                          </svg>
                                          <p className="mt-2 text-xs text-gray-500">
                                            <span className="font-semibold">
                                              Click to upload
                                            </span>{" "}
                                            or drag and drop
                                          </p>
                                          <p className="text-xs text-gray-500">
                                            PDF, PNG, JPG or JPEG
                                          </p>
                                        </div>
                                        <input
                                          id="school-id-upload"
                                          type="file"
                                          className="hidden"
                                          accept=".pdf,.png,.jpg,.jpeg"
                                          onChange={(e) =>
                                            handleFileChange(
                                              e,
                                              "uploadSchoolId"
                                            )
                                          }
                                        />
                                      </label>
                                    </div>
                                  )}
                                </div>
                              </div>

                              {/* Marksheet Upload Component */}
                              <div className="border border-dashed border-gray-300 rounded-lg p-4 bg-gray-50">
                                <div className="flex flex-col items-center">
                                  <div className="mb-2 text-center">
                                    <h4 className="font-medium text-gray-700">
                                      Latest Marksheet
                                    </h4>
                                    <p className="text-xs text-gray-500 mt-1">
                                      Upload recent academic results
                                    </p>
                                  </div>

                                  {newAthlete.latestMarksheet ? (
                                    <div className="w-full">
                                      <div className="flex items-center justify-between bg-green-50 p-2 rounded-md mb-2">
                                        <div className="flex items-center">
                                          <div className="p-1 bg-green-100 rounded mr-2">
                                            <svg
                                              className="h-4 w-4 text-green-700"
                                              fill="none"
                                              stroke="currentColor"
                                              viewBox="0 0 24 24"
                                              xmlns="http://www.w3.org/2000/svg"
                                            >
                                              <path
                                                strokeLinecap="round"
                                                strokeLinejoin="round"
                                                strokeWidth={2}
                                                d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
                                              />
                                            </svg>
                                          </div>
                                          <span className="text-xs text-gray-700 truncate max-w-[120px]">
                                            {newAthlete.latestMarksheet.name}
                                          </span>
                                        </div>
                                        <button
                                          type="button"
                                          onClick={() =>
                                            setNewAthlete({
                                              ...newAthlete,
                                              latestMarksheet: null,
                                            })
                                          }
                                          className="text-red-500 hover:text-red-700 text-xs"
                                        >
                                          Remove
                                        </button>
                                      </div>
                                    </div>
                                  ) : (
                                    <div className="flex items-center justify-center w-full">
                                      <label
                                        htmlFor="marksheet-upload"
                                        className="flex flex-col items-center justify-center w-full h-24 cursor-pointer"
                                      >
                                        <div className="flex flex-col items-center justify-center pt-5 pb-6">
                                          <svg
                                            className="w-8 h-8 text-gray-400"
                                            fill="none"
                                            stroke="currentColor"
                                            viewBox="0 0 24 24"
                                            xmlns="http://www.w3.org/2000/svg"
                                          >
                                            <path
                                              strokeLinecap="round"
                                              strokeLinejoin="round"
                                              strokeWidth={2}
                                              d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12"
                                            />
                                          </svg>
                                          <p className="mt-2 text-xs text-gray-500">
                                            <span className="font-semibold">
                                              Click to upload
                                            </span>{" "}
                                            or drag and drop
                                          </p>
                                          <p className="text-xs text-gray-500">
                                            PDF, PNG, JPG or JPEG
                                          </p>
                                        </div>
                                        <input
                                          id="marksheet-upload"
                                          type="file"
                                          className="hidden"
                                          accept=".pdf,.png,.jpg,.jpeg"
                                          onChange={(e) =>
                                            handleFileChange(
                                              e,
                                              "latestMarksheet"
                                            )
                                          }
                                        />
                                      </label>
                                    </div>
                                  )}
                                </div>
                              </div>
                            </div>
                          </div>

                          <div className="col-span-2">
                            <label className="block text-sm font-medium mb-2">
                              Sports *
                            </label>
                            <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-5 gap-2">
                              {sportsEnum.map((sport) => (
                                <div
                                  key={sport}
                                  onClick={() => handleSportSelection(sport)}
                                  className={`px-3 py-2 border rounded-md cursor-pointer text-center text-sm
                                    ${
                                      newAthlete.sports.includes(sport)
                                        ? "bg-blue-500 text-white border-blue-600"
                                        : "bg-white text-gray-800 border-gray-300 hover:bg-gray-50"
                                    }`}
                                >
                                  {sport}
                                </div>
                              ))}
                            </div>
                            {newAthlete.sports.length === 0 && (
                              <p className="text-xs text-red-500 mt-1">
                                Please select at least one sport
                              </p>
                            )}
                          </div>
                        </div>

                        <div className="mt-4 space-y-4">
                          <div>
                            <label className="block text-sm font-medium mb-1">
                              Skill Level *
                            </label>
                            <Select
                              value={newAthlete.skillLevel}
                              onValueChange={(value) =>
                                setNewAthlete({
                                  ...newAthlete,
                                  skillLevel: value,
                                })
                              }
                            >
                              <SelectTrigger>
                                <SelectValue placeholder="Select Skill Level" />
                              </SelectTrigger>
                              <SelectContent>
                                {skillLevelEnum.map((level) => (
                                  <SelectItem key={level} value={level}>
                                    {level}
                                  </SelectItem>
                                ))}
                              </SelectContent>
                            </Select>
                          </div>

                          <div>
                            <label className="block text-sm font-medium mb-1">
                              Dominant Hand
                            </label>
                            <Select
                              value={newAthlete.dominantHand}
                              onValueChange={(value) =>
                                setNewAthlete({
                                  ...newAthlete,
                                  dominantHand: value,
                                })
                              }
                            >
                              <SelectTrigger>
                                <SelectValue placeholder="Select Dominant Hand" />
                              </SelectTrigger>
                              <SelectContent>
                                {dominantHandEnum.map((hand) => (
                                  <SelectItem key={hand} value={hand}>
                                    {hand}
                                  </SelectItem>
                                ))}
                              </SelectContent>
                            </Select>
                          </div>

                          {newAthlete.sports.length > 0 && (
                            <div>
                              <label className="block text-sm font-medium mb-1">
                                Playing Positions
                              </label>
                              {newAthlete.sports.map((sport) => (
                                <div key={sport} className="mb-2">
                                  <p className="text-xs text-gray-600 mb-1">
                                    {sport}
                                  </p>
                                  <input
                                    type="text"
                                    className="w-full p-2 border rounded"
                                    placeholder={`Position for ${sport}`}
                                    value={newAthlete.positions[sport] || ""}
                                    onChange={(e) =>
                                      handlePositionChange(
                                        sport,
                                        e.target.value
                                      )
                                    }
                                  />
                                </div>
                              ))}
                            </div>
                          )}

                          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                            <div>
                              <label className="block text-sm font-medium mb-1">
                                Head Coach
                              </label>
                              <Select
                                value={newAthlete.headCoachAssigned || "none"}
                                onValueChange={(value) =>
                                  setNewAthlete({
                                    ...newAthlete,
                                    headCoachAssigned:
                                      value === "none" ? null : value,
                                  })
                                }
                              >
                                <SelectTrigger>
                                  <SelectValue placeholder="Select Coach" />
                                </SelectTrigger>
                                <SelectContent>
                                  <SelectItem value="none">None</SelectItem>
                                  {coaches.map((coach) => (
                                    <SelectItem
                                      key={coach._id || coach.id}
                                      value={coach._id || coach.id}
                                    >
                                      {coach.name}
                                    </SelectItem>
                                  ))}
                                </SelectContent>
                              </Select>
                            </div>

                            <div>
                              <label className="block text-sm font-medium mb-1">
                                Gym Trainer
                              </label>
                              <Select
                                value={newAthlete.gymTrainerAssigned || "none"}
                                onValueChange={(value) =>
                                  setNewAthlete({
                                    ...newAthlete,
                                    gymTrainerAssigned:
                                      value === "none" ? null : value,
                                  })
                                }
                              >
                                <SelectTrigger>
                                  <SelectValue placeholder="Select Trainer" />
                                </SelectTrigger>
                                <SelectContent>
                                  <SelectItem value="none">None</SelectItem>
                                  {gymTrainers.map((trainer) => (
                                    <SelectItem
                                      key={trainer._id || trainer.id}
                                      value={trainer._id || trainer.id}
                                    >
                                      {trainer.name}
                                    </SelectItem>
                                  ))}
                                </SelectContent>
                              </Select>
                            </div>

                            <div>
                              <label className="block text-sm font-medium mb-1">
                                Medical Staff
                              </label>
                              <Select
                                value={
                                  newAthlete.medicalStaffAssigned || "none"
                                }
                                onValueChange={(value) =>
                                  setNewAthlete({
                                    ...newAthlete,
                                    medicalStaffAssigned:
                                      value === "none" ? null : value,
                                  })
                                }
                              >
                                <SelectTrigger>
                                  <SelectValue placeholder="Select Medical Staff" />
                                </SelectTrigger>
                                <SelectContent>
                                  <SelectItem value="none">None</SelectItem>
                                  {medicalStaff.map((staff) => (
                                    <SelectItem
                                      key={staff._id || staff.id}
                                      value={staff._id || staff.id}
                                    >
                                      {staff.name}
                                    </SelectItem>
                                  ))}
                                </SelectContent>
                              </Select>
                            </div>
                          </div>
                        </div>

                        <div className="flex justify-between mt-4">
                          <Button
                            onClick={() => setActiveTab("basic")}
                            variant="outline"
                          >
                            <ArrowLeft className="mr-2 h-4 w-4" />
                            Back: Basic Info
                          </Button>
                          <Button
                            onClick={() => setActiveTab("medical")}
                            className="bg-blue-600 hover:bg-blue-700"
                          >
                            Next: Medical Info
                            <ArrowRight className="ml-2 h-4 w-4" />
                          </Button>
                        </div>
                      </TabsContent>

                      <TabsContent value="medical" className="space-y-4">
                        {/* Medical Info Tab */}
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                          <div>
                            <label className="block text-sm font-medium mb-1">
                              Height (cm) *
                            </label>
                            <input
                              type="number"
                              className="w-full p-2 border rounded"
                              value={newAthlete.height}
                              onChange={(e) =>
                                setNewAthlete({
                                  ...newAthlete,
                                  height: e.target.value,
                                })
                              }
                              required
                            />
                          </div>

                          <div>
                            <label className="block text-sm font-medium mb-1">
                              Weight (kg) *
                            </label>
                            <input
                              type="number"
                              className="w-full p-2 border rounded"
                              value={newAthlete.weight}
                              onChange={(e) =>
                                setNewAthlete({
                                  ...newAthlete,
                                  weight: e.target.value,
                                })
                              }
                              required
                            />
                          </div>

                          {newAthlete.height && newAthlete.weight && (
                            <div className="bg-blue-50 p-3 rounded-lg border border-blue-100">
                              <p className="text-sm font-medium text-blue-800">
                                BMI: {calculateBMI()}
                              </p>
                              <p className="text-xs text-blue-600 mt-1">
                                Body Mass Index
                              </p>
                            </div>
                          )}

                          <div>
                            <label className="block text-sm font-medium mb-1">
                              Blood Group
                            </label>
                            <Select
                              value={newAthlete.bloodGroup}
                              onValueChange={(value) =>
                                setNewAthlete({
                                  ...newAthlete,
                                  bloodGroup: value,
                                })
                              }
                            >
                              <SelectTrigger>
                                <SelectValue placeholder="Select Blood Group" />
                              </SelectTrigger>
                              <SelectContent>
                                {bloodGroupEnum.map((group) => (
                                  <SelectItem key={group} value={group}>
                                    {group}
                                  </SelectItem>
                                ))}
                              </SelectContent>
                            </Select>
                          </div>

                          <div className="col-span-2">
                            <label className="block text-sm font-medium mb-1">
                              Allergies (Optional)
                            </label>
                            <Textarea
                              placeholder="List allergies separated by commas"
                              className="w-full p-2"
                              value={newAthlete.allergies}
                              onChange={(e) =>
                                setNewAthlete({
                                  ...newAthlete,
                                  allergies: e.target.value,
                                })
                              }
                            />
                          </div>

                          <div className="col-span-2">
                            <label className="block text-sm font-medium mb-1">
                              Medical Conditions (Optional)
                            </label>
                            <Textarea
                              placeholder="List medical conditions separated by commas"
                              className="w-full p-2"
                              value={newAthlete.medicalConditions}
                              onChange={(e) =>
                                setNewAthlete({
                                  ...newAthlete,
                                  medicalConditions: e.target.value,
                                })
                              }
                            />
                          </div>
                        </div>

                        <div className="flex justify-between mt-4">
                          <Button
                            onClick={() => setActiveTab("school")}
                            variant="outline"
                          >
                            <ArrowLeft className="mr-2 h-4 w-4" />
                            Back: School & Sports
                          </Button>
                          <Button
                            onClick={() => setActiveTab("emergency")}
                            className="bg-blue-600 hover:bg-blue-700"
                          >
                            Next: Emergency Contact
                            <ArrowRight className="ml-2 h-4 w-4" />
                          </Button>
                        </div>
                      </TabsContent>

                      <TabsContent value="emergency" className="space-y-4">
                        {/* Emergency Contact Tab */}
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                          <div>
                            <label className="block text-sm font-medium mb-1">
                              Emergency Contact Name *
                            </label>
                            <input
                              type="text"
                              className="w-full p-2 border rounded"
                              value={newAthlete.emergencyContactName}
                              onChange={(e) =>
                                setNewAthlete({
                                  ...newAthlete,
                                  emergencyContactName: e.target.value,
                                })
                              }
                              required
                            />
                          </div>

                          <div>
                            <label className="block text-sm font-medium mb-1">
                              Emergency Contact Number *
                            </label>
                            <input
                              type="tel"
                              className="w-full p-2 border rounded"
                              value={newAthlete.emergencyContactNumber}
                              onChange={(e) =>
                                setNewAthlete({
                                  ...newAthlete,
                                  emergencyContactNumber: e.target.value,
                                })
                              }
                              required
                            />
                          </div>

                          <div className="col-span-2">
                            <label className="block text-sm font-medium mb-1">
                              Relationship to Athlete *
                            </label>
                            <input
                              type="text"
                              className="w-full p-2 border rounded"
                              placeholder="e.g. Parent, Guardian, Sibling"
                              value={newAthlete.emergencyContactRelationship}
                              onChange={(e) =>
                                setNewAthlete({
                                  ...newAthlete,
                                  emergencyContactRelationship: e.target.value,
                                })
                              }
                              required
                            />
                          </div>
                        </div>

                        <div className="flex justify-between mt-4">
                          <Button
                            onClick={() => setActiveTab("medical")}
                            variant="outline"
                          >
                            <ArrowLeft className="mr-2 h-4 w-4" />
                            Back: Medical Info
                          </Button>
                          <Button
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
                              <>Register Athlete</>
                            )}
                          </Button>
                        </div>
                      </TabsContent>
                    </Tabs>
                  </DialogContent>
                </Dialog>
              </div>
            </div>

            {/* Athletes table */}
            {loading ? (
              <div className="flex justify-center items-center py-12">
                <Loader2 className="h-8 w-8 animate-spin text-green-600" />
              </div>
            ) : athletes.length > 0 ? (
              <div className="overflow-x-auto">
                <table className="min-w-full bg-white">
                  <thead>
                    <tr className="bg-gray-50 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      <th className="px-6 py-3">Name</th>
                      <th className="px-6 py-3">Sports</th>
                      <th className="px-6 py-3">Gender</th>
                      <th className="px-6 py-3">School</th>
                      <th className="px-6 py-3">Skill Level</th>
                      <th className="px-6 py-3">Actions</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-200">
                    {athletes.map((athlete) => (
                      <tr key={athlete._id} className="hover:bg-gray-50">
                        <td className="px-6 py-4">
                          <div className="flex items-center">
                            <div className="h-10 w-10 flex-shrink-0">
                              {athlete.avatar ? (
                                <img
                                  className="h-10 w-10 rounded-full object-cover"
                                  src={athlete.avatar}
                                  alt={athlete.name}
                                />
                              ) : (
                                <div className="h-10 w-10 rounded-full bg-gray-200 flex items-center justify-center">
                                  <span className="text-gray-500 text-sm font-medium">
                                    {athlete.name.charAt(0).toUpperCase()}
                                  </span>
                                </div>
                              )}
                            </div>
                            <div className="ml-4">
                              <div className="text-sm font-medium text-gray-900">
                                {athlete.name}
                              </div>
                              <div className="text-xs text-gray-500">
                                {athlete.email}
                              </div>
                            </div>
                          </div>
                        </td>
                        <td className="px-6 py-4">
                          <div className="flex flex-wrap gap-1">
                            {athlete.sports?.map((sport, idx) => (
                              <span
                                key={idx}
                                className="px-2 py-1 text-xs rounded-full bg-blue-100 text-blue-800"
                              >
                                {sport}
                              </span>
                            ))}
                          </div>
                        </td>
                        <td className="px-6 py-4 text-sm text-gray-500">
                          {athlete.gender}
                        </td>
                        <td className="px-6 py-4 text-sm text-gray-500">
                          {athlete.schoolName}
                        </td>
                        <td className="px-6 py-4">
                          <span
                            className={`px-2 py-1 text-xs rounded-full 
                            ${
                              athlete.skillLevel === "Beginner"
                                ? "bg-green-100 text-green-800"
                                : athlete.skillLevel === "Intermediate"
                                ? "bg-blue-100 text-blue-800"
                                : athlete.skillLevel === "Advanced"
                                ? "bg-purple-100 text-purple-800"
                                : "bg-red-100 text-red-800"
                            }`}
                          >
                            {athlete.skillLevel}
                          </span>
                        </td>
                        <td className="px-6 py-4 text-sm font-medium">
                          <Button
                            size="sm"
                            variant="outline"
                            className="mr-2"
                            onClick={() => handleViewProfile(athlete)}
                          >
                            View
                          </Button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            ) : (
              <div className="text-center py-12 px-4">
                <p className="text-lg text-gray-500">
                  No athletes found matching your criteria
                </p>
                <p className="text-sm text-gray-400 mt-1">
                  Try adjusting your filters or add a new athlete
                </p>
              </div>
            )}

            {/* Pagination */}
            {athletes.length > 0 && (
              <div className="flex items-center justify-between mt-4 px-4">
                <div className="text-sm text-gray-500">
                  Page {currentPage} of {totalPages}
                </div>
                <div className="flex items-center space-x-2">
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={goToPreviousPage}
                    disabled={currentPage === 1}
                    className="p-2"
                  >
                    <ChevronLeft className="h-4 w-4" />
                  </Button>

                  {/* Page numbers */}
                  <div className="flex items-center space-x-1">
                    {Array.from({ length: Math.min(5, totalPages) }, (_, i) => {
                      const pageToShow =
                        i === 0
                          ? Math.max(
                              1,
                              Math.min(currentPage - 2, totalPages - 4)
                            )
                          : Math.max(
                              1,
                              Math.min(currentPage - 2, totalPages - 4)
                            ) + i;

                      if (pageToShow <= totalPages) {
                        return (
                          <Button
                            key={i}
                            variant={
                              pageToShow === currentPage ? "default" : "outline"
                            }
                            size="sm"
                            onClick={() => goToPage(pageToShow)}
                            className={
                              pageToShow === currentPage ? "bg-blue-600" : ""
                            }
                          >
                            {pageToShow}
                          </Button>
                        );
                      }
                      return null;
                    })}
                  </div>

                  <Button
                    variant="outline"
                    size="sm"
                    onClick={goToNextPage}
                    disabled={currentPage === totalPages}
                    className="p-2"
                  >
                    <ChevronRight className="h-4 w-4" />
                  </Button>
                </div>
              </div>
            )}
          </div>
        </>
      )}

      {/* Athlete Profile Dialog */}
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
                <div className="grid grid-cols-2 gap-3 mt-4">
                  {athleteDetails.schoolInfo.uploadSchoolId && (
                    <a
                      href={athleteDetails.schoolInfo.uploadSchoolId}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="flex items-center justify-center bg-blue-50 hover:bg-blue-100 text-blue-700 p-2 rounded-md text-xs"
                    >
                      <svg className="w-4 h-4 mr-1" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path d="M12 10V16M12 16L15 13M12 16L9 13M17 21H7C5.89543 21 5 20.1046 5 19V5C5 3.89543 5.89543 3 7 3H12.5858C12.851 3 13.1054 3.10536 13.2929 3.29289L18.7071 8.70711C18.8946 8.89464 19 9.149 19 9.41421V19C19 20.1046 18.1046 21 17 21Z" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
                      </svg>
                      School ID
                    </a>
                  )}
                  {athleteDetails.schoolInfo.latestMarksheet && (
                    <a
                      href={athleteDetails.schoolInfo.latestMarksheet}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="flex items-center justify-center bg-green-50 hover:bg-green-100 text-green-700 p-2 rounded-md text-xs"
                    >
                      <svg className="w-4 h-4 mr-1" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path d="M12 10V16M12 16L15 13M12 16L9 13M17 21H7C5.89543 21 5 20.1046 5 19V5C5 3.89543 5.89543 3 7 3H12.5858C12.851 3 13.1054 3.10536 13.2929 3.29289L18.7071 8.70711C18.8946 8.89464 19 9.149 19 9.41421V19C19 20.1046 18.1046 21 17 21Z" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
                      </svg>
                      Marksheet
                    </a>
                  )}
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
                
                {Object.keys(athleteDetails.sportsInfo.positions).length > 0 && (
                  <div>
                    <p className="text-sm text-gray-500">Positions</p>
                    <div className="mt-1 space-y-1">
                      {Object.entries(athleteDetails.sportsInfo.positions).map(([sport, position]) => (
                        <div key={sport} className="flex items-center justify-between">
                          <span className="text-xs font-medium">{sport}:</span>
                          <span className="text-xs bg-gray-100 px-2 py-1 rounded">{position}</span>
                        </div>
                      ))}
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
                      athleteDetails.staffAssignments.headCoach.name : 
                      "Not assigned"}
                  </p>
                </div>
                <div>
                  <p className="text-sm text-gray-500">Gym Trainer</p>
                  <p className="font-medium">
                    {athleteDetails.staffAssignments.gymTrainer ? 
                      athleteDetails.staffAssignments.gymTrainer.name : 
                      "Not assigned"}
                  </p>
                </div>
                <div>
                  <p className="text-sm text-gray-500">Medical Staff</p>
                  <p className="font-medium">
                    {athleteDetails.staffAssignments.medicalStaff ? 
                      athleteDetails.staffAssignments.medicalStaff.name : 
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
                    {athleteDetails.medicalInfo.allergies.join(", ")}
                  </p>
                </div>

                <div>
                  <p className="text-sm text-gray-500">Medical Conditions</p>
                  <p className="font-medium">
                    {athleteDetails.medicalInfo.medicalConditions.join(", ")}
                  </p>
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
                
                {athleteDetails.sportsInfo.stats && athleteDetails.sportsInfo.stats.length > 0 && (
                  <div className="mt-4 pt-4 border-t border-gray-200">
                    <p className="text-sm font-medium mb-3">Sport-Specific Stats</p>
                    {athleteDetails.sportsInfo.stats.map((sportStat, idx) => (
                      <div key={idx} className="mb-3">
                        <p className="text-xs font-medium text-gray-700 mb-1">{sportStat.sport}</p>
                        <div className="grid grid-cols-2 gap-2">
                          {sportStat.stats.map((stat, statIdx) => (
                            <div key={statIdx} className="bg-gray-50 p-2 rounded">
                              <span className="text-xs text-gray-500 block">{stat.statName}</span>
                              <span className="text-sm font-medium">{stat.value}</span>
                            </div>
                          ))}
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </CardContent>
            </Card>
            
            <Card>
              <CardHeader className="pb-2">
                <CardTitle className="text-lg">Organization</CardTitle>
              </CardHeader>
              <CardContent className="pt-0 space-y-2">
                <div className="flex items-center">
                  {athleteDetails.organization.logo && (
                    <img 
                      src={athleteDetails.organization.logo} 
                      alt="Organization Logo" 
                      className="h-10 w-10 mr-3 object-contain"
                    />
                  )}
                  <div>
                    <p className="font-medium">{athleteDetails.organization.name}</p>
                    <p className="text-xs text-gray-500">Member since {new Date(athleteDetails.metadata.createdAt).toLocaleDateString()}</p>
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
};

export default AthleteManagement;
