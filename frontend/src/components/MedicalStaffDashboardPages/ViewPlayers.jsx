import { useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";

const mockAthletes = [
  { id: 1, name: "Arjun Kumar", age: 28, sport: "Football", team: "Team A", status: "Active", coach: "Ravi Sharma", upcomingCheckupDate: "2025-05-10" },
  { id: 2, name: "Priya Gupta", age: 24, sport: "Basketball", team: "Team B", status: "Injured", coach: "Sunil Verma", upcomingCheckupDate: "2025-04-15" },
  { id: 3, name: "Vikram Reddy", age: 30, sport: "Tennis", team: "Team C", status: "Active", coach: "Rajesh Patil", upcomingCheckupDate: "2025-06-20" },
  { id: 4, name: "Neha Desai", age: 26, sport: "Swimming", team: "Team A", status: "Active", coach: "Anita Sharma", upcomingCheckupDate: "2025-07-02" },
  { id: 5, name: "Saurabh Mehta", age: 27, sport: "Cricket", team: "Team D", status: "Active", coach: "Vinod Singh", upcomingCheckupDate: "2025-08-05" },
  { id: 6, name: "Aarti Shah", age: 23, sport: "Badminton", team: "Team E", status: "Injured", coach: "Meena Yadav", upcomingCheckupDate: "2025-09-12" },
];

function ViewPlayers() {
  const [searchTerm, setSearchTerm] = useState("");
  const [athletes, setAthletes] = useState(mockAthletes);
  const [selectedCheckup, setSelectedCheckup] = useState(""); // state for upcoming checkup input
  const [isModalOpen, setIsModalOpen] = useState(false); // state to control modal visibility
  const [newAthlete, setNewAthlete] = useState({ name: "", age: "", sport: "", team: "", coach: "" }); // state for new athlete input

  const handleSearch = (event) => {
    setSearchTerm(event.target.value);
    const filteredAthletes = mockAthletes.filter(
      (athlete) =>
        athlete.name.toLowerCase().includes(event.target.value.toLowerCase()) ||
        athlete.sport.toLowerCase().includes(event.target.value.toLowerCase())
    );
    setAthletes(filteredAthletes);
  };

  const handleCheckupDateChange = (athleteId, newDate) => {
    const updatedAthletes = athletes.map((athlete) =>
      athlete.id === athleteId ? { ...athlete, upcomingCheckupDate: newDate } : athlete
    );
    setAthletes(updatedAthletes);
  };

  const handleOpenModal = () => {
    setIsModalOpen(true);
  };

  const handleCloseModal = () => {
    setIsModalOpen(false);
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setNewAthlete((prev) => ({ ...prev, [name]: value }));
  };

  const handleSubmit = () => {
    // Add the new athlete
    setAthletes([
      ...athletes,
      { ...newAthlete, id: athletes.length + 1, status: "Active", upcomingCheckupDate: "" },
    ]);
    setNewAthlete({ name: "", age: "", sport: "", team: "", coach: "" }); // reset the form
    setIsModalOpen(false); // close the modal
  };

  return (
    <div>
      <h1 className="text-3xl font-bold mb-4">View Athletes</h1>
      <div className="flex justify-between mb-4">
        <Input
          type="text"
          placeholder="Search athletes or sports..."
          value={searchTerm}
          onChange={handleSearch}
          className="max-w-sm"
        />
        <Button onClick={handleOpenModal}>Add New Athlete</Button>
      </div>

      {/* Modal for adding a new athlete */}
      {isModalOpen && (
        <div className="fixed inset-0 flex items-center justify-center bg-gray-800 bg-opacity-50">
          <div className="bg-white p-8 rounded-lg shadow-lg w-96">
            <h2 className="text-2xl mb-4">Add New Athlete</h2>
            <div className="mb-4">
              <Input
                type="text"
                name="name"
                value={newAthlete.name}
                onChange={handleInputChange}
                placeholder="Name"
                className="mb-2"
              />
              <Input
                type="number"
                name="age"
                value={newAthlete.age}
                onChange={handleInputChange}
                placeholder="Age"
                className="mb-2"
              />
              <Input
                type="text"
                name="sport"
                value={newAthlete.sport}
                onChange={handleInputChange}
                placeholder="Sport"
                className="mb-2"
              />
              <Input
                type="text"
                name="team"
                value={newAthlete.team}
                onChange={handleInputChange}
                placeholder="Team"
                className="mb-2"
              />
              <Input
                type="text"
                name="coach"
                value={newAthlete.coach}
                onChange={handleInputChange}
                placeholder="Coach"
                className="mb-4"
              />
            </div>
            <div className="flex justify-between">
              <Button onClick={handleCloseModal}>Cancel</Button>
              <Button onClick={handleSubmit}>Add Athlete</Button>
            </div>
          </div>
        </div>
      )}

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {athletes.map((athlete) => (
          <Card key={athlete.id}>
            <CardHeader>
              <CardTitle>{athlete.name}</CardTitle>
            </CardHeader>
            <CardContent>
              <p><strong>Age:</strong> {athlete.age}</p>
              <p><strong>Sport:</strong> {athlete.sport}</p>
              <p><strong>Team:</strong> {athlete.team}</p>
              <p><strong>Coach:</strong> {athlete.coach}</p>
              <p>
                <strong>Status:</strong>
                <span
                  className={`ml-2 px-2 py-1 rounded ${
                    athlete.status === "Active" ? "bg-green-200 text-green-800" : "bg-red-200 text-red-800"
                  }`}
                >
                  {athlete.status}
                </span>
              </p>
              <p><strong>Upcoming Checkup:</strong> {athlete.upcomingCheckupDate || "Not Set"}</p>
              <Input
                type="date"
                value={selectedCheckup}
                onChange={(e) => setSelectedCheckup(e.target.value)}
                className="mt-2"
              />
              <Button
                onClick={() => handleCheckupDateChange(athlete.id, selectedCheckup)}
                className="mt-2"
              >
                Set Checkup Date
              </Button>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
}

export default ViewPlayers;
