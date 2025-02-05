import asyncHandler from "../utils/asyncHandler";
import {ApiError} from "../utils/ApiError.js"
import {Admin} from "../models/admin.model.js"
import jwt from 'jsonwebtoken'




const generateAccessAndRefreshToken = async(userId) => {
    try {
      const admin = await  Admin.findById(userId)
 

      //we save refresh token in db
          // If no teacher is found, throw an error
    if (!Admin) {
        throw new ApiError(404, "Admin not found");
      }
  
      const adminAccessToken = admin.generateAccessToken()
      const adminRefreshToken = admin.generateRefreshToken()

      admin.refreshToken = adminRefreshToken
      //this is used if it is something other than password wich doesnt need to validate
      await admin.save({validateBeforeSave: false})

      return{adminRefreshToken, adminAccessToken}
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
    console.log("request : ", req);
    console.log("request's body : ", req.body);
    
    const {email, password} = req.body
    
    if(!email){
        throw new ApiError(400, "Email is required")
    
    }
    
    //alternative id you want to check both in the frontend !(username)
    
    const user = await Admin.findOne({email})
    
    if(!user){
        throw new ApiError(400, "User doesn't not exist")
    }
    
    const isPasswordValid = await user.isPasswordCorrect(password);
    
    if(!isPasswordValid){
        throw new ApiError(401, "Invalid User Credentials")
    }
    
    const {adminRefreshToken, adminAccessToken}= await generateAccessAndRefreshToken(user._id)
    
    const loggedInUser = await Admin.findById(user._id).
    select("-refreshToken -password")
    
     const options = {
        // now the cookies can only be accessed and changed from the server and not the frontend
            httpOnly: true,
            secure: true
     }
    
     //(key,value,options)
     return res.
     status(200)
     .cookie("adminAccessToken", adminAccessToken, options)
     .cookie("adminRefreshToken", adminRefreshToken, options)
     .json(
        new ApiResponse(
            200,{
                user:loggedInUser, adminAccessToken, adminRefreshToken
            },
            "Admin logged in Successfully"
        )
     )
    })

const logoutUser = asyncHandler( async(req,res) => {
        await Admin.findByIdAndUpdate(
            req.admin._id,
            // {
            //     $set: {refreshToken : undefined}
            // },
             // {
        //   refreshToken: undefined
        // }, dont use this approach, this dosent work well
    
        {
            $unset: {
              adminRefreshToken: 1, // this removes the field from the document
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
         .clearCookie("adminAcessToken", options)
         .clearCookie("adminRefreshToken", options)
         .json(
            new ApiResponse(200, {}, "User Logged Out")
         )
    
    
})

const getAdminProfile = asyncHandler(async(req,res) => {
    const admin = await Admin.findById(req.admin._id).select(
        "-password -refreshToken"
      );

      if (!admin) {
        throw new ApiError(404, "Admin not found");
      }
    
      return res.status(200).json(new ApiResponse(200, teacher, "Admin profile fetched successfully"));
})