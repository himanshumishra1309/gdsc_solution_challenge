import mongoose, {Schema} from "mongoose";

const performanceMetricsSchema = new mongoose.Schema({
  name: { type: String, required: true },
  unit: { type: String, required: true, },
  password: { type: String, required: true },
  isAdmin: { type: Boolean, default: false },


  createdBy: {type: Schema.Types.ObjectId, ref: 'Admin'}
}, { timestamps: true });

module.exports = mongoose.model('PerformanceMetrics', performanceMetricsSchema);