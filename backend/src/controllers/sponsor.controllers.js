import asyncHandler from "../utils/asyncHandler.js"
import {ApiError} from "../utils/ApiError.js"
import {Sponsor} from "../models/sponsor.model.js"
import jwt from 'jsonwebtoken'
import {ApiResponse} from "../utils/ApiResponse.js"


const generateAccessAndRefreshToken = async(userId) => {
    try {
      const sponsor = await  Sponsor.findById(userId)
 

      //we save refresh token in db
          // If no teacher is found, throw an error
    if (!sponsor
    ) {
        throw new ApiError(404, "Sponsor not found");
      }
  
      const sponsorAccessToken = sponsor.generateAccessToken()
      const sponsorRefreshToken = sponsor.generateRefreshToken()

      sponsor.refreshToken = sponsorRefreshToken
      //this is used if it is something other than password wich doesnt need to validate
      await sponsor.save({validateBeforeSave: false})

      return{sponsorRefreshToken, sponsorAccessToken}
    } catch (error) {
        console.error("Error generating tokens:", error); // Optional: for debugging purposes

        throw new ApiError(500, "Something went wrong while generating tokens")
    }
}

const registerSponsor = asyncHandler(async (req, res) => {
    const { name, email, dob, address, state, password } = req.body;

    if (!name || !email || !dob || !address || !state || !password) {
        throw new ApiError(400, "All fields are required");
    }

    const existingSponsor = await Sponsor.findOne({ email });

    if (existingSponsor) {
        throw new ApiError(400, "Sponsor with this email already exists");
    }

    const newSponsor = new Sponsor({
        name,
        email,
        dob,
        address,
        state,
        password
    });

    await newSponsor.save();

    const sponsorAccessToken = newSponsor.generateAccessToken();
    const sponsorRefreshToken = newSponsor.generateRefreshToken();

    newSponsor.refreshToken = sponsorRefreshToken;
    await newSponsor.save({ validateBeforeSave: false });

    const options = {
        httpOnly: true,
        secure: true
    };

    return res
        .status(201)
        .cookie("sponsorAccessToken", sponsorAccessToken, options)
        .cookie("sponsorRefreshToken", sponsorRefreshToken, options)
        .json(
            new ApiResponse(
                201,
                {
                    user: newSponsor
                },
                "Sponsor registered successfully"
            )
        );
});


const loginSponsor = asyncHandler(async (req,res) => {
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
    
    const user = await Sponsor.findOne({email})
    
    if(!user){
        throw new ApiError(400, "Sponsor doesn't not exist")
    }
    
      // we are not using 'User' rather we will use 'user' which is returned above, because 'User' is an instance of the moongoose of mongoDB and user is the data returned from the data base which signifies a single user and user.models.js file contain all the methods which can be accessed here such as isPasswordCorrect or refreshToken or accessToken
    const isPasswordValid = await user.isPasswordCorrect(password);
    
    if(!isPasswordValid){
        throw new ApiError(401, "Invalid User Credentials")
    }
    
    const {sponsorRefreshToken, sponsorAccessToken}= await generateAccessAndRefreshToken(user._id)
    
    const loggedInUser = await Sponsor.findById(user._id).
    select("-refreshToken -password")
    
     const options = {
        // now the cookies can only be accessed and changed from the server and not the frontend
            httpOnly: true,
            secure: true
     }
    
     //(key,value,options)
     return res.
     status(200)
     .cookie("sponsorAccessToken", sponsorAccessToken, options)
     .cookie("sponsorRefreshToken", sponsorRefreshToken, options)
     .json(
        new ApiResponse(
            200,{
                user:loggedInUser
            },
            "Sponsor logged in Successfully"
        )
     )
    })


const logoutSponsor = asyncHandler( async(req,res) => {
        await Sponsor.findByIdAndUpdate(
            req.sponsor._id,
            // {
            //     $set: {refreshToken : undefined}
            // },
             // {
        //   refreshToken: undefined
        // }, dont use this approach, this dosent work well
    
        {
            $unset: {
              sponsorRefreshToken: 1, // this removes the field from the document
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
         .clearCookie("sponsorAcessToken", options)
         .clearCookie("sponsorRefreshToken", options)
         .json(
            new ApiResponse(200, {}, "User Logged Out")
         )
    
    
    })

    
const getSponsorProfile = asyncHandler(async(req,res) => {
        const sponsor = await Sponsor.findById(req.sponsor._id).select(
            "-password -refreshToken"
          );
    
          if (!sponsor) {
            throw new ApiError(404, "Sponsor not found");
          }
        
          return res.status(200).json(new ApiResponse(200, teacher, "Sponsor profile fetched successfully"));
})

export {
    registerSponsor,
    loginSponsor,
    logoutSponsor,
 getSponsorProfile}