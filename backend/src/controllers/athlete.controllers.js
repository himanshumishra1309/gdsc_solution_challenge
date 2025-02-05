import asyncHandler from "../utils/asyncHandler";
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


const loginUser = asyncHandler(async (req,res) => {
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
    
    const {athleteRefreshToken, athleteAccessToken}= await generateAccessAndRefreshToken(user._id)
    
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
            200,{
                user:loggedInUser, athleteAccessToken, athleteRefreshToken
            },
            "Athlete logged in Successfully"
        )
     )
    })

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




export{
    generateAccessAndRefreshToken,
    loginUser,
    logoutUser,
    getAthleteProfile
}