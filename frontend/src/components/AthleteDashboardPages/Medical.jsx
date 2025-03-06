import { useState } from "react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Slider } from "@/components/ui/slider";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";

function Medical() {
  const [injuries, setInjuries] = useState([
    { date: "2023-05-15", type: "Sprained Ankle", status: "Recovered" },
    { date: "2023-07-02", type: "Muscle Strain", status: "In Treatment" },
  ]);
  const [newInjury, setNewInjury] = useState({ date: "", type: "", status: "" });
  const [rpe, setRpe] = useState(0);
  const [rpeHistory, setRpeHistory] = useState([]);
  const [file, setFile] = useState(null); 
  const [report, setReport] = useState(""); 
  const rpeDescriptions = [
    "No exertion (Resting)", "Very light", "Light", "Moderate", "Somewhat hard",
    "Hard", "Very hard", "Very, very hard", "Near maximal", "Maximal exertion"
  ];

  const addInjury = () => {
    if (newInjury.date && newInjury.type && newInjury.status) {
      setInjuries([...injuries, newInjury]);
      setNewInjury({ date: "", type: "", status: "" });
    }
  };

  const submitRpe = () => {
    if (rpe >= 0) {
      setRpeHistory([...rpeHistory, { date: new Date().toISOString().split("T")[0], value: rpe }]);
    }
  };

  const handleFileUpload = (event) => {
    setFile(event.target.files[0]);
  };

  const handleSaveReport = () => {
    console.log("Report saved:", report);
  };

  return (
    <div className="space-y-12 px-6 w-full">
      <h1 className="text-4xl font-bold text-center">Medical Records</h1>

      <div className="grid gap-8 md:grid-cols-2">
        {/* Injury Tracking Section */}
        <Card className="w-full">
          <CardHeader>
            <CardTitle className="text-3xl">Injury Tracking</CardTitle>
            <CardDescription className="text-xl">Record and monitor injuries</CardDescription>
          </CardHeader>
          <CardContent>
            <Table className="text-xl">
              <TableHeader>
                <TableRow>
                  <TableHead className="text-2xl">Date</TableHead>
                  <TableHead className="text-2xl">Injury Type</TableHead>
                  <TableHead className="text-2xl">Status</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {injuries.map((injury, index) => (
                  <TableRow key={index}>
                    <TableCell className="text-lg">{injury.date}</TableCell>
                    <TableCell className="text-lg">{injury.type}</TableCell>
                    <TableCell className="text-lg">{injury.status}</TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </CardContent>
        </Card>

        {/*  New Injury Section */}
        <Card className="w-full">
          <CardHeader>
            <CardTitle className="text-3xl">Add New Injury</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-6">
              <div className="space-y-3">
                <Label htmlFor="injury-date" className="text-2xl">Date</Label>
                <Input
                  id="injury-date"
                  type="date"
                  value={newInjury.date}
                  onChange={(e) => setNewInjury({ ...newInjury, date: e.target.value })}
                  className="text-lg p-4"
                />
              </div>
              <div className="space-y-3">
                <Label htmlFor="injury-type" className="text-2xl">Injury Type</Label>
                <Input
                  id="injury-type"
                  value={newInjury.type}
                  onChange={(e) => setNewInjury({ ...newInjury, type: e.target.value })}
                  placeholder="Enter injury type"
                  className="text-lg p-4"
                />
              </div>
              <div className="space-y-3">
                <Label htmlFor="injury-status" className="text-2xl">Status</Label>
                <Input
                  id="injury-status"
                  value={newInjury.status}
                  onChange={(e) => setNewInjury({ ...newInjury, status: e.target.value })}
                  placeholder="Enter injury status"
                  className="text-lg p-4"
                />
              </div>
              <Button onClick={addInjury} className="w-full text-xl py-3">Add Injury</Button>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Medical Report */}
      <Card className="w-full">
        <CardHeader>
          <CardTitle className="text-3xl">Medical Report</CardTitle>
          <CardDescription className="text-xl">Latest medical assessment</CardDescription>
        </CardHeader>
        <CardContent>
          <Textarea
            value={report}
            onChange={(e) => setReport(e.target.value)}
            placeholder="Enter medical report details here..."
            className="min-h-[250px] text-lg p-4"
          />
          <div className="mt-6 flex justify-start gap-4">
            <Button
              onClick={handleSaveReport}
              className="text-sm py-2 px-4"
            >
              Save Report
            </Button>
            <div>
              <Button
                className="text-sm py-2 px-4"
                onClick={() => document.getElementById("upload-report").click()}
              >
                Upload Report
              </Button>
              <input
                id="upload-report"
                type="file"
                onChange={handleFileUpload}
                className="hidden"
              />
              {file && <p className="mt-2 text-lg">File Selected: {file.name}</p>}
            </div>
          </div>
        </CardContent>
      </Card>

      {/* RPE Tracking */}
      <Card className="w-full">
        <CardHeader>
          <CardTitle className="text-3xl">Rate of Perceived Exertion (RPE)</CardTitle>
          <CardDescription className="text-xl">
            Select your exertion level based on the Modified Borg CR10 Scale.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="space-y-6">
            <Label className="text-2xl">Select RPE Level</Label>
            <Slider
              min={0}
              max={10}
              step={1}
              value={[rpe]}
              onValueChange={(val) => setRpe(val[0])}
              className="w-full"
            />
            <p className="text-lg font-semibold text-center">{rpe} - {rpeDescriptions[rpe]}</p>
            <Button onClick={submitRpe} className="w-full text-xl py-3">Submit RPE</Button>
          </div>
          <div className="mt-6">
            <h3 className="text-2xl font-semibold">RPE History</h3>
            <ul className="mt-3 space-y-2">
              {rpeHistory.map((entry, index) => (
                <li key={index} className="text-lg">
                  {entry.date}: RPE {entry.value} - {rpeDescriptions[entry.value]}
                </li>
              ))}
            </ul>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}

export default Medical;
