// to verify if user exists or not

import asyncHandler from "../utils/asyncHandler.js";
import jwt from "jsonwebtoken"
import {Coach} from "../models/coach.model.js"

//here no need of rs so we put _

export const verifyCoachJWT = asyncHandler( async (req, _, next) => {
    // request has cookie parser by injecting middleware in app.js
    // maybe cookies are sent by custom header
  try {
      const token =
      req.cookies?.coachAccessToken || req.header("Authorization")?.replace("Bearer ", "")
  
      if(!token){
          throw new ApiError(401, "Unauthorized request")
      }
  
      const decodedToken = jwt.verify(token, process.env.ACCESS_TOKEN_SECRET)
      const coach = await Coach.findById(decodedToken?._id).select("-password -refreshToken")
  
      if(!coach){
          //ToDO: Discuss about Frontend
          throw new ApiError(401, "Invalid Access Token")
      }
  
      req.coach = coach;
      next()
  } catch (error) {
    throw new ApiError(401, error?.messge || "Invalid access token")
  }
})