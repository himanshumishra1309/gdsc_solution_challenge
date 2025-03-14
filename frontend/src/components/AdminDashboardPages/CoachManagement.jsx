import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { Select, SelectTrigger, SelectValue, SelectContent, SelectItem } from "@/components/ui/select";
import { Button } from "@/components/ui/button";
import { Dialog, DialogTrigger, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Loader2, AlertTriangle, CheckCircle2 } from "lucide-react";
import { Alert, AlertDescription } from "@/components/ui/alert";
import axios from "axios";

const sportsList = ["All", "Cricket", "Football", "Badminton", "Basketball", "Tennis", "Hockey", "Other"];

const CoachManagement = () => {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [errorMessage, setErrorMessage] = useState("");
  const [successMessage, setSuccessMessage] = useState("");
  
  const [coaches, setCoaches] = useState([]);
  const [selectedSport, setSelectedSport] = useState("All");
  const [filteredCoaches, setFilteredCoaches] = useState([]);
  const [dialogOpen, setDialogOpen] = useState(false);
  
  // Get organization ID from localStorage
  const adminData = JSON.parse(localStorage.getItem('userData') || '{}');
  const organizationId = adminData?.organization || '67d2a52441f8f9d57e80242d';
  
  // Initial coach form state
  const [newCoach, setNewCoach] = useState({
    name: "",
    email: "",
    password: "",
    dob: "",
    gender: "",
    nationality: "India",
    contactNumber: "",
    address: "",
    city: "",
    state: "",
    country: "India",
    pincode: "",
    sport: "Cricket",
    experience: "",
    certifications: "",
    previousOrganizations: "",
    designation: "Assistant Coach",
  });
  
  // File uploads
  const [profilePhoto, setProfilePhoto] = useState(null);
  const [idProof, setIdProof] = useState(null);
  const [certificatesFile, setCertificatesFile] = useState(null);
  
  // Fetch coaches on component mount
  useEffect(() => {
    if (organizationId) {
      fetchCoaches();
    } else {
      setLoading(false);
    }
  }, [organizationId]);
  
  // Fetch coaches from API
  // Example frontend fetch
const fetchCoaches = async (organizationId) => {
  try {
    const response = await axios.get(`http://localhost:8000/api/v1/admins/coaches/${organizationId}`, {
      withCredentials: true
    });
    
    if (response.data && response.data.data) {
      const coachesData = response.data.data.coaches;
      // Process coaches data
    }
  } catch (error) {
    console.error("Error fetching coaches:", error);
  }
};
  
  // Filter coaches by sport
  const handleSportChange = (sport) => {
    setSelectedSport(sport);
    setFilteredCoaches(
      sport === "All" 
        ? coaches 
        : coaches.filter((coach) => coach.sport === sport)
    );
  };
  
  // Handle input change for form fields
  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setNewCoach({ ...newCoach, [name]: value });
  };
  
  // Handle select change (for dropdowns)
  const handleSelectChange = (name, value) => {
    setNewCoach({ ...newCoach, [name]: value });
  };
  
  // Handle file change
  const handleFileChange = (e, setterFunction) => {
    if (e.target.files && e.target.files[0]) {
      setterFunction(e.target.files[0]);
    }
  };
  
  // Add new coach
  const handleAddCoach = async () => {
    // Validate required fields
    if (!newCoach.name || !newCoach.email || !newCoach.password || 
        !newCoach.dob || !newCoach.gender || !newCoach.contactNumber || 
        !newCoach.address || !newCoach.state || !newCoach.country || 
        !newCoach.sport) {
      setErrorMessage("Please fill all required fields");
      return;
    }
    
    setSubmitting(true);
    setErrorMessage("");
    
    try {
      // Create FormData for file uploads
    const formData = new FormData();
    
    // Log organizationId value for debugging
    console.log("Using organization ID:", organizationId);
    
    // Append organization ID first (important field)
    formData.append("organizationId", organizationId);
    
    // Append all text fields
    Object.keys(newCoach).forEach(key => {
      formData.append(key, newCoach[key]);
    });
    
    // Append files if they exist
    if (profilePhoto) formData.append("profilePhoto", profilePhoto);
    if (idProof) formData.append("idProof", idProof);
    if (certificatesFile) formData.append("certificates", certificatesFile);
    
    // Debug what's being sent
    console.log("Form data contents:");
    for (let [key, value] of formData.entries()) {
      console.log(`${key}: ${value instanceof File ? value.name : value}`);
    }
    
    // Submit to API - REMOVE the Content-Type header completely
    const response = await axios.post('http://localhost:8000/api/v1/admins/register-coach', formData, {
      withCredentials: true,
      // Let browser set the content type with correct boundary
    });
      
      if (response.data && response.data.success) {
        // Show success message
        setSuccessMessage("Coach registered successfully!");
        
        // Reset form
        setNewCoach({
          name: "",
          email: "",
          password: "",
          dob: "",
          gender: "",
          nationality: "India",
          contactNumber: "",
          address: "",
          city: "",
          state: "",
          country: "India",
          pincode: "",
          sport: "Cricket",
          experience: "",
          certifications: "",
          previousOrganizations: "",
          designation: "Assistant Coach",
        });
        
        // Reset file uploads
        setProfilePhoto(null);
        setIdProof(null);
        setCertificatesFile(null);
        
        // Refresh coach list
        fetchCoaches();
        
        // Close dialog after short delay
        setTimeout(() => {
          setDialogOpen(false);
          setSuccessMessage("");
        }, 2000);
      }
    } catch (error) {
      console.error("Error registering coach:", error);
      if (error.response) {
        console.error("Response status:", error.response.status);
        console.error("Response data:", error.response.data);
      }
      setErrorMessage(error.response?.data?.message || "Failed to register coach. Please try again.");
    } finally {
      setSubmitting(false);
    }
  };
  
  // View coach profile
  const handleViewProfile = (coachId) => {
    navigate(`/coach-profile/${coachId}`);
  };

  return (
    <div className="p-6 space-y-6">
      <h1 className="text-2xl font-bold">Coach Management</h1>

      {/* Filter by Sport */}
      <div className="flex items-center space-x-4">
        <div className="w-64">
          <Select value={selectedSport} onValueChange={handleSportChange}>
            <SelectTrigger>
              <SelectValue>{selectedSport}</SelectValue>
            </SelectTrigger>
            <SelectContent>
              {sportsList.map((sport) => (
                <SelectItem key={sport} value={sport}>{sport}</SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
        
        {/* Add New Coach Button */}
        <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
          <DialogTrigger asChild>
            <Button variant="default">Register New Coach</Button>
          </DialogTrigger>

          {/* Modal Content */}
          <DialogContent className="max-w-4xl">
            <DialogHeader>
              <DialogTitle className="text-xl font-semibold">Register New Coach</DialogTitle>
            </DialogHeader>
            
            {errorMessage && (
              <Alert variant="destructive" className="mb-4">
                <AlertTriangle className="h-4 w-4 mr-2" />
                <AlertDescription>{errorMessage}</AlertDescription>
              </Alert>
            )}
            
            {successMessage && (
              <Alert className="mb-4 bg-green-50 text-green-700 border-green-200">
                <CheckCircle2 className="h-4 w-4 mr-2" />
                <AlertDescription>{successMessage}</AlertDescription>
              </Alert>
            )}

            {/* Form Fields - Basic Information */}
            <div className="space-y-4 max-h-[60vh] overflow-y-auto p-1">
              <h3 className="font-medium text-lg">Basic Information</h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <Label htmlFor="name">Full Name *</Label>
                  <Input 
                    id="name" 
                    name="name" 
                    placeholder="Full Name" 
                    value={newCoach.name} 
                    onChange={handleInputChange}
                  />
                </div>
                <div>
                  <Label htmlFor="email">Email Address *</Label>
                  <Input 
                    id="email" 
                    name="email" 
                    type="email" 
                    placeholder="Email Address" 
                    value={newCoach.email} 
                    onChange={handleInputChange}
                  />
                </div>
              </div>
              
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <Label htmlFor="password">Password *</Label>
                  <Input 
                    id="password" 
                    name="password" 
                    type="password" 
                    placeholder="Password" 
                    value={newCoach.password} 
                    onChange={handleInputChange}
                  />
                </div>
                <div>
                  <Label htmlFor="dob">Date of Birth *</Label>
                  <Input 
                    id="dob" 
                    name="dob" 
                    type="date" 
                    value={newCoach.dob} 
                    onChange={handleInputChange}
                  />
                </div>
              </div>
              
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <Label htmlFor="gender">Gender *</Label>
                  <Select 
                    value={newCoach.gender} 
                    onValueChange={(value) => handleSelectChange("gender", value)}
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
                  <Label htmlFor="nationality">Nationality</Label>
                  <Input 
                    id="nationality" 
                    name="nationality" 
                    placeholder="Nationality" 
                    value={newCoach.nationality} 
                    onChange={handleInputChange}
                  />
                </div>
              </div>
              
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <Label htmlFor="contactNumber">Contact Number *</Label>
                  <Input 
                    id="contactNumber" 
                    name="contactNumber" 
                    placeholder="Contact Number" 
                    value={newCoach.contactNumber} 
                    onChange={handleInputChange}
                  />
                </div>
                <div>
                  <Label htmlFor="profilePhoto">Profile Photo</Label>
                  <Input 
                    id="profilePhoto" 
                    type="file"
                    accept="image/*"
                    onChange={(e) => handleFileChange(e, setProfilePhoto)}
                  />
                </div>
              </div>
              
              {/* Form Fields - Address */}
              <h3 className="font-medium text-lg mt-6">Address Information</h3>
              <div>
                <Label htmlFor="address">Street Address *</Label>
                <Input 
                  id="address" 
                  name="address" 
                  placeholder="Street Address" 
                  value={newCoach.address} 
                  onChange={handleInputChange}
                />
              </div>
              
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <Label htmlFor="city">City</Label>
                  <Input 
                    id="city" 
                    name="city" 
                    placeholder="City" 
                    value={newCoach.city} 
                    onChange={handleInputChange}
                  />
                </div>
                <div>
                  <Label htmlFor="state">State *</Label>
                  <Input 
                    id="state" 
                    name="state" 
                    placeholder="State" 
                    value={newCoach.state} 
                    onChange={handleInputChange}
                  />
                </div>
              </div>
              
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <Label htmlFor="country">Country *</Label>
                  <Input 
                    id="country" 
                    name="country" 
                    placeholder="Country" 
                    value={newCoach.country} 
                    onChange={handleInputChange}
                  />
                </div>
                <div>
                  <Label htmlFor="pincode">Pincode</Label>
                  <Input 
                    id="pincode" 
                    name="pincode" 
                    placeholder="Pincode" 
                    value={newCoach.pincode} 
                    onChange={handleInputChange}
                  />
                </div>
              </div>
              
              {/* Form Fields - Professional Information */}
              <h3 className="font-medium text-lg mt-6">Professional Information</h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <Label htmlFor="sport">Sport *</Label>
                  <Select 
                    value={newCoach.sport} 
                    onValueChange={(value) => handleSelectChange("sport", value)}
                  >
                    <SelectTrigger>
                      <SelectValue placeholder="Select Sport" />
                    </SelectTrigger>
                    <SelectContent>
                      {sportsList.filter(sport => sport !== "All").map((sport) => (
                        <SelectItem key={sport} value={sport}>{sport}</SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
                <div>
                  <Label htmlFor="designation">Designation</Label>
                  <Select 
                    value={newCoach.designation} 
                    onValueChange={(value) => handleSelectChange("designation", value)}
                  >
                    <SelectTrigger>
                      <SelectValue placeholder="Select Designation" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="Head Coach">Head Coach</SelectItem>
                      <SelectItem value="Assistant Coach">Assistant Coach</SelectItem>
                      <SelectItem value="Training and Conditioning Staff">Training & Conditioning Staff</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </div>
              
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <Label htmlFor="experience">Years of Experience *</Label>
                  <Input 
                    id="experience" 
                    name="experience" 
                    type="number" 
                    placeholder="Years of Experience" 
                    value={newCoach.experience} 
                    onChange={handleInputChange}
                  />
                </div>
                <div>
                  <Label htmlFor="certifications">Certifications (comma separated)</Label>
                  <Input 
                    id="certifications" 
                    name="certifications" 
                    placeholder="E.g. BCCI Level 2, FIFA B License" 
                    value={newCoach.certifications} 
                    onChange={handleInputChange}
                  />
                </div>
              </div>
              
              <div>
                <Label htmlFor="previousOrganizations">Previous Organizations (comma separated)</Label>
                <Textarea 
                  id="previousOrganizations" 
                  name="previousOrganizations" 
                  placeholder="E.g. Delhi Cricket Club, Mumbai Football Academy" 
                  value={newCoach.previousOrganizations} 
                  onChange={handleInputChange}
                />
              </div>
              
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <Label htmlFor="idProof">ID Proof</Label>
                  <Input 
                    id="idProof" 
                    type="file"
                    onChange={(e) => handleFileChange(e, setIdProof)}
                  />
                </div>
                <div>
                  <Label htmlFor="certificatesFile">Certificates (PDF)</Label>
                  <Input 
                    id="certificates" 
                    type="file"
                    accept=".pdf"
                    onChange={(e) => handleFileChange(e, setCertificatesFile)}
                  />
                </div>
              </div>
            </div>

            <DialogFooter className="mt-6">
              <Button 
                variant="outline" 
                onClick={() => setDialogOpen(false)}
                disabled={submitting}
              >
                Cancel
              </Button>
              <Button 
                onClick={handleAddCoach}
                disabled={submitting}
              >
                {submitting ? (
                  <>
                    <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                    Registering...
                  </>
                ) : "Register Coach"}
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      </div>

      {/* Loading State */}
      {loading ? (
        <div className="flex justify-center items-center h-64">
          <Loader2 className="h-8 w-8 animate-spin text-blue-600" />
          <span className="ml-2 text-lg">Loading coaches...</span>
        </div>
      ) : (
        <>
          {/* Coach List */}
          {filteredCoaches.length > 0 ? (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {filteredCoaches.map((coach) => (
                <Card key={coach._id} className="hover:shadow-md transition-shadow">
                  <CardHeader className="pb-2">
                    <CardTitle className="flex items-center">
                      {coach.avatar ? (
                        <img 
                          src={coach.avatar} 
                          alt={coach.name} 
                          className="h-10 w-10 rounded-full object-cover mr-3"
                        />
                      ) : (
                        <div className="h-10 w-10 rounded-full bg-blue-100 text-blue-600 flex items-center justify-center font-bold mr-3">
                          {coach.name.charAt(0).toUpperCase()}
                        </div>
                      )}
                      <span className="cursor-pointer hover:text-blue-600" onClick={() => handleViewProfile(coach._id)}>
                        {coach.name}
                      </span>
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <p className="text-sm text-gray-600 mb-1">📧 {coach.email}</p>
                    <p className="text-sm text-gray-600 mb-1">🏅 {coach.sport}</p>
                    <p className="text-sm text-gray-600 mb-1">💼 {coach.designation}</p>
                    <p className="text-sm text-gray-600 mb-3">⏱️ {coach.experience} years experience</p>
                    
                    <Button 
                      size="sm" 
                      className="w-full" 
                      onClick={() => handleViewProfile(coach._id)}
                    >
                      View Profile
                    </Button>
                  </CardContent>
                </Card>
              ))}
            </div>
          ) : (
            <div className="text-center py-16 bg-gray-50 rounded-lg">
              <p className="text-gray-500 mb-4">No coaches found for {selectedSport === "All" ? "any sport" : selectedSport}.</p>
              <Button onClick={() => setDialogOpen(true)}>Register a New Coach</Button>
            </div>
          )}
        </>
      )}
    </div>
  );
};

export default CoachManagement;