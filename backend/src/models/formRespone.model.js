
import mongoose, {Schema} from "mongoose";



const formResponseSchema = new mongoose.Schema({
  formId: { type: mongoose.Schema.Types.ObjectId, ref: 'CustomForm', required: true }, // Reference to the form
  athleteId: { type: mongoose.Schema.Types.ObjectId, ref: 'Athlete', required: true }, // Athlete who submitted the response
  responses: [
    {
      fieldLabel: { type: String, required: true }, // Field label (e.g., "Speed")
      value: { type: mongoose.Schema.Types.Mixed, required: true }, // Field value (can be string, number, etc.)
    },
  ],
  submittedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'Coach', required: true }, // Coach who submitted the response (if applicable)
  createdAt: { type: Date, default: Date.now },
});

export const FormResponse = mongoose.model('FormResponse', formResponseSchema);