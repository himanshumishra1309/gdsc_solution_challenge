
import asyncHandler from "../utils/asyncHandler.js";
import {ApiResponse} from "../utils/ApiResponse.js"
import {Admin} from "../models/admin.model.js"
import {Coach} from "../models/coach.model.js"
import {Athlete} from "../models/athlete.model.js"
import {ApiError} from "../utils/ApiError.js"


const loginAdmin = async (req, res) => {
    try {
      const { email, password } = req.body;
      const admin = await Admin.findOne({ email });
  
      if (!admin) {
        return res.status(404).json({ error: "Admin not found" });
      }
  
      const isPasswordValid = await admin.isPasswordCorrect(password);
      if (!isPasswordValid) {
        return res.status(401).json({ error: "Invalid credentials" });
      }
  
      const adminAccessToken = admin.generateAccessToken();
      const adminRefreshToken = admin.generateRefreshToken();
  
      admin.refreshToken = adminRefreshToken;
      await admin.save({ validateBeforeSave: false });
  
      res.cookie("adminAccessToken", adminAccessToken, { httpOnly: true, secure: true });
      res.cookie("adminRefreshToken", adminRefreshToken, { httpOnly: true, secure: true });
  
      res.json(
        new ApiResponse(
            200,
            {
                admin: { _id: admin._id, email: admin.email, role: admin.role, organization: admin.organization },
                adminAccessToken,
                adminRefreshToken
            },
            "Admin login successful"
        )
    );
    } catch (error) {
      console.error("Admin login error:", error);
      next(new ApiError(500, "Internal server error"));
    }
  };
  

  const loginCoach = async (req, res) => {
    try {
      const { email, password } = req.body;
      const coach = await Coach.findOne({ email });
  
      if (!coach) {
        return res.status(404).json({ error: "Coach not found" });
      }
  
      const isPasswordValid = await coach.isPasswordCorrect(password);
      if (!isPasswordValid) {
        return res.status(401).json({ error: "Invalid credentials" });
      }
  
      const coachAccessToken = coach.generateAccessToken();
      const coachRefreshToken = coach.generateRefreshToken();
  
      coach.refreshToken = coachRefreshToken;
      await coach.save({ validateBeforeSave: false });
  
      res.cookie("coachAccessToken", coachAccessToken, { httpOnly: true, secure: true });
      res.cookie("coachRefreshToken", coachRefreshToken, { httpOnly: true, secure: true });
  
      return res.status(200).json(
        new ApiResponse(
            200,
            {
                coach: { _id: coach._id, name:coach.name, email: coach.email, role: coach.role, organization: coach.organization },
                coachAccessToken,
                coachRefreshToken
            },
            "Coach login successful"
        )
    );
    } catch (error) {
      console.error("Coach login error:", error);
      return next(new ApiError(500, "Internal server error"));
    }
  };
  

const loginAthlete = async (req, res) => {
    try {
      const { email, password } = req.body;
      const athlete = await Athlete.findOne({ email });
  
      if (!athlete) {
        return res.status(404).json({ error: "Athlete not found" });
      }
  
      const isPasswordValid = await athlete.isPasswordCorrect(password);
      if (!isPasswordValid) {
        return res.status(401).json({ error: "Invalid credentials" });
      }
  
      const athleteAccessToken = athlete.generateAccessToken();
      const athleteRefreshToken = athlete.generateRefreshToken();
  
      athlete.refreshToken = athleteRefreshToken;
      await athlete.save({ validateBeforeSave: false });
  
      res.cookie("athleteAccessToken", athleteAccessToken, { httpOnly: true, secure: true });
      res.cookie("athleteRefreshToken", athleteRefreshToken, { httpOnly: true, secure: true });
  
      return res.status(200).json(
        new ApiResponse(
            200,
            {
                athlete: { _id: athlete._id, name:athlete.name, email: athlete.email, role: athlete.role, organization: athlete.organization },
                athleteAccessToken,
                athleteRefreshToken
            },
            "Athlete login successful"
        )
    );
} catch (error) {
    console.error("Athlete login error:", error);
    return next(new ApiError(500, "Internal server error"));
}
  };
  
export{
    loginAdmin,
    loginCoach,
    loginAthlete
}