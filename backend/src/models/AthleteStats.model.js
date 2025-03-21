
import mongoose, {Schema} from "mongoose";

const AthleteStatsSchema = new mongoose.Schema({
    athlete: { type: mongoose.Schema.Types.ObjectId, ref: "Athlete", required: true },
    sport: { type: String, required: true },
    stats: [{
        statName: { type: String, required: true },
        value: { type: Number, required: true, default: 0 } // Ensures a default value
    }],
    isCustomSport: { type: Boolean, default: false }, // NEW FIELD

}, { timestamps: true });

export const AthleteStats = mongoose.model("AthleteStats", AthleteStatsSchema);