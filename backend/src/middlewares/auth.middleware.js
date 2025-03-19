import asyncHandler from "../utils/asyncHandler.js";
import jwt from "jsonwebtoken";
import { ApiError } from "../utils/ApiError.js";
import jwt from "jsonwebtoken"
import ApiError from "../utils/ApiError.js"
import { Admin } from "../models/admin.model.js";
import { IndividualAthlete } from "../models/individualAthlete.model.js";
import { Coach } from "../models/coach.model.js";
import { Athlete } from "../models/athlete.model.js";

const verifyJWT = asyncHandler(async (req, _, next) => {
  try {
    const token = 
      req.cookies?.accessToken || 
      req.header("Authorization")?.replace("Bearer ", "")?.trim();

    if (!token) {
      throw new ApiError(401, "Unauthorized request");
    }

    const decodedToken = jwt.verify(token, process.env.ACCESS_TOKEN_SECRET);

    let user = await Admin.findById(decodedToken?._id).select("-password -refreshToken");
    if (!user) {
      user = await Coach.findById(decodedToken?._id).select("-password -refreshToken");
    }
    if (!user) {
      user = await IndividualAthlete.findById(decodedToken?._id).select("-password -refreshToken");
    }
    if (!user) {
      user = await Athlete.findById(decodedToken?._id).select("-password -refreshToken");
    }

    if (!user) {
      throw new ApiError(401, "Invalid Access Token");
    }

    req.user = user; // Attach user to request
    next();
  } catch (error) {
    throw new ApiError(401, error?.message || "Invalid access token");
  }
});

const verifyJWTAthlete = asyncHandler(async (req, _, next) => {
  try {
    const token = 
      req.cookies?.athleteAccessToken || 
      req.header("Authorization")?.replace("Bearer ", "")?.trim();

    if (!token) {
      throw new ApiError(401, "Unauthorized request");
    }

    const decodedToken = jwt.verify(token, process.env.ACCESS_TOKEN_SECRET);
    const athlete = await Athlete.findById(decodedToken?._id).select("-password -refreshToken");

    if (!athlete) {
      throw new ApiError(401, "Invalid Access Token");
    }

    req.athlete = athlete;
    next();
  } catch (error) {
    throw new ApiError(401, error?.message || "Invalid access token");
  }
});

const verifyJWTAdmin = asyncHandler(async (req, _, next) => {
  try {
    const token = 
      req.cookies?.adminAccessToken || 
      req.header("Authorization")?.replace("Bearer ", "")?.trim();

    if (!token) {
      throw new ApiError(401, "Unauthorized request");
    }

    const decodedToken = jwt.verify(token, process.env.ACCESS_TOKEN_SECRET);
    const admin = await Admin.findById(decodedToken?._id).select("-password -refreshToken");

    if (!admin) {
      throw new ApiError(401, "Invalid Access Token");
    }

    // Ensure the user has an "admin" role
    if (admin.role !== "admin") {
      throw new ApiError(403, "Access denied. Admins only.");
    }
    
    req.admin = admin;
    next();
  } catch (error) {
    throw new ApiError(401, error?.message || "Invalid access token");
  }
});

const verifyJWTCoach = asyncHandler(async (req, _, next) => {
  try {
    const token = 
      req.cookies?.coachAccessToken || 
      req.header("Authorization")?.replace("Bearer ", "")?.trim();

    if (!token) {
      throw new ApiError(401, "Unauthorized request");
    }

    const decodedToken = jwt.verify(token, process.env.ACCESS_TOKEN_SECRET);
    const coach = await Coach.findById(decodedToken?._id).select("-password -refreshToken");

    if (!coach) {
      throw new ApiError(401, "Invalid Access Token");
    }

    req.coach = coach;
    next();
  } catch (error) {
    throw new ApiError(401, error?.message || "Invalid access token");
  }
});

const verifyJWTIndividualAthlete = asyncHandler(async (req, _, next) => {
  try {
    const token = 
      req.cookies?.individualAthleteAccessToken || 
      req.header("Authorization")?.replace("Bearer ", "")?.trim();

    if (!token) {
      throw new ApiError(401, "Unauthorized request");
    }

    const decodedToken = jwt.verify(token, process.env.ACCESS_TOKEN_SECRET);
    const athlete = await IndividualAthlete.findById(decodedToken?._id).select("-password -refreshToken");

    if (!athlete) {
      throw new ApiError(401, "Invalid Access Token");
    }

    req.athlete = athlete;
    next();
  } catch (error) {
    throw new ApiError(401, error?.message || "Invalid access token");
  }
});

export {
  verifyJWT,
  verifyJWTAthlete,
  verifyJWTAdmin,
  verifyJWTIndividualAthlete,
  verifyJWTCoach
};