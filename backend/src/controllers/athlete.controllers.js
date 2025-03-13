import asyncHandler from "../utils/asyncHandler.js";
import {ApiError} from "../utils/ApiError.js"
import {Athlete} from "../models/athlete.model.js"
import jwt from 'jsonwebtoken'
import {ApiResponse} from "../utils/ApiResponse.js"


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
      await athlete.save({validateBeforeSave: false})

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
  
  const getAthleteDetails = async (req, res) => {
    try {
      const { athleteId } = req.params;
  
      const athleteDetails = await Athlete.aggregate([
        {
          $match: { _id: new mongoose.Types.ObjectId(athleteId) },
        },
        {
          $lookup: {
            from: "achievements", // Collection name in MongoDB
            localField: "_id",
            foreignField: "athleteId",
            as: "achievements",
          },
        },
        {
          $lookup: {
            from: "injuryrecords",
            localField: "_id",
            foreignField: "athleteId",
            as: "injuryRecords",
          },
        },
        {
          $lookup: {
            from: "performancemetrics",
            localField: "_id",
            foreignField: "athleteId",
            as: "performanceStats",
          },
        },
        {
          $project: {
            password: 0, // Hide sensitive fields
            refreshToken: 0,
          },
        },
      ]);
  
      if (!athleteDetails.length) {
        return res.status(404).json({ message: "Athlete not found" });
      }
  
      res.status(200).json(athleteDetails[0]);
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
};


export{
    generateAccessAndRefreshToken,
    logoutUser,
    getAthleteProfile,
    getAthletes,
    getAthleteDetails
}