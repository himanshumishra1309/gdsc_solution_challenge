import { Link, useParams, useLocation } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { LogOut } from "lucide-react"; 
import { useNavigate } from "react-router-dom";

function PlLayout({ userType, navItems, children }) {
  const navigate = useNavigate();
  const location = useLocation();
  const { organizationId, playerName } = useParams(); 

  const handleSignOut = () => {
    localStorage.removeItem("userType");
    navigate("/");
  };

  return (
    <div className="flex h-screen bg-gray-50">
      {/* Sidebar */}
      <div className="flex flex-col w-72 bg-green-500 text-white border-r">
        <div className="flex flex-col items-center p-3 bg-green-600 border-b-2 border-green-700">
          <div className="w-24 h-24 mb-4 bg-white rounded-full overflow-hidden">
            <img
              src="https://www.w3schools.com/howto/img_avatar.png"
              alt="Player"
              className="w-full h-full object-cover"
            />
          </div>
          <h2 className="text-2xl font-semibold text-white">
            {playerName ? playerName : "Player"}
          </h2>
          <p className="text-sm text-gray-200">Athlete</p>
        </div>

        {/* Navigation Items */}
        <nav className="flex-1 p-4">
          {navItems.map((item, index) => {
            const isActive =
              location.pathname.includes(item.path) ||
              (item.path === "graphs" && location.pathname.endsWith(`/player-dashboard/${organizationId}/${playerName}`));

            return (
              <Link key={index} to={`/player-dashboard/${organizationId}/${playerName}/${item.path}`}>
                <Button
                  variant="ghost"
                  className={`w-full justify-start text-lg font-medium text-white hover:bg-green-600 hover:text-gray-100 rounded-lg py-3 transition-colors mb-2 ${
                    isActive ? "bg-green-600 text-gray-100" : ""
                  }`}
                >
                  <item.icon className="mr-1 h-5 w-5 text-gray-200 hover:text-white" />
                  {item.name} 
                </Button>
              </Link>
            );
          })}
        </nav>

        {/* Sign Out Button */}
        <div className="p-4 mt-auto">
          <Button
            variant="ghost"
            className="w-full justify-start text-lg font-medium text-white hover:bg-red-600 hover:text-gray-100 rounded-lg py-3 transition-colors"
            onClick={handleSignOut}
          >
            <LogOut className="mr-3 h-5 w-5 text-gray-200 hover:text-white" />
            Sign Out
          </Button>
        </div>
      </div>

      {/* Main Content */}
      <main className="flex-1 overflow-y-auto p-1 bg-white">
        {children}
      </main>
    </div>
  );
}

export default PlLayout;
