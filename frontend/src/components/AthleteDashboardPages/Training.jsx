import { useState } from "react";
import { Calendar } from "@/components/ui/calendar";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";


function Training() {
  const [date, setDate] = useState(new Date());
  const [events, setEvents] = useState([]);

  return (
    <div className="space-y-12 w-full px-4">
      <h1 className="text-5xl font-bold text-center">Training Schedule</h1>

      <div className="grid gap-8 grid-cols-1 md:grid-cols-2">
        
        <Card className="w-full">
          <CardHeader>
            <CardTitle className="text-3xl">Training Calendar</CardTitle>
          </CardHeader>
          <CardContent>
           
            <Calendar 
              mode="single" 
              selected={date} 
              onSelect={setDate} 
              className="rounded-md border border-gray-300 w-full text-xl h-[500px]"  
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
      </div>
    </div>
  );
}

export default Training;
