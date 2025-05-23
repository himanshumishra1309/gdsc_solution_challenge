import mongoose, { Schema } from "mongoose";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import { SponsorshipContract } from "./sponsorshipContract.model.js";

const sponsorSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    password: { type: String, required: [true, "Password is Required"] },
    avatar: {
      type: String,
    },
    dob: { type: Date, required: true },
    address: { type: String, required: true },
    state: { type: String, required: true },

    contactName: { type: String, required: true },
    contactNo: { type: String, required: true },

    sponsorshipRange: {
      start: { type: Number, default: 0 },
      end: { type: Number, default: 0 },
    },

    contracts: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "SponsorshipContract",
      },
    ],

    refreshToken: {
      type: String,
    },

    interestedSports: [
      {
        sport: { type: String, required: true },
        type: { type: String, enum: ["Team", "Individual"], required: true },
      },
    ],
    status: {
      type: String,
      enum: ["Pending", "Accepted", "Rejected"],
      default: "Pending",
    },
    sponsoredOrganizations: [
      { type: mongoose.Schema.Types.ObjectId, ref: "Organization" },
    ],
  },
  { timestamps: true }
);

sponsorSchema.pre("save", async function (next) {
  if (!this.isModified("password")) return next();
  this.password = await bcrypt.hash(this.password, 10);
  next();
});

sponsorSchema.methods.isPasswordCorrect = async function (password) {
  return await bcrypt.compare(password, this.password);
};

sponsorSchema.methods.generateAccessToken = function () {
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

sponsorSchema.methods.generateRefreshToken = function () {
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

export const Sponsor = mongoose.model("Sponsor", sponsorSchema);
