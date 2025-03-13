import mongoose, { Schema } from "mongoose";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";

const individualAthleteSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    avatar: { type: String, required: false },
    totalExperience: { type: String, required: false },
    dob: { type: Date, required: true },
    sex: { type: String, enum: ["Male", "Female", "Other"], required: false },
    highestLevelPlayed: { type: String, enum: ["District", "State", "National"], required: false },
    password: { type: String, required: [true, "Password is Required"] },
    sport: { type: String, enum: ["Cricket", "Basketball", "Football"], required: false },
    refreshToken: { type: String } // Added for token refresh functionality
  },
  { timestamps: true }
);

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
      _id: this._id, // Changed from this.id to this._id to match your middleware
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
      _id: this._id, // Changed from this.id to this._id to match your middleware
      email: this.email
    },
    process.env.REFRESH_TOKEN_SECRET,
    {
      expiresIn: process.env.REFRESH_TOKEN_EXPIRY,
    }
  );
};

export const IndividualAthlete = mongoose.model("IndividualAthlete", individualAthleteSchema);