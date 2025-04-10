import asyncHandler from "../utils/asyncHandler.js";
import ApiError from "../utils/ApiError.js";
import { Admin } from "../models/admin.model.js";
import { Athlete } from "../models/athlete.model.js";
import { Coach } from "../models/coach.model.js";
import { Organization } from "../models/organization.model.js";
import { Sponsor } from "../models/sponsor.model.js";
// import {sendEmail} from "../utils/sendEmail.js"
import ApiResponse from "../utils/ApiResponse.js";
import { CustomForm } from "../models/customForm.model.js";
import { SponsorRequest } from "../models/SponsorRequest.model.js";
import { AthleteStats } from "../models/AthleteStats.model.js";
import { SportStats } from "../models/SportStats.model.js";

import DEFAULT_SPORT_STATS from "../utils/defaultStats.js";
import SPORTS_ENUM from "../utils/sportsEnum.js";
import mongoose from "mongoose";

const registerOrganizationAthlete = asyncHandler(async (req, res) => {
  // Extract all fields from request
  const {
    // Basic Information
    name,
    dob,
    gender,
    nationality,
    address,
    phoneNumber,

    // School Information
    schoolName,
    year,
    studentId,
    schoolEmail,
    schoolWebsite,

    // Sports Information
    sports,
    skillLevel,
    trainingStartDate,
    positions,
    dominantHand,

    // Staff Assignments
    headCoachAssigned,
    gymTrainerAssigned,
    medicalStaffAssigned,

    // Medical Information
    height,
    weight,
    bloodGroup,
    allergies,
    medicalConditions,

    // Emergency Contact
    emergencyContactName,
    emergencyContactNumber,
    emergencyContactRelationship,

    // Authentication
    email,
    password,

    // Organization
    organizationId,

    // If updating an existing athlete
    athleteId,
  } = req.body;

  console.log("response: ", req.body);

  // Validate required fields
  if (
    !name ||
    !dob ||
    !gender ||
    !nationality ||
    !address ||
    !phoneNumber ||
    !schoolName ||
    !year ||
    !studentId ||
    !sports ||
    !skillLevel ||
    !trainingStartDate ||
    !height ||
    !weight ||
    !emergencyContactName ||
    !emergencyContactNumber ||
    !emergencyContactRelationship ||
    !email ||
    !password ||
    !organizationId
  ) {
    throw new ApiError(400, "All required fields must be provided");
  }

  // Validate organization ID
  if (!mongoose.Types.ObjectId.isValid(organizationId)) {
    throw new ApiError(400, "Invalid Organization ID format");
  }

  // Check if organization exists
  const organization = await Organization.findById(organizationId);
  if (!organization) {
    throw new ApiError(
      404,
      `Organization not found with ID: ${organizationId}`
    );
  }

  // Check for existing athlete - using ID if provided, otherwise email
  let existingAthlete = null;

  if (athleteId && mongoose.Types.ObjectId.isValid(athleteId)) {
    // If ID is provided, look up by ID
    existingAthlete = await Athlete.findById(athleteId);

    // If found but email doesn't match, verify it's not assigned to someone else
    if (existingAthlete && existingAthlete.email !== email) {
      const duplicateEmail = await Athlete.findOne({ email });
      if (duplicateEmail) {
        throw new ApiError(400, "Email is already assigned to another athlete");
      }
    }
  } else {
    // Otherwise check by email
    existingAthlete = await Athlete.findOne({ email });
    if (existingAthlete) {
      throw new ApiError(400, "Athlete with this email already exists");
    }
  }

  // Create a unique athleteId if not updating an existing athlete
  let athleteIdCode;

  if (!existingAthlete) {
    const currentDate = new Date();
    const yearPrefix = currentDate.getFullYear().toString().slice(-2);
    const orgPrefix = organization.name.substring(0, 3).toUpperCase();

    // Find last athlete ID for this org to create a sequential number
    const lastAthlete = await Athlete.findOne({
      organization: organizationId,
    }).sort({ createdAt: -1 });

    let sequentialNumber = 1;
    if (lastAthlete && lastAthlete.athleteId) {
      // Try to extract sequential number from existing ID
      const match = lastAthlete.athleteId.match(/\d+$/);
      if (match) {
        sequentialNumber = parseInt(match[0]) + 1;
      }
    }

    // Format sequential number with leading zeros
    const paddedNumber = sequentialNumber.toString().padStart(4, "0");

    // Generate athleteId: ORG-YY-0001
    athleteIdCode = `${orgPrefix}-${yearPrefix}-${paddedNumber}`;
  } else {
    // Keep existing code if updating
    athleteIdCode = existingAthlete.athleteId;
  }

  // Add this code before line 200 (where you create the positionsMap)

  // Handle file uploads
  let avatarUrl = null;
  let uploadSchoolIdUrl = null;
  let latestMarksheetUrl = null;

  // If files were uploaded, handle them
  if (req.files) {
    // Process avatar if uploaded
    if (req.files.avatar) {
      // In a real implementation, you would upload to a cloud storage
      // and get back the URL. For now, we'll just use a placeholder.
      avatarUrl = `/uploads/avatars/${Date.now()}-${req.files.avatar[0].originalname}`;

      // If using local storage, you might save the file like this:
      // const avatarFile = req.files.avatar[0];
      // fs.writeFileSync(path.join(__dirname, '..', 'public', avatarUrl), avatarFile.buffer);
    }

    // Process school ID document if uploaded
    if (req.files.uploadSchoolId) {
      uploadSchoolIdUrl = `/uploads/school-ids/${Date.now()}-${req.files.uploadSchoolId[0].originalname}`;
    }

    // Process marksheet if uploaded
    if (req.files.latestMarksheet) {
      latestMarksheetUrl = `/uploads/marksheets/${Date.now()}-${req.files.latestMarksheet[0].originalname}`;
    }
  }

  // Convert positions from object to Map
  const positionsMap = new Map();
  if (positions) {
    Object.keys(positions).forEach((sport) => {
      positionsMap.set(sport, positions[sport]);
    });
  }

  // Create or update athlete
  let athlete;

  if (existingAthlete) {
    // Update existing athlete
    athlete = await Athlete.findByIdAndUpdate(
      existingAthlete._id,
      {
        name,
        avatar: avatarUrl || existingAthlete.avatar,
        dob: new Date(dob),
        gender,
        nationality,
        address,
        phoneNumber,
        schoolName,
        year,
        studentId,
        schoolEmail: schoolEmail || "",
        schoolWebsite: schoolWebsite || "",
        uploadSchoolId: uploadSchoolIdUrl || existingAthlete.uploadSchoolId,
        latestMarksheet: latestMarksheetUrl || existingAthlete.latestMarksheet,
        sports: Array.isArray(sports) ? sports : [sports],
        skillLevel,
        trainingStartDate: new Date(trainingStartDate),
        positions: positionsMap,
        dominantHand: dominantHand || null,
        headCoachAssigned:
          headCoachAssigned || existingAthlete.headCoachAssigned,
        gymTrainerAssigned:
          gymTrainerAssigned || existingAthlete.gymTrainerAssigned,
        medicalStaffAssigned:
          medicalStaffAssigned || existingAthlete.medicalStaffAssigned,
        height: Number(height),
        weight: Number(weight),
        bloodGroup: bloodGroup || existingAthlete.bloodGroup,
        allergies: allergies
          ? Array.isArray(allergies)
            ? allergies
            : [allergies]
          : existingAthlete.allergies,
        medicalConditions: medicalConditions
          ? Array.isArray(medicalConditions)
            ? medicalConditions
            : [medicalConditions]
          : existingAthlete.medicalConditions,
        emergencyContactName,
        emergencyContactNumber,
        emergencyContactRelationship,
        email,
        // Don't update password unless specifically requested
        ...(req.body.updatePassword && { password }),
        organization: organizationId,
      },
      { new: true }
    );
  } else {
    // Create new athlete
    athlete = await Athlete.create({
      name,
      athleteId: athleteIdCode,
      avatar: avatarUrl,
      dob: new Date(dob),
      gender,
      nationality,
      address,
      phoneNumber,
      schoolName,
      year,
      studentId,
      schoolEmail: schoolEmail || "",
      schoolWebsite: schoolWebsite || "",
      uploadSchoolId: uploadSchoolIdUrl,
      latestMarksheet: latestMarksheetUrl,
      sports: Array.isArray(sports) ? sports : [sports],
      skillLevel,
      trainingStartDate: new Date(trainingStartDate),
      positions: positionsMap,
      dominantHand: dominantHand || null,
      headCoachAssigned: headCoachAssigned || null,
      gymTrainerAssigned: gymTrainerAssigned || null,
      medicalStaffAssigned: medicalStaffAssigned || null,
      height: Number(height),
      weight: Number(weight),
      bloodGroup: bloodGroup || null,
      allergies: allergies
        ? Array.isArray(allergies)
          ? allergies
          : [allergies]
        : [],
      medicalConditions: medicalConditions
        ? Array.isArray(medicalConditions)
          ? medicalConditions
          : [medicalConditions]
        : [],
      emergencyContactName,
      emergencyContactNumber,
      emergencyContactRelationship,
      email,
      password,
      role: "athlete",
      organization: organizationId,
    });

    // Send welcome email for new athletes
    try {
      await sendEmail({
        email: athlete.email,
        subject: "Welcome to AMS - Athlete Account Created",
        message: `
          <h3>Hi ${athlete.name},</h3>
          <p>Your athlete account has been created in the Athlete Management System.</p>
          <p><strong>Athlete ID:</strong> ${athlete.athleteId}</p>
          <p><strong>Email:</strong> ${athlete.email}</p>
          <p><strong>Password:</strong> ${password}</p>
          <p>Please log in and change your password at your earliest convenience.</p>
          <p>You have been registered with ${organization.name}.</p>
          <p>Thank you!</p>
        `,
      });
    } catch (emailError) {
      console.log("Email sending failed:", emailError);
    }
  }

  // Calculate age for response
  const birthDate = new Date(dob);
  const today = new Date();
  let age = today.getFullYear() - birthDate.getFullYear();
  const m = today.getMonth() - birthDate.getMonth();
  if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
    age--;
  }

  // Return success response
  res.status(201).json(
    new ApiResponse(
      201,
      {
        athlete: {
          _id: athlete._id,
          name: athlete.name,
          athleteId: athlete.athleteId,
          email: athlete.email,
          age: age,
          gender: athlete.gender,
          sports: athlete.sports,
          organization: {
            id: organization._id,
            name: organization.name,
          },
        },
      },
      existingAthlete
        ? "Athlete updated successfully."
        : "Athlete registered successfully. Welcome email sent."
    )
  );
});

const updateOrganizationAthlete = asyncHandler(async (req, res) => {
  const { athleteId } = req.params;
  const updateFields = req.body; // Get all updatable fields from request

  console.log("🛠 Incoming update request:", updateFields);

  // Validate athleteId
  if (!mongoose.Types.ObjectId.isValid(athleteId)) {
    throw new ApiError(400, "Invalid Athlete ID format");
  }

  // Find the athlete
  const athlete = await Athlete.findById(athleteId);
  if (!athlete) {
    throw new ApiError(404, "Athlete not found");
  }

  console.log("📌 Current Athlete Data:", athlete);

  // Define allowed fields
  const allowedFields = [
    "name",
    "dob",
    "gender",
    "nationality",
    "address",
    "phoneNumber",
    "schoolName",
    "year",
    "studentId",
    "schoolEmail",
    "schoolWebsite",
    "sports",
    "skillLevel",
    "trainingStartDate",
    "positions",
    "dominantHand",
    "headCoachAssigned",
    "gymTrainerAssigned",
    "medicalStaffAssigned",
    "height",
    "weight",
    "bloodGroup",
    "allergies",
    "medicalConditions",
    "emergencyContactName",
    "emergencyContactNumber",
    "emergencyContactRelationship",
    "avatar",
  ];

  // Check for invalid fields
  const invalidFields = Object.keys(updateFields).filter(
    (key) => !allowedFields.includes(key)
  );

  if (invalidFields.length > 0) {
    return res.status(400).json({
      success: false,
      message: `Invalid fields: ${invalidFields.join(", ")}`,
    });
  }

  // Update valid fields
  Object.keys(updateFields).forEach((key) => {
    athlete[key] = updateFields[key];
  });

  await athlete.save();

  res.status(200).json({
    success: true,
    message: "Athlete updated successfully",
    athlete,
  });
});

const getAthleteById = asyncHandler(async (req, res) => {
  const { athleteId } = req.params;

  if (!mongoose.Types.ObjectId.isValid(athleteId)) {
    throw new ApiError(400, "Invalid athlete ID format");
  }

  const athlete = await Athlete.findById(athleteId)
    .populate({
      path: "organization",
      select: "name logo",
    })
    .populate({
      path: "headCoachAssigned",
      select: "name email avatar",
    })
    .populate({
      path: "gymTrainerAssigned",
      select: "name email avatar",
    })
    .populate({
      path: "medicalStaffAssigned",
      select: "name email avatar",
    });

  if (!athlete) {
    throw new ApiError(404, "Athlete not found");
  }

  return res
    .status(200)
    .json(
      new ApiResponse(
        200,
        { athlete },
        "Athlete details retrieved successfully"
      )
    );
});

const getAllAthletes = asyncHandler(async (req, res) => {
  // Extract query parameters
  const {
    page = 1,
    limit = 10,
    sort = "name",
    order = "asc",
    search = "",
    sport = "",
    skillLevel = "",
    gender = "",
    organizationId,
  } = req.query;

  // Build filter object
  const filter = {};

  // Add organization filter based on user role
  if (req.admin) {
    // If admin, filter by their organization
    filter.organization = req.admin.organization;
  } else if (
    organizationId &&
    mongoose.Types.ObjectId.isValid(organizationId)
  ) {
    // If organization ID provided and valid, use it
    filter.organization = organizationId;
  }

  // Add sport filter if provided
  if (sport) {
    filter.sports = { $in: [sport] };
  }

  // Add skill level filter if provided
  if (skillLevel) {
    filter.skillLevel = skillLevel;
  }

  // Add gender filter if provided
  if (gender) {
    filter.gender = gender;
  }

  // Add search functionality (search by name or athleteId)
  if (search) {
    filter.$or = [
      { name: { $regex: search, $options: "i" } },
      { athleteId: { $regex: search, $options: "i" } },
      { email: { $regex: search, $options: "i" } },
    ];
  }

  // Set up pagination
  const pageNumber = parseInt(page, 10);
  const limitNumber = parseInt(limit, 10);
  const skip = (pageNumber - 1) * limitNumber;

  // Set up sort option
  const sortOption = {};
  sortOption[sort] = order === "asc" ? 1 : -1;

  try {
    // Get athletes with pagination, filtering, and sorting
    const athletes = await Athlete.find(filter)
      .sort(sortOption)
      .skip(skip)
      .limit(limitNumber)
      .select("-password -refreshToken")
      .populate({
        path: "organization",
        select: "name logo",
      })
      .populate({
        path: "headCoachAssigned",
        select: "name email",
      });

    // Get total count for pagination info
    const totalAthletes = await Athlete.countDocuments(filter);
    const totalPages = Math.ceil(totalAthletes / limitNumber);

    // Return response
    return res.status(200).json(
      new ApiResponse(
        200,
        {
          athletes,
          pagination: {
            totalAthletes,
            totalPages,
            currentPage: pageNumber,
            limit: limitNumber,
            hasNextPage: pageNumber < totalPages,
            hasPrevPage: pageNumber > 1,
          },
        },
        "Athletes fetched successfully"
      )
    );
  } catch (error) {
    throw new ApiError(500, "Error fetching athletes: " + error.message);
  }
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
    throw new ApiError(
      404,
      `Organization not found with ID: ${organizationId}`
    );
  }

  // Create admin
  const admin = await Admin.create({
    name,
    email,
    password, // Password will be hashed by the model's pre-save hook
    avatar: avatar || "",
    organization: organizationId,
    role: "admin",
  });

  // // Send welcome email
  // await sendEmail({
  //   email: admin.email,
  //   subject: "Welcome to AMS - Admin Account Created",
  //   message: `
  //     <h3>Hi ${admin.name},</h3>
  //     <p>Your admin account has been created in the Athlete Management System.</p>
  //     <p><strong>Email:</strong> ${admin.email}</p>
  //     <p><strong>Password:</strong> ${password}</p>
  //     <p>Please log in and change your password at your earliest convenience.</p>
  //     <p>You have been assigned as an administrator for ${organization.name}.</p>
  //     <p>Thank you!</p>
  //   `,
  // });

  // Send success response (without password)
  res.status(201).json({
    success: true,
    message: "Admin registered successfully",
    admin: {
      _id: admin._id,
      name: admin.name,
      email: admin.email,
      organization: organization.name,
      role: admin.role,
    },
  });
});

const updateAdmin = asyncHandler(async (req, res) => {
  const { adminId } = req.params;
  const { name, avatar, password } = req.body;

  // Validate adminId
  if (!mongoose.Types.ObjectId.isValid(adminId)) {
    throw new ApiError(400, "Invalid Admin ID format");
  }

  // Find existing admin
  const admin = await Admin.findById(adminId);
  if (!admin) {
    throw new ApiError(404, "Admin not found");
  }

  // Update fields if provided
  if (name) admin.name = name;
  if (avatar) admin.avatar = avatar;
  if (password) admin.password = password; // Will be hashed in pre-save hook

  await admin.save();

  res.status(200).json({
    success: true,
    message: "Admin updated successfully",
    admin: {
      _id: admin._id,
      name: admin.name,
      email: admin.email,
      avatar: admin.avatar,
    },
  });
});

const getAllAdmins = asyncHandler(async (req, res) => {
  // Extract query parameters
  const {
    page = 1,
    limit = 10,
    sort = "name",
    order = "asc",
    search = "",
    organizationId,
  } = req.query;

  // Build filter object
  const filter = {};

  // Add organization filter based on user role or query parameter
  if (req.admin && req.admin.role === "superadmin") {
    // Super admins can see all admins or filter by organization
    if (organizationId && mongoose.Types.ObjectId.isValid(organizationId)) {
      filter.organization = organizationId;
    }
  } else if (req.admin) {
    // Regular admins can only see admins from their own organization
    filter.organization = req.admin.organization;
  } else if (
    organizationId &&
    mongoose.Types.ObjectId.isValid(organizationId)
  ) {
    // If no logged-in admin but organization ID provided in query
    filter.organization = organizationId;
  }

  // Add search functionality (search by name or email)
  if (search) {
    filter.$or = [
      { name: { $regex: search, $options: "i" } },
      { email: { $regex: search, $options: "i" } },
    ];
  }

  // Set up pagination
  const pageNumber = parseInt(page, 10);
  const limitNumber = parseInt(limit, 10);
  const skip = (pageNumber - 1) * limitNumber;

  // Set up sort option
  const sortOption = {};
  sortOption[sort] = order === "asc" ? 1 : -1;

  try {
    // Get admins with pagination, filtering, and sorting
    const admins = await Admin.find(filter)
      .sort(sortOption)
      .skip(skip)
      .limit(limitNumber)
      .select("-password -refreshToken") // Exclude sensitive fields
      .populate({
        path: "organization",
        select: "name logo",
      });

    // Get total count for pagination info
    const totalAdmins = await Admin.countDocuments(filter);
    const totalPages = Math.ceil(totalAdmins / limitNumber);

    // Return response
    return res.status(200).json(
      new ApiResponse(
        200,
        {
          admins,
          pagination: {
            totalAdmins,
            totalPages,
            currentPage: pageNumber,
            limit: limitNumber,
            hasNextPage: pageNumber < totalPages,
            hasPrevPage: pageNumber > 1,
          },
        },
        "Administrators fetched successfully"
      )
    );
  } catch (error) {
    throw new ApiError(500, "Error fetching administrators: " + error.message);
  }
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
    designation, // Default value
    profilePhoto,
    idProof,
    certificatesFile,
  } = req.body;
  console.log("Received Coach Data:", req.body);

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
  // if (!organization.sportType.includes(sport)) {
  //   throw new ApiError(
  //     400,
  //     `Invalid sport. Allowed sports: ${organization.sportType.join(", ")}`
  //   );
  // }

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

  // Modify the coach creation part around line 730
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
    certifications: certificationsList.length
      ? certificationsList
      : ["Default Certification"], // Add a default if empty
    previousOrganizations: previousOrgList,
    designation,
    avatar: profilePhoto || "",
    documents: {
      // Use placeholder values instead of empty strings
      idProof: idProof || "placeholder-id-proof.jpg",
      certificates: certificatesFile || "placeholder-certificates.pdf",
    },
    status: "Active",
    joined_date: new Date(),
  });

  // // Send welcome email with login credentials
  // await sendEmail({
  //   email: coach.email,
  //   subject: "Welcome to AMS - Coach Login Details",
  //   message: `
  //     <h3>Hi ${coach.name},</h3>
  //     <p>Your account has been created in the Athlete Management System.</p>
  //     <p><strong>Email:</strong> ${coach.email}</p>
  //     <p><strong>Password:</strong> ${password}</p>
  //     <p>Please log in and change your password at your earliest convenience.</p>
  //     <p>You have been assigned to ${organization.name} as a ${designation} for ${sport}.</p>
  //     <p>For any questions, please contact the system administrator.</p>
  //     <p>Thank you!</p>
  //   `,
  // });

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

const updateCoach = asyncHandler(async (req, res, next) => {
  const { coachId } = req.params;
  const {
    name,
    email,
    contactNumber,
    sport,
    experience,
    designation,
    assignedAthletes,
  } = req.body;

  // Extract uploaded files (if any)
  const profilePhoto = req.files?.profilePhoto
    ? req.files.profilePhoto[0].path
    : null;
  const idProof = req.files?.idProof ? req.files.idProof[0].path : null;
  const certificates = req.files?.certificates
    ? req.files.certificates[0].path
    : null;

  // Validate Coach ID
  if (!mongoose.Types.ObjectId.isValid(coachId)) {
    return next(new ApiError(400, "Invalid Coach ID"));
  }

  // Find the coach
  let coach = await Coach.findById(coachId);
  if (!coach) {
    return next(new ApiError(404, "Coach not found"));
  }

  // 🔹 Check if email is being updated and already exists
  if (email && email !== coach.email) {
    const existingCoach = await Coach.findOne({ email });
    if (existingCoach) {
      return next(new ApiError(400, "Email already in use by another coach"));
    }
  }

  // 🔹 Handle file deletions (Cloudinary cleanup)
  if (profilePhoto && coach.profilePhoto) {
    await cloudinary.uploader.destroy(coach.profilePhoto);
  }
  if (idProof && coach.idProof) {
    await cloudinary.uploader.destroy(coach.idProof);
  }
  if (certificates && coach.certificates) {
    await cloudinary.uploader.destroy(coach.certificates);
  }

  // 🔹 Validate and Assign Athletes
  let validAthletes = [];
  if (assignedAthletes && Array.isArray(assignedAthletes)) {
    validAthletes = await Athlete.find({ _id: { $in: assignedAthletes } });
    if (validAthletes.length !== assignedAthletes.length) {
      return next(new ApiError(400, "Some athletes do not exist"));
    }
  }

  // 🔹 Update Coach Details
  const updatedCoach = await Coach.findByIdAndUpdate(
    coachId,
    {
      $set: {
        name: name || coach.name,
        email: email || coach.email,
        contactNumber: contactNumber || coach.contactNumber,
        sport: sport || coach.sport,
        experience: experience || coach.experience,
        designation: designation || coach.designation,
        assignedAthletes: validAthletes.map((a) => a._id),
        profilePhoto: profilePhoto || coach.profilePhoto,
        idProof: idProof || coach.idProof,
        certificates: certificates || coach.certificates,
      },
    },
    { new: true, runValidators: true }
  );

  res
    .status(200)
    .json(
      new ApiResponse(200, updatedCoach, "Coach details updated successfully")
    );
});

const getAllCoaches = asyncHandler(async (req, res) => {
  // Extract query parameters
  const {
    page = 1,
    limit = 10,
    sort = "name",
    order = "asc",
    search = "",
    sport = "",
    designation = "",
    organizationId,
  } = req.query;

  // Build filter object
  const filter = {};

  // Add organization filter based on user role
  if (req.admin) {
    // If admin, filter by their organization
    filter.organization = req.admin.organization;
  } else if (
    organizationId &&
    mongoose.Types.ObjectId.isValid(organizationId)
  ) {
    // If organization ID provided and valid, use it
    filter.organization = organizationId;
  }

  // Add sport filter if provided
  if (sport) {
    filter.sport = sport;
  }

  // Add designation filter if provided
  if (designation) {
    filter.designation = designation;
  }

  // Add search functionality (search by name or email)
  if (search) {
    filter.$or = [
      { name: { $regex: search, $options: "i" } },
      { email: { $regex: search, $options: "i" } },
      { contactNumber: { $regex: search, $options: "i" } },
    ];
  }

  // Set up pagination
  const pageNumber = parseInt(page, 10);
  const limitNumber = parseInt(limit, 10);
  const skip = (pageNumber - 1) * limitNumber;

  // Set up sort option
  const sortOption = {};
  sortOption[sort] = order === "asc" ? 1 : -1;

  try {
    // Get coaches with pagination, filtering, and sorting
    const coaches = await Coach.find(filter)
      .sort(sortOption)
      .skip(skip)
      .limit(limitNumber)
      .select("-password -refreshToken") // Exclude sensitive fields
      .populate({
        path: "organization",
        select: "name logo",
      })
      .populate({
        path: "assignedAthletes",
        select: "name athleteId avatar",
        options: { limit: 5 }, // Limit number of populated athletes
      });

    // Get total count for pagination info
    const totalCoaches = await Coach.countDocuments(filter);
    const totalPages = Math.ceil(totalCoaches / limitNumber);

    // Return response
    return res.status(200).json(
      new ApiResponse(
        200,
        {
          coaches,
          pagination: {
            totalCoaches,
            totalPages,
            currentPage: pageNumber,
            limit: limitNumber,
            hasNextPage: pageNumber < totalPages,
            hasPrevPage: pageNumber > 1,
          },
        },
        "Coaches fetched successfully"
      )
    );
  } catch (error) {
    throw new ApiError(500, "Error fetching coaches: " + error.message);
  }
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

const getOrganizationStats = asyncHandler(async (req, res) => {
  try {
    // Get organization ID either from the authenticated admin or from query params
    let organizationId;

    if (req.admin) {
      // If request comes from authenticated admin, use their organization
      organizationId = req.admin.organization;
    } else if (
      req.query.organizationId &&
      mongoose.Types.ObjectId.isValid(req.query.organizationId)
    ) {
      // Otherwise, if provided in query, use that
      organizationId = req.query.organizationId;
    } else {
      throw new ApiError(400, "Valid organization ID is required");
    }

    // Count total number of entities for the organization
    const [adminCount, coachCount, athleteCount, sponsorCount] =
      await Promise.all([
        Admin.countDocuments({ organization: organizationId }),
        Coach.countDocuments({ organization: organizationId }),
        Athlete.countDocuments({ organization: organizationId }),
        // If you have a Sponsor model, use the line below. Otherwise, just return 0
        Sponsor.countDocuments({ organization: organizationId }),
        // Promise.resolve(0) // Placeholder for sponsors if you don't have a model yet
      ]);

    return res.status(200).json(
      new ApiResponse(
        200,
        {
          stats: {
            adminCount: adminCount || 0,
            coachCount: coachCount || 0,
            athleteCount: athleteCount || 0,
            sponsorCount: sponsorCount || 0,
            // You can add more statistics here as needed
          },
        },
        "Organization statistics fetched successfully"
      )
    );
  } catch (error) {
    throw new ApiError(
      500,
      "Error fetching organization statistics: " + error.message
    );
  }
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

const sendSponsorInvitation = asyncHandler(async (req, res, next) => {
  const { requestType, companyName, contactPerson, email, phone, notes } =
    req.body;
  const organizationId = req.admin.organization;

  if (!requestType || !companyName || !contactPerson || !email || !phone) {
    return next(
      new ApiError(
        400,
        "All fields are required for manual sponsor invitations"
      )
    );
  }

  // Check if a sponsor already exists with this email
  let sponsor = await Sponsor.findOne({ email });

  if (!sponsor) {
    // If sponsor does not exist, create a new sponsor entry
    sponsor = await Sponsor.create({
      companyName,
      contactPerson,
      email,
      phone,
    });
  }

  // Check if a pending request already exists for this sponsor
  const existingRequest = await SponsorRequest.findOne({
    organization: organizationId,
    sponsor: sponsor._id,
    status: "Pending",
  });
  if (existingRequest) {
    return next(
      new ApiError(400, "A pending request already exists for this sponsor")
    );
  }

  // Create a sponsor request linked to the existing/new sponsor
  const newRequest = await SponsorRequest.create({
    organization: organizationId,
    sponsor: sponsor._id, // Linking request to sponsor
    requestType,
    companyName,
    contactPerson,
    email,
    phone,
    notes,
    status: "Pending",
  });

  res
    .status(201)
    .json(
      new ApiResponse(201, newRequest, "Sponsor invitation sent successfully!")
    );
});

const sendPotentialSponsorRequest = asyncHandler(async (req, res, next) => {
  const { sponsorId, requestType, title, message } = req.body;
  const organizationId = req.admin.organization;

  if (!sponsorId || !requestType || !title || !message) {
    return next(
      new ApiError(
        400,
        "Sponsor ID, request type, title, and message are required"
      )
    );
  }

  const sponsor = await Sponsor.findById(sponsorId);
  if (!sponsor) {
    return next(new ApiError(404, "Sponsor not found"));
  }

  // Check if a pending request already exists for this sponsor
  const existingRequest = await SponsorRequest.findOne({
    organization: organizationId,
    sponsor: sponsorId,
    status: "Pending",
  });
  if (existingRequest) {
    return next(
      new ApiError(400, "A pending request already exists for this sponsor")
    );
  }

  const newRequest = await SponsorRequest.create({
    sponsor: sponsorId,
    organization: organizationId,
    requestType,
    title,
    message,
    status: "Pending",
  });

  res
    .status(201)
    .json(
      new ApiResponse(201, newRequest, "Sponsor request sent successfully!")
    );
});

const getPotentialSponsors = asyncHandler(async (req, res, next) => {
  const organizationId = req.admin.organization;

  // Get sponsors that are NOT already sponsoring this organization
  const potentialSponsors = await Sponsor.find({
    sponsoredOrganizations: { $ne: organizationId },
  }).select("Name contactName contactNo email");

  if (!potentialSponsors.length) {
    return next(new ApiError(404, "No potential sponsors found"));
  }

  res
    .status(200)
    .json(
      new ApiResponse(
        200,
        potentialSponsors,
        "Potential sponsors retrieved successfully"
      )
    );
});

const getCurrentSponsors = asyncHandler(async (req, res, next) => {
  const organizationId = req.admin.organization; // Get the admin's organization ID

  const currentSponsors = await Sponsor.find({
    sponsoredOrganizations: organizationId,
  }).select("companyName contactPerson email phone");

  res
    .status(200)
    .json(
      new ApiResponse(
        200,
        currentSponsors,
        "Current sponsors retrieved successfully"
      )
    );
});

const deleteSponsorRequest = asyncHandler(async (req, res, next) => {
  const sponsor = await Sponsor.findById(req.params.sponsorId);

  if (!sponsor) {
    return next(new ApiError(404, "Sponsor request not found"));
  }

  await Sponsor.findByIdAndDelete(req.params.sponsorId);
  res
    .status(200)
    .json(new ApiResponse(200, null, "Sponsor request removed successfully"));
});

const getRequestsLog = asyncHandler(async (req, res, next) => {
  const organizationId = req.admin.organization;
  const { status, page = 1, limit = 10 } = req.query;

  // Filter by status if provided
  const filter = { organization: organizationId };
  if (status && ["Pending", "Accepted", "Declined"].includes(status)) {
    filter.status = status;
  }

  // Paginate results
  const requests = await SponsorRequest.find(filter)
    .populate("sponsor", "companyName contactPerson email phone")
    .sort({ createdAt: -1 }) // Newest requests first
    .skip((page - 1) * limit)
    .limit(parseInt(limit));

  // Count total requests for pagination metadata
  const totalRequests = await SponsorRequest.countDocuments(filter);

  res
    .status(200)
    .json(
      new ApiResponse(
        200,
        { requests, totalRequests },
        "Fetched requests log successfully!"
      )
    );
});

const addSportStats = asyncHandler(async (req, res, next) => {
  const { sport, stats } = req.body;

  // Check if sport already exists (predefined or custom)
  let sportEntry = await SportStats.findOne({ sport });

  if (!sportEntry) {
    // If it's a new custom sport, allow creation
    sportEntry = new SportStats({ sport, stats: [...new Set(stats)] });
  } else {
    // Merge predefined and custom stats
    sportEntry.stats = [...new Set([...sportEntry.stats, ...stats])];
  }

  await sportEntry.save();

  res
    .status(201)
    .json(new ApiResponse(201, sportEntry, "Sport stats updated successfully"));
});

const getSportStats = asyncHandler(async (req, res, next) => {
  const { sportId } = req.params;
  const sportStats = await SportStats.findOne({
    $or: [{ _id: sportId }, { sport: sportId }],
  });

  if (!sportStats) {
    return next(new ApiError(404, "Sport stats not found"));
  }

  res.status(200).json(
    new ApiResponse(
      200,
      {
        sport: sportStats.sport,
        stats: sportStats.stats,
      },
      "Sport stats retrieved successfully"
    )
  );
});

const addAthleteStats = asyncHandler(async (req, res, next) => {
  const { athleteId, sport, stats } = req.body;

  // 1️⃣ Ensure athleteId is provided
  if (!athleteId) {
    return next(new ApiError(400, "Athlete ID is required"));
  }

  // 2️⃣ Validate athlete existence
  const athleteExists = await Athlete.findById(athleteId);
  if (!athleteExists) {
    return next(new ApiError(404, "Athlete not found"));
  }

  // 3️⃣ Restrict Coaches - Only update their assigned athletes
  if (req.coach) {
    const coach = await Coach.findById(req.coach._id);
    if (!coach) {
      return next(new ApiError(404, "Coach not found"));
    }

    // Check if athlete is assigned to this coach
    if (!coach.assignedAthletes.includes(athleteId)) {
      return next(
        new ApiError(403, "You can only update stats for assigned athletes")
      );
    }
  }

  // 4️⃣ Validate sport
  if (!Object.values(SPORTS_ENUM).includes(sport)) {
    return next(new ApiError(400, "Invalid sport type"));
  }

  // Find the sport stats or create a new one if it doesn’t exist
  let sportStats = await SportStats.findOne({ sport });
  if (!sportStats) {
    sportStats = new SportStats({ sport, stats: [] });
  }

  // Find athlete stats, or create new if it doesn’t exist
  let athleteStats = await AthleteStats.findOne({ athlete: athleteId, sport });
  if (!athleteStats) {
    athleteStats = new AthleteStats({
      athlete: athleteId,
      sport,
      stats: sportStats.stats.map((stat) => ({ statName: stat, value: 0 })),
    });
  }

  let newCustomStats = [];

  stats.forEach(({ statName, value }) => {
    const existingStat = athleteStats.stats.find(
      (stat) => stat.statName === statName
    );
    if (existingStat) {
      existingStat.value = value;
    } else {
      athleteStats.stats.push({ statName, value });
      newCustomStats.push(statName);
    }
  });

  await athleteStats.save();

  // Update SportStats with new custom stats before saving athlete stats
  if (newCustomStats.length > 0) {
    sportStats.stats = [...new Set([...sportStats.stats, ...newCustomStats])];
    await sportStats.save();
  }

  res
    .status(200)
    .json(
      new ApiResponse(200, athleteStats, "Athlete stats updated successfully")
    );
});

export {
  registerOrganizationAthlete,
  updateOrganizationAthlete,
  getAllAthletes,
  registerAdmin,
  updateAdmin,
  registerCoach,
  updateCoach,
  getAllUsers,
  generateAccessAndRefreshToken,
  logoutAdmin,
  getAdminProfile,
  getRpeInsights,
  getAllAdmins,
  getAllCoaches,
  getAthleteById,
  getPotentialSponsors,
  getCurrentSponsors,
  deleteSponsorRequest,
  getRequestsLog,
  sendSponsorInvitation,
  sendPotentialSponsorRequest,

  //stats
  addSportStats,
  getSportStats,
  addAthleteStats,
  getOrganizationStats,
};
