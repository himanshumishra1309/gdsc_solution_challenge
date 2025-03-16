import { useState } from "react";
import { FaGooglePlusG, FaFacebookF, FaHome } from "react-icons/fa";
import { useNavigate } from "react-router-dom";
import axios from "axios";
import { toast, ToastContainer } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";

export default function AthleteSignUp() {
  const [isActive, setIsActive] = useState(false);
  const navigate = useNavigate();
  
  // Sign up form state
  const [signUpData, setSignUpData] = useState({
    name: "",
    email: "",
    password: "",
    dob: "",
    sex: "",
    sport: "",
    totalExperience: "",
    highestLevelPlayed: "",
    address: "",
  });

  // Sign in form state
  const [signInData, setSignInData] = useState({
    email: "",
    password: ""
  });

  // Loading states
  const [isSigningUp, setIsSigningUp] = useState(false);
  const [isSigningIn, setIsSigningIn] = useState(false);
  
  // File upload state
  const [avatar, setAvatar] = useState(null);
  const [avatarPreview, setAvatarPreview] = useState(null);

  // Constants for form options
  const competitionLevels = ["District", "State", "National"];
  const genderOptions = ["Male", "Female", "Other"];
  const sportOptions = ["Cricket", "Basketball", "Football"];
  const experienceOptions = ["Less than 1 year", "1-3 years", "3-5 years", "5-10 years", "10+ years"];

  // Handle sign up form changes
  const handleSignUpChange = (e) => {
    const { name, value } = e.target;
    setSignUpData({
      ...signUpData,
      [name]: value
    });
  };

  // Handle sign in form changes
  const handleSignInChange = (e) => {
    const { name, value } = e.target;
    setSignInData({
      ...signInData,
      [name]: value
    });
  };

  // Handle file upload
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

  // Handle sign up submission
  const handleSignUp = async (e) => {
    e.preventDefault();
    setIsSigningUp(true);
    
    try {
      // Form validation
      if (!signUpData.name || !signUpData.email || !signUpData.password || !signUpData.dob) {
        toast.error("Name, email, password, and date of birth are required");
        setIsSigningUp(false);
        return;
      }
      
      // Create FormData object for multipart/form-data
      const formData = new FormData();
      formData.append("name", signUpData.name);
      formData.append("email", signUpData.email);
      formData.append("password", signUpData.password);
      formData.append("dob", signUpData.dob);
      
      // Only append optional fields if they have value
      if (signUpData.sex) formData.append("sex", signUpData.sex);
      if (signUpData.sport) formData.append("sport", signUpData.sport);
      if (signUpData.totalExperience) formData.append("totalExperience", signUpData.totalExperience);
      if (signUpData.highestLevelPlayed) formData.append("highestLevelPlayed", signUpData.highestLevelPlayed);
      
      // Append avatar if it exists
      if (avatar) {
        formData.append("avatar", avatar);
      }

      // API call to register
      const response = await axios.post(
        "http://localhost:8000/api/v1/independent-athletes/register", 
        formData,
        {
          headers: {
            "Content-Type": "multipart/form-data",
          },
          withCredentials: true, // Important for cookies
        }
      );

      if (response.data.success || response.status === 201) {
        toast.success("Registration successful!");
        
        // Store user data in localStorage (excluding sensitive information)
        const userData = response.data.data.user;
        localStorage.setItem("user", JSON.stringify(userData));
        localStorage.setItem("userType", "independentAthlete");
        const athleteId = userData._id;
        const athleteName = userData.name.replace(/\s+/g, "-");
        
        // Navigate to dashboard with a delay to show success message
        setTimeout(() => {
          navigate(`/athlete-dashboard/${athleteId}/${athleteName}/home`);
        }, 1500);
      }
    } catch (error) {
      console.error("Registration error:", error);
      const errorMessage = error.response?.data?.message || "Registration failed. Please try again.";
      toast.error(errorMessage);
    } finally {
      setIsSigningUp(false);
    }
  };

  // Handle sign in submission
  const handleSignIn = async (e) => {
    e.preventDefault();
    setIsSigningIn(true);
    
    try {
      // Validate form
      if (!signInData.email || !signInData.password) {
        toast.error("Email and password are required");
        setIsSigningIn(false);
        return;
      }
      
      // API call to login
      const response = await axios.post(
        "http://localhost:8000/api/v1/independent-athletes/login",
        signInData,
        {
          headers: {
            "Content-Type": "application/json",
          },
          withCredentials: true, // Important for cookies
        }
      );

      // In your handleSignIn function
      if (response.data.success || response.status === 200) {
        toast.success("Login successful!");
        
        // Store user data in localStorage
        const userData = response.data.data.user;
        localStorage.setItem("user", JSON.stringify(userData));
        localStorage.setItem("userType", "independentAthlete");
        const athleteId = userData._id;
        const athleteName = userData.name.replace(/\s+/g, "-");
        
        // Navigate to dashboard with a delay to show success message
        setTimeout(() => {
          navigate(`/athlete-dashboard/${athleteId}/${athleteName}/home`);
        }, 0);
      }
    } catch (error) {
      console.error("Login error:", error);
      const errorMessage = error.response?.data?.message || "Login failed. Please check your credentials.";
      toast.error(errorMessage);
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

      <div className={`relative w-[700px] max-w-full min-h-[620px] bg-white rounded-3xl shadow-2xl overflow-hidden transition-all duration-1000 ${isActive ? "active" : ""}`}>

        {/* Form Container */}
        <div className="absolute top-0 left-0 w-full h-full flex">

          {/* Sign In Form */}
          <form 
            onSubmit={handleSignIn} 
            className={`w-1/2 h-full flex flex-col items-center justify-center px-6 transition-all duration-700 z-10 ${isActive ? "translate-x-full opacity-0" : ""}`}
          >
            <h1 className="text-2xl font-semibold text-gray-800">Athlete Sign In</h1>
            
            <input 
              type="email" 
              name="email"
              placeholder="Email" 
              value={signInData.email}
              onChange={handleSignInChange}
              className="mt-3 p-2 w-full bg-gray-200 rounded-md outline-none focus:ring-2 focus:ring-green-500" 
              required 
            />
            
            <input 
              type="password" 
              name="password"
              placeholder="Password" 
              value={signInData.password}
              onChange={handleSignInChange}
              className="mt-2 p-2 w-full bg-gray-200 rounded-md outline-none focus:ring-2 focus:ring-green-500" 
              required 
            />
            
            <a href="#" className="text-xs text-gray-600 mt-3">Forgot your password?</a>

            <button 
              type="submit" 
              disabled={isSigningIn}
              className={`mt-4 px-6 py-2 ${isSigningIn ? 'bg-gray-500' : 'bg-green-700 hover:bg-green-800'} text-white rounded-md transition text-sm flex items-center`}
            >
              {isSigningIn ? (
                <>
                  <svg className="animate-spin -ml-1 mr-2 h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                  </svg>
                  Signing In...
                </>
              ) : 'Sign In'}
            </button>
          </form>

          {/* Sign Up Form */}
          <form 
            onSubmit={handleSignUp} 
            className={`w-1/2 h-full flex flex-col items-center justify-center px-6 transition-all duration-700 z-10 overflow-hidden py-8 ${isActive ? "" : "translate-x-full opacity-0"}`}
          >
            <h1 className="text-2xl font-semibold text-gray-800">Athlete Sign Up</h1>
            
            {/* Avatar Upload */}
            <div className="w-full flex flex-col items-center mb-2">
              <div className="w-16 h-16 rounded-full bg-gray-200 overflow-hidden mb-1">
                {avatarPreview ? (
                  <img src={avatarPreview} alt="Avatar Preview" className="w-full h-full object-cover" />
                ) : (
                  <div className="w-full h-full flex items-center justify-center">
                    <span className="text-xs text-gray-500">No Image</span>
                  </div>
                )}
              </div>
              <label className="cursor-pointer text-xs text-green-700 hover:underline">
                Upload Avatar
                <input
                  type="file"
                  accept="image/*"
                  onChange={handleFileChange}
                  className="hidden"
                />
              </label>
            </div>

            {/* Full Name */}
            <input 
              type="text" 
              name="name"
              placeholder="Full Name" 
              value={signUpData.name}
              onChange={handleSignUpChange}
              className="mt-1 p-2 w-full bg-gray-200 rounded-md outline-none focus:ring-2 focus:ring-green-500" 
              required 
            />
            
            {/* Email */}
            <input 
              type="email" 
              name="email"
              placeholder="Email" 
              value={signUpData.email}
              onChange={handleSignUpChange}
              className="mt-2 p-2 w-full bg-gray-200 rounded-md outline-none focus:ring-2 focus:ring-green-500" 
              required 
            />
            
            {/* Password */}
            <input 
              type="password" 
              name="password"
              placeholder="Password" 
              value={signUpData.password}
              onChange={handleSignUpChange}
              className="mt-2 p-2 w-full bg-gray-200 rounded-md outline-none focus:ring-2 focus:ring-green-500" 
              required 
            />
            
            {/* Date of Birth */}
            <div className="w-full mt-2">
              <label className="block text-xs text-gray-600 mb-1">Date of Birth</label>
              <input 
                type="date" 
                name="dob"
                value={signUpData.dob}
                onChange={handleSignUpChange}
                className="p-2 w-full bg-gray-200 rounded-md outline-none focus:ring-2 focus:ring-green-500" 
                required 
              />
            </div>
            
            {/* Gender */}
            <select 
              name="sex"
              value={signUpData.sex}
              onChange={handleSignUpChange}
              className="mt-2 p-2 w-full bg-gray-200 rounded-md outline-none focus:ring-2 focus:ring-green-500"
            >
              <option value="">Select Gender</option>
              {genderOptions.map((option, index) => (
                <option key={index} value={option}>{option}</option>
              ))}
            </select>
            
            {/* Sport Type */}
            <select 
              name="sport"
              value={signUpData.sport}
              onChange={handleSignUpChange}
              className="mt-2 p-2 w-full bg-gray-200 rounded-md outline-none focus:ring-2 focus:ring-green-500"
            >
              <option value="">Select Sport</option>
              {sportOptions.map((sport, index) => (
                <option key={index} value={sport}>{sport}</option>
              ))}
            </select>
            
            {/* Experience Level */}
            <select 
              name="totalExperience"
              value={signUpData.totalExperience}
              onChange={handleSignUpChange}
              className="mt-2 p-2 w-full bg-gray-200 rounded-md outline-none focus:ring-2 focus:ring-green-500"
            >
              <option value="">Select Experience</option>
              {experienceOptions.map((exp, index) => (
                <option key={index} value={exp}>{exp}</option>
              ))}
            </select>

            {/* Highest Level Played */}
            <select 
              name="highestLevelPlayed"
              value={signUpData.highestLevelPlayed}
              onChange={handleSignUpChange}
              className="mt-2 p-2 w-full bg-gray-200 rounded-md outline-none focus:ring-2 focus:ring-green-500" 
            >
              <option value="">Select Highest Level Played</option>
              {competitionLevels.map((level, index) => (
                <option key={index} value={level}>{level}</option>
              ))}
            </select>

            <button 
              type="submit" 
              disabled={isSigningUp}
              className={`mt-4 px-6 py-2 ${isSigningUp ? 'bg-gray-500' : 'bg-green-700 hover:bg-green-800'} text-white rounded-md transition text-sm flex items-center`}
            >
              {isSigningUp ? (
                <>
                  <svg className="animate-spin -ml-1 mr-2 h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
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
        <div className={`absolute top-0 left-1/2 w-1/2 h-full flex items-center justify-center bg-green-700 text-white transition-all duration-1000 z-20 ${isActive ? "-translate-x-full rounded-tr-3xl rounded-br-3xl" : "rounded-tl-3xl rounded-bl-3xl"}`}>
          <div className="text-center p-8">
            <h1 className="text-2xl font-semibold">{isActive ? "Welcome Back!" : "Hello Athlete!"}</h1>
            <p className="mt-3 text-sm px-6">
              {isActive 
                ? "To keep connected with us, please login with your personal info." 
                : "Enter your details to create an account and start your athletic journey."}
            </p>
            <button 
              onClick={() => setIsActive(!isActive)} 
              className="mt-6 px-7 py-2 bg-transparent border border-white rounded-md hover:bg-white hover:text-gray-800 transition text-sm"
            >
              {isActive ? "Sign In" : "Sign Up"}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}