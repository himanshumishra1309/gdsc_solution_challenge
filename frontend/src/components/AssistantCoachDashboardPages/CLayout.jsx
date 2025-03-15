import { Button } from "@/components/ui/button";
import { LogOut } from "lucide-react"; 
import { Link, useNavigate, useLocation, useParams } from "react-router-dom";

function CLayout({ userType, navItems, children }) {
  const navigate = useNavigate();
  const location = useLocation();
  const { organizationId, coachName } = useParams(); // Capture organizationId and coachName from the URL

  const handleSignOut = () => {
    localStorage.removeItem("userType");
    navigate("/");
  };

  return (
    <div className="flex h-screen bg-gray-50">
      <div className="flex flex-col w-72 bg-violet-400 text-white border-r">
        <div className="flex flex-col items-center p-3 bg-violet-500 border-b-2 border-darkblue-700">
          <div className="w-24 h-24 mb-4 bg-white rounded-full overflow-hidden">
            <img
              src="https://www.w3schools.com/howto/img_avatar.png"
              alt="Coach"
              className="w-full h-full object-cover"
            />
          </div>
          {/* Use coachName from URL */}
          <h2 className="text-2xl font-semibold text-white">{coachName}</h2>
          <p className="text-sm text-gray-200">Assistant Coach</p>
        </div>

        <nav className="flex-1 p-4">
          {navItems.map((item, index) => {
            const isActive = location.pathname.includes(item.path);

            return (
              <Link key={index} to={`/assistantcoach-dashboard/${organizationId}/${coachName}/${item.path}`}>
                <Button
                  variant="ghost"
                  className={`w-full justify-start text-lg font-medium text-white hover:bg-green-600 hover:text-gray-100 rounded-lg py-3 transition-colors mb-2 ${isActive ? "bg-green-600 text-gray-100" : ""}`}
                >
                  <item.icon className="mr-3 h-5 w-5 text-gray-200 hover:text-white" />
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
          >
            <LogOut className="mr-3 h-5 w-5 text-gray-200 hover:text-white" />
            Sign Out
          </Button>
        </div>
      </div>

      <main className="flex-1 overflow-y-auto p-8 bg-white">
        {children}
      </main>
    </div>
  );
};

export default CLayout;
