import React, { useState } from "react";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { Pencil, Plus } from "lucide-react";

const initialAdmins = [
  { id: 1, name: "Rajesh Kumar", email: "rajesh.kumar@example.com", password: "password123" },
  { id: 2, name: "Aisha Verma", email: "aisha.verma@example.com", password: "password456" },
];

const AdminManagement = () => {
  const [admins, setAdmins] = useState(initialAdmins);
  const [newAdmin, setNewAdmin] = useState({ name: "", email: "", password: "" });
  const [editAdmin, setEditAdmin] = useState(null);
  const [dialogOpen, setDialogOpen] = useState(false); 

  // Handle input change
  const handleInputChange = (e, type) => {
    const { name, value } = e.target;
    if (type === "new") setNewAdmin((prev) => ({ ...prev, [name]: value }));
    else setEditAdmin((prev) => ({ ...prev, [name]: value }));
  };

  // Add new admin
  const handleAddAdmin = () => {
    if (newAdmin.name && newAdmin.email && newAdmin.password) {
      const newAdminWithId = { id: admins.length + 1, ...newAdmin };
      setAdmins([...admins, newAdminWithId]);
      setNewAdmin({ name: "", email: "", password: "" }); 
      setDialogOpen(false); 
    }
  };

  // Update existing admin
  const handleEditAdmin = () => {
    setAdmins(admins.map((admin) => (admin.id === editAdmin.id ? editAdmin : admin)));
    setEditAdmin(null);
  };

  return (
    <div className="p-6 max-w-6xl mx-auto">
      <h1 className="text-3xl font-bold mb-6 text-center">Admin Management</h1>

      {/* Add Admin Button */}
      <div className="flex justify-end mb-4">
        <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
          <DialogTrigger asChild>
            <Button className="flex items-center gap-2 bg-green-600 text-white">
              <Plus size={16} /> Add Admin
            </Button>
          </DialogTrigger>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>Add New Admin</DialogTitle>
            </DialogHeader>
            <div className="space-y-4">
              <Input
                name="name"
                placeholder="Full Name"
                value={newAdmin.name}
                onChange={(e) => handleInputChange(e, "new")}
              />
              <Input
                name="email"
                placeholder="Email Address"
                value={newAdmin.email}
                onChange={(e) => handleInputChange(e, "new")}
              />
              <Input
                name="password"
                type="password"
                placeholder="Password"
                value={newAdmin.password}
                onChange={(e) => handleInputChange(e, "new")}
              />
              <Button className="w-full bg-blue-600 text-white" onClick={handleAddAdmin}>
                Add Admin
              </Button>
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
          <div className="space-y-4">
            {admins.map((admin) => (
              <div key={admin.id} className="flex justify-between items-center p-4 border rounded-lg shadow-xl">
                <div className="flex flex-col">
                  <p className="font-semibold">{admin.name}</p>
                  <p className="text-gray-600 text-sm">{admin.email}</p>
                </div>
                <Dialog>
                  <DialogTrigger asChild>
                    <Button variant="outline" className="flex items-center gap-2">
                      <Pencil size={16} /> Edit
                    </Button>
                  </DialogTrigger>
                  <DialogContent>
                    <DialogHeader>
                      <DialogTitle>Edit Admin</DialogTitle>
                    </DialogHeader>
                    <div className="space-y-4">
                      <Input
                        name="name"
                        value={editAdmin?.name || admin.name}
                        onChange={(e) => handleInputChange(e, "edit")}
                      />
                      <Input
                        name="email"
                        value={editAdmin?.email || admin.email}
                        onChange={(e) => handleInputChange(e, "edit")}
                      />
                      <Input
                        name="password"
                        type="password"
                        value={editAdmin?.password || admin.password}
                        onChange={(e) => handleInputChange(e, "edit")}
                      />
                      <Button className="w-full bg-yellow-500" onClick={handleEditAdmin}>
                        Save Changes
                      </Button>
                    </div>
                  </DialogContent>
                </Dialog>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>
    </div>
  );
};

export default AdminManagement;
