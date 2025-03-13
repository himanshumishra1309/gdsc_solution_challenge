import asyncHandler from "../utils/asyncHandler.js";
import { ApiError } from "../utils/ApiError.js";
import { Admin } from "../models/admin.model.js";
import { Athlete } from "../models/athlete.model.js";
import { Coach } from "../models/coach.model.js";
import { Organization } from "../models/organization.model.js";
import { sendEmail } from "../utils/sendEmail.js";
import { RPE } from "../models/rpe.model.js";
import { ApiResponse } from "../utils/ApiResponse.js";
import { CustomForm } from "../models/customForm.model.js";
import mongoose from "mongoose";
import jwt from "jsonwebtoken";

const registerOrganizationAthlete = asyncHandler(async (req, res) => {
  const { name, email, password, organizationId, sport } = req.body;

  if (!organizationId) {
    throw new ApiError(
      400,
      "Organization ID is required for organization athletes"
    );
  }

  const existingAthlete = await Athlete.findOne({ email });
  if (existingAthlete) {
    throw new ApiError(400, "Athlete with this email already exists");
  }

  const organizationExists = await Organization.exists({ _id: organizationId });
  if (!organizationExists) {
    throw new ApiError(404, "Organization not found");
  }

  const athlete = await Athlete.create({
    name,
    email,
    password,
    sport,
    isIndependent: false,
    organization: organizationId,
  });

  await sendEmail({
    email: athlete.email,
    subject: "Welcome to AMS - Athlete Login Details",
    message: `<h3>Hi ${athlete.name},</h3>
              <p>Your account has been created in the Athlete Management System.</p>
              <p><strong>Email:</strong> ${athlete.email}</p>
              <p><strong>Password:</strong> ${password}</p>
              <p>Please log in and change your password.</p>`,
  });

  res.status(201).json({
    success: true,
    message: "Athlete registered successfully, email sent.",
    athlete: {
      _id: athlete._id,
      name: athlete.name,
      email: athlete.email,
      sportType: organization.sportType,
      isIndependent: false,
      organization: organizationId,
    },
  });
});

const registerAdmin = asyncHandler(async (req, res) => {
  const { name, email, password, organizationId, avatar } = req.body;

  // Validate required fields
  if (!name || !email || !password || !organizationId) {
    throw new ApiError(400, "All required fields must be provided");
  }

  // Check if admin with email already exists
  const existingAdmin = await Admin.findOne({ email });
  if (existingAdmin) {
    throw new ApiError(400, "Admin with this email already exists");
  }

  // Validate organization ID
  if (!mongoose.Types.ObjectId.isValid(organizationId)) {
    throw new ApiError(400, "Invalid Organization ID format");
  }

  // Verify organization exists
  const organization = await Organization.findById(organizationId);
  if (!organization) {
    throw new ApiError(404, `Organization not found with ID: ${organizationId}`);
  }

  // Create admin
  const admin = await Admin.create({
    name,
    email,
    password,  // Password will be hashed by the model's pre-save hook
    avatar: avatar || "",
    organization: organizationId,
    role: "admin"
  });

  // Send welcome email
  await sendEmail({
    email: admin.email,
    subject: "Welcome to AMS - Admin Account Created",
    message: `
      <h3>Hi ${admin.name},</h3>
      <p>Your admin account has been created in the Athlete Management System.</p>
      <p><strong>Email:</strong> ${admin.email}</p>
      <p><strong>Password:</strong> ${password}</p>
      <p>Please log in and change your password at your earliest convenience.</p>
      <p>You have been assigned as an administrator for ${organization.name}.</p>
      <p>Thank you!</p>
    `,
  });

  // Send success response (without password)
  res.status(201).json({
    success: true,
    message: "Admin registered successfully",
    admin: {
      _id: admin._id,
      name: admin.name,
      email: admin.email,
      organization: organization.name,
      role: admin.role
    }
  });
});

const registerCoach = asyncHandler(async (req, res) => {
  const {
    name,
    email,
    password,
    organizationId,
    dob,
    gender,
    nationality,
    contactNumber,
    address,
    city,
    state,
    country,
    pincode,
    sport,
    experience,
    certifications,
    previousOrganizations,
    designation = "Assistant Coach", // Default value
    profilePhoto,
    idProof,
    certificatesFile,
  } = req.body;

  console.log("Received Organization ID:", organizationId);

  // Validate required fields
  if (
    !name ||
    !email ||
    !password ||
    !organizationId ||
    !dob ||
    !gender ||
    !contactNumber ||
    !address ||
    !state ||
    !country ||
    !sport
  ) {
    throw new ApiError(400, "Please provide all required fields");
  }

  // Validate organization ID
  if (!mongoose.Types.ObjectId.isValid(organizationId)) {
    throw new ApiError(400, "Invalid Organization ID format");
  }
  const orgId = new mongoose.Types.ObjectId(organizationId);

  // Verify organization exists
  const organization = await Organization.findById(orgId);
  console.log("Organization Query Result:", organization);

  if (!organization) {
    throw new ApiError(
      404,
      `Organization not found with ID: ${organizationId}`
    );
  }

  // Validate sport against organization's sports
  if (!organization.sportType.includes(sport)) {
    throw new ApiError(
      400,
      `Invalid sport. Allowed sports: ${organization.sportType.join(", ")}`
    );
  }

  // Check if coach with email already exists
  const existingCoach = await Coach.findOne({ email });
  if (existingCoach) {
    throw new ApiError(400, "Coach with this email already exists");
  }

  // Parse date of birth
  const dobDate = new Date(dob);
  if (isNaN(dobDate.getTime())) {
    throw new ApiError(400, "Invalid date of birth format");
  }

  // Parse experience as a number
  const experienceYears = parseInt(experience);
  if (isNaN(experienceYears)) {
    throw new ApiError(400, "Experience must be a valid number");
  }

  // Format certifications and previous organizations
  const certificationsList = certifications
    ? certifications.split(",").map((cert) => cert.trim())
    : [];
  const previousOrgList = previousOrganizations
    ? previousOrganizations.split(",").map((org) => org.trim())
    : [];

  // Create coach with all provided fields
  const coach = await Coach.create({
    name,
    email,
    password,
    organization: orgId,
    dob: dobDate,
    gender,
    nationality,
    contactNumber,
    address: {
      street: address,
      city: city || "",
      state,
      country,
      pincode: pincode || "",
    },
    sport,
    experience: experienceYears,
    certifications: certificationsList,
    previousOrganizations: previousOrgList,
    designation,
    avatar: profilePhoto || "",
    documents: {
      idProof: idProof || "",
      certificates: certificatesFile || "",
    },
    status: "Active",
    joined_date: new Date(),
  });

  // Send welcome email with login credentials
  await sendEmail({
    email: coach.email,
    subject: "Welcome to AMS - Coach Login Details",
    message: `
      <h3>Hi ${coach.name},</h3>
      <p>Your account has been created in the Athlete Management System.</p>
      <p><strong>Email:</strong> ${coach.email}</p>
      <p><strong>Password:</strong> ${password}</p>
      <p>Please log in and change your password at your earliest convenience.</p>
      <p>You have been assigned to ${organization.name} as a ${designation} for ${sport}.</p>
      <p>For any questions, please contact the system administrator.</p>
      <p>Thank you!</p>
    `,
  });

  // Send success response
  res.status(201).json({
    success: true,
    message: "Coach registered successfully, welcome email sent.",
    coach: {
      _id: coach._id,
      name: coach.name,
      email: coach.email,
      organization: organization.name,
      sport,
      designation,
      contactNumber,
      experience: experienceYears,
      joined_date: coach.joined_date,
    },
  });
});

const getAllUsers = asyncHandler(async (req, res) => {
  const { organization } = req.user;

  const athletes = await Athlete.find({ organization });
  const coaches = await Coach.find({ organization });

  res.status(200).json({
    success: true,
    athletes,
    coaches,
  });
});

const generateAccessAndRefreshToken = async (userId) => {
  try {
    const admin = await Admin.findById(userId);

    //we save refresh token in db
    // If no teacher is found, throw an error
    if (!admin) {
      throw new ApiError(404, "Admin not found");
    }

    const adminAccessToken = admin.generateAccessToken();
    const adminRefreshToken = admin.generateRefreshToken();

    admin.refreshToken = adminRefreshToken;

    await admin.save({ validateBeforeSave: false });

    return { adminRefreshToken, adminAccessToken };
  } catch (error) {
    console.error("Error generating tokens:", error);

    throw new ApiError(500, "Something went wrong while generating tokens");
  }
};

const logoutAdmin = asyncHandler(async (req, res) => {
  await Admin.findByIdAndUpdate(
    req.admin._id,
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
    .clearCookie("adminAccessToken", options)
    .clearCookie("adminRefreshToken", options)
    .json(new ApiResponse(200, {}, "Admin logged out successfully"));
});

const getAdminProfile = asyncHandler(async (req, res) => {
  const admin = await Admin.findById(req.admin._id)
    .select("-password -refreshToken")
    .populate("organization", "name email organizationType");

  if (!admin) {
    throw new ApiError(404, "Admin not found");
  }

  return res
    .status(200)
    .json(new ApiResponse(200, admin, "Admin profile fetched successfully"));
});

const getRpeInsights = asyncHandler(async (req, res) => {
  const { athleteId } = req.params;
  const userId = req.user._id;
  const userRole = req.user.role;

  try {
    const athlete = await Athlete.findById(athleteId);
    if (!athlete) {
      return res.status(404).json({ message: "Athlete not found." });
    }

    if (userRole === "athlete") {
      if (athleteId !== userId.toString()) {
        return res.status(403).json({
          message: "Access denied. You can only view your own RPE insights.",
        });
      }
    } else if (
      userRole === "head_coach" ||
      userRole === "assistant_coach" ||
      userRole === "training_staff"
    ) {
      const coach = await Coach.findById(userId);
      if (
        !coach ||
        coach.organization.toString() !== athlete.organization.toString()
      ) {
        return res.status(403).json({
          message:
            "Access denied. Athlete does not belong to your organization.",
        });
      }
    } else {
      return res.status(403).json({ message: "Access denied. Invalid role." });
    }

    const rpeRecords = await RPE.find({ athleteId });
    const averageRPE =
      rpeRecords.reduce((sum, record) => sum + record.rpe, 0) /
      rpeRecords.length;

    let recommendation = "";
    if (averageRPE >= 8) {
      recommendation =
        "High RPE detected. Consider rest and recovery activities.";
    } else if (averageRPE <= 4) {
      recommendation =
        "Low RPE detected. Check for injuries or adjust training intensity.";
    } else {
      recommendation =
        "RPE within normal range. Maintain current training plan.";
    }

    res.json({ averageRPE, recommendation });
  } catch (error) {
    throw new ApiError(500);
    res.status(500).json({ message: "Error fetching RPE insights", error });
  }
});

const createCustomForm = asyncHandler(async (req, res) => {
  const { title, sport, fields } = req.body;
  const organizationId = req.user.organization;

  try {
    const customForm = new CustomForm({
      title,
      sport,
      organization: organizationId,
      fields,
    });

    await customForm.save();
    res.status(201).json(customForm);
  } catch (error) {
    res.status(500).json({ message: "Error creating custom form", error });
  }
});

export {
  registerOrganizationAthlete,
  registerAdmin,
  registerCoach,
  getAllUsers,
  generateAccessAndRefreshToken,
  logoutAdmin,
  getAdminProfile,
  getRpeInsights,
};
