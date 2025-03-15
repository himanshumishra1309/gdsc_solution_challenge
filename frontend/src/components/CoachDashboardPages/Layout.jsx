import { Link, useParams } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { LogOut } from "lucide-react"; 
import { useNavigate, useLocation } from "react-router-dom";
import { useState } from "react";
import axios from "axios";

function Layout({ userType, navItems, children }) {
  const navigate = useNavigate();
  const location = useLocation();
  const { organizationId, coachName } = useParams(); // Get coach name and org ID from URL
  const [loggingOut, setLoggingOut] = useState(false);

  const handleSignOut = async () => {
    try {
      setLoggingOut(true);
      
      // Call the backend logout API
      const response = await axios.post(
        "http://localhost:8000/api/v1/coaches/logout",{},
        {
          withCredentials: true // Important to include cookies
        }
      );
      
      console.log("Logout successful:", response.data);
      
      // Clear all localStorage items
      localStorage.removeItem("userType");
      localStorage.removeItem("userData");
      localStorage.removeItem("userRole");
      localStorage.removeItem("token");
      
      // Navigate to landing page
      navigate("/");
    } catch (error) {
      console.error("Logout failed:", error);
      
      // If API call fails, still clear local storage and redirect
      localStorage.clear();
      navigate("/");
    } finally {
      setLoggingOut(false);
    }
  };

  return (
    <div className="flex h-screen bg-gray-50">
      <div className="flex flex-col w-72 bg-blue-500 text-white border-r">
        <div className="flex flex-col items-center p-3 bg-blue-600 border-b-2 border-blue-700">
          <div className="w-24 h-24 mb-4 bg-white rounded-full overflow-hidden">
            <img
              src="https://www.w3schools.com/howto/img_avatar.png"
              alt="Coach"
              className="w-full h-full object-cover"
            />
          </div>
          <h2 className="text-2xl font-semibold text-white">
            {coachName ? coachName.replace(/-/g, ' ') : "Coach"}
          </h2>
          <p className="text-sm text-gray-200">Coach</p>
        </div>

        <nav className="flex-1 p-4">
          {navItems.map((item, index) => {
            const isActive = 
              location.pathname.endsWith(item.path) || 
              (location.pathname === '/' && item.path === 'teammanagement'); // Highlight team when on '/'

            return (
              <Link 
                key={index} 
                to={`/coach-dashboard/${organizationId}/${coachName}/${item.path}`}
              >
                <Button
                  variant="ghost"
                  className={`w-full justify-start text-lg font-medium text-white hover:bg-green-600 hover:text-gray-100 rounded-lg py-3 transition-colors mb-2 ${isActive ? "bg-green-600 text-gray-100" : ""}`}
                >
                  <item.icon className="mr-1 h-5 w-5 text-gray-200 hover:text-white" />
                  {item.label}
                </Button>
              </Link>
            );
          })}
        </nav>

        <div className="p-4 mt-auto">
          <Button
            variant="ghost"
            className="w-full justify-start text-lg font-medium text-white hover:bg-red-600 hover:text-gray-100 rounded-lg py-3 transition-colors"
            onClick={handleSignOut}
            disabled={loggingOut}
          >
            <LogOut className="mr-3 h-5 w-5 text-gray-200 hover:text-white" />
            {loggingOut ? "Signing Out..." : "Sign Out"}
          </Button>
        </div>
      </div>

      <main className="flex-1 overflow-y-auto p-1 bg-white">
        {children}
      </main>
    </div>
  );
};

export default Layout;