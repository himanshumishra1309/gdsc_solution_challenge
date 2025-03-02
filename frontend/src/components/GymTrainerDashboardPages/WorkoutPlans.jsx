import { useState } from "react";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Calendar } from "@/components/ui/calendar";
import { Table, TableHeader, TableRow, TableHead, TableBody, TableCell } from "@/components/ui/table";
import { Progress } from "@/components/ui/progress";
import { Dialog, DialogTrigger, DialogContent } from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";

const athletes = [
  { name: "Aarav Sharma", completed: 70 },
  { name: "Neha Verma", completed: 50 },
  { name: "Rohan Iyer", completed: 30 },
  { name: "Priya Menon", completed: 90 },
];

function WorkoutPlans() {
  const [date, setDate] = useState(new Date());
  const [workouts, setWorkouts] = useState([]);
  const [newWorkout, setNewWorkout] = useState("");

  const addWorkout = () => {
    if (newWorkout) {
      setWorkouts([...workouts, { date, workout: newWorkout }]);
      setNewWorkout("");
    }
  };

  return (
    <div className="p-6 space-y-6 bg-gray-100 text-gray-900">
      <h1 className="text-3xl font-bold text-blue-600">Workout Plans</h1>
      
      <div className="grid grid-cols-2 gap-6">
        <Card className="bg-white shadow-lg border-l-4 border-blue-500">
          <CardContent className="p-4">
            <h2 className="text-lg font-semibold mb-4 text-blue-700">Workout Calendar</h2>
            <Calendar mode="single" selected={date} onSelect={setDate} />
            <div className="mt-4">
              <Dialog>
                <DialogTrigger>
                  <Button className="bg-blue-500 text-white">Add Workout</Button>
                </DialogTrigger>
                <DialogContent className="p-4">
                  <Input className="border-blue-400" placeholder="Enter workout details" value={newWorkout} onChange={(e) => setNewWorkout(e.target.value)} />
                  <Button className="mt-2 bg-green-500 text-white" onClick={addWorkout}>Save</Button>
                </DialogContent>
              </Dialog>
            </div>
          </CardContent>
        </Card>

        <Card className="bg-white shadow-lg border-l-4 border-green-500">
          <CardContent className="p-4">
            <h2 className="text-lg font-semibold mb-4 text-green-700">Personalized Workout Plans</h2>
            <p className="text-gray-700">Create custom workout plans tailored for individual athletes.</p>
            <Button className="mt-4 bg-green-500 text-white">Create Plan</Button>
          </CardContent>
        </Card>
      </div>
      
      <Card className="bg-white shadow-lg border-l-4 border-orange-500">
        <CardContent className="p-4">
          <h2 className="text-lg font-semibold mb-4 text-orange-700">Assign Workouts</h2>
          <Table>
            <TableHeader>
              <TableRow className="bg-orange-100">
                <TableHead>Athlete</TableHead>
                <TableHead>Completion</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {athletes.map((athlete, index) => (
                <TableRow key={index} className="hover:bg-orange-50">
                  <TableCell className="font-medium text-orange-700">{athlete.name}</TableCell>
                  <TableCell>
                    <Progress className="bg-orange-200" value={athlete.completed} />
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

export default WorkoutPlans;
