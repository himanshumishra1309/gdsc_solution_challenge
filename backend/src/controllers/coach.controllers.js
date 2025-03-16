import asyncHandler from "../utils/asyncHandler.js";
import ApiError from "../utils/ApiError.js"
import jwt from 'jsonwebtoken'


import { Coach } from "../models/coach.model.js";

const logoutUser = asyncHandler(async (req, res) => {
  await Coach.findByIdAndUpdate(
    req.coach._id,

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
    .clearCookie("coachAccessToken", options)
    .clearCookie("coachRefreshToken", options)
    .json(new ApiResponse(200, {}, "User Logged Out"));
});

const registerUser = asyncHandler(async (req, res) => {
  const { fullname, username, email, password } = req.body;

  if (
    [fullname, email, password, username].some((field) => field?.trim() === "")
  ) {
    throw new ApiError(400, "All fields are requied");
  }

  const existedUser = await User.findOne({
    $or: [{ username }, { email }],
  });

  if (existedUser) {
    throw new ApiError(409, "User with email or username already exists");
  }

  const avatarLocalPath = req.files?.avatar[0]?.path;
  console.log({ avatarLocalPath });

  let coverImageLocalPath;
  if (
    req.files &&
    Array.isArray(req.files.coverImage) &&
    req.files.coverImage.length > 0
  ) {
    coverImageLocalPath = req.files.coverImage[0].path;
  }

  if (!avatarLocalPath) {
    throw new ApiError(400, "Avatar File is required");
  }

  const avatar = await uploadOnCloudinary(avatarLocalPath);
  const coverImage = await uploadOnCloudinary(coverImageLocalPath);

  if (!avatar) {
    throw new ApiError(400, "Avatar File is required");
  }

  const user = await User.create({
    fullname,
    avatar: avatar.url,
    coverImage: coverImage?.url || "",
    email,
    password,
    username: username.toLowerCase(),
  });

  const createdUser = await User.findById(user._id).select(
    "-password -refreshToken"
  );

  if (!createdUser) {
    throw new ApiError(500, "Something went wrong while generating the user");
  }

  return res
    .status(201)
    .json(new ApiResponse(200, createdUser, "User Registered Successfully"));
});

const getCoachProfile = asyncHandler(async (req, res) => {
  const coach = await Coach.findById(req.coach._id).select(
    "-password -refreshToken"
  );

  if (!coach) {
    throw new ApiError(404, "Coach not found");
  }

  return res
    .status(200)
    .json(new ApiResponse(200, teacher, "Coah profile fetched successfully"));
});

const logRpe = asyncHandler(async (req, res) => {
  const { athleteId, sessionId, rpe, notes } = req.body;
  const coachId = req.user._id;

  try {
    const coach = await Coach.findById(coachId);
    if (!coach || coach.designation !== "training_staff") {
      return res.status(403).json({
        message:
          "Access denied. Only Training and Conditioning Staff can log RPE.",
      });
    }

    if (!coach.assignedAthletes.includes(athleteId)) {
      return res
        .status(403)
        .json({ message: "Access denied. Athlete is not assigned to you." });
    }

    const athlete = await Athlete.findById(athleteId);
    if (
      !athlete ||
      athlete.organization.toString() !== coach.organization.toString()
    ) {
      return res.status(403).json({
        message: "Access denied. Athlete does not belong to your organization.",
      });
    }

    const rpeRecord = new RPE({
      athleteId,
      sessionId,
      rpe,
      notes,
      recordedBy: coachId,
    });

    await rpeRecord.save();
    res.status(201).json(rpeRecord);
  } catch (error) {
    throw new ApiError(500, error?.message || "Error logging Rpe");
  }
});

const getCoaches = asyncHandler(async (req, res) => {
  const { organization } = req.user;
  const { designation, search } = req.query;

  let query = { organization };

  if (designation) query.designation = designation;
  if (search) {
    query.$or = [
      { name: { $regex: search, $options: "i" } },
      { email: { $regex: search, $options: "i" } },
    ];
  }

  const coaches = await Coach.find(query).select("-password");

  res.status(200).json({
    success: true,
    coaches,
  });
});

export { logoutUser, registerUser, getCoachProfile, getCoaches };
