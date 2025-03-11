import mongoose, {Schema} from "mongoose";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";

const coachSchema = new mongoose.Schema(
  {
    name: { 
      type: String,
      required: [true, "Full name is required"]
    },
    email: { 
      type: String,
      required: [true, "Email address is required"],
      unique: true,
      match: [/^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/, "Please enter a valid email address"]
    },
    password: { 
      type: String,
      required: [true, "Password is required"],
      minLength: [6, "Password must be at least 6 characters"]
    },
    avatar: { 
      type: String, 
      required: false 
    },
    organization: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Organization",
      required: true,
    },
    dob: { 
      type: Date,
      required: [true, "Date of birth is required"]
    },
    gender: { 
      type: String, 
      enum: ["Male", "Female", "Other"],
      required: [true, "Gender is required"]
    },
    nationality: {
      type: String,
      required: [true, "Nationality is required"]
    },
    contactNumber: {
      type: String,
      required: [true, "Phone number is required"],
      match: [/^\d{10}$/, "Please enter a valid 10-digit phone number"]
    },
    address: {
      street: { type: String, required: [true, "Address is required"] },
      city: { type: String },
      state: { type: String, required: [true, "State is required"] },
      country: { type: String, required: [true, "Country is required"] },
      pincode: { type: String }
    },
    sport: { 
      type: String,
      required: [true, "Sport is required"],
      enum: ["Cricket", "Football", "Badminton", "Basketball", "Tennis", "Hockey", "Other"]
    },
    experience: { 
      type: Number,
      required: [true, "Years of experience is required"]
    },
    certifications: [{
      type: String,
      required: [true, "At least one certification is required"]
    }],
    previousOrganizations: [{ 
      type: String
    }],
    designation: {
      type: String,
      enum: [
        "Head Coach",
        "Assistant Coach",
        "Athletes",
        "Training and Conditioning Staff",
      ],
      default: "Assistant Coach"
    },
    specialization: { type: String },
    qualification: [{ type: String }],
    highestLevelPlayed: {
      type: String,
      enum: ["District", "State", "National", "International", "None"],
    },
    documents: {
      idProof: { type: String, required: [true, "ID proof document is required"] },
      certificates: { type: String, required: [true, "Certificate documents are required"] }
    },
    assignedAthletes: [{ 
      type: mongoose.Schema.Types.ObjectId,
      ref: "Athlete" 
    }],
    status: {
      type: String,
      enum: ["Active", "Inactive", "Suspended", "Pending"],
      default: "Active"
    },
    joined_date: {
      type: Date,
      validate: {
        validator: (value) => value <= new Date(),
        message: "Date cannot be in the future.",
      },
      default: Date.now
    },
    refreshToken: {
      type: String,
    },
  },
  { timestamps: true }
);

coachSchema.pre('save', async function (next) {
  if(!this.isModified("password")) return next();
  this.password = await bcrypt.hash(this.password, 10);
  next();
});

coachSchema.methods.isPasswordCorrect = async function (password) {
  return await bcrypt.compare(password, this.password); 
};

coachSchema.methods.generateAccessToken = function (){
  return jwt.sign(
    {
      _id: this.id,
      email: this.email,
      name: this.name,
      role: "coach"
    },
    process.env.ACCESS_TOKEN_SECRET,
    {
      expiresIn: process.env.ACCESS_TOKEN_EXPIRY
    },
  );
};

coachSchema.methods.generateRefreshToken = function (){
  return jwt.sign(
    {
      _id: this.id
    },
    process.env.REFRESH_TOKEN_SECRET,
    {
      expiresIn: process.env.REFRESH_TOKEN_EXPIRY
    }
  );
};

// Virtual for age calculation
coachSchema.virtual('age').get(function() {
  return Math.floor((new Date() - new Date(this.dob)) / (365.25 * 24 * 60 * 60 * 1000));
});

// Ensure virtuals are included in JSON output
coachSchema.set('toJSON', { virtuals: true });
coachSchema.set('toObject', { virtuals: true });

export const Coach = mongoose.model("Coach", coachSchema);