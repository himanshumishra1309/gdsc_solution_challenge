import { useState } from "react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";

function Nutrition() {
  const [meals, setMeals] = useState([
    { time: "Breakfast", description: "Oatmeal with berries and nuts" },
    { time: "Lunch", description: "Grilled chicken salad with avocado" },
    { time: "Dinner", description: "Salmon with quinoa and roasted vegetables" },
  ]);

  const [newMeal, setNewMeal] = useState({ time: "", description: "" });

  const addMeal = () => {
    if (newMeal.time && newMeal.description) {
      setMeals([...meals, newMeal]);
      setNewMeal({ time: "", description: "" });
    }
  };

  return (
    <div className="space-y-12 px-6 w-full">
      <h1 className="text-5xl font-bold text-center">Nutrition Plan</h1>
      <div className="grid gap-8 md:grid-cols-2">
        <Card className="w-full">
          <CardHeader>
            <CardTitle className="text-3xl">Daily Meal Plan</CardTitle>
            <CardDescription className="text-xl">Your personalized nutrition guide</CardDescription>
          </CardHeader>
          <CardContent>
            <Table className="text-xl">
              <TableHeader>
                <TableRow>
                  <TableHead className="text-2xl">Time</TableHead>
                  <TableHead className="text-2xl">Meal Description</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {meals.map((meal, index) => (
                  <TableRow key={index}>
                    <TableCell className="text-lg">{meal.time}</TableCell>
                    <TableCell className="text-lg">{meal.description}</TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </CardContent>
        </Card>
        <Card className="w-full">
          <CardHeader>
            <CardTitle className="text-3xl">Add New Meal</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-6">
              <div className="space-y-3">
                <Label htmlFor="meal-time" className="text-2xl">Meal Time</Label>
                <Input
                  id="meal-time"
                  value={newMeal.time}
                  onChange={(e) => setNewMeal({ ...newMeal, time: e.target.value })}
                  placeholder="Enter meal time"
                  className="text-lg p-4"
                />
              </div>
              <div className="space-y-3">
                <Label htmlFor="meal-description" className="text-2xl">Meal Description</Label>
                <Textarea
                  id="meal-description"
                  value={newMeal.description}
                  onChange={(e) => setNewMeal({ ...newMeal, description: e.target.value })}
                  placeholder="Enter meal description"
                  className="text-lg p-4"
                />
              </div>
              <Button onClick={addMeal} className="w-full text-xl py-3">Add Meal</Button>
            </div>
          </CardContent>
        </Card>
      </div>
      <Card className="w-full">
        <CardHeader>
          <CardTitle className="text-3xl">Nutritionist's Notes</CardTitle>
        </CardHeader>
        <CardContent>
          <Textarea
            placeholder="Enter nutritionist's recommendations here..."
            className="min-h-[250px] text-lg p-4"
          />
          <Button className="mt-6 w-full text-xl py-3">Save Notes</Button>
        </CardContent>
      </Card>
    </div>
  );
}

export default Nutrition;
