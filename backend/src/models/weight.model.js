import mongoose, {Schema} from "mongoose";

const WeightSchema = new mongoose.Schema({
    athlete_id: { type: Schema.Types.ObjectId, ref: "Athlete", required: true},

  name: { type: String, required: true },
  category: {type: String, enum:["Pre-workout","Post-Workout"]},
  weight:{type: String, required: true},
  recordedBy: {type: Schema.Types.ObjectID, ref: "Coach"},

  date: {type: Date, default: Date.now}

}, { timestamps: true });

module.exports = mongoose.model('Weight', WeightSchema);