import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Progress } from "@/components/ui/progress";
import { Alert } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { useState } from "react";

const InjuryManagement = () => {
  const [showAlert, setShowAlert] = useState(false);
  const injuries = [
    { 
      id: 1, 
      athlete: "Ravi Kumar", 
      sport: "Kabaddi", 
      injury: "Sprained Ankle", 
      status: "Recovering", 
      trainer: "Coach Raj", 
      medicalStaff: "Dr. Mehta", 
      recoveryProgress: 60, 
      report: "Ravi is progressing well in recovery, expect a full recovery in 2 weeks." 
    },
    { 
      id: 2, 
      athlete: "Pooja Sharma", 
      sport: "Cricket", 
      injury: "Knee Strain", 
      status: "Injured", 
      trainer: "Coach Ananya", 
      medicalStaff: "Dr. Kapoor", 
      recoveryProgress: 0, 
      report: "Pooja has a knee strain and will begin rehabilitation after 3 days of rest." 
    },
    { 
      id: 3, 
      athlete: "Amit Singh", 
      sport: "Hockey", 
      injury: "Shoulder Dislocation", 
      status: "Rehabilitating", 
      trainer: "Coach Vikram", 
      medicalStaff: "Dr. Rao", 
      recoveryProgress: 40, 
      report: "Amit is in the early stages of rehabilitation and will undergo physical therapy." 
    },
  ];

  const statusColors = {
    "Recovering": "text-green-600",
    "Injured": "text-red-600",
    "Rehabilitating": "text-yellow-600"
  };

  const handleShowAlert = () => setShowAlert(true);

  return (
    <Card className="bg-gray-100 p-6 rounded-lg shadow-lg w-full max-w-5xl mx-auto">
      <CardHeader>
        <CardTitle className="text-blue-700 text-2xl font-bold">Injury Management</CardTitle>
      </CardHeader>
      <CardContent>
        <div className="overflow-x-auto mb-6">
          <Table className="w-full text-lg">
            <TableHeader>
              <TableRow>
                <TableHead>Athlete</TableHead>
                <TableHead>Sport</TableHead>
                <TableHead>Injury</TableHead>
                <TableHead>Trainer</TableHead>
                <TableHead>Medical Staff</TableHead>
                <TableHead>Status</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {injuries.map((injury) => (
                <TableRow key={injury.id} className="text-lg">
                  <TableCell>{injury.athlete}</TableCell>
                  <TableCell>{injury.sport}</TableCell>
                  <TableCell>{injury.injury}</TableCell>
                  <TableCell>{injury.trainer}</TableCell>
                  <TableCell>{injury.medicalStaff}</TableCell>
                  <TableCell className={`${statusColors[injury.status]} font-semibold`}>
                    {injury.status}
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </div>

        
        <div className="my-6">
          <h3 className="text-xl font-semibold text-blue-700">Recovery Progress</h3>
          {injuries.map((injury) => (
            <div key={injury.id} className="mb-4">
              <div className="flex items-center justify-between">
                <span>{injury.athlete} ({injury.injury})</span>
                <span>{injury.recoveryProgress}%</span>
              </div>
              <Progress value={injury.recoveryProgress} max={100} />
            </div>
          ))}
        </div>

       
        <div className="my-6">
          <h3 className="text-xl font-semibold text-blue-700">Injury Reports</h3>
          {injuries.map((injury) => (
            <div key={injury.id} className="mb-4">
              <h4 className="font-medium">{injury.athlete}'s Report</h4>
              <p>{injury.report}</p>
            </div>
          ))}
        </div>

       
        <div className="my-6">
          <h3 className="text-xl font-semibold text-blue-700">Modified Training Plans</h3>
          {injuries.map((injury) => (
            <div key={injury.id} className="mb-4">
              <h4 className="font-medium">{injury.athlete} ({injury.injury})</h4>
              <Button onClick={handleShowAlert} className="bg-blue-600 text-white">Assign Modified Training Plan</Button>
            </div>
          ))}
        </div>

        
        {showAlert && (
          <Alert className="mb-4">
            <div className="flex justify-between items-center">
              <span className="font-semibold text-green-800">New update on an athlete's recovery progress!</span>
              <Button variant="link" onClick={() => setShowAlert(false)} className="text-green-500">Close</Button>
            </div>
          </Alert>
        )}
      </CardContent>
    </Card>
  );
};

export default InjuryManagement;
