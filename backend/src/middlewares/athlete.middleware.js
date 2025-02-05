// to verify if user exists or not

import asyncHandler from "../utils/asyncHandler.js";
import jwt from "jsonwebtoken"
import {Athlete} from "../models/athlete.model.js"

//here no need of rs so we put _

export const verifyAthleteJWT = asyncHandler( async (req, _, next) => {
    // request has cookie parser by injecting middleware in app.js
    // maybe cookies are sent by custom header
  try {
      const token =
      req.cookies?.athleteAccessToken || req.header("Authorization")?.replace("Bearer ", "")
  
      if(!token){
          throw new ApiError(401, "Unauthorized request")
      }
  
      const decodedToken = jwt.verify(token, process.env.ACCESS_TOKEN_SECRET)
      const athlete = await Athlete.findById(decodedToken?._id).select("-password -refreshToken")
  
      if(!athlete){
          //ToDO: Discuss about Frontend
          throw new ApiError(401, "Invalid Access Token")
      }
  
      req.athlete = athlete;
      next()
  } catch (error) {
    throw new ApiError(401, error?.messge || "Invalid access token")
  }
})