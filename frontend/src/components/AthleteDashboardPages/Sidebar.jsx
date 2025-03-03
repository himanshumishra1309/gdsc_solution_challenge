import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { BarChart,House, Dumbbell, PiggyBank, User, Heart, Apple, House } from "lucide-react";

const navItems = [
  { name: "Performance", icon: BarChart, id: "performance" },
  { name: "Training", icon: Dumbbell, id: "training" },
  { name: "Medical", icon: Heart, id: "medical" },
  { name: "Nutrition", icon: Apple, id: "nutrition" },
  { name: "Finance", icon: PiggyBank, id: "finance" },
  { name: "Profile", icon: User, id: "profile" },
];

function Sidebar({ setActiveSection }) {
  return (
    <div className="flex flex-col w-64 bg-gradient-to-b from-gray-800 to-gray-900 text-gray-100 border-r">
      {/* Avatar and user info section */}
      <div className="flex flex-col items-center p-6 bg-gray-800 border-b-2 border-gray-700">
        <Avatar className="w-24 h-24 mb-4 border-4 border-gray-600">
          <AvatarImage src="/placeholder-avatar.png" alt="Athlete" />
          <AvatarFallback>AT</AvatarFallback>
        </Avatar>
        <h2 className="text-2xl font-semibold text-gray-100">Sanjay Gupta</h2>
        <p className="text-sm text-gray-300">Professional Athlete</p>
      </div>
      
      {/* Navigation section */}
      <nav className="flex-1 p-4">
        <ul className="space-y-4">
          {navItems.map((item) => (
            <li key={item.id}>
              <Button
                variant="ghost"
                className="w-full justify-start text-lg font-medium text-gray-300 hover:bg-gray-700 hover:text-white rounded-lg py-3 transition-colors"
                onClick={() => setActiveSection(item.id)}
              >
                <item.icon className="mr-3 h-5 w-5 text-gray-400 hover:text-white" />
                {item.name}
              </Button>
            </li>
          ))}
        </ul>
      </nav>
    </div>
  );
}

export default Sidebar;
