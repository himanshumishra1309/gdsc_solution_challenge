import asyncHandler from "../utils/asyncHandler.js";
import ApiError from "../utils/ApiError.js";
import ApiResponse from "../utils/ApiResponse.js";
import {Athlete} from "../models/athlete.model.js"
import {AthleteStats} from "../models/AthleteStats.model.js"
import mongoose from "mongoose";
import jwt from 'jsonwebtoken'


const generateAccessAndRefreshToken = async (userId) => {
  try {
    const athlete = await Athlete.findById(userId);

    if (!athlete) {
      throw new ApiError(404, "Athlete not found");
    }

    const athleteAccessToken = athlete.generateAccessToken();
    const athleteRefreshToken = athlete.generateRefreshToken();

    athlete.refreshToken = athleteRefreshToken;

    await athlete.save({ validateBeforeSave: false });

    return { athleteRefreshToken, athleteAccessToken };
  } catch (error) {
    console.error("Error generating tokens:", error);

    throw new ApiError(500, "Something went wrong while generating tokens");
  }
};

const logoutUser = asyncHandler(async (req, res) => {
  await Athlete.findByIdAndUpdate(
    req.athlete._id,

    {
      $unset: {
        refreshToken: 1,
      },
    },
    {
      new: true,
    }
  );

  const options = {
    httpOnly: true,
    secure: true,
  };

  return res
    .status(200)
    .clearCookie("athleteAccessToken", options)
    .clearCookie("athleteRefreshToken", options)
    .json(new ApiResponse (200, {}, "User Logged Out"));
});

const getAthleteProfile = asyncHandler(async (req, res) => {
  const athlete = await Athlete.findById(req.athlete._id).select(
    "-password -refreshToken"
  );

  if (!athlete) {
    throw new ApiError(404, "Athlete not found");
  }

  return res
    .status(200)
    .json(
      new ApiResponse (200, teacher, "Athlete profile fetched successfully")
    );
});

const getAthletes = asyncHandler(async (req, res) => {
  const { organization } = req.user;
  const { sport, playingPosition, search } = req.query;

  let query = { organization };

  if (sport) query.sport = sport;
  if (playingPosition) query.playingPosition = playingPosition;
  if (search) {
    query.$or = [
      { name: { $regex: search, $options: "i" } },
      { email: { $regex: search, $options: "i" } },
    ];
  }

  const athletes = await Athlete.find(query).select("-password");

  res.status(200).json({
    success: true,
    athletes,
  });
});

const getAthleteDetails = async (req, res) => {
  try {
    const { athleteId } = req.params;

    const athleteDetails = await Athlete.aggregate([
      {
        $match: { _id: new mongoose.Types.ObjectId(athleteId) },
      },
      {
        $lookup: {
          from: "achievements",
          localField: "_id",
          foreignField: "athleteId",
          as: "achievements",
        },
      },
      {
        $lookup: {
          from: "injuryrecords",
          localField: "_id",
          foreignField: "athleteId",
          as: "injuryRecords",
        },
      },
      {
        $lookup: {
          from: "performancemetrics",
          localField: "_id",
          foreignField: "athleteId",
          as: "performanceStats",
        },
      },
      {
        $project: {
          password: 0,
          refreshToken: 0,
        },
      },
    ]);

    if (!athleteDetails.length) {
      return res.status(404).json({ message: "Athlete not found" });
    }

    res.status(200).json(athleteDetails[0]);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const getAthleteStats = asyncHandler(async (req, res, next) => {
  const athleteId = req.athlete.id; // Get ID from the JWT middleware

  if (!athleteId) {
      return next(new ApiError(400, "Athlete ID not found in token"));
  }

  // Ensure athlete exists
  const athlete = await Athlete.findById(athleteId);
  if (!athlete) {
      return next(new ApiError(404, "Athlete not found"));
  }

  // Fetch all stats for the athlete across multiple sports
  const athleteStats = await AthleteStats.find({ athlete: athleteId });

  res.status(200).json(new ApiResponse(200, athleteStats, "Athlete stats retrieved successfully"));
});

export {
  generateAccessAndRefreshToken,
  logoutUser,
  getAthleteProfile,
  getAthletes,
  getAthleteDetails,
  getAthleteStats,
};