import mongoose, {Schema} from "mongoose";

const medicalRecordSchema = new mongoose.Schema({
athlete_id: { type: Schema.Types.ObjectId, ref: "Athlete", required: true},

  testName: { type: String, required: true },
  testDate: {type: String},
  //uploading images
  testResults: [{type:String}],  //check if array is needed
  physicianNotes: {type: String},
  nextReviewDate:{type: Date},
  reportFileUrl:[{type: String, required: [true, "Medical Report is required"]}],

  chronicMedicalCondition: {type: String},
  prescribedMedication: {type: Schema.Types.ObjectId, ref: "Medication"},

  createdBy: {type: Schema.Types.ObjectID, ref: "Coach"}

}, { timestamps: true });

export const MedicalRecord = mongoose.model('MedicalRecord', medicalRecordSchema);