import { Button } from "@/components/ui/button";
import { Home, LogOut } from "lucide-react";
import { Link, useNavigate, useLocation, useParams } from "react-router-dom";

function DashboardLayout({ userType, navItems, children }) {
  const navigate = useNavigate();
  const location = useLocation();
  const { athleteName } = useParams(); 

  const handleSignOut = () => {
    localStorage.removeItem("userType");
    navigate("/");
  };

  return (
    <div className="flex h-screen bg-gray-50">
      
      <div className="flex flex-col w-72 bg-green-500 text-white border-r">
        
        <div className="flex flex-col items-center p-6 bg-green-600 border-b-2 border-green-700">
          <div className="w-24 h-24 mb-4 bg-white rounded-full overflow-hidden">
            <img
              src="https://www.w3schools.com/howto/img_avatar.png"
              alt="Athlete"
              className="w-full h-full object-cover"
            />
          </div>
          <h2 className="text-2xl font-semibold text-white">{athleteName || "Athlete"}</h2>
          <p className="text-sm text-gray-200">{userType}</p>
        </div>

       
        <nav className="flex-1 p-4">
          {navItems.length > 0 ? (
            <ul className="space-y-4">
              {navItems.map((item) => {
                const isActive = location.pathname.includes(item.path);
                return (
                  <li key={item.name}>
                    <Link to={`/athlete-dashboard/${athleteName}/${item.path}`}>
                      <Button
                        variant="ghost"
                        className={`w-full justify-start text-lg font-medium text-white hover:bg-green-600 hover:text-gray-100 rounded-lg py-3 transition-colors ${
                          isActive ? "bg-green-600 text-gray-100" : ""
                        }`}
                      >
                        <item.icon className="mr-3 h-5 w-5 text-gray-200 hover:text-white" />
                        {item.name}
                      </Button>
                    </Link>
                  </li>
                );
              })}
            </ul>
          ) : (
            <Button
              variant="ghost"
              className="w-full justify-start text-lg font-medium text-white hover:bg-green-600 hover:text-gray-100 rounded-lg py-3 transition-colors"
              onClick={() => navigate("/")}
            >
              <Home className="mr-3 h-5 w-5 text-gray-200 hover:text-white" />
              Back to Main Dashboard
            </Button>
          )}
        </nav>

        
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

      
      <main className="flex-1 overflow-y-auto p-8 bg-white">{children}</main>
    </div>
  );
}

export default DashboardLayout;
