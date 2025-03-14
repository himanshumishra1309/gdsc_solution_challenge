import React, { useState, useEffect } from "react";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger, DialogFooter } from "@/components/ui/dialog";
import { Pencil, Plus, Loader2, AlertTriangle, CheckCircle2 } from "lucide-react";
import { Alert, AlertDescription } from "@/components/ui/alert";
import axios from "axios";

const AdminManagement = () => {
  const [admins, setAdmins] = useState([]);
  const [loading, setLoading] = useState(true);
  const [newAdmin, setNewAdmin] = useState({ name: "", email: "", password: "" });
  const [editAdmin, setEditAdmin] = useState(null);
  const [dialogOpen, setDialogOpen] = useState(false);
  const [avatar, setAvatar] = useState(null);
  const [errorMessage, setErrorMessage] = useState("");
  const [successMessage, setSuccessMessage] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);
  
  // Get organization ID from localStorage (super admin should be logged in)
  const adminData = JSON.parse(localStorage.getItem('userData') || '{}');
  const organizationId = adminData?.organization || '67d2a52441f8f9d57e80242d';

  // Fetch admins on component mount
  useEffect(() => {
    fetchAdmins();
  }, []);

  // Fix the fetch administrators endpoint
const fetchAdmins = async () => {
  setLoading(true);
  try {
    const response = await axios.get('http://localhost:8000/api/v1/admins/administrators', { 
      params: { organizationId },
      withCredentials: true 
    });
    
    if (response.data && response.data.data) {
      setAdmins(response.data.data.admins || []);
    }
  } catch (error) {
    console.error("Error fetching admins:", error);
    setErrorMessage("Failed to load administrators. Please try again later.");
  } finally {
    setLoading(false);
  }
};

  // Handle input change
  const handleInputChange = (e, type) => {
    const { name, value } = e.target;
    if (type === "new") setNewAdmin((prev) => ({ ...prev, [name]: value }));
    else setEditAdmin((prev) => ({ ...prev, [name]: value }));
  };

  // Handle file change for avatar
  const handleFileChange = (e) => {
    if (e.target.files && e.target.files[0]) {
      setAvatar(e.target.files[0]);
    }
  };

  // Add new admin
  const handleAddAdmin = async () => {
    // Validate inputs
    if (!newAdmin.name || !newAdmin.email || !newAdmin.password) {
      setErrorMessage("Please fill out all required fields.");
      return;
    }

    if (!organizationId) {
      setErrorMessage("Organization ID is required. Please log in again.");
      return;
    }

    setIsSubmitting(true);
    setErrorMessage("");
    
    try {
      // Create FormData object
      const formData = new FormData();
      formData.append("name", newAdmin.name);
      formData.append("email", newAdmin.email);
      formData.append("password", newAdmin.password);
      formData.append("organizationId", organizationId);
      
      // Add avatar if present
      if (avatar) {
        formData.append("avatar", avatar);
      }

      // Submit form data
      const response = await axios.post('http://localhost:8000/api/v1/admins/register', formData, {
        headers: {
          "Content-Type": "multipart/form-data",
        },
        withCredentials: true
      });

      if (response.data && response.data.success) {
        // Show success message
        setSuccessMessage("Admin registered successfully!");
        
        // Reset form
        setNewAdmin({ name: "", email: "", password: "" });
        setAvatar(null);
        
        // Refresh admin list
        fetchAdmins();
        
        // Close dialog after short delay
        setTimeout(() => {
          setDialogOpen(false);
          setSuccessMessage("");
        }, 2000);
      }
    } catch (error) {
      console.error("Error registering admin:", error);
      setErrorMessage(error.response?.data?.message || "Failed to register admin. Please try again.");
    } finally {
      setIsSubmitting(false);
    }
  };

  // Update existing admin
  const handleEditAdmin = () => {
    // Implementation would go here - you'll need to create an endpoint for this
    setAdmins(admins.map((admin) => (admin._id === editAdmin._id ? editAdmin : admin)));
    setEditAdmin(null);
  };

  return (
    <div className="p-6 max-w-6xl mx-auto">
      <h1 className="text-3xl font-bold mb-6 text-center">Admin Management</h1>

      {/* Add Admin Button */}
      <div className="flex justify-end mb-4">
        <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
          <DialogTrigger asChild>
            <Button className="flex items-center gap-2 bg-green-600 text-white hover:bg-green-700">
              <Plus size={16} /> Add Admin
            </Button>
          </DialogTrigger>
          <DialogContent>
            <DialogHeader>
              <DialogTitle className="text-xl font-semibold mb-2">Add New Admin</DialogTitle>
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
            
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium mb-1">Full Name *</label>
                <Input
                  name="name"
                  placeholder="Full Name"
                  value={newAdmin.name}
                  onChange={(e) => handleInputChange(e, "new")}
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium mb-1">Email Address *</label>
                <Input
                  name="email"
                  type="email"
                  placeholder="Email Address"
                  value={newAdmin.email}
                  onChange={(e) => handleInputChange(e, "new")}
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium mb-1">Password *</label>
                <Input
                  name="password"
                  type="password"
                  placeholder="Password"
                  value={newAdmin.password}
                  onChange={(e) => handleInputChange(e, "new")}
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium mb-1">Profile Avatar</label>
                <Input
                  type="file"
                  accept="image/*"
                  onChange={handleFileChange}
                />
              </div>
              
              <DialogFooter className="mt-4">
                <Button 
                  variant="outline" 
                  onClick={() => setDialogOpen(false)}
                  disabled={isSubmitting}
                >
                  Cancel
                </Button>
                <Button 
                  className="bg-blue-600 hover:bg-blue-700 text-white ml-2" 
                  onClick={handleAddAdmin}
                  disabled={isSubmitting}
                >
                  {isSubmitting ? (
                    <>
                      <Loader2 className="h-4 w-4 animate-spin mr-2" />
                      Registering...
                    </>
                  ) : "Add Admin"}
                </Button>
              </DialogFooter>
            </div>
          </DialogContent>
        </Dialog>
      </div>

      {/* Admin List */}
      <Card>
        <CardHeader>
          <CardTitle>Admin List</CardTitle>
        </CardHeader>
        <CardContent>
          {loading ? (
            <div className="flex justify-center items-center h-40">
              <Loader2 className="h-8 w-8 animate-spin text-blue-600" />
              <span className="ml-2 text-lg">Loading administrators...</span>
            </div>
          ) : admins.length > 0 ? (
            <div className="space-y-4">
              {admins.map((admin) => (
                <div key={admin._id} className="flex justify-between items-center p-4 border rounded-lg shadow-sm">
                  <div className="flex items-center">
                    {admin.avatar ? (
                      <img 
                        src={admin.avatar} 
                        alt={admin.name} 
                        className="h-10 w-10 rounded-full object-cover mr-4"
                      />
                    ) : (
                      <div className="h-10 w-10 rounded-full bg-blue-100 flex items-center justify-center text-blue-600 font-bold mr-4">
                        {admin.name.charAt(0).toUpperCase()}
                      </div>
                    )}
                    <div className="flex flex-col">
                      <p className="font-semibold">{admin.name}</p>
                      <p className="text-gray-600 text-sm">{admin.email}</p>
                    </div>
                  </div>
                  <Button variant="outline" className="flex items-center gap-2">
                    <Pencil size={16} /> Edit
                  </Button>
                </div>
              ))}
            </div>
          ) : (
            <div className="text-center py-8 text-gray-500">
              No administrators found. Add a new admin to get started.
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
};

export default AdminManagement;