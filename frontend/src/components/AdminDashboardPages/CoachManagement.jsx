import React, { useState, useEffect } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { Select, SelectTrigger, SelectValue, SelectContent, SelectItem } from "@/components/ui/select";
import { Button } from "@/components/ui/button";
import { Dialog, DialogTrigger, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Loader2, AlertTriangle, CheckCircle2, ChevronLeft, ChevronRight } from "lucide-react";
import { Alert, AlertDescription } from "@/components/ui/alert";
import axios from "axios";

const sportsList = ["All", "Cricket", "Football", "Badminton", "Basketball", "Tennis", "Hockey", "Other"];
const designationList = ["All", "Head Coach", "Assistant Coach", "Training and Conditioning Staff"];

const CoachManagement = () => {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [errorMessage, setErrorMessage] = useState("");
  const [successMessage, setSuccessMessage] = useState("");
  
  // Basic state
  const [coaches, setCoaches] = useState([]);
  const [dialogOpen, setDialogOpen] = useState(false);
  
  // Pagination state
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [totalCoaches, setTotalCoaches] = useState(0);
  const [limit, setLimit] = useState(10);
  
  // Sorting state
  const [sortField, setSortField] = useState('name');
  const [sortOrder, setSortOrder] = useState('asc');
  
  // Filter state
  const [selectedSport, setSelectedSport] = useState("All");
  const [selectedDesignation, setSelectedDesignation] = useState("All");
  const [searchQuery, setSearchQuery] = useState('');
  
  // Get organization ID from URL params
  const { organizationId } = useParams();
  console.log("Organization ID:", organizationId);
  
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

  // Fetch coaches when pagination, sorting, or filters change
  useEffect(() => {
    if (organizationId) {
      fetchCoaches();
    } else {
      setLoading(false);
    }
  }, [organizationId, currentPage, limit, sortField, sortOrder, selectedSport, selectedDesignation, searchQuery]);
  
  // Fetch coaches with all parameters
  const fetchCoaches = async () => {
    setLoading(true);
    try {
      // Build query parameters
      const params = {
        organizationId,
        page: currentPage,
        limit,
        sort: sortField,
        order: sortOrder,
        search: searchQuery,
      };
      
      // Add optional filters only if they're not "All"
      if (selectedSport !== "All") params.sport = selectedSport;
      if (selectedDesignation !== "All") params.designation = selectedDesignation;
      
      const response = await axios.get("http://localhost:8000/api/v1/admins/coaches", {
        params,
        withCredentials: true
      });
      
      console.log("Coach data received:", response.data);
      
      if (response.data?.data?.coaches) {
        // Update coaches state with fetched data
        setCoaches(response.data.data.coaches);
        
        // Update pagination information
        const pagination = response.data.data.pagination;
        setTotalPages(pagination.totalPages);
        setTotalCoaches(pagination.totalCoaches);
      } else {
        console.warn("No coaches data found in response");
        setCoaches([]);
      }
    } catch (error) {
      console.error("Error fetching coaches:", error);
      setErrorMessage("Failed to load coaches. Please try again.");
      setCoaches([]);
    } finally {
      setLoading(false);
    }
  };
  
  // Handle filter changes
  const handleSportChange = (sport) => {
    setSelectedSport(sport);
    setCurrentPage(1); // Reset to first page when filter changes
  };
  
  const handleDesignationChange = (designation) => {
    setSelectedDesignation(designation);
    setCurrentPage(1); // Reset to first page when filter changes
  };
  
  const handleSearchChange = (e) => {
    setSearchQuery(e.target.value);
    setCurrentPage(1); // Reset to first page when search changes
  };
  
  // Handle sorting changes
  const handleSortChange = (field) => {
    // If clicking the same field, toggle order
    if (field === sortField) {
      setSortOrder(sortOrder === 'asc' ? 'desc' : 'asc');
    } else {
      // If new field, set to that field with ascending order
      setSortField(field);
      setSortOrder('asc');
    }
  };
  
  // Handle pagination
  const goToPage = (page) => {
    setCurrentPage(page);
  };
  
  const goToNextPage = () => {
    if (currentPage < totalPages) {
      setCurrentPage(currentPage + 1);
    }
  };
  
  const goToPreviousPage = () => {
    if (currentPage > 1) {
      setCurrentPage(currentPage - 1);
    }
  };
  
  // Handle form input changes
  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setNewCoach(prev => ({ ...prev, [name]: value }));
  };
  
  const handleSelectChange = (name, value) => {
    setNewCoach(prev => ({ ...prev, [name]: value }));
  };
  
  const handleFileChange = (e, setFileFn) => {
    if (e.target.files && e.target.files[0]) {
      setFileFn(e.target.files[0]);
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

      {/* Search and Filters */}
      <div className="bg-white p-4 rounded-lg shadow-sm">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-4">
          <div>
            <label className="text-sm font-medium mb-1 block">Search</label>
            <Input
              placeholder="Search by name, email, or phone"
              value={searchQuery}
              onChange={handleSearchChange}
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
                {sportsList.map((sport) => (
                  <SelectItem key={sport} value={sport}>{sport}</SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
          
          <div>
            <label className="text-sm font-medium mb-1 block">Designation</label>
            <Select value={selectedDesignation} onValueChange={handleDesignationChange}>
              <SelectTrigger>
                <SelectValue placeholder="Select Designation">{selectedDesignation}</SelectValue>
              </SelectTrigger>
              <SelectContent>
                {designationList.map((designation) => (
                  <SelectItem key={designation} value={designation}>{designation}</SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
          
          <div>
            <label className="text-sm font-medium mb-1 block">Results per page</label>
            <Select value={limit.toString()} onValueChange={(val) => setLimit(Number(val))}>
              <SelectTrigger>
                <SelectValue placeholder="Per page">{limit}</SelectValue>
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="5">5</SelectItem>
                <SelectItem value="10">10</SelectItem>
                <SelectItem value="20">20</SelectItem>
                <SelectItem value="50">50</SelectItem>
              </SelectContent>
            </Select>
          </div>
        </div>
        
        <div className="flex justify-between items-center">
          <div className="text-sm text-gray-600">
            Showing {coaches.length} of {totalCoaches} coaches
          </div>
          
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
                
                {/* Rest of the form fields... */}
                {/* For brevity, I'll keep just the form structure as is */}
                
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
                
                {/* ... other form sections ... */}
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
          {coaches.length > 0 ? (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {coaches.map((coach) => (
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
              <p className="text-gray-500 mb-4">No coaches found matching your criteria.</p>
              <Button onClick={() => setDialogOpen(true)}>Register a New Coach</Button>
            </div>
          )}
          
          {/* Pagination Controls */}
          {coaches.length > 0 && (
            <div className="flex items-center justify-between border-t border-gray-200 bg-white px-4 py-3 sm:px-6 mt-4 rounded-lg">
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
                    Showing <span className="font-medium">{coaches.length}</span> of{' '}
                    <span className="font-medium">{totalCoaches}</span> coaches
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
                    
                    {/* Page number buttons */}
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
          )}
        </>
      )}
    </div>
  );
};

export default CoachManagement;