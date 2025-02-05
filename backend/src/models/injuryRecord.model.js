import mongoose, {Schema} from "mongoose";

const injuryRecordSchema = new mongoose.Schema({
  athlete_id: { type: Schema.Types.ObjectId, ref: "Athlete", required: true},
  InjuryLocation:[],
  injurySeverity: {type: String, enum:["Minor","Moderate","Severe"]},
  recurrenceRisk: {type: String, enum:["low", "medium", "high"]},
  treatmentPlan: {type: Schema.Types.ObjectId, ref: "TreatmentPlan"},
  dateReported: {type: Date},
  expectedRecorveryDate: {type: Date},
  injurystatus:{type: String, enum: ["In Treatment", "Recovered", "Under Monitoring"]},
  doctorNotes: {type: String}


}, { timestamps: true });

module.exports = mongoose.model('InjuryRecord', injuryRecordSchema);