import { useState } from "react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";

const sponsorData = [
  { name: "SportsTech Inc.", amount: 50000, status: "Active" },
  { name: "FitGear Co.", amount: 35000, status: "Active" },
  { name: "HealthBoost Labs", amount: 25000, status: "Pending" },
];

function Finance() {
  const [searchTerm, setSearchTerm] = useState("");

  
  const filteredSponsors = sponsorData.filter(({ name, status }) => 
    name.toLowerCase().includes(searchTerm.toLowerCase()) || 
    status.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className="space-y-8 w-full">
      <h1 className="text-4xl font-bold text-center">Financial Overview</h1>
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
    </div>
  );
}

export default Finance;
