import mongoose, {Schema} from "mongoose";


const menstrualTrackingSchema = new mongoose.Schema({
  name: { type: String, required: true },
  cycleLength: {type: String, default: 28},
  periodDuration: {type: String, default: 5},
  symptoms: {
    type: String,
    enum:["Cramps", "Fatigue", "Bloating",
        "Mood Swings", "Nausea", "Headache"]
  },
  flowIntensity:{
    type: String,
    flowIntensity:
["Light", "Moderate", 
"Heavy"]

  },
  Notes: {type: String},
  nextExpectedPeriod: {type: String}




}, { timestamps: true });

export const MenstrualTracking = mongoose.model('MenstrualTracking', menstrualTrackingSchema);