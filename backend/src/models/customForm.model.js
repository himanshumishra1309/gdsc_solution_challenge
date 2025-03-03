




import mongoose, {Schema} from "mongoose";

const formFieldSchema = new mongoose.Schema({
  label: { type: String, required: true }, // Field label (e.g., "Speed")
  type: { type: String, enum: ['text', 'number', 'dropdown', 'date'], required: true }, // Field type
  options: [{ type: String }], // Options for dropdown fields
  required: { type: Boolean, default: false }, // Is this field mandatory?
});

const customFormSchema = new mongoose.Schema({
  title: { type: String, required: true }, // Form title (e.g., "Performance Metrics")
  sport: { type: String, required: true }, // Sport this form is for (e.g., "Football")
  organization: { type: mongoose.Schema.Types.ObjectId, ref: 'Organization', required: true }, // Organization this form belongs to
  fields: [formFieldSchema], // Array of form fields
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now },
});

export const CustomForm = mongoose.model('CustomForm', customFormSchema);