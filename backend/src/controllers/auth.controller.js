
import asyncHandler from "../utils/asyncHandler.js";
import {ApiResponse} from "../utils/ApiResponse.js"
import {Admin} from "../models/admin.model.js"
import {Coach} from "../models/coach.model.js"
import {Athlete} from "../models/athlete.model.js"
import {ApiError} from "../utils/ApiError.js"


const loginAdmin = async (req, res) => {
    try {
      const { email, password } = req.body;
      const admin = await Admin.findOne({ email });
  
      if (!admin) {
        return res.status(404).json({ error: "Admin not found" });
      }
  
      const isPasswordValid = await admin.isPasswordCorrect(password);
      if (!isPasswordValid) {
        return res.status(401).json({ error: "Invalid credentials" });
      }
  
      const accessToken = admin.generateAccessToken();
      const refreshToken = admin.generateRefreshToken();
  
      admin.refreshToken = refreshToken;
      await admin.save({ validateBeforeSave: false });
  
      res.cookie("accessToken", accessToken, { httpOnly: true, secure: true });
      res.cookie("refreshToken", refreshToken, { httpOnly: true, secure: true });
  
      res.json(
        new ApiResponse(
            200,
            {
                admin: { _id: admin._id, email: admin.email, role: admin.role },
                accessToken,
                refreshToken
            },
            "Admin login successful"
        )
    );
    } catch (error) {
      console.error("Admin login error:", error);
      return next(new ApiError(500, "Internal server error"));
    }
};

const loginAdmin = asyncHandler(async (req, res) => {
    const { email, password } = req.body;
  
    if (!email || !password) {
      throw new ApiError(400, "Email and password are required");
    }
  
    const admin = await Admin.findOne({ email });
  
    if (!admin) {
      throw new ApiError(401, "Invalid email or password");
    }
  
    const isPasswordValid = await admin.isPasswordCorrect(password);
  
    if (!isPasswordValid) {
      throw new ApiError(401, "Invalid email or password");
    }
  
    const { adminAccessToken, adminRefreshToken } = await generateAccessAndRefreshToken(admin._id);
  
    const loggedInAdmin = await Admin.findById(admin._id)
      .select("-password -refreshToken")
      .populate("organization", "name email organizationType");
  
    const options = {
      httpOnly: true,
      secure: true
    };
  
    return res
      .status(200)
      .cookie("adminAccessToken", adminAccessToken, options)
      .cookie("adminRefreshToken", adminRefreshToken, options)
      .json(
        new ApiResponse(
          200,
          {
            admin: loggedInAdmin,
            accessToken: adminAccessToken,
            refreshToken: adminRefreshToken
          },
          "Admin logged in successfully"
        )
      );
});

const loginCoach = asyncHandler(async (req,res) => {
        /*
        TO DO:
        req body -> data
        check if the user is created
        req.file match the password or username ,
        Access and refresh token
        Send them through  secured cookies
        check if expired if yes then match refresh token
        */
        
        const {email, password} = req.body
        
        if(!email){
            throw new ApiError(400, "Email is required")
        
        }
        
        //alternative id you want to check both in the frontend !(username)
        
        const user = await Coach.findOne({email})
        
        if(!user){
            throw new ApiError(400, "Coach doesn't not exist")
        }
        
          // we are not using 'User' rather we will use 'user' which is returned above, because 'User' is an instance of the moongoose of mongoDB and user is the data returned from the data base which signifies a single user and user.models.js file contain all the methods which can be accessed here such as isPasswordCorrect or refreshToken or accessToken
        const isPasswordValid = await user.isPasswordCorrect(password);
        
        if(!isPasswordValid){
            throw new ApiError(401, "Invalid User Credentials")
        }
        
        const {coachRefreshToken, coachAccessToken}= await generateAccessAndRefreshToken(user._id, Coach)
        
        const loggedInUser = await Coach.findById(user._id).
        select("-refreshToken -password")
        
         const options = {
            // now the cookies can only be accessed and changed from the server and not the frontend
                httpOnly: true,
                secure: true
         }
        
         //(key,value,options)
         return res.
         status(200)
         .cookie("coachAccessToken", coachAccessToken, options)
         .cookie("coachRefreshToken", coachRefreshToken, options)
         .json(
            new ApiResponse(
                200,{
                    user:loggedInUser
                },
                "Coach logged in Successfully"
            )
         )
});
  
const loginAthlete = asyncHandler(async (req,res) => {
    /*
    TO DO:
    req body -> data
    check if the user is created
    req.file match the password or username ,
    Access and refresh token
    Send them through  secured cookies
    check if expired if yes then match refresh token
    */
    
    const {email, password} = req.body
    
    if(!email){
        throw new ApiError(400, "Email is required")
    
    }
    
    //alternative id you want to check both in the frontend !(username)
    
    const user = await Athlete.findOne({email})
    
    if(!user){
        throw new ApiError(400, "Athlete doesn't not exist")
    }
    
      // we are not using 'User' rather we will use 'user' which is returned above, because 'User' is an instance of the moongoose of mongoDB and user is the data returned from the data base which signifies a single user and user.models.js file contain all the methods which can be accessed here such as isPasswordCorrect or refreshToken or accessToken
    const isPasswordValid = await user.isPasswordCorrect(password);
    
    if(!isPasswordValid){
        throw new ApiError(401, "Invalid User Credentials")
    }
    
    const {athleteRefreshToken, athleteAccessToken}= await generateAccessAndRefreshToken(user._id, Athlete)
    
    const loggedInUser = await Athlete.findById(user._id).
    select("-refreshToken -password")
    
     const options = {
        // now the cookies can only be accessed and changed from the server and not the frontend
            httpOnly: true,
            secure: true
     }
    
     //(key,value,options)
     return res.
     status(200)
     .cookie("athleteAccessToken", athleteAccessToken, options)
     .cookie("athleteRefreshToken", athleteRefreshToken, options)
     .json(
        new ApiResponse(
            200,
            {
                athlete: { _id: athlete._id, email: athlete.email, role: athlete.role },
                accessToken,
                refreshToken
            },
            "Athlete login successful"
        )
    );
} catch (error) {
    console.error("Athlete login error:", error);
    return next(new ApiError(500, "Internal server error"));
}
  };
  
export{
    loginAdmin,
    loginCoach,
    loginAthlete
}