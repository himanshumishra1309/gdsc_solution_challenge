import mongoose, {Schema} from "mongoose";

const medicationSchema = new mongoose.Schema({

  athlete_id: { type: Schema.Types.ObjectId, ref: "Athlete", required: true},
  medicationName: { type: String, required: true },
  dosage: { type: String, required: true },
  frequency: {type: String, enum: ["Daily","Weekly", "Monthly"]},

  startDate: {type: Date},
  endDate: {type: Date},

  prescribedBy: {type: Schema.Types.ObjectId, ref: "Coach"}


}, { timestamps: true });

module.exports = mongoose.model('Medication', medicationSchema);