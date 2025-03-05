import asyncHandler from "../utils/asyncHandler.js";
import {ApiError} from "../utils/ApiError.js"
import {Athlete} from "../models/athlete.model.js"
import jwt from 'jsonwebtoken'


const generateAccessAndRefreshToken = async(userId) => {
    try {
      const athlete = await  Athlete.findById(userId)
 

      //we save refresh token in db
          // If no teacher is found, throw an error
    if (!athlete) {
        throw new ApiError(404, "Athlete not found");
      }
  
      const athleteAccessToken = athlete.generateAccessToken()
      const athleteRefreshToken = athlete.generateRefreshToken()

      athlete.refreshToken = athleteRefreshToken
      //this is used if it is something other than password wich doesnt need to validate
      await user.save({validateBeforeSave: false})

      return{athleteRefreshToken, athleteAccessToken}
    } catch (error) {
        console.error("Error generating tokens:", error); // Optional: for debugging purposes

        throw new ApiError(500, "Something went wrong while generating tokens")
    }
}

const logoutUser = asyncHandler( async(req,res) => {
        await Athlete.findByIdAndUpdate(
            req.athlete._id,
            // {
            //     $set: {refreshToken : undefined}
            // },
             // {
        //   refreshToken: undefined
        // }, dont use this approach, this dosent work well
    
        {
            $unset: {
              athleteRefreshToken: 1, // this removes the field from the document
            },
          },
            {
                new: true
            }
        )
        //clear cookies
        // reset the refresh token in User modelSchema
    
        const options = {
                httpOnly: true,
                secure: true
         }
    
         return res
         .status(200)
         .clearCookie("athleteAcessToken", options)
         .clearCookie("athleteRefreshToken", options)
         .json(
            new ApiResponse(200, {}, "User Logged Out")
         )
    
    
})
const getAthleteProfile = asyncHandler(async(req,res) => {
    const athlete = await Athlete.findById(req.athlete._id).select(
        "-password -refreshToken"
      );

      if (!athlete) {
        throw new ApiError(404, "Athlete not found");
      }
    
      return res.status(200).json(new ApiResponse(200, teacher, "Athlete profile fetched successfully"));
})

const getAthletes = asyncHandler(async (req, res) => {
    const { organization } = req.user; // Assuming admin is logged in
    const { sport, playingPosition, search } = req.query;
  
    let query = { organization };
  
    if (sport) query.sport = sport;
    if (playingPosition) query.playingPosition = playingPosition;
    if (search) {
      query.$or = [
        { name: { $regex: search, $options: "i" } }, // Case-insensitive name search
        { email: { $regex: search, $options: "i" } }
      ];
    }
  
    const athletes = await Athlete.find(query).select("-password");
  
    res.status(200).json({
      success: true,
      athletes,
    });
  });

const registerIndependentAthlete = asyncHandler(async (req, res) => {
    const { name, email, password, sportType } = req.body;
  
    // Check if athlete already exists
    const existingAthlete = await Athlete.findOne({ email });
    if (existingAthlete) {
      throw new ApiError(400, "An athlete with this email already exists");
    }
  
    // Create Independent Athlete
    const athlete = await Athlete.create({
      name,
      email,
      password,
      sportType,
      isIndependent: true, // ✅ Automatically set for independent athletes
      organization: null, // ✅ No organization assigned
    });
  
    res.status(201).json({
      success: true,
      message: "Independent athlete registered successfully",
      athlete: {
        _id: athlete._id,
        name: athlete.name,
        email: athlete.email,
        sportType: athlete.sportType,
        isIndependent: true,
        organization: null,
      },
    });
  });

  const loginIndependentAthlete = asyncHandler(async (req, res) => {
    const { email, password } = req.body;
  
    if (!email || !password) {
      throw new ApiError(400, "Email and password are required");
    }
  
    // Find independent athlete
    const user = await Athlete.findOne({ email, isIndependent: true });
  
    if (!user) {
      throw new ApiError(400, "Independent athlete doesn't exist");
    }
  
    // Validate password
    const isPasswordValid = await user.isPasswordCorrect(password);
    if (!isPasswordValid) {
      throw new ApiError(401, "Invalid credentials");
    }
  
    // Generate JWT tokens
    const { athleteRefreshToken, athleteAccessToken } = await generateAccessAndRefreshToken(user._id, Athlete);
  
    const options = { httpOnly: true, secure: true };
  
    return res
      .status(200)
      .cookie("athleteAccessToken", athleteAccessToken, options)
      .cookie("athleteRefreshToken", athleteRefreshToken, options)
      .json(
        new ApiResponse(
          200,
          {
            user: {
              _id: user._id,
              name: user.name,
              email: user.email,
              sportType: user.sportType, // ✅ Include sport
              isIndependent: true, // ✅ Ensures this is an individual
              organization: null,
            },
            athleteAccessToken,
            athleteRefreshToken,
          },
          "Independent athlete logged in successfully"
        )
      );
  });
  



export{
    generateAccessAndRefreshToken,
    logoutUser,
    getAthleteProfile,
    getAthletes,
    registerIndependentAthlete,
    loginIndependentAthlete
}