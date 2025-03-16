import { Button } from "@/components/ui/button";
import { Home, LogOut } from "lucide-react";
import { Link, useNavigate, useLocation, useParams } from "react-router-dom";
import axios from "axios";
import { useState } from "react";
import { toast, ToastContainer } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";

function DashboardLayout({ userType, navItems, children }) {
  const navigate = useNavigate();
  const location = useLocation();
  const { athleteName } = useParams();
  const [isLoggingOut, setIsLoggingOut] = useState(false);

  const handleSignOut = async () => {
    setIsLoggingOut(true);
    
    try {
      // Call the backend logout endpoint
      const response = await axios.post(
        "http://localhost:8000/api/v1/independent-athletes/logout",
        {},
        {
          withCredentials: true, // Important for sending cookies
        }
      );

      if (response.status === 200) {
        // Clear local storage
        localStorage.removeItem("user");
        localStorage.removeItem("userType");
        
        // Show success message
        toast.success("Logged out successfully");
        
        // Redirect after a short delay to show toast
        setTimeout(() => {
          navigate("/");
        }, 0);
      } else {
        // Handle unexpected success response
        toast.warning("Logged out with unexpected response");
        localStorage.removeItem("user");
        localStorage.removeItem("userType");
        setTimeout(() => {
          navigate("/");
        }, 1500);
      }
    } catch (error) {
      console.error("Logout error:", error);
      
      // Even if API call fails, clear local storage and redirect
      toast.error("Logout failed on server, but you've been logged out locally");
      localStorage.removeItem("user");
      localStorage.removeItem("userType");
      
      setTimeout(() => {
        navigate("/");
      }, 1500);
    } finally {
      setIsLoggingOut(false);
    }
  };

  return (
    <div className="flex h-screen bg-gray-50">
      <ToastContainer position="top-right" autoClose={1500} />
      
      <div className="flex flex-col w-72 bg-green-500 text-white border-r">
        
        <div className="flex flex-col items-center p-3 bg-green-600 border-b-2 border-green-700">
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
              // Check if this nav item is active
              const isActive = location.pathname === item.path;
              
              return (
                <li key={item.name}>
                  <Link
                    to={item.path}
                    className={`flex items-center px-4 py-2 rounded-md transition-colors ${
                      isActive 
                        ? "bg-blue-100 text-blue-700" 
                        : "hover:bg-gray-100"
                    }`}
                  >
                    <item.icon className="h-5 w-5 mr-3" />
                    {item.name}
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
            disabled={isLoggingOut}
          >
            {isLoggingOut ? (
              <>
                <svg className="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                  <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                  <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
                Signing Out...
              </>
            ) : (
              <>
                <LogOut className="mr-3 h-5 w-5 text-gray-200 hover:text-white" />
                Sign Out
              </>
            )}
          </Button>
        </div>
      </div>

      
      <main className="flex-1 overflow-y-auto p-8 bg-white">{children}</main>
    </div>
  );
}

export default DashboardLayout;