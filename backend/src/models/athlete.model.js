import mongoose, { Schema } from "mongoose";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";

const athleteSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    password: { type: String, required: [true, "Password is Required"] },
    avatar: { type: String, required: false },
    organization: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Organization",
    },
    totalExperience: { type: String },
    dob: { type: Date, required: true },
    sex: { type: String, enum: ["Male", "Female", "Other"] },
    joined_date: { type: Date },
    sport: { type: String, enum: ["Cricket", "Basketball", "Football"] },
    isIndependent: { type: Boolean, default: false },

    currentLevel: {
      type: String,
      enum: ["Club", "District", "State", "National", "International"],
    },
    highestLevelPlayed: {
      type: String,
      enum: ["District", "State", "National"],
    },
    jerseyNo: { type: Number },
    teamRole: { type: String },
    qualifications: [
      {
        type: String,
      },
    ],
    achievements: [{ type: String }],
    coach: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Coach",
    },
    refreshToken: {
      type: "String",
    },
    InjuryRecords: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "InjuryRecord",
      },
    ],
    performanceStats:[{
      type: mongoose.Schema.Types.ObjectId,
      ref: "PerformanceMetrics"
    }],
     trainingPlans: [{
      type: mongoose.Schema.Types.ObjectId,
      ref: "TrainingPlan"
    }],
    monthlyBudget: {
      type: Number, // Budget for tracking expenses
      default: 0,
    },
  },

  { timestamps: true }
);

athleteSchema.pre("save", async function (next) {
  if (!this.isModified("password")) return next();
  this.password = await bcrypt.hash(this.password, 10);
  next();
});

athleteSchema.methods.isPasswordCorrect = async function (password) {
  return await bcrypt.compare(password, this.password);
};

athleteSchema.methods.generateAccessToken = function () {
  return jwt.sign(
    {
      _id: this.id,
      email: this.email,
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
      _id: this.id,
      email: this.email,
    },
    process.env.REFRESH_TOKEN_SECRET,
    {
      expiresIn: process.env.REFRESH_TOKEN_EXPIRY,
    }
  );
};

export const Athlete = mongoose.model("Athlete", athleteSchema);
