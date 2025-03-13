import { IndividualAthlete } from "../models/individualAthlete.model.js";
import { ApiError } from "../utils/ApiError.js";
import { ApiResponse } from "../utils/ApiResponse.js";
import asyncHandler from "../utils/asyncHandler.js";

const registerIndependentAthlete = asyncHandler(async (req, res) => {
  const {
    name,
    email,
    password,
    dob,
    sex,
    sport,
    totalExperience,
    highestLevelPlayed,
  } = req.body;

  if (!name || !email || !password || !dob) {
    throw new ApiError(
      400,
      "Name, email, password, and date of birth are required"
    );
  }

  const existingAthlete = await IndividualAthlete.findOne({ email });
  if (existingAthlete) {
    throw new ApiError(400, "An athlete with this email already exists");
  }

  let avatar;
  if (req.file) {
    avatar = req.file.path;
  }

  const athlete = await IndividualAthlete.create({
    name,
    email,
    password,
    dob: new Date(dob),
    sex: sex || undefined,
    sport: sport || undefined,
    totalExperience: totalExperience || undefined,
    avatar: avatar || undefined,
    highestLevelPlayed: highestLevelPlayed || undefined,
  });

  const athleteAccessToken = athlete.generateAccessToken();
  const athleteRefreshToken = athlete.generateRefreshToken();

  athlete.refreshToken = athleteRefreshToken;
  await athlete.save({ validateBeforeSave: false });

  const athleteResponse = {
    _id: athlete._id,
    name: athlete.name,
    email: athlete.email,
    sport: athlete.sport,
    dob: athlete.dob,
    sex: athlete.sex,
    avatar: athlete.avatar,
    totalExperience: athlete.totalExperience,
    highestLevelPlayed: athlete.highestLevelPlayed,
  };

  const options = {
    httpOnly: true,
    secure: process.env.NODE_ENV === "production",
    sameSite: "Strict",
  };

  return res
    .status(201)
    .cookie("individualAthleteAccessToken", athleteAccessToken, options)
    .cookie("individualAthleteRefreshToken", athleteRefreshToken, options)
    .json(
      new ApiResponse(
        201,
        {
          user: athleteResponse,
          individualAthleteAccessToken: athleteAccessToken,
          individualAthleteRefreshToken: athleteRefreshToken,
        },
        "Independent athlete registered successfully"
      )
    );
});

const loginIndependentAthlete = asyncHandler(async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    throw new ApiError(400, "Email and password are required");
  }

  const athlete = await IndividualAthlete.findOne({ email });

  if (!athlete) {
    throw new ApiError(400, "Independent athlete not found");
  }

  const isPasswordValid = await athlete.isPasswordCorrect(password);
  if (!isPasswordValid) {
    throw new ApiError(401, "Invalid credentials");
  }

  const athleteAccessToken = athlete.generateAccessToken();
  const athleteRefreshToken = athlete.generateRefreshToken();

  athlete.refreshToken = athleteRefreshToken;
  await athlete.save({ validateBeforeSave: false });

  const athleteData = {
    _id: athlete._id,
    name: athlete.name,
    email: athlete.email,
    sport: athlete.sport,
    dob: athlete.dob,
    sex: athlete.sex,
    avatar: athlete.avatar,
    totalExperience: athlete.totalExperience,
    highestLevelPlayed: athlete.highestLevelPlayed,
  };

  const options = {
    httpOnly: true,
    secure: process.env.NODE_ENV === "production",
    sameSite: "Strict",
  };

  return res
    .status(200)
    .cookie("individualAthleteAccessToken", athleteAccessToken, options)
    .cookie("individualAthleteRefreshToken", athleteRefreshToken, options)
    .json(
      new ApiResponse(
        200,
        {
          user: athleteData,
          individualAthleteAccessToken: athleteAccessToken,
          individualAthleteRefreshToken: athleteRefreshToken,
        },
        "Independent athlete logged in successfully"
      )
    );
});

const getIndependentAthleteProfile = asyncHandler(async (req, res) => {
  const athleteId = req.athlete?._id;

  if (!athleteId) {
    throw new ApiError(401, "Unauthorized request");
  }

  const athlete = await IndividualAthlete.findById(athleteId).select(
    "-password -refreshToken"
  );

  if (!athlete) {
    throw new ApiError(404, "Athlete not found");
  }

  return res
    .status(200)
    .json(
      new ApiResponse(200, athlete, "Athlete profile fetched successfully")
    );
});

const updateIndependentAthleteProfile = asyncHandler(async (req, res) => {
  const athleteId = req.athlete?._id;

  if (!athleteId) {
    throw new ApiError(401, "Unauthorized request");
  }

  const { name, dob, sex, sport, totalExperience, highestLevelPlayed } =
    req.body;

  let avatar;
  if (req.file) {
    avatar = req.file.path;
  }

  const updatedFields = {
    ...(name && { name }),
    ...(dob && { dob: new Date(dob) }),
    ...(sex && { sex }),
    ...(sport && { sport }),
    ...(totalExperience && { totalExperience }),
    ...(highestLevelPlayed && { highestLevelPlayed }),
    ...(avatar && { avatar }),
  };

  const updatedAthlete = await IndividualAthlete.findByIdAndUpdate(
    athleteId,
    {
      $set: updatedFields,
    },
    {
      new: true,
      select: "-password -refreshToken",
    }
  );

  if (!updatedAthlete) {
    throw new ApiError(404, "Athlete not found");
  }

  return res
    .status(200)
    .json(
      new ApiResponse(
        200,
        updatedAthlete,
        "Athlete profile updated successfully"
      )
    );
});

const logoutIndependentAthlete = asyncHandler(async (req, res) => {
  const athleteId = req.athlete?._id;

  if (!athleteId) {
    throw new ApiError(401, "Unauthorized request");
  }

  await IndividualAthlete.findByIdAndUpdate(athleteId, {
    $unset: {
      refreshToken: 1,
    },
  });

  const options = {
    httpOnly: true,
    secure: process.env.NODE_ENV === "production",
    sameSite: "Strict",
  };

  return res
    .status(200)
    .clearCookie("individualAthleteAccessToken", options)
    .clearCookie("individualAthleteRefreshToken", options)
    .json(new ApiResponse(200, {}, "Athlete logged out successfully"));
});

const refreshAccessToken = asyncHandler(async (req, res) => {
  const incomingRefreshToken =
    req.cookies?.individualAthleteRefreshToken || req.body.refreshToken;

  if (!incomingRefreshToken) {
    throw new ApiError(401, "Unauthorized request");
  }

  try {
    const decodedToken = jwt.verify(
      incomingRefreshToken,
      process.env.REFRESH_TOKEN_SECRET
    );

    const athlete = await IndividualAthlete.findById(decodedToken?._id);

    if (!athlete) {
      throw new ApiError(401, "Invalid refresh token");
    }

    if (incomingRefreshToken !== athlete?.refreshToken) {
      throw new ApiError(401, "Refresh token is expired or used");
    }

    const accessToken = athlete.generateAccessToken();
    const refreshToken = athlete.generateRefreshToken();

    athlete.refreshToken = refreshToken;
    await athlete.save({ validateBeforeSave: false });

    const options = {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "Strict",
    };

    return res
      .status(200)
      .cookie("individualAthleteAccessToken", accessToken, options)
      .cookie("individualAthleteRefreshToken", refreshToken, options)
      .json(
        new ApiResponse(
          200,
          {
            individualAthleteAccessToken: accessToken,
            individualAthleteRefreshToken: refreshToken,
          },
          "Access token refreshed"
        )
      );
  } catch (error) {
    throw new ApiError(401, error?.message || "Invalid refresh token");
  }
});

export {
  registerIndependentAthlete,
  loginIndependentAthlete,
  getIndependentAthleteProfile,
  updateIndependentAthleteProfile,
  logoutIndependentAthlete,
  refreshAccessToken,
};
