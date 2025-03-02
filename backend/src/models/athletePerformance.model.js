import mongoose, {Schema} from "mongoose";

const athletePerformanceSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  avatar: {type: String, required: true},
  
}, { timestamps: true });

export const AthletePerformance = mongoose.model('AthletePerformance', athletePerformanceSchema);