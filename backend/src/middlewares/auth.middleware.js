// to verify if user exists or not

import asyncHandler from "../utils/asyncHandler.js";
import jwt from "jsonwebtoken"
import {ApiError} from "../utils/ApiError.js"
import { Admin } from "../models/admin.model.js";

//here no need of rs so we put _

// const verifyJWT = asyncHandler( async (req, _, next) => {
//     // request has cookie parser by injecting middleware in app.js
//     // maybe cookies are sent by custom header
//   try {
//       const token =
//       req.cookies?.accessToken || req.header("Authorization")?.replace("Bearer ", "")
  
//       if(!token){
//           throw new ApiError(401, "Unauthorized request")
//       }
  
//       const decodedToken = jwt.verify(token, process.env.ACCESS_TOKEN_SECRET)
//       const user = await User.findById(decodedToken?._id).select("-password -refreshToken")
  
//       if(!user){
//           //ToDO: Discuss about Frontend
//           throw new ApiError(401, "Invalid Access Token")
//       }
  
//       req.user = user;
//       next()
//   } catch (error) {
//     throw new ApiError(401, error?.messge || "Invalid access token")
//   }
// })

const verifyJWT = asyncHandler(async (req, _, next) => {
  try {
    const token =
      req.cookies?.accessToken || req.header("Authorization")?.replace("Bearer ", "").trim();

    if (!token) {
      throw new ApiError(401, "Unauthorized request");
    }

    const decodedToken = jwt.verify(token, process.env.ACCESS_TOKEN_SECRET);

    let user = await Admin.findById(decodedToken?._id).select("-password -refreshToken");
    if (!user) {
      user = await Coach.findById(decodedToken?._id).select("-password -refreshToken");
    }
    if (!user) {
      user = await Athlete.findById(decodedToken?._id).select("-password -refreshToken");
    }

    if (!user) {
      throw new ApiError(401, "Invalid Access Token");
    }

    req.user = user; // ✅ Attach user to request
    next();
  } catch (error) {
    throw new ApiError(401, error?.message || "Invalid access token");
  }
});


export{
  verifyJWT
}