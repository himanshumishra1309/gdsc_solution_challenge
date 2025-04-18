import asyncHandler from "../utils/asyncHandler.js";
import ApiError from "../utils/ApiError.js";
import { Admin } from "../models/admin.model.js";
import { Athlete } from "../models/athlete.model.js";
import { Coach } from "../models/coach.model.js";
import { Organization } from "../models/organization.model.js";
import { Sponsor } from "../models/sponsor.model.js";

import ApiResponse from "../utils/ApiResponse.js";
import { CustomForm } from "../models/customForm.model.js";
import { SponsorRequest } from "../models/SponsorRequest.model.js";
import { AthleteStats } from "../models/AthleteStats.model.js";
import { SportStats } from "../models/SportStats.model.js";

import DEFAULT_SPORT_STATS from "../utils/defaultStats.js";
import SPORTS_ENUM from "../utils/sportsEnum.js";
import mongoose from "mongoose";

const registerOrganizationAthlete = asyncHandler(async (req, res) => {
  const {
    name,
    dob,
    gender,
    nationality,
    address,
    phoneNumber,

    schoolName,
    year,
    studentId,
    schoolEmail,
    schoolWebsite,

    sports,
    skillLevel,
    trainingStartDate,
    positions,
    dominantHand,

    headCoachAssigned,
    gymTrainerAssigned,
    medicalStaffAssigned,

    height,
    weight,
    bloodGroup,
    allergies,
    medicalConditions,

    emergencyContactName,
    emergencyContactNumber,
    emergencyContactRelationship,

    email,
    password,

    organizationId,

    athleteId,
  } = req.body;

  console.log("response: ", req.body);

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

  if (!mongoose.Types.ObjectId.isValid(organizationId)) {
    throw new ApiError(400, "Invalid Organization ID format");
  }

  const organization = await Organization.findById(organizationId);
  if (!organization) {
    throw new ApiError(
      404,
      `Organization not found with ID: ${organizationId}`
    );
  }

  let existingAthlete = null;

  if (athleteId && mongoose.Types.ObjectId.isValid(athleteId)) {
    existingAthlete = await Athlete.findById(athleteId);

    if (existingAthlete && existingAthlete.email !== email) {
      const duplicateEmail = await Athlete.findOne({ email });
      if (duplicateEmail) {
        throw new ApiError(400, "Email is already assigned to another athlete");
      }
    }
  } else {
    existingAthlete = await Athlete.findOne({ email });
    if (existingAthlete) {
      throw new ApiError(400, "Athlete with this email already exists");
    }
  }

  let athleteIdCode;

  if (!existingAthlete) {
    const currentDate = new Date();
    const yearPrefix = currentDate.getFullYear().toString().slice(-2);
    const orgPrefix = organization.name.substring(0, 3).toUpperCase();

    const lastAthlete = await Athlete.findOne({
      organization: organizationId,
    }).sort({ createdAt: -1 });

    let sequentialNumber = 1;
    if (lastAthlete && lastAthlete.athleteId) {
      const match = lastAthlete.athleteId.match(/\d+$/);
      if (match) {
        sequentialNumber = parseInt(match[0]) + 1;
      }
    }

    const paddedNumber = sequentialNumber.toString().padStart(4, "0");

    athleteIdCode = `${orgPrefix}-${yearPrefix}-${paddedNumber}`;
  } else {
    athleteIdCode = existingAthlete.athleteId;
  }

  let avatarUrl = null;
  let uploadSchoolIdUrl = null;
  let latestMarksheetUrl = null;

  if (req.files) {
    if (req.files.avatar) {
      avatarUrl = `/uploads/avatars/${Date.now()}-${req.files.avatar[0].originalname}`;
    }

    if (req.files.uploadSchoolId) {
      uploadSchoolIdUrl = `/uploads/school-ids/${Date.now()}-${req.files.uploadSchoolId[0].originalname}`;
    }

    if (req.files.latestMarksheet) {
      latestMarksheetUrl = `/uploads/marksheets/${Date.now()}-${req.files.latestMarksheet[0].originalname}`;
    }
  }

  const positionsMap = new Map();
  if (positions) {
    Object.keys(positions).forEach((sport) => {
      positionsMap.set(sport, positions[sport]);
    });
  }

  let athlete;

  if (existingAthlete) {
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

        ...(req.body.updatePassword && { password }),
        organization: organizationId,
      },
      { new: true }
    );
  } else {
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

  const birthDate = new Date(dob);
  const today = new Date();
  let age = today.getFullYear() - birthDate.getFullYear();
  const m = today.getMonth() - birthDate.getMonth();
  if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
    age--;
  }

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
  const updateFields = req.body;

  console.log("🛠 Incoming update request:", updateFields);

  if (!mongoose.Types.ObjectId.isValid(athleteId)) {
    throw new ApiError(400, "Invalid Athlete ID format");
  }

  const athlete = await Athlete.findById(athleteId);
  if (!athlete) {
    throw new ApiError(404, "Athlete not found");
  }

  console.log("📌 Current Athlete Data:", athlete);

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

  const invalidFields = Object.keys(updateFields).filter(
    (key) => !allowedFields.includes(key)
  );

  if (invalidFields.length > 0) {
    return res.status(400).json({
      success: false,
      message: `Invalid fields: ${invalidFields.join(", ")}`,
    });
  }

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

  const filter = {};

  if (req.admin) {
    filter.organization = req.admin.organization;
  } else if (
    organizationId &&
    mongoose.Types.ObjectId.isValid(organizationId)
  ) {
    filter.organization = organizationId;
  }

  if (sport) {
    filter.sports = { $in: [sport] };
  }

  if (skillLevel) {
    filter.skillLevel = skillLevel;
  }

  if (gender) {
    filter.gender = gender;
  }

  if (search) {
    filter.$or = [
      { name: { $regex: search, $options: "i" } },
      { athleteId: { $regex: search, $options: "i" } },
      { email: { $regex: search, $options: "i" } },
    ];
  }

  const pageNumber = parseInt(page, 10);
  const limitNumber = parseInt(limit, 10);
  const skip = (pageNumber - 1) * limitNumber;

  const sortOption = {};
  sortOption[sort] = order === "asc" ? 1 : -1;

  try {
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

    const totalAthletes = await Athlete.countDocuments(filter);
    const totalPages = Math.ceil(totalAthletes / limitNumber);

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

  if (!name || !email || !password || !organizationId) {
    throw new ApiError(400, "All required fields must be provided");
  }

  const existingAdmin = await Admin.findOne({ email });
  if (existingAdmin) {
    throw new ApiError(400, "Admin with this email already exists");
  }

  if (!mongoose.Types.ObjectId.isValid(organizationId)) {
    throw new ApiError(400, "Invalid Organization ID format");
  }

  const organization = await Organization.findById(organizationId);
  if (!organization) {
    throw new ApiError(
      404,
      `Organization not found with ID: ${organizationId}`
    );
  }

  const admin = await Admin.create({
    name,
    email,
    password,
    avatar: avatar || "",
    organization: organizationId,
    role: "admin",
  });

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

  if (!mongoose.Types.ObjectId.isValid(adminId)) {
    throw new ApiError(400, "Invalid Admin ID format");
  }

  const admin = await Admin.findById(adminId);
  if (!admin) {
    throw new ApiError(404, "Admin not found");
  }

  if (name) admin.name = name;
  if (avatar) admin.avatar = avatar;
  if (password) admin.password = password;

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
  const {
    page = 1,
    limit = 10,
    sort = "name",
    order = "asc",
    search = "",
    organizationId,
  } = req.query;

  const filter = {};

  if (req.admin && req.admin.role === "superadmin") {
    if (organizationId && mongoose.Types.ObjectId.isValid(organizationId)) {
      filter.organization = organizationId;
    }
  } else if (req.admin) {
    filter.organization = req.admin.organization;
  } else if (
    organizationId &&
    mongoose.Types.ObjectId.isValid(organizationId)
  ) {
    filter.organization = organizationId;
  }

  if (search) {
    filter.$or = [
      { name: { $regex: search, $options: "i" } },
      { email: { $regex: search, $options: "i" } },
    ];
  }

  const pageNumber = parseInt(page, 10);
  const limitNumber = parseInt(limit, 10);
  const skip = (pageNumber - 1) * limitNumber;

  const sortOption = {};
  sortOption[sort] = order === "asc" ? 1 : -1;

  try {
    const admins = await Admin.find(filter)
      .sort(sortOption)
      .skip(skip)
      .limit(limitNumber)
      .select("-password -refreshToken")
      .populate({
        path: "organization",
        select: "name logo",
      });

    const totalAdmins = await Admin.countDocuments(filter);
    const totalPages = Math.ceil(totalAdmins / limitNumber);

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
    designation,
    profilePhoto,
    idProof,
    certificatesFile,
  } = req.body;
  console.log("Received Coach Data:", req.body);

  console.log("Received Organization ID:", organizationId);

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

  if (!mongoose.Types.ObjectId.isValid(organizationId)) {
    throw new ApiError(400, "Invalid Organization ID format");
  }
  const orgId = new mongoose.Types.ObjectId(organizationId);

  const organization = await Organization.findById(orgId);
  console.log("Organization Query Result:", organization);

  if (!organization) {
    throw new ApiError(
      404,
      `Organization not found with ID: ${organizationId}`
    );
  }

  const existingCoach = await Coach.findOne({ email });
  if (existingCoach) {
    throw new ApiError(400, "Coach with this email already exists");
  }

  const dobDate = new Date(dob);
  if (isNaN(dobDate.getTime())) {
    throw new ApiError(400, "Invalid date of birth format");
  }

  const experienceYears = parseInt(experience);
  if (isNaN(experienceYears)) {
    throw new ApiError(400, "Experience must be a valid number");
  }

  const certificationsList = certifications
    ? certifications.split(",").map((cert) => cert.trim())
    : [];
  const previousOrgList = previousOrganizations
    ? previousOrganizations.split(",").map((org) => org.trim())
    : [];

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
      : ["Default Certification"],
    previousOrganizations: previousOrgList,
    designation,
    avatar: profilePhoto || "",
    documents: {
      idProof: idProof || "placeholder-id-proof.jpg",
      certificates: certificatesFile || "placeholder-certificates.pdf",
    },
    status: "Active",
    joined_date: new Date(),
  });

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

  const profilePhoto = req.files?.profilePhoto
    ? req.files.profilePhoto[0].path
    : null;
  const idProof = req.files?.idProof ? req.files.idProof[0].path : null;
  const certificates = req.files?.certificates
    ? req.files.certificates[0].path
    : null;

  if (!mongoose.Types.ObjectId.isValid(coachId)) {
    return next(new ApiError(400, "Invalid Coach ID"));
  }

  let coach = await Coach.findById(coachId);
  if (!coach) {
    return next(new ApiError(404, "Coach not found"));
  }

  if (email && email !== coach.email) {
    const existingCoach = await Coach.findOne({ email });
    if (existingCoach) {
      return next(new ApiError(400, "Email already in use by another coach"));
    }
  }

  if (profilePhoto && coach.profilePhoto) {
    await cloudinary.uploader.destroy(coach.profilePhoto);
  }
  if (idProof && coach.idProof) {
    await cloudinary.uploader.destroy(coach.idProof);
  }
  if (certificates && coach.certificates) {
    await cloudinary.uploader.destroy(coach.certificates);
  }

  let validAthletes = [];
  if (assignedAthletes && Array.isArray(assignedAthletes)) {
    validAthletes = await Athlete.find({ _id: { $in: assignedAthletes } });
    if (validAthletes.length !== assignedAthletes.length) {
      return next(new ApiError(400, "Some athletes do not exist"));
    }
  }

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

  const filter = {};

  if (req.admin) {
    filter.organization = req.admin.organization;
  } else if (
    organizationId &&
    mongoose.Types.ObjectId.isValid(organizationId)
  ) {
    filter.organization = organizationId;
  }

  if (sport) {
    filter.sport = sport;
  }

  if (designation) {
    filter.designation = designation;
  }

  if (search) {
    filter.$or = [
      { name: { $regex: search, $options: "i" } },
      { email: { $regex: search, $options: "i" } },
      { contactNumber: { $regex: search, $options: "i" } },
    ];
  }

  const pageNumber = parseInt(page, 10);
  const limitNumber = parseInt(limit, 10);
  const skip = (pageNumber - 1) * limitNumber;

  const sortOption = {};
  sortOption[sort] = order === "asc" ? 1 : -1;

  try {
    const coaches = await Coach.find(filter)
      .sort(sortOption)
      .skip(skip)
      .limit(limitNumber)
      .select("-password -refreshToken")
      .populate({
        path: "organization",
        select: "name logo",
      })
      .populate({
        path: "assignedAthletes",
        select: "name athleteId avatar",
        options: { limit: 5 },
      });

    const totalCoaches = await Coach.countDocuments(filter);
    const totalPages = Math.ceil(totalCoaches / limitNumber);

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
    let organizationId;

    if (req.admin) {
      organizationId = req.admin.organization;
    } else if (
      req.query.organizationId &&
      mongoose.Types.ObjectId.isValid(req.query.organizationId)
    ) {
      organizationId = req.query.organizationId;
    } else {
      throw new ApiError(400, "Valid organization ID is required");
    }

    const [adminCount, coachCount, athleteCount, sponsorCount] =
      await Promise.all([
        Admin.countDocuments({ organization: organizationId }),
        Coach.countDocuments({ organization: organizationId }),
        Athlete.countDocuments({ organization: organizationId }),

        Sponsor.countDocuments({ organization: organizationId }),
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

  let sponsor = await Sponsor.findOne({ email });

  if (!sponsor) {
    sponsor = await Sponsor.create({
      companyName,
      contactPerson,
      email,
      phone,
    });
  }

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

  const newRequest = await SponsorRequest.create({
    organization: organizationId,
    sponsor: sponsor._id,
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
  const organizationId = req.admin.organization;

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

  const filter = { organization: organizationId };
  if (status && ["Pending", "Accepted", "Declined"].includes(status)) {
    filter.status = status;
  }

  const requests = await SponsorRequest.find(filter)
    .populate("sponsor", "companyName contactPerson email phone")
    .sort({ createdAt: -1 })
    .skip((page - 1) * limit)
    .limit(parseInt(limit));

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

  let sportEntry = await SportStats.findOne({ sport });

  if (!sportEntry) {
    sportEntry = new SportStats({ sport, stats: [...new Set(stats)] });
  } else {
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

  if (!athleteId) {
    return next(new ApiError(400, "Athlete ID is required"));
  }

  const athleteExists = await Athlete.findById(athleteId);
  if (!athleteExists) {
    return next(new ApiError(404, "Athlete not found"));
  }

  if (req.coach) {
    const coach = await Coach.findById(req.coach._id);
    if (!coach) {
      return next(new ApiError(404, "Coach not found"));
    }

    if (!coach.assignedAthletes.includes(athleteId)) {
      return next(
        new ApiError(403, "You can only update stats for assigned athletes")
      );
    }
  }

  if (!Object.values(SPORTS_ENUM).includes(sport)) {
    return next(new ApiError(400, "Invalid sport type"));
  }

  let sportStats = await SportStats.findOne({ sport });
  if (!sportStats) {
    sportStats = new SportStats({ sport, stats: [] });
  }

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

const getAthleteFullDetails = asyncHandler(async (req, res) => {
  const { athleteId } = req.params;
  
  // Validate athlete ID
  if (!mongoose.Types.ObjectId.isValid(athleteId)) {
    throw new ApiError(400, "Invalid athlete ID format");
  }
  
  // Get the admin's organization ID
  const organizationId = req.admin.organization;
  
  try {
    // Fetch athlete basic information first
    const athlete = await Athlete.findById(athleteId);
    
    // Verify athlete exists
    if (!athlete) {
      throw new ApiError(404, "Athlete not found");
    }
    
    // Verify the admin has access to this athlete's data
    if (athlete.organization.toString() !== organizationId.toString()) {
      throw new ApiError(403, "You don't have permission to access this athlete's data");
    }
    
    // Populate fields safely with separate queries
    const populatedData = {
      organization: null,
      headCoachAssigned: null,
      gymTrainerAssigned: null,
      medicalStaffAssigned: null
    };
    
    // Populate organization
    try {
      if (athlete.organization) {
        const org = await Organization.findById(athlete.organization).select("name logo");
        populatedData.organization = org;
      }
    } catch (err) {
      console.error("Error populating organization:", err);
    }
    
    // Populate headCoachAssigned
    try {
      if (athlete.headCoachAssigned) {
        const coach = await Coach.findById(athlete.headCoachAssigned).select("name email avatar contactNumber");
        populatedData.headCoachAssigned = coach;
      }
    } catch (err) {
      console.error("Error populating headCoach:", err);
    }
    
    // Populate gymTrainerAssigned
    try {
      if (athlete.gymTrainerAssigned) {
        const trainer = await Coach.findById(athlete.gymTrainerAssigned).select("name email avatar contactNumber");
        populatedData.gymTrainerAssigned = trainer;
      }
    } catch (err) {
      console.error("Error populating gymTrainer:", err);
    }
    
    // Don't attempt to populate medicalStaffAssigned if the model doesn't exist
    
    // Get athleteStats if available
    let athleteStats = [];
    try {
      athleteStats = await AthleteStats.find({ athlete: athleteId });
    } catch (err) {
      console.error("Error fetching athlete stats:", err);
    }
    
    // Format positions from Map to Object
    const positions = {};
    if (athlete.positions && athlete.positions.size > 0) {
      for (const [sport, position] of athlete.positions.entries()) {
        positions[sport] = position;
      }
    }
    
    // Calculate training duration
    const trainingStartDate = new Date(athlete.trainingStartDate);
    const today = new Date();
    let trainingYears = today.getFullYear() - trainingStartDate.getFullYear();
    const trainingMonths = today.getMonth() - trainingStartDate.getMonth();
    if (trainingMonths < 0 || (trainingMonths === 0 && today.getDate() < trainingStartDate.getDate())) {
      trainingYears--;
    }
    
    // Format complete athlete details
    const athleteDetails = {
      basicInfo: {
        id: athlete._id,
        athleteId: athlete.athleteId,
        name: athlete.name,
        email: athlete.email,
        age: athlete.age, // Virtual field from schema
        dob: athlete.dob,
        gender: athlete.gender,
        nationality: athlete.nationality,
        address: athlete.address,
        phoneNumber: athlete.phoneNumber,
        avatar: athlete.avatar
      },
      schoolInfo: {
        schoolName: athlete.schoolName,
        year: athlete.year,
        studentId: athlete.studentId,
        schoolEmail: athlete.schoolEmail || "Not provided",
        schoolWebsite: athlete.schoolWebsite || "Not provided",
        uploadSchoolId: athlete.uploadSchoolId,
        latestMarksheet: athlete.latestMarksheet
      },
      sportsInfo: {
        sports: athlete.sports,
        skillLevel: athlete.skillLevel,
        trainingStartDate: athlete.trainingStartDate,
        trainingDuration: `${trainingYears} years, ${Math.abs(trainingMonths)} months`,
        positions: positions,
        dominantHand: athlete.dominantHand || "Not specified",
        stats: athleteStats || []
      },
      staffAssignments: {
        headCoach: populatedData.headCoachAssigned || null,
        gymTrainer: populatedData.gymTrainerAssigned || null,
        medicalStaff: null // We're not attempting to populate this
      },
      medicalInfo: {
        height: athlete.height, // in cm
        weight: athlete.weight, // in kg
        bmi: (athlete.weight / Math.pow(athlete.height/100, 2)).toFixed(2),
        bloodGroup: athlete.bloodGroup || "Not recorded",
        allergies: athlete.allergies.length > 0 ? athlete.allergies : ["None reported"],
        medicalConditions: athlete.medicalConditions.length > 0 ? athlete.medicalConditions : ["None reported"]
      },
      emergencyContact: {
        name: athlete.emergencyContactName,
        number: athlete.emergencyContactNumber,
        relationship: athlete.emergencyContactRelationship
      },
      organization: {
        id: athlete.organization,
        name: populatedData.organization?.name || "Unknown Organization",
        logo: populatedData.organization?.logo || null
      },
      metadata: {
        createdAt: athlete.createdAt,
        updatedAt: athlete.updatedAt
      }
    };
    
    return res.status(200).json(
      new ApiResponse(
        200,
        { athlete: athleteDetails },
        "Athlete details retrieved successfully"
      )
    );
  } catch (error) {
    if (error instanceof ApiError) {
      throw error;
    }
    throw new ApiError(500, "Error fetching athlete details: " + error.message);
  }
});

const getAllSponsors = asyncHandler(async (req, res) => {
  const {
    page = 1,
    limit = 10,
    sort = "companyName",
    order = "asc",
    search = "",
    status = "", // "active", "potential", "all"
  } = req.query;

  // Get the admin's organization ID
  const organizationId = req.admin.organization;

  // Build filter based on query params
  const filter = {};
  
  // Filter by sponsorship status if specified
  if (status === "active") {
    filter.sponsoredOrganizations = organizationId;
  } else if (status === "potential") {
    filter.sponsoredOrganizations = { $ne: organizationId };
  }
  
  // Add search functionality
  if (search) {
    filter.$or = [
      { companyName: { $regex: search, $options: "i" } },
      { contactPerson: { $regex: search, $options: "i" } },
      { email: { $regex: search, $options: "i" } },
      { phone: { $regex: search, $options: "i" } }
    ];
  }

  // Set up pagination
  const pageNumber = parseInt(page, 10);
  const limitNumber = parseInt(limit, 10);
  const skip = (pageNumber - 1) * limitNumber;

  // Set up sorting
  const sortOption = {};
  sortOption[sort] = order === "asc" ? 1 : -1;

  try {
    // Fetch sponsors with pagination and sorting
    const sponsors = await Sponsor.find(filter)
      .sort(sortOption)
      .skip(skip)
      .limit(limitNumber)
      .select("companyName contactPerson email phone logo industry sponsoredOrganizations interestLevel");

    // Add isCurrentSponsor flag to each sponsor
    const sponsorsWithStatus = sponsors.map(sponsor => {
      const sponsorObj = sponsor.toObject();
      sponsorObj.isCurrentSponsor = sponsor.sponsoredOrganizations?.includes(organizationId);
      return sponsorObj;
    });
    
    // Get total count for pagination
    const totalSponsors = await Sponsor.countDocuments(filter);
    const totalPages = Math.ceil(totalSponsors / limitNumber);

    // Return response
    return res.status(200).json(
      new ApiResponse(
        200,
        {
          sponsors: sponsorsWithStatus,
          pagination: {
            totalSponsors,
            totalPages,
            currentPage: pageNumber,
            limit: limitNumber,
            hasNextPage: pageNumber < totalPages,
            hasPrevPage: pageNumber > 1,
          },
        },
        "Sponsors retrieved successfully"
      )
    );
  } catch (error) {
    throw new ApiError(500, "Error fetching sponsors: " + error.message);
  }
});

export {
  registerOrganizationAthlete,
  updateOrganizationAthlete,
  getAllSponsors,
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
