import { useState } from "react";
import { FaGooglePlusG, FaFacebookF, FaHome, FaUser } from "react-icons/fa";
import { useNavigate } from "react-router-dom";
import axios from "axios";
import { toast, ToastContainer } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";

export default function SponsorSignUp() {
  const [isActive, setIsActive] = useState(false);
  const navigate = useNavigate();
  
  // States for signup form
  const [signupData, setSignupData] = useState({
    name: "", // company name
    email: "",
    password: "",
    dob: "", // date of establishment
    address: "", // company address
    state: "",
    contactName: "", // person's name
    contactNo: "", // contact number
    sponsorshipStart: "", // sponsorship range start
    sponsorshipEnd: "", // sponsorship range end
  });
  
  // Avatar state
  const [avatar, setAvatar] = useState(null);
  const [avatarPreview, setAvatarPreview] = useState(null);
  
  // States for signin form
  const [signinData, setSigninData] = useState({
    email: "",
    password: ""
  });
  
  // Loading states
  const [isSigningUp, setIsSigningUp] = useState(false);
  const [isSigningIn, setIsSigningIn] = useState(false);

  // Handle file change for avatar
  const handleFileChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      setAvatar(file);
      const reader = new FileReader();
      reader.onloadend = () => {
        setAvatarPreview(reader.result);
      };
      reader.readAsDataURL(file);
    }
  };

  // Handle signup form changes
  const handleSignupChange = (e) => {
    setSignupData({
      ...signupData,
      [e.target.name]: e.target.value
    });
  };

  // Handle signin form changes
  const handleSigninChange = (e) => {
    setSigninData({
      ...signinData,
      [e.target.name]: e.target.value
    });
  };

  // In your handleSignUp function in SponsorSignUp.jsx
const handleSignUp = async (e) => {
  e.preventDefault();
  setIsSigningUp(true);
  
  try {
    // Validate required fields
    if (!signupData.name || !signupData.email || !signupData.password || 
        !signupData.dob || !signupData.address || !signupData.state || 
        !signupData.contactName || !signupData.contactNo) {
      toast.error("Please fill in all required fields");
      setIsSigningUp(false);
      return;
    }
    
    // For debugging - log the data being sent
    console.log("Form data being submitted:", signupData);
    
    // Instead of using FormData which can be tricky with nested objects, 
    // send JSON directly - this is more reliable
    const response = await axios.post(
      "http://localhost:8000/api/v1/sponsors/register",
      {
        name: signupData.name,
        email: signupData.email,
        password: signupData.password,
        dob: signupData.dob,
        address: signupData.address,
        state: signupData.state,
        contactName: signupData.contactName,
        contactNo: signupData.contactNo,
        sponsorshipStart: signupData.sponsorshipStart,
        sponsorshipEnd: signupData.sponsorshipEnd
        // Note: We're sending sponsorshipStart and sponsorshipEnd directly
        // The controller will handle creating the sponsorshipRange object
      },
      {
        withCredentials: true // For cookies
      }
    );
    
    if (response.status === 201) {
      toast.success("Registration successful!");
      
      // Store user data in localStorage
      const userData = response.data.data.user;
      localStorage.setItem("user", JSON.stringify(userData));
      localStorage.setItem("userType", "sponsor");
      
      // Navigate to sponsor dashboard after a short delay
      setTimeout(() => {
        navigate(`/sponsor-dashboard/${userData.name.replace(/\s+/g, "-")}/`);
      }, 1500);
    }
  } catch (error) {
    console.error("Registration error:", error);
    
    // More detailed error handling
    if (error.response) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx
      const errorMsg = error.response.data?.message || "Registration failed. Please try again.";
      toast.error(errorMsg);
      console.log("Error response:", error.response.data);
    } else if (error.request) {
      // The request was made but no response was received
      toast.error("No response from server. Please check your connection.");
    } else {
      // Something happened in setting up the request that triggered an Error
      toast.error("An error occurred while processing your request.");
    }
  } finally {
    setIsSigningUp(false);
  }
};

  // Handle sponsor login
  const handleSignIn = async (e) => {
    e.preventDefault();
    setIsSigningIn(true);
    
    try {
      // Validate required fields
      if (!signinData.email || !signinData.password) {
        toast.error("Email and password are required");
        setIsSigningIn(false);
        return;
      }
      
      // API call to login
      const response = await axios.post(
        "http://localhost:8000/api/v1/sponsors/login",
        {
          email: signinData.email,
          password: signinData.password
        },
        {
          withCredentials: true // For cookies
        }
      );
      
      if (response.status === 200) {
        toast.success("Login successful!");
        
        // Store user data in localStorage
        const userData = response.data.data.user;
        localStorage.setItem("user", JSON.stringify(userData));
        localStorage.setItem("userType", "sponsor");
        
        // Navigate to sponsor dashboard after a short delay
        setTimeout(() => {
          navigate(`/sponsor-dashboard/${userData.name.replace(/\s+/g, "-")}/`);
        }, 1500);
      }
    } catch (error) {
      console.error("Login error:", error);
      const errorMsg = error.response?.data?.message || "Login failed. Please check your credentials.";
      toast.error(errorMsg);
    } finally {
      setIsSigningIn(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-r from-green-200 via-teal-200 to-blue-200">
      <ToastContainer position="top-right" autoClose={3000} />

      {/* Home Button */}
      <div className="absolute top-4 left-4 cursor-pointer" onClick={() => navigate("/")}>
        <FaHome className="w-8 h-8 text-gray-700 hover:text-green-700 transition" />
      </div>

      <div className={`relative w-[700px] max-w-full min-h-[600px] bg-white rounded-3xl shadow-2xl overflow-hidden transition-all duration-1000 ${isActive ? "active" : ""}`}>

        {/* Form Container */}
        <div className="absolute top-0 left-0 w-full h-full flex items-center justify-center">

          {/* Sign In Form */}
          <form 
            onSubmit={handleSignIn} 
            className={`w-1/2 h-full flex flex-col items-center justify-center px-10 transition-all duration-1000 ${isActive ? "opacity-0 pointer-events-none" : "opacity-100"}`}
          >
            <h1 className="text-3xl font-bold text-gray-800 mb-4">Sponsor Sign In</h1>
            <div className="flex gap-4 my-4">
              <FaGooglePlusG className="w-10 h-10 border p-2 rounded-full text-gray-700 cursor-pointer hover:bg-gray-100 transition" />
              <FaFacebookF className="w-10 h-10 border p-2 rounded-full text-gray-700 cursor-pointer hover:bg-gray-100 transition" />
            </div>
            <span className="text-sm text-gray-600 mb-6">or use your registered email</span>
            
            <input 
              type="email" 
              name="email"
              placeholder="Email" 
              value={signinData.email}
              onChange={handleSigninChange}
              className="mt-4 p-2 w-full bg-gray-100 border border-gray-300 rounded-md outline-none focus:ring-2 focus:ring-green-500" 
              required 
            />
            
            <input 
              type="password" 
              name="password"
              placeholder="Password" 
              value={signinData.password}
              onChange={handleSigninChange}
              className="mt-3 p-2 w-full bg-gray-100 border border-gray-300 rounded-md outline-none focus:ring-2 focus:ring-green-500" 
              required 
            />
            
            <a href="#" className="text-sm text-green-700 hover:underline mt-3 self-end">Forgot your password?</a>
            
            <button 
              type="submit" 
              disabled={isSigningIn}
              className={`mt-8 px-8 py-2 ${isSigningIn ? 'bg-gray-500' : 'bg-green-700 hover:bg-green-800'} text-white rounded-md transition-colors flex items-center justify-center w-full`}
            >
              {isSigningIn ? (
                <>
                  <svg className="animate-spin -ml-1 mr-2 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                  </svg>
                  Signing In...
                </>
              ) : 'Sign In'}
            </button>
          </form>

          {/* Sign Up Form - with improved layout */}
          <form 
            onSubmit={handleSignUp}
            className={`w-1/2 h-full flex flex-col justify-start items-center px-10 transition-all duration-1000 overflow-y-auto py-8 ${isActive ? "opacity-100" : "opacity-0 pointer-events-none"}`}
          >
            <h1 className="text-2xl font-bold text-gray-800 mt-2">Sponsor Sign Up</h1>
            
            {/* Avatar Upload */}
            <div className="w-full flex flex-col items-center mb-4 mt-4">
              <div className="w-20 h-20 rounded-full bg-gray-200 overflow-hidden mb-2 border-2 border-green-500">
                {avatarPreview ? (
                  <img src={avatarPreview} alt="Avatar Preview" className="w-full h-full object-cover" />
                ) : (
                  <div className="w-full h-full flex items-center justify-center bg-gray-200">
                    <FaUser className="text-gray-400 w-10 h-10" />
                  </div>
                )}
              </div>
              <label className="cursor-pointer text-sm text-green-700 hover:underline flex items-center">
                <span>{avatar ? "Change Photo" : "Upload Profile Photo"}</span>
                <input
                  type="file"
                  accept="image/*"
                  onChange={handleFileChange}
                  className="hidden"
                />
              </label>
            </div>

            {/* Company/Organization information */}
            <div className="bg-green-50 w-full mt-2 p-3 rounded-md">
              <h2 className="text-sm font-bold text-green-800 border-b border-green-200 pb-1 mb-2">Company Information</h2>
              
              <div className="space-y-3">
                <div>
                  <label className="block text-xs text-gray-600 mb-1">Company Name*</label>
                  <input 
                    type="text" 
                    name="name"
                    value={signupData.name}
                    onChange={handleSignupChange}
                    className="p-2 w-full bg-white border border-gray-300 rounded-md outline-none focus:ring-2 focus:ring-green-500" 
                    required 
                  />
                </div>
                
                <div>
                  <label className="block text-xs text-gray-600 mb-1">Company Address*</label>
                  <input 
                    type="text" 
                    name="address"
                    value={signupData.address}
                    onChange={handleSignupChange}
                    className="p-2 w-full bg-white border border-gray-300 rounded-md outline-none focus:ring-2 focus:ring-green-500" 
                    required 
                  />
                </div>
                
                <div>
                  <label className="block text-xs text-gray-600 mb-1">State/UT*</label>
                  <input 
                    type="text" 
                    name="state"
                    value={signupData.state}
                    onChange={handleSignupChange}
                    className="p-2 w-full bg-white border border-gray-300 rounded-md outline-none focus:ring-2 focus:ring-green-500" 
                    required 
                  />
                </div>
              </div>
            </div>

            {/* Contact Person information */}
            <div className="bg-green-50 w-full mt-4 p-3 rounded-md">
              <h2 className="text-sm font-bold text-green-800 border-b border-green-200 pb-1 mb-2">Contact Person Information</h2>
              
              <div className="space-y-3">
                <div>
                  <label className="block text-xs text-gray-600 mb-1">Contact Person's Name*</label>
                  <input 
                    type="text" 
                    name="contactName"
                    value={signupData.contactName}
                    onChange={handleSignupChange}
                    className="p-2 w-full bg-white border border-gray-300 rounded-md outline-none focus:ring-2 focus:ring-green-500" 
                    required 
                  />
                </div>
                
                <div>
                  <label className="block text-xs text-gray-600 mb-1">Email Address*</label>
                  <input 
                    type="email" 
                    name="email"
                    value={signupData.email}
                    onChange={handleSignupChange}
                    className="p-2 w-full bg-white border border-gray-300 rounded-md outline-none focus:ring-2 focus:ring-green-500" 
                    required 
                  />
                </div>

                <div>
                  <label className="block text-xs text-gray-600 mb-1">Date of Birth*</label>
                  <input 
                    type="date" 
                    name="dob"
                    value={signupData.dob}
                    onChange={handleSignupChange}
                    className="p-2 w-full bg-white border border-gray-300 rounded-md outline-none focus:ring-2 focus:ring-green-500" 
                    required 
                  />
                </div>
                
                <div>
                  <label className="block text-xs text-gray-600 mb-1">Contact Number*</label>
                  <input 
                    type="tel" 
                    name="contactNo"
                    value={signupData.contactNo}
                    onChange={handleSignupChange}
                    className="p-2 w-full bg-white border border-gray-300 rounded-md outline-none focus:ring-2 focus:ring-green-500" 
                    required 
                  />
                </div>
                
                <div>
                  <label className="block text-xs text-gray-600 mb-1">Password*</label>
                  <input 
                    type="password" 
                    name="password"
                    value={signupData.password}
                    onChange={handleSignupChange}
                    className="p-2 w-full bg-white border border-gray-300 rounded-md outline-none focus:ring-2 focus:ring-green-500" 
                    required 
                  />
                </div>
              </div>
            </div>

            {/* Sponsorship Range */}
            <div className="bg-green-50 w-full mt-4 p-3 rounded-md">
              <h2 className="text-sm font-bold text-green-800 border-b border-green-200 pb-1 mb-2">Sponsorship Budget Range (₹)</h2>
              
              <div className="flex gap-4 w-full">
                <div className="w-1/2">
                  <label className="block text-xs text-gray-600 mb-1">Minimum Amount</label>
                  <input 
                    type="number" 
                    name="sponsorshipStart"
                    placeholder="Min Amount" 
                    value={signupData.sponsorshipStart}
                    onChange={handleSignupChange}
                    className="p-2 w-full bg-white border border-gray-300 rounded-md outline-none focus:ring-2 focus:ring-green-500" 
                  />
                </div>
                
                <div className="w-1/2">
                  <label className="block text-xs text-gray-600 mb-1">Maximum Amount</label>
                  <input 
                    type="number" 
                    name="sponsorshipEnd"
                    placeholder="Max Amount" 
                    value={signupData.sponsorshipEnd}
                    onChange={handleSignupChange}
                    className="p-2 w-full bg-white border border-gray-300 rounded-md outline-none focus:ring-2 focus:ring-green-500" 
                  />
                </div>
              </div>
            </div>

            <p className="text-xs text-gray-500 mt-4">Fields marked with * are required</p>

            <button 
              type="submit"
              disabled={isSigningUp}
              className={`mt-6 px-8 py-2 ${isSigningUp ? 'bg-gray-500' : 'bg-green-700 hover:bg-green-800'} text-white rounded-md transition-colors flex items-center justify-center w-full`}
            >
              {isSigningUp ? (
                <>
                  <svg className="animate-spin -ml-1 mr-2 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                  </svg>
                  Signing Up...
                </>
              ) : 'Sign Up'}
            </button>
          </form>

        </div>

        {/* Overlay Panel */}
        <div className={`absolute top-0 left-1/2 w-1/2 h-full flex items-center justify-center bg-green-700 text-white transition-all duration-1000 ${isActive ? "-translate-x-full rounded-tr-3xl rounded-br-3xl" : "rounded-tl-3xl rounded-bl-3xl"}`}>
          <div className="text-center px-8">
            <h1 className="text-3xl font-bold">{isActive ? "Welcome Back!" : "Hello Sponsor!"}</h1>
            <p className="mt-6 text-base">
              {isActive 
                ? "To keep connected with us, please login with your personal details." 
                : "Register as a sponsor to connect with talented athletes and support their growth journey."}
            </p>
            <button 
              type="button"
              onClick={() => setIsActive(!isActive)} 
              className="mt-10 px-8 py-2.5 bg-transparent border-2 border-white rounded-lg hover:bg-white hover:text-green-700 transition-colors text-base font-medium"
            >
              {isActive ? "Sign In" : "Sign Up"}
            </button>
          </div>
        </div>

      </div>
    </div>
  );
}