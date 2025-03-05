import asyncHandler from "../utils/asyncHandler.js";

import {ApiError} from "../utils/ApiError.js"
import  {Admin} from "../models/admin.model.js"
import {Athlete} from "../models/athlete.model.js"
import {Coach} from "../models/coach.model.js"
import {Organization} from "../models/organization.model.js"
import {sendEmail} from "../utils/sendEmail.js"
import {RPE} from "../models/rpe.model.js"
import {ApiResponse} from "../utils/ApiResponse.js"
import {CustomForm} from "../models/customForm.model.js"

import mongoose from "mongoose"

// import {CustomForm} from "../models/customForm.model.js"


import jwt from 'jsonwebtoken'



const registerOrganizationAthlete = asyncHandler(async (req, res) => {
  const { name, email, password, organizationId, sport } = req.body;

    // 1️⃣ Ensure organization ID is provided
    if (!organizationId) {
      throw new ApiError(400, "Organization ID is required for organization athletes");
    }

  // ✅ Check if athlete already exists
  const existingAthlete = await Athlete.findOne({ email });
  if (existingAthlete) {
    throw new ApiError(400, "Athlete with this email already exists");
  }

  // 2️⃣ Validate if the organization exists
  const organizationExists = await Organization.exists({ _id: organizationId });
  if (!organizationExists) {
    throw new ApiError(404, "Organization not found");
  }

  // ✅ Create athlete
  const athlete = await Athlete.create({
    name,
    email,
    password, // Will be hashed automatically in the model
    sport,
    isIndependent: false, // ✅ Automatically set for organization athletes
    organization: organizationId, // ✅ Assign valid organization
  });

  // ✅ Send Email with Login Credentials
  await sendEmail({
    email: athlete.email,
    subject: "Welcome to AMS - Athlete Login Details",
    message: `<h3>Hi ${athlete.name},</h3>
              <p>Your account has been created in the Athlete Management System.</p>
              <p><strong>Email:</strong> ${athlete.email}</p>
              <p><strong>Password:</strong> ${password}</p>
              <p>Please log in and change your password.</p>`,
  });

  // ✅ Response
  res.status(201).json({
    success: true,
    message: "Athlete registered successfully, email sent.",
    athlete: {
      _id: athlete._id,
      name: athlete.name,
      email: athlete.email,
      sportType: organization.sportType, // Get sport from organization
      isIndependent: false, // ✅ Ensures frontend understands athlete belongs to an organization
      organization: organizationId,
    },
  });
});

// ✅ Register Coach (Only Admin can do this)
const registerCoach = asyncHandler(async (req, res) => {
  const { name, email, password, organizationId, designation, sport } = req.body;

  console.log("Received Organization ID:", organizationId); // 🔹 Debugging

  // ✅ Convert organizationId to ObjectId (if it's a valid format)
  if (!mongoose.Types.ObjectId.isValid(organizationId)) {
    throw new ApiError(400, "Invalid Organization ID format");
  }
  const orgId = new mongoose.Types.ObjectId(organizationId); // Convert to ObjectId

  // ✅ Verify if Organization exists
  const organization = await Organization.findById(orgId);
  console.log("Organization Query Result:", organization); // 🔹 Debugging

  if (!organization) {
    throw new ApiError(404, `Organization not found with ID: ${organizationId}`);
  }

  // ✅ Validate if the selected sport is allowed in the organization
  if (!organization.sportType.includes(sport)) {
    throw new ApiError(400, `Invalid sport. Allowed sports: ${organization.sportType.join(", ")}`);
  }

  // ✅ Check if coach already exists
  const existingCoach = await Coach.findOne({ email });
  if (existingCoach) {
    throw new ApiError(400, "Coach with this email already exists");
  }

  // ✅ Create coach
  const coach = await Coach.create({
    name,
    email,
    password, // Hashed in model
    organization: orgId,
    sport,
    designation,
  });

  // ✅ Send Email with Login Credentials
  await sendEmail({
    email: coach.email,
    subject: "Welcome to AMS - Coach Login Details",
    message: `<h3>Hi ${coach.name},</h3>
              <p>Your account has been created in the Athlete Management System.</p>
              <p><strong>Email:</strong> ${coach.email}</p>
              <p><strong>Password:</strong> ${password}</p>
              <p>Please log in and change your password.</p>`,
  });

  // ✅ Response
  res.status(201).json({
    success: true,
    message: "Coach registered successfully, email sent.",
    coach: {
      _id: coach._id,
      name: coach.name,
      email: coach.email,
      organization: organizationId,
      sport,
      designation,
    },
  });
});

// ✅ Fetch All Athletes & Coaches (For Admin Dashboard)
const getAllUsers = asyncHandler(async (req, res) => {
  const { organization } = req.user; // Assuming admin is logged in

  const athletes = await Athlete.find({ organization });
  const coaches = await Coach.find({ organization });

  res.status(200).json({
    success: true,
    athletes,
    coaches,
  });
});


const generateAccessAndRefreshToken = async(userId) => {
    try {
      const admin = await  Admin.findById(userId)
 

      //we save refresh token in db
          // If no teacher is found, throw an error
    if (!Admin) {
        throw new ApiError(404, "Admin not found");
      }
  
      const adminAccessToken = admin.generateAccessToken()
      const adminRefreshToken = admin.generateRefreshToken()

      admin.refreshToken = adminRefreshToken
      //this is used if it is something other than password wich doesnt need to validate
      await admin.save({validateBeforeSave: false})

      return{adminRefreshToken, adminAccessToken}
    } catch (error) {
        console.error("Error generating tokens:", error); // Optional: for debugging purposes

        throw new ApiError(500, "Something went wrong while generating tokens")
    }
}



const logoutUser = asyncHandler( async(req,res) => {
        await Admin.findByIdAndUpdate(
            req.admin._id,
            // {
            //     $set: {refreshToken : undefined}
            // },
             // {
        //   refreshToken: undefined
        // }, dont use this approach, this dosent work well
    
        {
            $unset: {
              adminRefreshToken: 1, // this removes the field from the document
            },
          },
            {
                new: true
            }
        )
        //clear cookies
        // reset the refresh token in User modelSchema
    
        const options = {
                httpOnly: true,
                secure: true
         }
    
         return res
         .status(200)
         .clearCookie("adminAcessToken", options)
         .clearCookie("adminRefreshToken", options)
         .json(
            new ApiResponse(200, {}, "User Logged Out")
         )
    
    
})

const getAdminProfile = asyncHandler(async(req,res) => {
    const admin = await Admin.findById(req.admin._id).select(
        "-password -refreshToken"
      );

      if (!admin) {
        throw new ApiError(404, "Admin not found");
      }
    
      return res.status(200).json(new ApiResponse(200, teacher, "Admin profile fetched successfully"));
})

const getRpeInsights = asyncHandler(async (req, res) => {
    const { athleteId } = req.params; // Extract athleteId from URL path
    const userId = req.user._id; // User ID from authenticated user
    const userRole = req.user.role; // User role (athlete, head_coach, assistant_coach, training_staff)
  
    try {
      // Fetch the athlete
      const athlete = await Athlete.findById(athleteId);
      if (!athlete) {
        return res.status(404).json({ message: 'Athlete not found.' });
      }
  
      // Check access permissions
      if (userRole === 'athlete') {
        // Athletes can only view their own RPE insights
        if (athleteId !== userId.toString()) {
          return res.status(403).json({ message: 'Access denied. You can only view your own RPE insights.' });
        }
      } else if (userRole === 'head_coach' || userRole === 'assistant_coach' || userRole === 'training_staff') {
        // Coaches can view RPE insights for athletes in their organization
        const coach = await Coach.findById(userId);
        if (!coach || coach.organization.toString() !== athlete.organization.toString()) {
          return res.status(403).json({ message: 'Access denied. Athlete does not belong to your organization.' });
        }
      } else {
        return res.status(403).json({ message: 'Access denied. Invalid role.' });
      }
  
      // Fetch RPE records for the athlete
      const rpeRecords = await RPE.find({ athleteId });
      const averageRPE = rpeRecords.reduce((sum, record) => sum + record.rpe, 0) / rpeRecords.length;
  
      // Generate recommendations
      let recommendation = '';
      if (averageRPE >= 8) {
        recommendation = 'High RPE detected. Consider rest and recovery activities.';
      } else if (averageRPE <= 4) {
        recommendation = 'Low RPE detected. Check for injuries or adjust training intensity.';
      } else {
        recommendation = 'RPE within normal range. Maintain current training plan.';
      }
  
      res.json({ averageRPE, recommendation });
    } catch (error) {
        throw new ApiError(500)
      res.status(500).json({ message: 'Error fetching RPE insights', error });
    }
  })


 const createCustomForm = asyncHandler(async (req, res) => {
    const { title, sport, fields } = req.body;
    const organizationId = req.user.organization; // Admin's organization
  
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
      res.status(500).json({ message: 'Error creating custom form', error });
    }
  });
  
  
  export {
    registerOrganizationAthlete,
    registerCoach,
    getAllUsers,
    generateAccessAndRefreshToken,
    logoutUser,
    getAdminProfile,
    getRpeInsights,
    // createCustomForm,
  }