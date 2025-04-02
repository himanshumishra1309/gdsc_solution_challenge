import mongoose, { Schema } from "mongoose";

const SponsorRequestSchema = new mongoose.Schema(
  {
    sponsor: { type: mongoose.Schema.Types.ObjectId, ref: "Sponsor" },
    organization: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Organization",
      required: true,
    },
    requestType: {
      type: String,
      enum: ["Facility", "Equipment", "Financial"],
      required: true,
    },
    companyName: { type: String },
    contactPerson: { type: String },
    email: { type: String },
    phone: { type: String },
    notes: { type: String },
    title: { type: String }, // When requesting from potential sponsors
    message: { type: String }, // When requesting from potential sponsors
    viewed: { type: Boolean, default: false },
    status: {
      type: String,
      enum: ["Pending", "Accepted", "Declined"],
      default: "Pending",
    },
    createdAt: { type: Date, default: Date.now },
  },
  { timestamps: true }
);

export const SponsorRequest = mongoose.model("SponsorRequest", SponsorRequestSchema);
