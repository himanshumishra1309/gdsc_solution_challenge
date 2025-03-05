
import asyncHandler from "../utils/asyncHandler.js";
import {ApiResponse} from "../utils/ApiResponse.js"
import {Admin} from "../models/admin.model.js"
import {Coach} from "../models/coach.model.js"
import {Athlete} from "../models/athlete.model.js"
import {ApiError} from "../utils/ApiError.js"

const generateAccessAndRefreshToken = async (userId, userModel) => {
    try {
        const user = await userModel.findById(userId); // Dynamically fetching user

        if (!user) {
            throw new ApiError(404, "User not found");
        }

        console.log("Checking user methods:", user.generateAccessToken, user.generateRefreshToken);


        const accessToken = user.generateAccessToken(); 
        const refreshToken = user.generateRefreshToken();

        user.refreshToken = refreshToken;
        await user.save({ validateBeforeSave: false });

        return { refreshToken, accessToken };
    } catch (error) {
        console.error("Error generating tokens:", error);
        throw new ApiError(500, "Something went wrong while generating tokens");
    }
};

const loginAdmin = asyncHandler(async (req, res) => {
    console.log("Request body:", req.body);
    
    const { email, password } = req.body;
    if (!email) {
        throw new ApiError(400, "Email is required");
    }

    const user = await Admin.findOne({ email });
    if (!user) {
        throw new ApiError(400, "User doesn't exist");
    }

    const isPasswordValid = await user.isPasswordCorrect(password);
    if (!isPasswordValid) {
        throw new ApiError(401, "Invalid User Credentials");
    }

    // Generate tokens
    const { refreshToken: adminRefreshToken, accessToken: adminAccessToken } = await generateAccessAndRefreshToken(user._id, Admin);
    console.log("Generated Tokens: ", { adminAccessToken, adminRefreshToken });

    if (!adminAccessToken || !adminRefreshToken) {
        throw new ApiError(500, "Token generation failed");
    }

    const loggedInUser = await Admin.findById(user._id).select("-refreshToken -password -__v");

    const options = {
        httpOnly: true,
        secure: process.env.NODE_ENV === "production", // Secure only in production
        sameSite: "Strict",
    };

    return res
        .status(200)
        .cookie("adminAccessToken", adminAccessToken, options)
        .cookie("adminRefreshToken", adminRefreshToken, options)
        .json(new ApiResponse(200, { user: loggedInUser, adminAccessToken, adminRefreshToken }, "Admin logged in Successfully"));
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
                    user:loggedInUser, coachAccessToken, coachRefreshToken
                },
                "Coach logged in Successfully"
            )
         )
  })
  
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
                    user: {
                      ...loggedInUser.toObject(),
                      isIndependent: user.isIndependent, // ✅ Add flag for frontend
                      organization: user.organization ? user.organization : null, // ✅ Ensure null for independent athletes
                    }, athleteAccessToken, athleteRefreshToken
            },
            "Athlete logged in Successfully"
        )
     )
})

export{
    loginAdmin,
    loginCoach,
    loginAthlete
}