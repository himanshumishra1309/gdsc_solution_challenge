import { useState } from "react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";

const sponsorData = [
  { name: "SportsTech Inc.", amount: 50000, status: "Active" },
  { name: "FitGear Co.", amount: 35000, status: "Active" },
  { name: "HealthBoost Labs", amount: 25000, status: "Pending" },
];

const financeData = [
  { category: "Training", amount: 2000 },
  { category: "Equipment", amount: 1500 },
  { category: "Travel", amount: 3000 },
];

function Finance() {
  const [searchTerm, setSearchTerm] = useState("");
  const [finances, setFinances] = useState(financeData);
  const [editingIndex, setEditingIndex] = useState(null);
  const [editValues, setEditValues] = useState({ category: "", amount: "" });

  const filteredSponsors = sponsorData.filter(({ name, status }) => 
    name.toLowerCase().includes(searchTerm.toLowerCase()) || 
    status.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const handleEdit = (index) => {
    setEditingIndex(index);
    setEditValues(finances[index]);
  };

  const handleSave = (index) => {
    const updatedFinances = [...finances];
    updatedFinances[index] = editValues;
    setFinances(updatedFinances);
    setEditingIndex(null);
  };

  return (
    <div className="space-y-5 w-full">
      <h1 className="text-2xl font-bold text-center">Financial Overview</h1>
      <Card className="w-full">
        <CardHeader>
          <CardTitle className="text-2xl">Sponsorship Details</CardTitle>
          <CardDescription>Your current and pending sponsorships</CardDescription>
          <div className="mt-4">
            <input
              type="text"
              className="w-full p-2 border rounded"
              placeholder="Search by sponsor name or status"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
          </div>
        </CardHeader>
        <CardContent>
          <Table className="w-full text-lg">
            <TableHeader>
              <TableRow>
                <TableHead>Sponsor Name</TableHead>
                <TableHead>Amount</TableHead>
                <TableHead>Status</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {filteredSponsors.map(({ name, amount, status }) => (
                <TableRow key={name}>
                  <TableCell>{name}</TableCell>
                  <TableCell>${amount.toLocaleString()}</TableCell>
                  <TableCell>{status}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      <Card className="w-full">
        <CardHeader>
          <CardTitle className="text-2xl">My Spendings and Finances</CardTitle>
          <CardDescription>Track your financial activities</CardDescription>
        </CardHeader>
        <CardContent>
          <Table className="w-full text-lg">
            <TableHeader>
              <TableRow>
                <TableHead>Category</TableHead>
                <TableHead>Amount</TableHead>
                <TableHead>Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {finances.map((item, index) => (
                <TableRow key={index}>
                  <TableCell>
                    {editingIndex === index ? (
                      <Input
                        value={editValues.category}
                        onChange={(e) => setEditValues({ ...editValues, category: e.target.value })}
                      />
                    ) : (
                      item.category
                    )}
                  </TableCell>
                  <TableCell>
                    {editingIndex === index ? (
                      <Input
                        type="number"
                        value={editValues.amount}
                        onChange={(e) => setEditValues({ ...editValues, amount: e.target.value })}
                      />
                    ) : (
                      `$${item.amount}`
                    )}
                  </TableCell>
                  <TableCell>
                    {editingIndex === index ? (
                      <Button onClick={() => handleSave(index)}>Save</Button>
                    ) : (
                      <Button onClick={() => handleEdit(index)}>Edit</Button>
                    )}
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </div>
  );
}

export default Finance;
