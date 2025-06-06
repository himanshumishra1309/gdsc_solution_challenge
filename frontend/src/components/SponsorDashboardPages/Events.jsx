import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { useState } from "react";

const initialEvents = [
  { name: "National Sports Meet", date: "March 15, 2025", location: "New Delhi", description: "A gathering of top athletes from various sports." },
  { name: "Elite Athlete Summit", date: "April 10, 2025", location: "Mumbai", description: "Networking event for sponsors and emerging athletes." },
  { name: "Future Stars Camp", date: "May 5, 2025", location: "Bangalore", description: "A platform for young athletes to showcase their talent." },
];

const Events = () => {
  const [events, setEvents] = useState(initialEvents);

  const handleDelete = (index) => {
    const updatedEvents = events.filter((_, i) => i !== index);
    setEvents(updatedEvents);
  };

  return (
    <div className="p-6 space-y-6 min-h-screen">
      <h1 className="text-2xl font-bold">Upcoming Events</h1>
      {events.length > 0 ? (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {events.map((event, index) => (
            <Card key={index}>
              <CardHeader>
                <CardTitle>{event.name}</CardTitle>
              </CardHeader>
              <CardContent>
                <p className="text-gray-600">📅 {event.date}</p>
                <p className="text-gray-600">📍 {event.location}</p>
                <p className="mt-2">{event.description}</p>
                <div className="flex gap-4 mt-4">
                  <Button>View Invitation</Button>
                  <Button variant="destructive" onClick={() => handleDelete(index)}>
                    Delete Invitation
                  </Button>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      ) : (
        <p className="text-gray-500">No upcoming events.</p>
      )}
    </div>
  );
};

export default Events;
