import asyncHandler from "../utils/asyncHandler";
import {ApiError} from "../utils/ApiError.js"
import jwt from 'jsonwebtoken'


import {Coach} from "../models/coach.model.js"


const generateAccessAndRefreshToken = async(userId) => {
    try {
      const coach = await  Coach.findById(userId)
 

      //we save refresh token in db
          // If no teacher is found, throw an error
    if (!user) {
        throw new ApiError(404, "User not found");
      }
  
      const coachAccessToken = user.generateAccessToken()
      const coachRefreshToken = user.generateRefreshToken()

      coach.refreshToken = coachRefreshToken
      //this is used if it is something other than password wich doesnt need to validate
      await coach.save({validateBeforeSave: false})

      return{coachRefreshToken, coachAccessToken}
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
    
    const user = await Coach.findOne({email})
    
    if(!user){
        throw new ApiError(400, "Coach doesn't not exist")
    }
    
      // we are not using 'User' rather we will use 'user' which is returned above, because 'User' is an instance of the moongoose of mongoDB and user is the data returned from the data base which signifies a single user and user.models.js file contain all the methods which can be accessed here such as isPasswordCorrect or refreshToken or accessToken
    const isPasswordValid = await user.isPasswordCorrect(password);
    
    if(!isPasswordValid){
        throw new ApiError(401, "Invalid User Credentials")
    }
    
    const {coachRefreshToken, coachAccessToken}= await generateAccessAndRefreshToken(user._id)
    
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

const logoutUser = asyncHandler( async(req,res) => {
        await Coach.findByIdAndUpdate(
            req.coach._id,
            // {
            //     $set: {refreshToken : undefined}
            // },
             // {
        //   refreshToken: undefined
        // }, dont use this approach, this dosent work well
    
        {
            $unset: {
              coachRefreshToken: 1, // this removes the field from the document
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
         .clearCookie("coachAcessToken", options)
         .clearCookie("coachRefreshToken", options)
         .json(
            new ApiResponse(200, {}, "User Logged Out")
         )
    
    
})


const registerUser = asyncHandler(async(req,res) =>{
    //get user details from frontend
    //validation
    //check if it already exists: check using username and email both
    //check for images and avatar
    //upload them to cloudinary, avatar
    //create user object - create entry in db
    //remove password and refresh token field from the respone, because response will send all fields o user schema model
    //check for user creation
    // return res , if not then null, if succesfull creation then return res

    const {fullname, username, email, password} = req.body
        //console.log("email: ", email);


  

    if(
        [fullname, email, password, username].some((field) => field?.trim() === "")
    ){
        throw new ApiError(400, "All fields are requied")
    }

    const existedUser = await User.findOne({ 
        $or: [{ username }, { email }]
    })


    if(existedUser){
        throw new ApiError(409,"User with email or username already exists")
    }

    //we need the first prop of avatar which is its path

   // console.log(req.files)
    const avatarLocalPath = req.files?.avatar[0]?.path
    console.log({avatarLocalPath});
    // const coverImageLocalPath = req.files?.coverImage[0]?.path

        // const coverImage = await uploadOnCloudinary(coverImageLocalPath)
    // above gives the undefined error because of the chaining?, in this case
    //use the if else condition
    

    let coverImageLocalPath;
    if (req.files && Array.isArray(req.files.coverImage) && req.files.coverImage.length > 0) {
        coverImageLocalPath = req.files.coverImage[0].path
    }

    if(!avatarLocalPath){
        throw new ApiError(400,"Avatar File is required")
    }

    const avatar = await uploadOnCloudinary(avatarLocalPath)
    const coverImage = await uploadOnCloudinary(coverImageLocalPath)


    
    if(!avatar){
        throw new ApiError(400,"Avatar File is required")

    }


   const user = await User.create({
        fullname,
        avatar: avatar.url,
        coverImage: coverImage?.url || "",
        email,
        password,
        username: username.toLowerCase()
    })

    //Mongodb automatically generates a unique _id field
    //weird syntax of select, a string of what you don want
    const createdUser = await User.findById(user._id).select(
            "-password -refreshToken"
    )

    if(!createdUser){
        throw new ApiError(500, "Something went wrong while generating the user")
    }

    return res.status(201).json(
        new ApiResponse(200, createdUser, "User Registered Successfully")
    )

})


const logRpe = asyncHandler(async(req, res) => {
    const { athleteId, sessionId, rpe, notes } = req.body;

    try {

        const athlete = await Athlete.findById(athleteId)
        
    } catch (error) {

            throw new ApiError(500,error?.message || "Error logging Rpe");
        
        
    }
})


const getCoachProfile = asyncHandler(async(req,res) => {
    const coach = await Coach.findById(req.coach._id).select(
        "-password -refreshToken"
      );

      if (!coach) {
        throw new ApiError(404, "Coach not found");
      }
    
      return res.status(200).json(new ApiResponse(200, teacher, "Coah profile fetched successfully"));
})


