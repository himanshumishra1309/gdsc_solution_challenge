import mongoose, {Schema} from "mongoose";

const sponsorshipContractSchema = new mongoose.Schema({
  contractDetails: { type: String, required: true },
  paymentSchedule: { type: String, required: true },

  
  startDate: {type: Date},
  endDate: {type: Date},

  paymentSchedule: []
}, { timestamps: true });

module.exports = mongoose.model('SponsorshipContract', sponsorshipContractSchema);