import { useState } from "react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";

function Diet() {
  const [athletes, setAthletes] = useState([
    { id: 1, name: "Ravi Kumar", assignedPlan: "" },
    { id: 2, name: "Pooja Sharma", assignedPlan: "" },
  ]);

  const [meals1, setMeals1] = useState([ // Meal Plan 1
    { time: "Breakfast", description: "Oatmeal with berries and nuts" },
    { time: "Lunch", description: "Grilled chicken salad with avocado" },
    { time: "Dinner", description: "Salmon with quinoa and roasted vegetables" },
  ]);

  const [meals2, setMeals2] = useState([ // Meal Plan 2
    { time: "Breakfast", description: "Greek yogurt with granola and honey" },
    { time: "Lunch", description: "Tuna salad with olive oil dressing" },
    { time: "Dinner", description: "Grilled steak with steamed broccoli" },
  ]);

  const [newMeal, setNewMeal] = useState({ time: "", description: "" });
  const [selectedAthlete, setSelectedAthlete] = useState(null);
  const [weeklyMealPlans, setWeeklyMealPlans] = useState({});

  const addMeal = () => {
    if (newMeal.time && newMeal.description) {
      setMeals1([...meals1, newMeal]);
      setMeals2([...meals2, newMeal]);
      setNewMeal({ time: "", description: "" });
    }
  };

  const assignMealPlanToAthlete = (athleteId, planNumber) => {
    const plan = planNumber === 1 ? meals1 : meals2;
    setWeeklyMealPlans({
      ...weeklyMealPlans,
      [athleteId]: plan, 
    });
  };

  const handleNutritionistNotes = (athleteId, notes) => {
    console.log(`Saving notes for athlete ${athleteId}: ${notes}`);
  };

  return (
    <div className="space-y-4 px-4 w-full">
      <h1 className="text-2xl font-semibold text-center">Diet Plans</h1>

      <div className="grid gap-6 md:grid-cols-1">
        <Card className="w-full">
          <CardHeader>
            <CardTitle className="text-2xl">Athletes</CardTitle>
            <CardDescription className="text-base">Manage athletes and assign nutrition plans</CardDescription>
          </CardHeader>
          <CardContent>
            <Table className="text-sm">
              <TableHeader>
                <TableRow>
                  <TableHead className="text-lg">Athlete Name</TableHead>
                  <TableHead className="text-lg">Assigned Plan</TableHead>
                  <TableHead className="text-lg">Assign Plan</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {athletes.map((athlete) => (
                  <TableRow key={athlete.id}>
                    <TableCell className="text-sm">{athlete.name}</TableCell>
                    <TableCell className="text-sm">{athlete.assignedPlan || "No plan assigned"}</TableCell>
                    <TableCell className="text-sm">
                      <Button
                        onClick={() => {
                          setSelectedAthlete(athlete);
                          assignMealPlanToAthlete(athlete.id, athlete.id === 1 ? 1 : 2);
                        }}
                        className="w-full text-sm py-2"
                      >
                        Assign Plan
                      </Button>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </CardContent>
        </Card>
      </div>

      {selectedAthlete && (
        <div className="grid gap-6 md:grid-cols-1">
          <Card className="w-full">
            <CardHeader>
              <CardTitle className="text-2xl">Weekly Meal Plan for {selectedAthlete.name}</CardTitle>
              <CardDescription className="text-base">Assign meals to the athlete for the week</CardDescription>
            </CardHeader>
            <CardContent>
              <Table className="text-sm">
                <TableHeader>
                  <TableRow>
                    <TableHead className="text-lg">Time</TableHead>
                    <TableHead className="text-lg">Meal Description</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {weeklyMealPlans[selectedAthlete.id]?.map((meal, index) => (
                    <TableRow key={index}>
                      <TableCell className="text-sm">{meal.time}</TableCell>
                      <TableCell className="text-sm">{meal.description}</TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </CardContent>
          </Card>
        </div>
      )}

      <div className="grid gap-6 md:grid-cols-1">
        <Card className="w-full">
          <CardHeader>
            <CardTitle className="text-2xl">Add New Meal</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="meal-time" className="text-lg">Meal Time</Label>
                <Input
                  id="meal-time"
                  value={newMeal.time}
                  onChange={(e) => setNewMeal({ ...newMeal, time: e.target.value })}
                  placeholder="Enter meal time"
                  className="text-sm p-3"
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="meal-description" className="text-lg">Meal Description</Label>
                <Textarea
                  id="meal-description"
                  value={newMeal.description}
                  onChange={(e) => setNewMeal({ ...newMeal, description: e.target.value })}
                  placeholder="Enter meal description"
                  className="text-sm p-3"
                />
              </div>
              <Button onClick={addMeal} className="w-full text-sm py-2">Add Meal</Button>
            </div>
          </CardContent>
        </Card>
      </div>

      <Card className="w-full">
        <CardHeader>
          <CardTitle className="text-2xl">Nutritionist's Notes</CardTitle>
        </CardHeader>
        <CardContent>
          <Textarea
            placeholder="Enter nutritionist's recommendations here..."
            className="min-h-[150px] text-sm p-3"
          />
          <Button className="mt-4 w-full text-sm py-2">Save Notes</Button>
        </CardContent>
      </Card>
    </div>
  );
}

export default Diet;
