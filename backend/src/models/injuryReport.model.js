import mongoose, { Schema } from "mongoose";

const InjuryReportSchema = new mongoose.Schema({
  athlete: { type: Schema.Types.ObjectId, ref: "Athlete", required: true },
  doctor: { type: Schema.Types.ObjectId, ref: "Coach", required: true },
  title: { type: String, required: true },
  injuryType: { type: String, required: true },
  bodyPart: { type: String, required: true },
  painLevel: { type: Number, min: 1, max: 10, required: true },
  dateOfInjury: { type: Date, required: true },
  activityContext: { type: String, required: true },
  symptoms: [String],
  affectingPerformance: {
    type: String,
    enum: ["CANNOT_PLAY", "LIMITED", "MINIMAL", "NONE"],
  },
  previouslyInjured: { type: Boolean, default: false },
  notes: { type: String },
  images: [String]
}, {timestamps: true});

export const InjuryReport = mongoose.model("InjuryReport", InjuryReportSchema);
