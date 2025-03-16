import mongoose, { Schema } from "mongoose";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";

const individualAthleteSchema = new mongoose.Schema(
  {
    // Split name into firstName and lastName
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    avatar: { type: String, required: false },
    
    // Physical measurements
    height: { type: Number, required: false }, // in cm
    weight: { type: Number, required: false }, // in kg
    bmi: { type: Number, required: false },
    bloodGroup: { 
      type: String, 
      enum: ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"], 
      required: false 
    },
    
    // Contact information
    address: { type: String, required: false },
    state: { type: String, required: false },
    number: { type: String, required: false }, // Contact number
    
    // Existing fields
    totalExperience: { type: String, required: false },
    dob: { type: Date, required: true },
    gender: { type: String, enum: ["Male", "Female", "Other"], required: false },
    highestLevelPlayed: { type: String, enum: ["District", "State", "National"], required: false },
    password: { type: String, required: [true, "Password is Required"] },
    sport: { 
      type: String, 
      enum: ["Cricket", "Basketball", "Football", "Tennis", "Swimming", "Hockey", "Badminton", "Volleyball"], 
      required: false 
    },
    refreshToken: { type: String } // For token refresh functionality
  },
  { timestamps: true }
);

// Keep the existing methods unchanged...
individualAthleteSchema.pre("save", async function (next) {
  if (!this.isModified("password")) return next();
  this.password = await bcrypt.hash(this.password, 10);
  next();
});

individualAthleteSchema.methods.isPasswordCorrect = async function (password) {
  return await bcrypt.compare(password, this.password);
};

individualAthleteSchema.methods.generateAccessToken = function () {
  return jwt.sign(
    {
      _id: this._id,
      email: this.email
    },
    process.env.ACCESS_TOKEN_SECRET,
    {
      expiresIn: process.env.ACCESS_TOKEN_EXPIRY,
    }
  );
};

individualAthleteSchema.methods.generateRefreshToken = function () {
  return jwt.sign(
    {
      _id: this._id,
      email: this.email
    },
    process.env.REFRESH_TOKEN_SECRET,
    {
      expiresIn: process.env.REFRESH_TOKEN_EXPIRY,
    }
  );
};

export const IndividualAthlete = mongoose.model("IndividualAthlete", individualAthleteSchema);