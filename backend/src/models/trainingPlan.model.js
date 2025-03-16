import mongoose from "mongoose";

const TrainingPlanSchema = new mongoose.Schema({
    organization: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Organization",
        required: true,
    },
    title: { type: String, required: true, trim: true }, // e.g., "Football Pre-Season Plan"
    description: { type: String, trim: true }, // Optional details
    goal: { type: String, trim: true }, // Optional field
    durationWeeks: { type: Number, required: true },
    difficultyLevel: { type: String, enum: ["Beginner", "Intermediate", "Advanced"] },
    // visibility: { type: String, enum: ["Private", "Organization-Wide", "Public"], default: "Private" },
    requiredEquipment: [{ type: String }], // Array of equipment names
    referenceMaterial: [
      {
          title: { type: String, trim: true }, // E.g., "Sprint Techniques Guide"
          url: { type: String, trim: true }, // External reference
          type: { type: String, enum: ["PDF", "Video", "Article"], required: true }
      }
  ],
      createdBy: { type: mongoose.Schema.Types.ObjectId, ref: "Coach", required: true },
    assignedAthletes: [{ type: mongoose.Schema.Types.ObjectId, ref: "Athlete" }], // List of assigned athletes
    sportType: { type: String, enum: ["Football", "Cricket", "Basketball"], required: true },
    sessions: [{ type: mongoose.Schema.Types.ObjectId, ref: "TrainingSession" }], // Linked sessions
    progress: { type: Number, min: 0, max: 100, default: 0 }, // Completion percentage
    isActive: { type: Boolean, default: true }, // Active or archived
}, { timestamps: true });

const TrainingPlan = mongoose.model("TrainingPlan", TrainingPlanSchema);
export default TrainingPlan;
