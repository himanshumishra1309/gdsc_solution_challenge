import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Label } from "@/components/ui/label";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";

function Profile() {
  return (
    <div className="space-y-8 w-full">
      <h1 className="text-4xl font-bold text-center">Athlete Profile</h1>
      <Card className="w-full">
        <CardHeader>
          <CardTitle className="text-3xl">Personal Information</CardTitle>
          <CardDescription className="text-xl">Update your profile details</CardDescription>
        </CardHeader>
        <CardContent>
          <form className="space-y-6">
            <div className="grid grid-cols-2 gap-6">
              <div className="space-y-2">
                <Label htmlFor="firstName" className="text-lg">First Name</Label>
                <Input id="firstName" placeholder="Aarav" className="text-lg" />
              </div>
              <div className="space-y-2">
                <Label htmlFor="lastName" className="text-lg">Last Name</Label>
                <Input id="lastName" placeholder="Sharma" className="text-lg" />
              </div>
            </div>
            <div className="space-y-2">
              <Label htmlFor="email" className="text-lg">Email</Label>
              <Input id="email" type="email" placeholder="aarav.sharma@example.com" className="text-lg" />
            </div>
            <div className="space-y-2">
              <Label htmlFor="sport" className="text-lg">Sport</Label>
              <Input id="sport" placeholder="Cricket" className="text-lg" />
            </div>
            <div className="space-y-2">
              <Label htmlFor="coach" className="text-lg">Assigned Coach</Label>
              <Select>
                <SelectTrigger className="text-lg">
                  <SelectValue placeholder="Select a coach" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="coach1">Ravi Kumar</SelectItem>
                  <SelectItem value="coach2">Priya Singh</SelectItem>
                  <SelectItem value="coach3">Anil Joshi</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <Button type="submit" className="w-full text-lg py-2">Update Profile</Button>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}

export default Profile;
