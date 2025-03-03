import { useState } from "react";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";

// Mock data 
const mockMedicalRecords = [
  {
    id: 1,
    athleteName: "Ravi Kumar",
    dateOfBirth: "1990-05-15",
    height: "180cm",
    weight: "75kg",
    bloodType: "A+",
    allergies: "None",
    lastCheckup: "2023-06-01",
  },
  {
    id: 2,
    athleteName: "Pooja Sharma",
    dateOfBirth: "1992-08-22",
    height: "165cm",
    weight: "62kg",
    bloodType: "O-",
    allergies: "Peanuts",
    lastCheckup: "2023-05-28",
  },
  {
    id: 3,
    athleteName: "Amit Singh",
    dateOfBirth: "1988-11-30",
    height: "190cm",
    weight: "85kg",
    bloodType: "B+",
    allergies: "Penicillin",
    lastCheckup: "2023-06-05",
  },
];

// Function to calculate BMI
const calculateBMI = (height, weight) => {
  const heightInMeters = parseInt(height) / 100; // Convert height from cm to meters
  const weightInKg = parseInt(weight); // Convert weight to kg
  return (weightInKg / (heightInMeters * heightInMeters)).toFixed(2); // BMI formula
};

function MedicalRecords() {
  const [searchTerm, setSearchTerm] = useState("");
  const [records, setRecords] = useState(mockMedicalRecords);
  const [newRecord, setNewRecord] = useState({
    athleteName: "",
    dateOfBirth: "",
    height: "",
    weight: "",
    bloodType: "",
    allergies: "",
    lastCheckup: "",
  });

  const handleSearch = (event) => {
    setSearchTerm(event.target.value);
    const filteredRecords = mockMedicalRecords.filter((record) =>
      record.athleteName.toLowerCase().includes(event.target.value.toLowerCase())
    );
    setRecords(filteredRecords);
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setNewRecord((prevRecord) => ({
      ...prevRecord,
      [name]: value,
    }));
  };

  const addNewRecord = () => {
    if (
      newRecord.athleteName &&
      newRecord.dateOfBirth &&
      newRecord.height &&
      newRecord.weight &&
      newRecord.bloodType &&
      newRecord.allergies &&
      newRecord.lastCheckup
    ) {
      setRecords((prevRecords) => [
        ...prevRecords,
        { ...newRecord, id: prevRecords.length + 1 },
      ]);
      
      setNewRecord({
        athleteName: "",
        dateOfBirth: "",
        height: "",
        weight: "",
        bloodType: "",
        allergies: "",
        lastCheckup: "",
      });
    } else {
      alert("Please fill in all fields.");
    }
  };

  return (
    <div className="px-8">
      <h1 className="text-3xl font-bold mb-4">Medical Records</h1>
      <div className="flex justify-between mb-6">
        <Input
          type="text"
          placeholder="Search athletes..."
          value={searchTerm}
          onChange={handleSearch}
          className="max-w-sm text-xl p-4"
        />
        <Button onClick={() => document.getElementById("addRecordForm").classList.toggle("hidden")} className="text-xl px-6 py-3">
          Add New Record
        </Button>
      </div>

      
      <div id="addRecordForm" className="hidden mb-6">
        <div className="space-y-6">
          <div>
            <Label htmlFor="athleteName" className="text-2xl">Athlete Name</Label>
            <Input
              id="athleteName"
              name="athleteName"
              value={newRecord.athleteName}
              onChange={handleInputChange}
              placeholder="Enter athlete name"
              className="text-xl p-4"
            />
          </div>
          <div>
            <Label htmlFor="dateOfBirth" className="text-2xl">Date of Birth</Label>
            <Input
              id="dateOfBirth"
              name="dateOfBirth"
              value={newRecord.dateOfBirth}
              onChange={handleInputChange}
              placeholder="Enter date of birth"
              className="text-xl p-4"
            />
          </div>
          <div>
            <Label htmlFor="height" className="text-2xl">Height</Label>
            <Input
              id="height"
              name="height"
              value={newRecord.height}
              onChange={handleInputChange}
              placeholder="Enter height"
              className="text-xl p-4"
            />
          </div>
          <div>
            <Label htmlFor="weight" className="text-2xl">Weight</Label>
            <Input
              id="weight"
              name="weight"
              value={newRecord.weight}
              onChange={handleInputChange}
              placeholder="Enter weight"
              className="text-xl p-4"
            />
          </div>
          <div>
            <Label htmlFor="bloodType" className="text-2xl">Blood Type</Label>
            <Input
              id="bloodType"
              name="bloodType"
              value={newRecord.bloodType}
              onChange={handleInputChange}
              placeholder="Enter blood type"
              className="text-xl p-4"
            />
          </div>
          <div>
            <Label htmlFor="allergies" className="text-2xl">Allergies</Label>
            <Input
              id="allergies"
              name="allergies"
              value={newRecord.allergies}
              onChange={handleInputChange}
              placeholder="Enter allergies"
              className="text-xl p-4"
            />
          </div>
          <div>
            <Label htmlFor="lastCheckup" className="text-2xl">Last Checkup</Label>
            <Input
              id="lastCheckup"
              name="lastCheckup"
              value={newRecord.lastCheckup}
              onChange={handleInputChange}
              placeholder="Enter last checkup date"
              className="text-xl p-4"
            />
          </div>
          <Button onClick={addNewRecord} className="text-xl py-3 px-8">Add Record</Button>
        </div>
      </div>

      <Table>
        <TableHeader>
          <TableRow>
            <TableHead className="text-xl">Athlete Name</TableHead>
            <TableHead className="text-xl">Date of Birth</TableHead>
            <TableHead className="text-xl">Height</TableHead>
            <TableHead className="text-xl">Weight</TableHead>
            <TableHead className="text-xl">BMI</TableHead> {/* BMI column next to Height and Weight */}
            <TableHead className="text-xl">Blood Type</TableHead>
            <TableHead className="text-xl">Allergies</TableHead>
            <TableHead className="text-xl">Last Checkup</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {records.map((record) => (
            <TableRow key={record.id}>
              <TableCell className="text-xl">{record.athleteName}</TableCell>
              <TableCell className="text-xl">{record.dateOfBirth}</TableCell>
              <TableCell className="text-xl">{record.height}</TableCell>
              <TableCell className="text-xl">{record.weight}</TableCell>
              <TableCell className="text-xl">
                {/* Calculate and display BMI */}
                {calculateBMI(record.height, record.weight)}
              </TableCell>
              <TableCell className="text-xl">{record.bloodType}</TableCell>
              <TableCell className="text-xl">{record.allergies}</TableCell>
              <TableCell className="text-xl">{record.lastCheckup}</TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </div>
  );
}

export default MedicalRecords;
