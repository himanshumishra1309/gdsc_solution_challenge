import asyncHandler from "../utils/asyncHandler.js";
import { Organization } from "../models/organization.model.js";
import { Admin } from "../models/admin.model.js";
import { ApiError } from "../utils/ApiError.js";
import { uploadOnCloudinary } from "../utils/cloudinary.js";
import { ApiResponse } from "../utils/ApiResponse.js";
import { sendEmail } from "../utils/sendEmail.js";

const organizationTypeEnum = [
  "sports_club",
  "education",
  "pro_team",
  "youth",
  "association",
  "government",
  "nonprofit",
  "company",
];

const registerOrganization = asyncHandler(async (req, res) => {
  const {
    orgName,
    orgEmail,
    organizationType,
    address,
    country,
    state,
    adminName,
    adminEmail,
    adminPassword,
  } = req.body;

  console.log("Request body:", req.body);

  if (
    !orgName ||
    !orgEmail ||
    !organizationType ||
    !address ||
    !country ||
    !state
  ) {
    throw new ApiError(
      400,
      "All required organization fields must be provided"
    );
  }

  if (!adminName || !adminEmail || !adminPassword) {
    throw new ApiError(400, "All required admin fields must be provided");
  }

  if (!organizationTypeEnum.includes(organizationType)) {
    throw new ApiError(
      400,
      `Invalid organization type. Allowed values: ${organizationTypeEnum.join(", ")}`
    );
  }

  const existingOrgByName = await Organization.findOne({ name: orgName });
  if (existingOrgByName) {
    throw new ApiError(400, "Organization with this name already exists");
  }

  const existingOrgByEmail = await Organization.findOne({ email: orgEmail });
  if (existingOrgByEmail) {
    throw new ApiError(400, "Organization with this email already exists");
  }

  const existingAdmin = await Admin.findOne({ email: adminEmail });
  if (existingAdmin) {
    throw new ApiError(400, "Admin with this email already exists");
  }

  let logoUrl = "";
  let certificatesUrl = "";
  let adminAvatarUrl = "";

  if (req.files?.logo) {
    const logoLocalPath = req.files.logo[0]?.path;
    if (logoLocalPath) {
      const uploadedLogo = await uploadOnCloudinary(logoLocalPath);
      if (!uploadedLogo)
        throw new ApiError(400, "Error uploading organization logo");
      logoUrl = uploadedLogo.url;
    }
  }

  if (req.files?.certificates) {
    const certificatesLocalPath = req.files.certificates[0]?.path;
    if (certificatesLocalPath) {
      const uploadedCertificates = await uploadOnCloudinary(
        certificatesLocalPath
      );
      if (!uploadedCertificates)
        throw new ApiError(400, "Error uploading certificates");
      certificatesUrl = uploadedCertificates.url;
    }
  }

  if (req.files?.adminAvatar) {
    const avatarLocalPath = req.files.adminAvatar[0]?.path;
    if (avatarLocalPath) {
      const uploadedAvatar = await uploadOnCloudinary(avatarLocalPath);
      if (!uploadedAvatar)
        throw new ApiError(400, "Error uploading admin avatar");
      adminAvatarUrl = uploadedAvatar.url;
    }
  }

  const admin = await Admin.create({
    name: adminName,
    email: adminEmail,
    password: adminPassword,
    avatar: adminAvatarUrl,
    role: "admin",
  });

  const organization = await Organization.create({
    name: orgName,
    email: orgEmail,
    logo: logoUrl,
    organizationType,
    certificates: certificatesUrl,
    address,
    country,
    state,
    admin: admin._id,
  });

  await Admin.findByIdAndUpdate(
    admin._id,
    { organization: organization._id },
    { new: true }
  );

  try {
    await sendEmail({
      email: adminEmail,
      subject: "Welcome to AMS - Organization Registered",
      message: `
        <h3>Hi ${adminName},</h3>
        <p>Your organization "${orgName}" has been successfully registered in the Athlete Management System.</p>
        <p>You have been set up as an administrator with the following credentials:</p>
        <p><strong>Email:</strong> ${adminEmail}</p>
        <p>Please log in to access your organization's dashboard.</p>
        <p>Thank you!</p>
      `,
    });
  } catch (emailError) {
    console.log("Email sending failed:", emailError);
  }

  res.status(201).json(
    new ApiResponse(
      201,
      {
        organization: {
          _id: organization._id,
          name: organization.name,
          email: organization.email,
          logo: organization.logo,
          organizationType: organization.organizationType,
          certificates: organization.certificates,
          address: organization.address,
          country: organization.country,
          state: organization.state,
        },
        admin: {
          _id: admin._id,
          name: admin.name,
          email: admin.email,
          role: admin.role,
        },
      },
      "Organization and admin registered successfully."
    )
  );
});

const updateOrganizationAdmin = asyncHandler(async (req, res) => {
  const { organizationId, adminId } = req.body;

  if (!organizationId || !adminId) {
    throw new ApiError(400, "Organization ID and Admin ID are required");
  }

  const updatedOrg = await Organization.findByIdAndUpdate(
    organizationId,
    { admin: adminId },
    { new: true }
  );

  if (!updatedOrg) {
    throw new ApiError(404, "Organization not found");
  }

  res
    .status(200)
    .json(
      new ApiResponse(
        200,
        { organization: updatedOrg },
        "Organization updated with admin successfully"
      )
    );
});

const getOrganizationDetails = asyncHandler(async (req, res) => {
  const { orgId } = req.params;

  const organization = await Organization.findById(orgId).populate(
    "admin",
    "-password"
  );
  if (!organization) {
    throw new ApiError(404, "Organization not found");
  }

  res.status(200).json({
    success: true,
    organization,
  });
});

const getAllOrganizations = asyncHandler(async (req, res) => {
  const organizations = await Organization.find(
    {},
    "_id name email organizationType logo country state"
  );

  res.status(200).json({
    success: true,
    count: organizations.length,
    organizations,
  });
});

export {
  registerOrganization,
  updateOrganizationAdmin,
  getOrganizationDetails,
  getAllOrganizations,
};
