import { useState } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Button } from "@/components/ui/button"

const mockAthletes = [
  { id: 1, name: "Arjun Kumar", age: 28, sport: "Football", team: "Team A", status: "Active", gymTrainer: "Ravi Sharma", upcomingCheckupDate: "2025-05-10" },
  { id: 2, name: "Priya Gupta", age: 24, sport: "Basketball", team: "Team B", status: "Injured", gymTrainer: "Sunil Verma", upcomingCheckupDate: "2025-04-15" },
  { id: 3, name: "Vikram Reddy", age: 30, sport: "Tennis", team: "Team C", status: "Active", gymTrainer: "Rajesh Patil", upcomingCheckupDate: "2025-06-20" },
  { id: 4, name: "Neha Desai", age: 26, sport: "Swimming", team: "Team A", status: "Active", gymTrainer: "Amay Singh", upcomingCheckupDate: "2025-07-02" },
  { id: 5, name: "Saurabh Mehta", age: 27, sport: "Cricket", team: "Team D", status: "Active", gymTrainer: "Amay Singh", upcomingCheckupDate: "2025-08-05" },
  { id: 6, name: "Aarti Shah", age: 23, sport: "Badminton", team: "Team E", status: "Injured", gymTrainer: "Meena Yadav", upcomingCheckupDate: "2025-09-12" },
]

function View() {
  const [searchTerm, setSearchTerm] = useState("")
  const [athletes, setAthletes] = useState(mockAthletes)
  const [gymTrainer, setGymTrainer] = useState("Amay Singh") 

  const handleSearch = (event) => {
    setSearchTerm(event.target.value)
    const filteredAthletes = mockAthletes.filter(
      (athlete) =>
        athlete.name.toLowerCase().includes(event.target.value.toLowerCase()) ||
        athlete.sport.toLowerCase().includes(event.target.value.toLowerCase()),
    )
    setAthletes(filteredAthletes)
  }

  // Filter athletes assigned to Gym Trainer Amay Singh
  const filteredAthletesByGymTrainer = athletes.filter(athlete => athlete.gymTrainer === gymTrainer)

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
        <Button>Add New Athlete</Button>
      </div>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        
        {athletes.map((athlete) => (
          <Card key={athlete.id}>
            <CardHeader>
              <CardTitle>{athlete.name}</CardTitle>
            </CardHeader>
            <CardContent>
              <p>
                <strong>Age:</strong> {athlete.age}
              </p>
              <p>
                <strong>Sport:</strong> {athlete.sport}
              </p>
              <p>
                <strong>Team:</strong> {athlete.team}
              </p>
              <p>
                <strong>Gym Trainer:</strong> {athlete.gymTrainer}
              </p>
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
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  )
}

export default View
