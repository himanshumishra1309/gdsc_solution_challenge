//need a model for training Plan given to athletes by coaches for our athlete mangement software


import mongoose, {Schema} from "mongoose";

const TrainingPlanSchema = new mongoose.Schema({
  exerciseName: { type: String, required: true },
  sets: { type: String, required: true },
  reps : { type: String, required: true },
  bodyPart: { type: String, required: true },
  description: { type: String, required: true },
  coach: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: "Coach", 
    required: true 
  },
  athlete: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Athlete",
    required: true
  },
  date: { type: Date, required: true }
    
}, { timestamps: true });

export const TrainingPlan = mongoose.model('TrainingPlan', TrainingPlanSchema);