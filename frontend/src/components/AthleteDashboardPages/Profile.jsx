import { useState, useEffect } from "react";
import axios from "axios";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Label } from "@/components/ui/label";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Loader2, CheckCircle, AlertCircle } from "lucide-react";
import { Alert, AlertTitle, AlertDescription } from "@/components/ui/alert";

const bloodGroupOptions = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"];
const sportOptions = ["Cricket", "Basketball", "Football", "Tennis", "Swimming", "Hockey", "Badminton", "Volleyball"];

function Profile() {
  const [profile, setProfile] = useState({
    firstName: "",
    lastName: "",
    email: "",
    sport: "",
    height: "",
    weight: "",
    bmi: "",
    bloodGroup: "",
    address: "",
    state: "",
    number: "",
    dob: "",
    gender: ""
  });
  
  const [loading, setLoading] = useState(true);
  const [updating, setUpdating] = useState(false);
  const [success, setSuccess] = useState("");
  const [error, setError] = useState("");
  const [avatar, setAvatar] = useState(null);
  const [avatarPreview, setAvatarPreview] = useState("");

  // Calculate BMI when height or weight changes
  useEffect(() => {
    if (profile.height && profile.weight) {
      // Convert height from cm to meters
      const heightInMeters = parseFloat(profile.height) / 100;
      const weightInKg = parseFloat(profile.weight);
      
      if (heightInMeters > 0 && weightInKg > 0) {
        const calculatedBMI = (weightInKg / (heightInMeters * heightInMeters)).toFixed(2);
        setProfile(prev => ({ ...prev, bmi: calculatedBMI }));
      }
    }
  }, [profile.height, profile.weight]);

  // Fetch profile data on component mount
  useEffect(() => {
    const fetchProfile = async () => {
      try {
        setLoading(true);
        
        const response = await axios.get(
          "http://localhost:8000/api/v1/independent-athletes/profile",
          {
            withCredentials: true,
            headers: {
              "Content-Type": "application/json",
              "Authorization": `Bearer ${localStorage.getItem("token")}`
            }
          }
        );
        
        const userData = response.data.data;
        
        // Split name into firstName and lastName if coming as single field
        let firstName = userData.firstName || "";
        let lastName = userData.lastName || "";
        
        if (!firstName && !lastName && userData.name) {
          const nameParts = userData.name.split(" ");
          firstName = nameParts[0] || "";
          lastName = nameParts.slice(1).join(" ") || "";
        }
        
        setProfile({
          firstName,
          lastName,
          email: userData.email || "",
          sport: userData.sport || "",
          height: userData.height?.toString() || "",
          weight: userData.weight?.toString() || "",
          bmi: userData.bmi?.toString() || "",
          bloodGroup: userData.bloodGroup || "",
          address: userData.address || "",
          state: userData.state || "",
          number: userData.number || "",
          dob: userData.dob ? new Date(userData.dob).toISOString().split('T')[0] : "",
          gender: userData.gender || ""
        });
        
        if (userData.avatar) {
          setAvatarPreview(userData.avatar);
        }
        
      } catch (error) {
        console.error("Error fetching profile:", error);
        setError("Failed to load profile data. Please try again later.");
      } finally {
        setLoading(false);
      }
    };
    
    fetchProfile();
  }, []);

  const handleChange = (e) => {
    setProfile({ ...profile, [e.target.id]: e.target.value });
  };
  
  const handleSelectChange = (field, value) => {
    setProfile({ ...profile, [field]: value });
  };
  
  const handleFileChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      setAvatar(file);
      setAvatarPreview(URL.createObjectURL(file));
    }
  };

  const handleUpdate = async (e) => {
    e.preventDefault();
    setUpdating(true);
    setError("");
    setSuccess("");
    
    try {
      // Create form data for file upload
      const formData = new FormData();
      formData.append("name", `${profile.firstName} ${profile.lastName}`);
      formData.append("email", profile.email);
      formData.append("sport", profile.sport);
      formData.append("height", profile.height);
      formData.append("weight", profile.weight);
      formData.append("bmi", profile.bmi);
      formData.append("bloodGroup", profile.bloodGroup);
      formData.append("address", profile.address);
      formData.append("state", profile.state);
      formData.append("number", profile.number);
      formData.append("dob", profile.dob);
      formData.append("gender", profile.gender);
      
      if (avatar) {
        formData.append("avatar", avatar);
      }
      
      const response = await axios.patch(
        "http://localhost:8000/api/v1/independent-athletes/profile",
        formData,
        {
          withCredentials: true,
          headers: {
            "Content-Type": "multipart/form-data",
            "Authorization": `Bearer ${localStorage.getItem("token")}`
          }
        }
      );
      
      setSuccess("Profile updated successfully!");
    } catch (error) {
      console.error("Error updating profile:", error);
      setError(error.response?.data?.message || "Failed to update profile. Please try again.");
    } finally {
      setUpdating(false);
    }
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <Loader2 className="h-8 w-8 animate-spin text-blue-600" />
        <span className="ml-2">Loading profile...</span>
      </div>
    );
  }

  return (
    <div className="space-y-8 w-full">
      <h1 className="text-2xl font-bold text-center">Athlete Profile</h1>
      
      {error && (
        <Alert variant="destructive">
          <AlertCircle className="h-4 w-4" />
          <AlertTitle>Error</AlertTitle>
          <AlertDescription>{error}</AlertDescription>
        </Alert>
      )}
      
      {success && (
        <Alert className="bg-green-50 text-green-800 border-green-200">
          <CheckCircle className="h-4 w-4 text-green-600" />
          <AlertTitle>Success</AlertTitle>
          <AlertDescription>{success}</AlertDescription>
        </Alert>
      )}
      
      <Card className="w-full">
        <CardHeader>
          <div className="flex items-center space-x-4">
            <div className="relative">
              <div className="h-20 w-20 rounded-full overflow-hidden bg-gray-200">
                {avatarPreview ? (
                  <img src={avatarPreview} alt="Profile" className="h-full w-full object-cover" />
                ) : (
                  <div className="h-full w-full flex items-center justify-center text-3xl font-semibold text-gray-400">
                    {profile.firstName.charAt(0)}
                  </div>
                )}
              </div>
              <label className="absolute bottom-0 right-0 bg-blue-500 rounded-full p-1 cursor-pointer">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="text-white">
                  <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
                  <polyline points="17 8 12 3 7 8"></polyline>
                  <line x1="12" y1="3" x2="12" y2="15"></line>
                </svg>
                <input type="file" accept="image/*" className="hidden" onChange={handleFileChange} />
              </label>
            </div>
            <div>
              <CardTitle className="text-xl">Personal Information</CardTitle>
              <CardDescription className="text-lg">Update your profile details</CardDescription>
            </div>
          </div>
        </CardHeader>
        <CardContent>
          <form className="space-y-6" onSubmit={handleUpdate}>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="space-y-2">
                <Label htmlFor="firstName" className="text-lg">First Name</Label>
                <Input id="firstName" value={profile.firstName} onChange={handleChange} className="text-lg" />
              </div>
              <div className="space-y-2">
                <Label htmlFor="lastName" className="text-lg">Last Name</Label>
                <Input id="lastName" value={profile.lastName} onChange={handleChange} className="text-lg" />
              </div>
            </div>
            
            <div className="space-y-2">
              <Label htmlFor="email" className="text-lg">Email</Label>
              <Input id="email" type="email" value={profile.email} onChange={handleChange} className="text-lg" readOnly />
              <p className="text-xs text-gray-500 mt-1">Email address cannot be changed</p>
            </div>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="space-y-2">
                <Label htmlFor="dob" className="text-lg">Date of Birth</Label>
                <Input id="dob" type="date" value={profile.dob} onChange={handleChange} className="text-lg" />
              </div>
              <div className="space-y-2">
                <Label htmlFor="gender" className="text-lg">Gender</Label>
                <Select value={profile.gender} onValueChange={(value) => handleSelectChange("gender", value)}>
                  <SelectTrigger id="gender" className="text-lg">
                    <SelectValue placeholder="Select Gender" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="Male">Male</SelectItem>
                    <SelectItem value="Female">Female</SelectItem>
                    <SelectItem value="Other">Other</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            </div>
            
            <div className="space-y-2">
              <Label htmlFor="sport" className="text-lg">Sport</Label>
              <Select value={profile.sport} onValueChange={(value) => handleSelectChange("sport", value)}>
                <SelectTrigger id="sport" className="text-lg">
                  <SelectValue placeholder="Select Sport" />
                </SelectTrigger>
                <SelectContent>
                  {sportOptions.map(sport => (
                    <SelectItem key={sport} value={sport}>{sport}</SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="space-y-2">
                <Label htmlFor="height" className="text-lg">Height (cm)</Label>
                <Input id="height" type="number" value={profile.height} onChange={handleChange} className="text-lg" />
              </div>
              <div className="space-y-2">
                <Label htmlFor="weight" className="text-lg">Weight (kg)</Label>
                <Input id="weight" type="number" value={profile.weight} onChange={handleChange} className="text-lg" />
              </div>
            </div>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="space-y-2">
                <Label htmlFor="bmi" className="text-lg">BMI</Label>
                <Input id="bmi" value={profile.bmi} readOnly className="text-lg bg-gray-50" />
                <p className="text-xs text-gray-500 mt-1">Calculated automatically</p>
              </div>
              <div className="space-y-2">
                <Label htmlFor="bloodGroup" className="text-lg">Blood Group</Label>
                <Select value={profile.bloodGroup} onValueChange={(value) => handleSelectChange("bloodGroup", value)}>
                  <SelectTrigger id="bloodGroup" className="text-lg">
                    <SelectValue placeholder="Select Blood Group" />
                  </SelectTrigger>
                  <SelectContent>
                    {bloodGroupOptions.map(group => (
                      <SelectItem key={group} value={group}>{group}</SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
            </div>
            
            <div className="space-y-2">
              <Label htmlFor="address" className="text-lg">Address</Label>
              <Input id="address" value={profile.address} onChange={handleChange} className="text-lg" />
            </div>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="space-y-2">
                <Label htmlFor="state" className="text-lg">State</Label>
                <Input id="state" value={profile.state} onChange={handleChange} className="text-lg" />
              </div>
              <div className="space-y-2">
                <Label htmlFor="number" className="text-lg">Contact Number</Label>
                <Input id="number" value={profile.number} onChange={handleChange} className="text-lg" />
              </div>
            </div>

            <Button 
              type="submit" 
              className="w-full text-lg py-2"
              disabled={updating}
            >
              {updating ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  Updating...
                </>
              ) : "Update Profile"}
            </Button>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}

export default Profile;