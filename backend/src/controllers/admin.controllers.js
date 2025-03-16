import asyncHandler from "../utils/asyncHandler.js";

import ApiError from "../utils/ApiError.js"
import  {Admin} from "../models/admin.model.js"
import {Athlete} from "../models/athlete.model.js"
import {Coach} from "../models/coach.model.js"
import {Organization} from "../models/organization.model.js"
import {sendEmail} from "../utils/sendEmail.js"
import {RPE} from "../models/rpe.model.js"
import ApiResponse from "../utils/ApiResponse.js"
import {CustomForm} from "../models/customForm.model.js"

import mongoose from "mongoose"




import jwt from 'jsonwebtoken'



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
    athleteId
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
    throw new ApiError(404, `Organization not found with ID: ${organizationId}`);
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
      organization: organizationId 
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
    const paddedNumber = sequentialNumber.toString().padStart(4, '0');
    
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
    Object.keys(positions).forEach(sport => {
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
        headCoachAssigned: headCoachAssigned || existingAthlete.headCoachAssigned,
        gymTrainerAssigned: gymTrainerAssigned || existingAthlete.gymTrainerAssigned,
        medicalStaffAssigned: medicalStaffAssigned || existingAthlete.medicalStaffAssigned,
        height: Number(height),
        weight: Number(weight),
        bloodGroup: bloodGroup || existingAthlete.bloodGroup,
        allergies: allergies ? (Array.isArray(allergies) ? allergies : [allergies]) : existingAthlete.allergies,
        medicalConditions: medicalConditions ? 
          (Array.isArray(medicalConditions) ? medicalConditions : [medicalConditions]) : 
          existingAthlete.medicalConditions,
        emergencyContactName,
        emergencyContactNumber,
        emergencyContactRelationship,
        email,
        // Don't update password unless specifically requested
        ...(req.body.updatePassword && { password }),
        organization: organizationId
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
      allergies: allergies ? (Array.isArray(allergies) ? allergies : [allergies]) : [],
      medicalConditions: medicalConditions ? 
        (Array.isArray(medicalConditions) ? medicalConditions : [medicalConditions]) : [],
      emergencyContactName,
      emergencyContactNumber,
      emergencyContactRelationship,
      email,
      password,
      role: "athlete",
      organization: organizationId
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
  res.status(201).json(new ApiResponse(
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
          name: organization.name
        }
      }
    },
    existingAthlete ? "Athlete updated successfully." : "Athlete registered successfully. Welcome email sent."
  ));
});

const getAthleteById = asyncHandler(async (req, res) => {
  const { athleteId } = req.params;

  if (!mongoose.Types.ObjectId.isValid(athleteId)) {
    throw new ApiError(400, "Invalid athlete ID format");
  }

  const athlete = await Athlete.findById(athleteId)
    .populate({
      path: 'organization',
      select: 'name logo'
    })
    .populate({
      path: 'headCoachAssigned',
      select: 'name email avatar'
    })
    .populate({
      path: 'gymTrainerAssigned',
      select: 'name email avatar'
    })
    .populate({
      path: 'medicalStaffAssigned',
      select: 'name email avatar'
    });

  if (!athlete) {
    throw new ApiError(404, "Athlete not found");
  }

  return res.status(200).json(
    new ApiResponse(200, { athlete }, "Athlete details retrieved successfully")
  );
});

const getAllAthletes = asyncHandler(async (req, res) => {
  // Extract query parameters
  const { 
    page = 1, 
    limit = 10, 
    sort = 'name', 
    order = 'asc', 
    search = '',
    sport = '',
    skillLevel = '',
    gender = '',
    organizationId
  } = req.query;

  // Build filter object
  const filter = {};

  // Add organization filter based on user role
  if (req.admin) {
    // If admin, filter by their organization
    filter.organization = req.admin.organization;
  } else if (organizationId && mongoose.Types.ObjectId.isValid(organizationId)) {
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
      { name: { $regex: search, $options: 'i' } },
      { athleteId: { $regex: search, $options: 'i' } },
      { email: { $regex: search, $options: 'i' } }
    ];
  }

  // Set up pagination
  const pageNumber = parseInt(page, 10);
  const limitNumber = parseInt(limit, 10);
  const skip = (pageNumber - 1) * limitNumber;

  // Set up sort option
  const sortOption = {};
  sortOption[sort] = order === 'asc' ? 1 : -1;

  try {
    // Get athletes with pagination, filtering, and sorting
    const athletes = await Athlete.find(filter)
      .sort(sortOption)
      .skip(skip)
      .limit(limitNumber)
      .select('-password -refreshToken')
      .populate({
        path: 'organization',
        select: 'name logo'
      })
      .populate({
        path: 'headCoachAssigned',
        select: 'name email'
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
            hasPrevPage: pageNumber > 1
          }
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
      role: admin.role
    }
  });
});

const getAllAdmins = asyncHandler(async (req, res) => {
  // Extract query parameters
  const { 
    page = 1, 
    limit = 10, 
    sort = 'name', 
    order = 'asc', 
    search = '',
    organizationId
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
  } else if (organizationId && mongoose.Types.ObjectId.isValid(organizationId)) {
    // If no logged-in admin but organization ID provided in query
    filter.organization = organizationId;
  }

  // Add search functionality (search by name or email)
  if (search) {
    filter.$or = [
      { name: { $regex: search, $options: 'i' } },
      { email: { $regex: search, $options: 'i' } }
    ];
  }

  // Set up pagination
  const pageNumber = parseInt(page, 10);
  const limitNumber = parseInt(limit, 10);
  const skip = (pageNumber - 1) * limitNumber;

  // Set up sort option
  const sortOption = {};
  sortOption[sort] = order === 'asc' ? 1 : -1;

  try {
    // Get admins with pagination, filtering, and sorting
    const admins = await Admin.find(filter)
      .sort(sortOption)
      .skip(skip)
      .limit(limitNumber)
      .select('-password -refreshToken') // Exclude sensitive fields
      .populate({
        path: 'organization',
        select: 'name logo'
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
            hasPrevPage: pageNumber > 1
          }
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
  certifications: certificationsList.length ? certificationsList : ["Default Certification"],  // Add a default if empty
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

const getAllCoaches = asyncHandler(async (req, res) => {
  // Extract query parameters
  const { 
    page = 1, 
    limit = 10, 
    sort = 'name', 
    order = 'asc', 
    search = '',
    sport = '',
    designation = '',
    organizationId
  } = req.query;

  // Build filter object
  const filter = {};

  // Add organization filter based on user role
  if (req.admin) {
    // If admin, filter by their organization
    filter.organization = req.admin.organization;
  } else if (organizationId && mongoose.Types.ObjectId.isValid(organizationId)) {
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
      { name: { $regex: search, $options: 'i' } },
      { email: { $regex: search, $options: 'i' } },
      { contactNumber: { $regex: search, $options: 'i' } }
    ];
  }

  // Set up pagination
  const pageNumber = parseInt(page, 10);
  const limitNumber = parseInt(limit, 10);
  const skip = (pageNumber - 1) * limitNumber;

  // Set up sort option
  const sortOption = {};
  sortOption[sort] = order === 'asc' ? 1 : -1;

  try {
    // Get coaches with pagination, filtering, and sorting
    const coaches = await Coach.find(filter)
      .sort(sortOption)
      .skip(skip)
      .limit(limitNumber)
      .select('-password -refreshToken') // Exclude sensitive fields
      .populate({
        path: 'organization',
        select: 'name logo'
      })
      .populate({
        path: 'assignedAthletes',
        select: 'name athleteId avatar',
        options: { limit: 5 } // Limit number of populated athletes
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
            hasPrevPage: pageNumber > 1
          }
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
  getAllAthletes,
  registerAdmin,
  registerCoach,
  getAllUsers,
  generateAccessAndRefreshToken,
  logoutAdmin,
  getAdminProfile,
  getRpeInsights,
  getAllAdmins,
  getAllCoaches,
  getAthleteById
};