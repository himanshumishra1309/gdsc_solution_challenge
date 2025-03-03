import { useState } from "react";
import { Calendar } from "@/components/ui/calendar";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Select, SelectItem, SelectTrigger, SelectContent, SelectValue } from "@/components/ui/select";

function Training() {
  const [date, setDate] = useState(new Date());
  const [events, setEvents] = useState([]);
  const [showPlan, setShowPlan] = useState(false);
  const [selectedWeek, setSelectedWeek] = useState("Week 1");
  const [selectedDay, setSelectedDay] = useState("Monday");

  const trainingPlans = {
    "Week 1": {
      Monday: "20 Reps Squats, 30 Pushups, 15 Min Run",
      Tuesday: "15 Reps Deadlifts, 20 Burpees, 10 Min Jump Rope",
      Wednesday: "30 Min Cardio, 10 Reps Bench Press, 50 Sit-ups",
      Thursday: "20 Reps Pull-ups, 10 Min Cycling, 30 Lunges",
      Friday: "15 Min HIIT, 20 Reps Shoulder Press, 40 Planks",
      Saturday: "5K Run, 30 Reps Jump Squats, 15 Min Yoga",
      Sunday: "Rest Day / Light Stretching",
    },
    "Week 2": {
      Monday: "25 Reps Squats, 35 Pushups, 20 Min Run",
      Tuesday: "20 Reps Deadlifts, 25 Burpees, 15 Min Jump Rope",
      Wednesday: "35 Min Cardio, 15 Reps Bench Press, 60 Sit-ups",
      Thursday: "25 Reps Pull-ups, 15 Min Cycling, 40 Lunges",
      Friday: "20 Min HIIT, 25 Reps Shoulder Press, 50 Planks",
      Saturday: "10K Run, 40 Reps Jump Squats, 20 Min Yoga",
      Sunday: "Active Recovery / Mobility Exercises",
    },
  };

  return (
    <div className="space-y-12 w-full px-4">
      <h1 className="text-5xl font-bold text-center">Training Schedule</h1>

      <div className="grid gap-8 grid-cols-1 md:grid-cols-2 lg:grid-cols-3">
        <Card className="w-full flex flex-col items-center">
          <CardHeader>
            <CardTitle className="text-3xl">Training Calendar</CardTitle>
          </CardHeader>
          <CardContent className="flex flex-col items-center w-full">
            <Calendar 
              mode="single" 
              selected={date} 
              onSelect={setDate} 
              className="rounded-md border border-gray-300 w-full max-w-md text-xl"  
            />
          </CardContent>
        </Card>

        <Card className="w-full">
          <CardHeader>
            <CardTitle className="text-3xl">Upcoming Events</CardTitle>
          </CardHeader>
          <CardContent>
            <ul className="space-y-4">
              {events.map((event, index) => (
                <li key={index} className="flex justify-between items-center text-xl">
                  <span>{event.title}</span>
                  <span className="text-sm text-gray-500">{event.date.toLocaleDateString()}</span>
                </li>
              ))}
            </ul>
            
            <h2 className="text-2xl font-bold mt-6">Featured Upcoming Event</h2>
            <div className="bg-gray-100 p-4 rounded-md mt-4">
              <h3 className="text-xl font-semibold">Marathon in Mumbai</h3>
              <p className="text-lg text-gray-700">Date: March 15, 2025</p>
              <p className="text-lg text-gray-700">Time: 6:00 AM</p>
              <p className="text-lg text-gray-700">Location: Marine Drive, Mumbai</p>
            </div>
          </CardContent>
        </Card>

        {/* Training Plan Selection Section */}
        <Card className="w-full">
          <CardHeader>
            <CardTitle className="text-3xl">Training Plan Selection</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <Select value={selectedWeek} onValueChange={setSelectedWeek}>
              <SelectTrigger className="w-full">
                <SelectValue placeholder="Select a week" />
              </SelectTrigger>
              <SelectContent>
                {Object.keys(trainingPlans).map((week, index) => (
                  <SelectItem key={index} value={week}>{week}</SelectItem>
                ))}
              </SelectContent>
            </Select>
            
            <Select value={selectedDay} onValueChange={setSelectedDay}>
              <SelectTrigger className="w-full">
                <SelectValue placeholder="Select a day" />
              </SelectTrigger>
              <SelectContent>
                {Object.keys(trainingPlans[selectedWeek]).map((day, index) => (
                  <SelectItem key={index} value={day}>{day}</SelectItem>
                ))}
              </SelectContent>
            </Select>

            <Button className="w-full" onClick={() => setShowPlan(!showPlan)}>
              {showPlan ? "Hide Training Plan" : "View Training Plan"}
            </Button>
          </CardContent>
        </Card>
      </div>

      {/* Training Plan Display */}
      {showPlan && (
        <Card className="w-full max-w-3xl mx-auto">
          <CardHeader>
            <CardTitle className="text-3xl">Training Plan</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-lg text-gray-700">
              {trainingPlans[selectedWeek][selectedDay]}
            </p>
          </CardContent>
        </Card>
      )}
    </div>
  );
}

export default Training;
