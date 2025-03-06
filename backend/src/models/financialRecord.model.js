import mongoose from "mongoose";

const financialRecordSchema = new mongoose.Schema(
  {
    athlete: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Athlete", // Reference to Athlete model
      required: true,
    },
    category: {
      type: String,
      enum: [
        "Income",
        "Salary/Stipend",
        "Prize Money Allocation",
        "Sponsorship Deals",
        "Expenses",
        "Training & Facility",
        "Travel & Accommodation",
        "Medical & Insurance",
        "Coaching Fees",
        "Team Equipment & Gear Costs",
        "Medical & Physiotherapy",
        "Taxes",
        "Agent/Manager Fees",
      ],
      required: true,
    },
    amount: {
      type: Number,
      required: true,
    },
    currency: {
      type: String,
      enum: ["USD", "EUR", "INR", "GBP", "AUD", "JPY"],
      default: "USD",
    },
    date: {
      type: Date,
      required: true,
      default: Date.now,
    },
    isReimbursable: {
      type: Boolean,
      default: false,
    },
    reimbursementStatus: {
      type: String,
      enum: ["Pending", "Approved", "Rejected", "Reimbursed"],
      default: "Pending",
    },
    notes: {
      type: String,
      default: "",
    },
  },
  { timestamps: true }
);

const FinancialRecord = mongoose.model("FinancialRecord", financialRecordSchema);

export default FinancialRecord;
