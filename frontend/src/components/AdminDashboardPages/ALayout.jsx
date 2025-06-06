import { Link, useNavigate, useLocation } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { LogOut } from "lucide-react";
import axios from "axios";
import { useState } from "react";

function ALayout({ userType, navItems = [], organizationId, children }) {
  const navigate = useNavigate();
  const location = useLocation();
  const [loggingOut, setLoggingOut] = useState(false);

  const handleSignOut = async () => {
    try {
      setLoggingOut(true);

      const response = await axios.post(
        "http://localhost:8000/api/v1/admins/logout",
        {},
        {
          withCredentials: true,
          headers: {
            "Content-Type": "application/json",
          },
        }
      );

      console.log("Logout successful:", response.data);

      localStorage.removeItem("userType");
      localStorage.removeItem("userData");
      localStorage.removeItem("userRole");
      localStorage.removeItem("token");

      navigate("/");
    } catch (error) {
      console.error("Logout failed:", error);
      localStorage.clear();
      navigate("/");
    } finally {
      setLoggingOut(false);
    }
  };

  const normalizePath = (path) =>
    path.replace(/\/+$/, "").toLowerCase(); 

  return (
    <div className="flex h-screen bg-gray-50">
      {/* Sidebar */}
      <div className="flex flex-col w-70 bg-rose-800 text-white border-r">
        {/* Profile Section */}
        <div className="flex flex-col items-center p-3 bg-rose-900 border-b">
          <div className="w-24 h-24 mb-4 bg-white rounded-full overflow-hidden">
            <img
              src="https://www.w3schools.com/howto/img_avatar.png"
              alt="Admin"
              className="w-full h-full object-cover"
            />
          </div>
          <h2 className="text-2xl font-semibold text-white">{userType}</h2>
          <p className="text-sm text-gray-300">Dashboard</p>
        </div>

        {/* Navigation Items */}
        <nav className="flex-1 p-4 space-y-2">
          {navItems.map((item, index) => {
            const fullPath = `/${userType.toLowerCase()}-dashboard/${organizationId}/${item.path}`;
            const currentPath = normalizePath(location.pathname);
            const targetPath = normalizePath(fullPath);

            const isActive =
              currentPath === targetPath ||
              currentPath.startsWith(targetPath + "/");

            return (
              <Link key={index} to={fullPath}>
                <Button
                  variant="ghost"
                  className={`w-full flex items-center justify-start text-lg font-medium rounded-lg py-3 transition-colors 
                  ${
                    isActive
                      ? "bg-green-600 text-white"
                      : "text-gray-200 hover:bg-green-700 hover:text-white"
                  }`}
                >
                  <item.icon className="mr-3 h-5 w-5 text-white" />
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
            className="w-full flex items-center justify-start text-lg font-medium rounded-lg py-3 transition-colors hover:bg-red-600"
            onClick={handleSignOut}
            disabled={loggingOut}
          >
            <LogOut className="mr-3 h-5 w-5 text-white" />
            {loggingOut ? "Signing Out..." : "Sign Out"}
          </Button>
        </div>
      </div>

      {/* Main Content */}
      <main className="flex-1 overflow-y-auto p-1 bg-white">{children}</main>
    </div>
  );
}

export default ALayout;
