import { useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Calendar } from "@/components/ui/calendar";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";

const Training = () => {
  const [sessions, setSessions] = useState([
    { id: 1, date: "2025-02-10", athlete: "Ravi Kumar", sport: "Kabaddi", plan: "Speed Training", completed: false },
    { id: 2, date: "2025-02-12", athlete: "Pooja Sharma", sport: "Cricket", plan: "Strength Training", completed: false },
  ]);

  const [newSessionDate, setNewSessionDate] = useState("");
  const [newAthlete, setNewAthlete] = useState("");
  const [newPlan, setNewPlan] = useState("");
  const [selectedSport, setSelectedSport] = useState("All");

  const athletes = ["Ravi Kumar", "Pooja Sharma", "Amit Singh", "John Doe"];
  const trainingPlans = ["Speed Training", "Strength Training", "Endurance Training"];

  const addSession = () => {
    if (!newSessionDate || !newAthlete || !newPlan) return;
    setSessions((prevSessions) => [
      ...prevSessions,
      { id: prevSessions.length + 1, date: newSessionDate, athlete: newAthlete, sport: selectedSport, plan: newPlan, completed: false },
    ]);
    setNewSessionDate("");
    setNewAthlete("");
    setNewPlan("");
  };

  const toggleCompletion = (sessionId) => {
    setSessions((prevSessions) =>
      prevSessions.map((session) =>
        session.id === sessionId ? { ...session, completed: !session.completed } : session
      )
    );
  };

  const filteredSessions = sessions.filter((session) => selectedSport === "All" || session.sport === selectedSport);

  return (
    <Card>
      <CardHeader>
        <CardTitle>Training Plans</CardTitle>
      </CardHeader>
      <CardContent>
        
        <div className="mb-4">
          <Calendar
            events={sessions.map((session) => ({
              title: `${session.athlete} - ${session.plan}`,
              start: new Date(session.date),
              end: new Date(session.date),
              allDay: true,
            }))}
          />
        </div>

        
        <div className="mb-6">
          <h3 className="text-lg font-semibold">Add New Training Session</h3>
          <div className="space-y-4">
            <div className="flex space-x-2">
              <Input
                type="date"
                value={newSessionDate}
                onChange={(e) => setNewSessionDate(e.target.value)}
                className="w-48"
              />
              <Select value={selectedSport} onValueChange={setSelectedSport}>
                <SelectTrigger className="w-48">
                  <SelectValue placeholder="Select Sport" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="All">All Sports</SelectItem>
                  <SelectItem value="Kabaddi">Kabaddi</SelectItem>
                  <SelectItem value="Cricket">Cricket</SelectItem>
                  <SelectItem value="Hockey">Hockey</SelectItem>
                  <SelectItem value="Football">Football</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div className="flex space-x-2">
              <Select value={newAthlete} onValueChange={setNewAthlete} className="w-48">
                <SelectTrigger>
                  <SelectValue placeholder="Select Athlete" />
                </SelectTrigger>
                <SelectContent>
                  {athletes.map((athlete, idx) => (
                    <SelectItem key={idx} value={athlete}>
                      {athlete}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
              <Select value={newPlan} onValueChange={setNewPlan} className="w-48">
                <SelectTrigger>
                  <SelectValue placeholder="Select Training Plan" />
                </SelectTrigger>
                <SelectContent>
                  {trainingPlans.map((plan, idx) => (
                    <SelectItem key={idx} value={plan}>
                      {plan}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <Button onClick={addSession}>Add Session</Button>
          </div>
        </div>

        
        <div className="mt-6">
          <h3 className="text-lg font-semibold mb-4">Training Sessions</h3>
          <div className="overflow-x-auto">
            <table className="min-w-full table-auto">
              <thead>
                <tr>
                  <th className="px-4 py-2 border">Date</th>
                  <th className="px-4 py-2 border">Athlete</th>
                  <th className="px-4 py-2 border">Plan</th>
                  <th className="px-4 py-2 border">Status</th>
                  <th className="px-4 py-2 border">Actions</th>
                </tr>
              </thead>
              <tbody>
                {filteredSessions.map((session) => (
                  <tr key={session.id}>
                    <td className="px-4 py-2 border">{session.date}</td>
                    <td className="px-4 py-2 border">{session.athlete}</td>
                    <td className="px-4 py-2 border">{session.plan}</td>
                    <td className="px-4 py-2 border">
                      <span className={`font-semibold ${session.completed ? "text-green-500" : "text-red-500"}`}>
                        {session.completed ? "Completed" : "Pending"}
                      </span>
                    </td>
                    <td className="px-4 py-2 border">
                      <Button onClick={() => toggleCompletion(session.id)}>
                        {session.completed ? "Mark as Pending" : "Mark as Completed"}
                      </Button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </CardContent>
    </Card>
  );
};

export default Training;
