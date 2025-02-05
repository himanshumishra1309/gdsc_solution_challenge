import asyncHandler from "../utils/asyncHandler.js"
import {ApiError} from "../utils/ApiError.js"
import {User} from "../models/user.model.js"
import { uploadOnCloudinary } from "../utils/cloudinary.js"
import { ApiResponse } from "../utils/ApiResponse.js"
import jwt from 'jsonwebtoken'


const generateAccessAndRefreshToken = async(userId) => {
    try {
      const user = await  User.findById(userId)
 

      //we save refresh token in db
          // If no teacher is found, throw an error
    if (!user) {
        throw new ApiError(404, "User not found");
      }
  
      const accessToken = user.generateAccessToken()
      const refreshToken = user.generateRefreshToken()

      user.refreshToken = refreshToken
      //this is used if it is something other than password wich doesnt need to validate
      await user.save({validateBeforeSave: false})

      return{refreshToken, accessToken}
    } catch (error) {
            console.error("Error generating tokens:", error); // Optional: for debugging purposes

        throw new ApiError(500, "Something went wrong while generating tokens")
    }
}

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


   // console.log(req.body);

    console.log({
        fullname: fullname,
        username: username,
        email: email,
        password: password
    });
    

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

const {username, email, password} = req.body

if(!username && !email){
    throw new ApiError(400, "Username or email is required")

}

//alternative id you want to check both in the frontend !(username)

const user = await User.findOne({
    $or: [{username}, {email}]
})

if(!user){
    throw new ApiError(400, "User doesn't not exist")
}

const isPasswordValid = await user.isPasswordCorrect(password);

if(!isPasswordValid){
    throw new ApiError(401, "Invalid User Credentials")
}

const {refreshToken, accessToken}= await generateAccessAndRefreshToken(user._id)

const loggedInUser = await User.findById(user._id).
select("-refreshToken -password")

 const options = {
    // now the cookies can only be accessed and changed from the server and not the frontend
        httpOnly: true,
        secure: true
 }

 //(key,value,options)
 return res.
 status(200)
 .cookie("accessToken", accessToken, options)
 .cookie("refreshToken", refreshToken, options)
 .json(
    new ApiResponse(
        200,{
            user:loggedInUser, accessToken, refreshToken
        },
        "User logged in Successfully"
    )
 )
})

const logoutUser = asyncHandler( async(req,res) => {
    await User.findByIdAndUpdate(
        req.user._id,
        // {
        //     $set: {refreshToken : undefined}
        // },
         // {
    //   refreshToken: undefined
    // }, dont use this approach, this dosent work well

    {
        $unset: {
          teacherRefreshToken: 1, // this removes the field from the document
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
     .clearCookie("acessToken", options)
     .clearCookie("refreshToken", options)
     .json(
        new ApiResponse(200, {}, "User Logged Out")
     )


})

const refreshAccessToken = asyncHandler(async (req,res) => {
    const incomingRefreshToken = req.cookies.refreshToken || req.body.refreshToken

    if(!incomingRefreshToken){
        throw new ApiError(401, "Unauthorized request")
    }

try {
        const decodedToken = jwt.verify(incomingRefreshToken, process.env.REFRESH_TOKEN_SECRET)
        // while generating refresh token we store the id as payload
       const user = await User.findById(decodedToken?._id)
    
       if(!user){
        throw new ApiError(401, "Invalid Refresh Token")
    }
    
    if(incomingRefreshToken !== user?.refreshToken){
        throw new ApiError(401, "Refresh Token is expired or used")
    }
    
    const options = {
        httpOnly: true,
        secure: true
    }
    
    const{accessToken, newRefreshToken} = await generateAccessAndRefreshToken(user._id)
    
    return res
    .status(200)
    .cookie("accessToken", accessToken, options)
    .cookie("refreshToken", newRefreshToken, options)
    .json(
        new ApiResponse(
            200, 
            {accessToken, refreshToken: newRefreshToken}, 
            "Access Token Refreshed Successfully"
        )
    )
} catch (error) {
    throw new ApiError(401,error?.message || "Invalid refresh Token")
}

})

const changeCurrentPassword = asyncHandler(async (req,res) => {
    const {oldPassword, newPassword, confirmPassowrd} = req.body

    if(!(newPassword === oldPassword)){
        throw new ApiError(401, "The existing and confirm password do not match with each other")
    }
    const user = await User.findById(req.user?._id)
    const isPasswordCorrect = await user.isPasswordCorrect(oldPassword)

    if(!isPasswordCorrect){
        throw new ApiError(400, "Invalid Old Password")
    }

    user.password = newPassword
    await user.save({validateBeforeSave: false})

    return res
    .status(200)
    .json(
        new ApiResponse(
            200,
            {

            },
            "Password Changed Successfully"
        )
    )
})

const getCurrentUser = asyncHandler(async (req, res) => {
    return res
    .status(200)
    .json(
        new ApiResponse(
            200,
            req.user,
            "current user fetched successfully"
        )
        )
})

const updateAccountDetails = asyncHandler(async (req,res) => {
    const {fullname, email} = req.body

    if(!fullname || !email){
        throw new ApiError(400, "All Fields are required")
    }

   const user =  User.findByIdAndUpdate(
        req.user?._id,
        {
            $set: {
                fullname,
                email
            }
        },
        //this will return theentire info after updated
        {new : true}
    ).select("-password")

    return res
    .status(200)
    .json(
        new ApiResponse(200, user, "Account details updated successfully")
    )
})

const updateUserAvatar = asyncHandler(async (req,res) => {
   const avatarLocalPath =  req.file?.path

   if(!avatarLocalPath){
    throw new ApiError(400, "Avatar File is misssing")
   }

   const avatar = await uploadOnCloudinary(avatarLocalPath)
   if(!avatar.url){
    throw new ApiError(400, "Error while uploading avatar")
   }

   const user = await user.findByIdAndUpdate(
    req.user?._id,
    {
        $set: {
            avatar: avatar.url
        }
    },
    {new: true}
   ).select("-password")

   return res
   .status(200, user, "Avatar Image uploaded successfully")



})

const updateUserCoverImage = asyncHandler(async (req,res) => {
    const coverImageLocalPath =  req.file?.path
 
    if(!coverImageLocalPath){
     throw new ApiError(400, "Cover Image File is misssing")
    }
 
    const coverImage = await uploadOnCloudinary(coverImageLocalPath)
    if(!coverImage.url){
     throw new ApiError(400, "Error while uploading coverImage")
    }
 
    const user = await user.findByIdAndUpdate(
     req.user?._id,
     {
         $set: {
             coverImage: coverImage.url
         }
     },
     {new: true}
    ).select("-password")
 
    return res
    .status(200, user, "Over Image uploaded successfully") 
})
const getUserChannelProfile = asyncHandler(async(req,res) => {
    //we will take the username fro the url using params

    const {username} = req.params

    if(!username?.trim()){
            throw new ApiError(400, "username is missing")
    }

    // There is a better method because you will take the username then by id you will aggregate
    // User.find({username})

    //you can directly aggregate using $match

    const channel = await User.aggregate([
        {
            $match: {
                username: username
            }
        },
        {
            $lookup: {
                from: "subscriptions",
                localField: "_id",
                foreignField: "channel",
                as: "subscribers"
            }
        },
        {
            $lookup: {
                from: "subscriptions",
                localField: "_id",
                foreignField: "subscriber",
                as: "subscribedTo"
            }
        },
        {
            //adds additional fields to original User Object
            $addFields: {
                subscriberCount: {
                    //calculates the count of documents
                    $size: "subscribers"
                },
                channelSubsrcibedToCount: {
                    $size: "subscribedTo"
                },
                isSubscribed : {
                    $cond: {
                        //$in works in both array and object, here we have searched if it exists in object
                        if: {$in: [req.user?._id, "$subscribers.subscriber"]},
                        then: true,
                        else: false
                    }
                }
            }
        },
        {
            $project: {
                fullname: 1,
                username: 1,
                subscriberCount: 1,
                channelSubsrcibedToCount: 1,
                isSubscribed: 1,
                avatar: 1,
                coverImage: 1,

            }
        }
    ])

    //console log to find what datatype is returned by aggregate, mostly array

    if(!channel?.length){

        throw new ApiError(400,"Channel does not exist")
    }

    return res
    .status(200)
    .json(
        new ApiResponse(200, channel[0], "User channel fetched succesfully")
    )

})

const getWatchHistory = asyncHandler(async(req,res) => {

    const user = await User.aggregate([
        {
            $match: {
                _id: new mongoose.Types.ObjectId(req.user?._id)
            }
        },
        {
            //nested lookup
                $lookup: {
                    from: "videos",
                    localField: "watchHistory",
                    foreignField: "_id",
                    as: "watchHistory",
                    pipeline: [
                        {
                            $lookup: {
                                from: "users",
                                localField: "owner",
                                foreignField: "_id",
                                as: "owner",
                                pipeline: [
                                    {
                                        $project: {
                                            fullname: 1,
                                            username: 1,
                                            avatar: 1
                                        }
                                    }

                                ]
                            }
                        },
                        //In array t just sned the first object of array, so that it gets easy
                        {
                            $addfields: {
                                //overriding the exisiting field
                                owner: {
                                    //or arrayelementsAt
                                    $first: "$owner"
                                }
                            }
                        }
                    ]
                }
        }
    ])

    return res
    .status(200)
    .json(
        new ApiResponse(
            200,
            user[0].watchHistory,
            "Watch History fetched successfully"
        )
    )
})



// to update files you need multer and to check if logged in

export {registerUser, 
    loginUser, 
    logoutUser, 
    refreshAccessToken,
    changeCurrentPassword,
    getCurrentUser,
    updateAccountDetails,
    updateUserAvatar,
    updateUserCoverImage,
    getUserChannelProfile,
    getWatchHistory

 }