import { useState } from "react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";

const months = [
  "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"
];

const weeks = ["Week 1", "Week 2", "Week 3", "Week 4"];

const initialMealPlans = {};
months.forEach((month) => {
  initialMealPlans[month] = {};
  weeks.forEach((week) => {
    initialMealPlans[month][week] = [
      { time: "Breakfast", description: "Oatmeal with berries and nuts" },
      { time: "Lunch", description: "Grilled chicken salad with avocado" },
      { time: "Dinner", description: "Salmon with quinoa and roasted vegetables" }
    ];
  });
});

function Nutrition() {
  const [selectedMonth, setSelectedMonth] = useState("January");
  const [selectedWeek, setSelectedWeek] = useState("Week 1");
  const [mealPlans, setMealPlans] = useState(initialMealPlans);
  const [newMeal, setNewMeal] = useState({ time: "", description: "" });

  const addMeal = () => {
    if (newMeal.time && newMeal.description) {
      setMealPlans((prevPlans) => {
        const updatedPlans = { ...prevPlans };
        updatedPlans[selectedMonth][selectedWeek] = [...updatedPlans[selectedMonth][selectedWeek], newMeal];
        return updatedPlans;
      });
      setNewMeal({ time: "", description: "" });
    }
  };

  return (
    <div className="space-y-12 px-6 w-full">
      <h1 className="text-4xl font-bold text-center">Nutrition Plan</h1>
      <Card className="w-full">
        <CardHeader>
          <CardTitle className="text-3xl">Weekly Diet Plan</CardTitle>
          <CardDescription>Select a month and week to view or modify meals</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="flex gap-4 mb-6">
            <select
              className="border p-2 rounded"
              value={selectedMonth}
              onChange={(e) => setSelectedMonth(e.target.value)}
            >
              {months.map((month) => (
                <option key={month} value={month}>{month}</option>
              ))}
            </select>
            <select
              className="border p-2 rounded"
              value={selectedWeek}
              onChange={(e) => setSelectedWeek(e.target.value)}
            >
              {weeks.map((week) => (
                <option key={week} value={week}>{week}</option>
              ))}
            </select>
          </div>
          <Table className="text-xl">
            <TableHeader>
              <TableRow>
                <TableHead className="text-2xl">Time</TableHead>
                <TableHead className="text-2xl">Meal Description</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {mealPlans[selectedMonth][selectedWeek].map((meal, index) => (
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
              <label className="text-2xl">Meal Time</label>
              <Input
                value={newMeal.time}
                onChange={(e) => setNewMeal({ ...newMeal, time: e.target.value })}
                placeholder="Enter meal time"
                className="text-lg p-4"
              />
            </div>
            <div className="space-y-3">
              <label className="text-2xl">Meal Description</label>
              <Textarea
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
