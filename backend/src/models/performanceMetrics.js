import mongoose, {Schema} from "mongoose";

const performanceMetricsSchema = new mongoose.Schema({
  athleteId: { type: mongoose.Schema.Types.ObjectId, ref: "Athlete", required: true },
  name: { type: String, required: true },
  unit: { type: String, required: true, },
  value: { type: Number, required: true },


}, { timestamps: true });

export const PerformanceMetric = mongoose.model('PerformanceMetric', performanceMetricsSchema);