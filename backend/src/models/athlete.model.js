import mongoose from "mongoose";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import SPORTS_ENUM from "../utils/sportsEnum.js";

// const sportsEnum = ["Cricket", "Basketball", "Football", "Tennis", "Swimming", "Athletics", "Badminton", "Hockey", "Volleyball", "Table Tennis"];
const skillLevelEnum = ["Beginner", "Intermediate", "Advanced", "Elite"];
const bloodGroupEnum = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"];
const dominantHandEnum = ["Right", "Left", "Ambidextrous"];

const athleteSchema = new mongoose.Schema(
  {
    // Basic Information
    name: { 
      type: String, 
      required: true,
      trim: true
    },
    athleteId: { 
      type: String, 
      required: true,
      unique: true
    },
    avatar: { 
      type: String
    },
    dob: { 
      type: Date, 
      required: true 
    },
    gender: { 
      type: String, 
      enum: ["Male", "Female", "Other"],
      required: true 
    },
    nationality: { 
      type: String, 
      required: true 
    },
    address: { 
      type: String, 
      required: true 
    },
    phoneNumber: { 
      type: String, 
      required: true 
    },
    
    // School Information
    schoolName: { 
      type: String, 
      required: true 
    },
    year: { 
      type: String, 
      required: true 
    },
    studentId: { 
      type: String, 
      required: true 
    },
    schoolEmail: { 
      type: String 
    },
    schoolWebsite: { 
      type: String 
    },
    uploadSchoolId: { 
      type: String // URL to uploaded school ID document
    },
    latestMarksheet: { 
      type: String // URL to uploaded marksheet
    },
    
    // Sports Information
    sports: {
      type: [{
        type: String,
        enum: SPORTS_ENUM
      }],
      required: true,
      validate: [array => array.length > 0, 'At least one sport must be selected']
    },
    skillLevel: { 
      type: String, 
      enum: skillLevelEnum,
      required: true 
    },
    trainingStartDate: { 
      type: Date, 
      required: true 
    },
    positions: {
      // Stores positions for each sport
      type: Map,
      of: String,
      default: new Map()
    },
    dominantHand: { 
      type: String, 
      enum: dominantHandEnum 
    },
    
    // Staff Assignments
    headCoachAssigned: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Coach"
    },
    gymTrainerAssigned: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Coach" // Assuming trainers are also in Coach model
    },
    medicalStaffAssigned: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "MedicalStaff" // You'll need this model
    },
    
    // Medical Information
    height: { 
      type: Number, // in cm
      required: true 
    },
    weight: { 
      type: Number, // in kg
      required: true 
    },
    bloodGroup: { 
      type: String, 
      enum: bloodGroupEnum 
    },
    allergies: [{ 
      type: String 
    }],
    medicalConditions: [{ 
      type: String 
    }],
    
    // Emergency Contact
    emergencyContactName: { 
      type: String, 
      required: true 
    },
    emergencyContactNumber: { 
      type: String, 
      required: true 
    },
    emergencyContactRelationship: { 
      type: String, 
      required: true 
    },
    
    // Authentication fields
    email: { 
      type: String, 
      required: true, 
      unique: true,
      trim: true,
      lowercase: true
    },
    password: { 
      type: String, 
      required: [true, "Password is Required"] 
    },
    role: { 
      type: String, 
      default: "athlete", 
      enum: ["athlete"] 
    },
    organization: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Organization"
    },
    refreshToken: {
      type: String
    }
  },
  { timestamps: true }
);

// Position helper methods
athleteSchema.methods.addPosition = function(sport, position) {
  if (!sportsEnum.includes(sport)) {
    throw new Error(`Invalid sport: ${sport}`);
  }
  this.positions.set(sport, position);
};

athleteSchema.methods.getPosition = function(sport) {
  return this.positions.get(sport);
};

// Password encryption before saving
athleteSchema.pre("save", async function (next) {
  if (!this.isModified("password")) return next();
  this.password = await bcrypt.hash(this.password, 10);
  next();
});

// Authentication methods
athleteSchema.methods.isPasswordCorrect = async function (password) {
  return await bcrypt.compare(password, this.password);
};

athleteSchema.methods.generateAccessToken = function () {
  return jwt.sign(
    {
      _id: this._id,
      email: this.email,
      role: this.role,
      name: this.name
    },
    process.env.ACCESS_TOKEN_SECRET,
    {
      expiresIn: process.env.ACCESS_TOKEN_EXPIRY,
    }
  );
};

athleteSchema.methods.generateRefreshToken = function () {
  return jwt.sign(
    {
      _id: this._id,
    },
    process.env.REFRESH_TOKEN_SECRET,
    {
      expiresIn: process.env.REFRESH_TOKEN_EXPIRY,
    }
  );
};

// Age calculation virtual
athleteSchema.virtual('age').get(function() {
  if (!this.dob) return null;
  const today = new Date();
  const birthDate = new Date(this.dob);
  let age = today.getFullYear() - birthDate.getFullYear();
  const m = today.getMonth() - birthDate.getMonth();
  if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
    age--;
  }
  return age;
});

// We want virtuals in JSON
athleteSchema.set('toJSON', { virtuals: true });
athleteSchema.set('toObject', { virtuals: true });

export const Athlete = mongoose.model("Athlete", athleteSchema);