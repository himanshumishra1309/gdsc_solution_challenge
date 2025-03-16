import asyncHandler from "../utils/asyncHandler.js";
import {Organization} from "../models/organization.model.js";
import {Admin} from "../models/admin.model.js";
import ApiError from "../utils/ApiError.js";

// ✅ Register Organization & Admin Together
 const registerOrganization = asyncHandler(async (req, res) => {
  const { orgName, sportType, adminName, adminEmail, adminPassword } = req.body;

    // Validate required fields
    if (!orgName || !sportType || !adminName || !adminEmail || !adminPassword) {
      throw new ApiError(400, "All fields are required");
    }
  
    // Validate sportType against predefined enum
    if (!sportEnum.includes(sportType)) {
      throw new ApiError(400, `Invalid sport type. Allowed values: ${sportEnum.join(", ")}`);
    }

  // Check if organization exists
  const existingOrg = await Organization.findOne({ name: orgName });
  if (existingOrg) {
    throw new ApiError(400, "Organization with this name already exists");
  }

  // Check if admin email is already taken
  const existingAdmin = await Admin.findOne({ email: adminEmail });
  if (existingAdmin) {
    throw new ApiError(400, "An admin with this email already exists");
  }


  // Create Organization
  const organization = await Organization.create({
    name: orgName,
    sportType,
  });

  // Create Admin (Password hashing handled in Admin model)
  const admin = await Admin.create({
    name: adminName,
    email: adminEmail,
    password: adminPassword, // ✅ No need to hash manually
    organization: organization._id,
  });

  res.status(201).json({
    success: true,
    message: "Organization and Admin registered successfully",
    organization: {
      _id: organization._id,
      name: organization.name,
      sportType: organization.sportType,
    },
    admin: {
      _id: admin._id,
      name: admin.name,
      email: admin.email,
    },
  });
});

// ✅ Fetch Organization Details
 const getOrganizationDetails = asyncHandler(async (req, res) => {
  const { orgId } = req.params;

  const organization = await Organization.findById(orgId).populate("admin");
  if (!organization) {
    throw new ApiError(404, "Organization not found");
  }

  res.status(200).json({
    success: true,
    organization,
  });
});

const getAllOrganizations = asyncHandler(async (req, res, next) => {
  try {
    const organizations = await Organization.find({}, "_id name sportType"); // Only return necessary fields

    res.status(200).json({
      success: true,
      count: organizations.length,
      organizations,
    });
  } catch (error) {
    console.error("Error fetching organizations:", error);
    res.status(500).json({
      success: false,
      statusCode: 500,
      message: "Internal Server Error",
      errors: [error.message],
    });
  }
});

export {
    registerOrganization,
    getOrganizationDetails,
    getAllOrganizations
}
