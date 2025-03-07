import { useState } from "react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Label } from "@/components/ui/label";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";

function Profile() {
  const [profile, setProfile] = useState({
    firstName: "",
    lastName: "",
    email: "",
    sport: "",
    coach: "",
    height: "",
    weight: "",
    bmi: "",
    bloodGroup: "",
    address: "",
    state: "",
    number: ""
  });

  const handleChange = (e) => {
    setProfile({ ...profile, [e.target.id]: e.target.value });
  };

  const handleCoachChange = (value) => {
    setProfile({ ...profile, coach: value });
  };

  const handleUpdate = (e) => {
    e.preventDefault();
    alert("Profile Updated Successfully!");
    console.log("Updated Profile:", profile);
  };

  return (
    <div className="space-y-8 w-full">
      <h1 className="text-2xl font-bold text-center">Athlete Profile</h1>
      <Card className="w-full">
        <CardHeader>
          <CardTitle className="text-xl">Personal Information</CardTitle>
          <CardDescription className="text-lg">Update your profile details</CardDescription>
        </CardHeader>
        <CardContent>
          <form className="space-y-6" onSubmit={handleUpdate}>
            <div className="grid grid-cols-2 gap-6">
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
              <Input id="email" type="email" value={profile.email} onChange={handleChange} className="text-lg" />
            </div>
            <div className="space-y-2">
              <Label htmlFor="sport" className="text-lg">Sport</Label>
              <Input id="sport" value={profile.sport} onChange={handleChange} className="text-lg" />
            </div>
            <div className="space-y-2">
              <Label htmlFor="coach" className="text-lg">Assigned Coach</Label>
              <Select onValueChange={handleCoachChange}>
                <SelectTrigger className="text-lg">
                  <SelectValue placeholder={profile.coach || "Select a coach"} />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="Ravi Kumar">Ravi Kumar</SelectItem>
                  <SelectItem value="Priya Singh">Priya Singh</SelectItem>
                  <SelectItem value="Anil Joshi">Anil Joshi</SelectItem>
                </SelectContent>
              </Select>
            </div>

            {/* New Fields */}
            <div className="grid grid-cols-2 gap-6">
              <div className="space-y-2">
                <Label htmlFor="height" className="text-lg">Height (cm)</Label>
                <Input id="height" value={profile.height} onChange={handleChange} className="text-lg" />
              </div>
              <div className="space-y-2">
                <Label htmlFor="weight" className="text-lg">Weight (kg)</Label>
                <Input id="weight" value={profile.weight} onChange={handleChange} className="text-lg" />
              </div>
            </div>
            <div className="grid grid-cols-2 gap-6">
              <div className="space-y-2">
                <Label htmlFor="bmi" className="text-lg">BMI</Label>
                <Input id="bmi" value={profile.bmi} onChange={handleChange} className="text-lg" />
              </div>
              <div className="space-y-2">
                <Label htmlFor="bloodGroup" className="text-lg">Blood Group</Label>
                <Input id="bloodGroup" value={profile.bloodGroup} onChange={handleChange} className="text-lg" />
              </div>
            </div>
            <div className="space-y-2">
              <Label htmlFor="address" className="text-lg">Address</Label>
              <Input id="address" value={profile.address} onChange={handleChange} className="text-lg" />
            </div>
            <div className="grid grid-cols-2 gap-6">
              <div className="space-y-2">
                <Label htmlFor="state" className="text-lg">State</Label>
                <Input id="state" value={profile.state} onChange={handleChange} className="text-lg" />
              </div>
              <div className="space-y-2">
                <Label htmlFor="number" className="text-lg">Contact Number</Label>
                <Input id="number" value={profile.number} onChange={handleChange} className="text-lg" />
              </div>
            </div>

            <Button type="submit" className="w-full text-lg py-2">Update Profile</Button>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}

export default Profile;
