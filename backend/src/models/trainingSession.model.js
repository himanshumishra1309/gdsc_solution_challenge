import mongoose from "mongoose";

const TrainingSessionSchema = new mongoose.Schema({
    trainingPlan: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "TrainingPlan",
        required: false, // Optional, in case of standalone sessions
    },
    athlete: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Athlete",
        required: false, // Optional, for personalized sessions
    },
    date: { type: Date, required: true },
    duration: { type: Number, required: true }, // In minutes
    intensity: { type: String, enum: ["Low", "Moderate", "High"], required: true },
    exercises: [
        {
            name: { type: String, required: true }, // e.g., "Sprint Drills"
            sets: { type: Number, required: true },
            reps: { type: Number, required: false }, // Reps (if applicable)
            duration: { type: Number, required: false }, // Seconds (if applicable)
        }
    ],
    videoLinks: [
        {
            title: { type: String, trim: true }, // E.g., "How to Sprint Faster"
            url: { type: String, trim: true },
            platform: { type: String, enum: ["YouTube", "Vimeo", "Other"], required: true }
        }
    ],
    location: { type: String }, // Gym, Field, etc.
    coachNotes: { type: String, trim: true }, // Coach's feedback
    completionStatus: { type: String, enum: ["Pending", "In Progress", "Completed"], default: "Pending" },
    sessionType: { type: String, enum: ["General", "Recovery", "Rehabilitation", "Conditioning"], default: "General" },
    attendance: [
        {
            athlete: { type: mongoose.Schema.Types.ObjectId, ref: "Athlete" },
            checkInTime: { type: Date },
            checkOutTime: { type: Date }
        }
    ],
    completedByAthletes: [
        {
            athlete: { type: mongoose.Schema.Types.ObjectId, ref: "Athlete" },
            completedAt: { type: Date, default: null },
            recoveryNotes: { type: String, trim: true } // Add recovery progress notes
        }
    ]
}, { timestamps: true });

const TrainingSession = mongoose.model("TrainingSession", TrainingSessionSchema);
export default TrainingSession;

TrainingSessionSchema.index({ date: 1 });
TrainingSessionSchema.index({ completionStatus: 1 });
TrainingSessionSchema.index({ athlete: 1 });
TrainingSessionSchema.index({ "attendance.athlete": 1 });
TrainingSessionSchema.index({ "completedByAthletes.athlete": 1 });
