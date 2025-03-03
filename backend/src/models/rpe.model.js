import mongoose, {Schema} from "mongoose";

const rpeSchema = new mongoose.Schema({
  athlete_id: { type: Schema.Types.ObjectId, ref: "Athete", required: true },
  rpe: {type: Number, required: true, min: 0, max: 10},
  notes: {type: String}


}, { timestamps: true });

export const RPE = mongoose.model('RPE', rpeSchema);