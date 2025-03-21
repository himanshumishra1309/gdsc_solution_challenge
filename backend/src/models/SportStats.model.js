import mongoose, {Schema} from "mongoose";



const SportStatsSchema = new mongoose.Schema({
    sport: { type: String, required: true, unique: true }, // e.g., "Cricket", "Basketball"
    stats: [{ type: String, required: true }] // e.g., ["No. of Runs", "Wickets Taken"]
}, { timestamps: true });

export const SportStats = mongoose.model("SportStats", SportStatsSchema);