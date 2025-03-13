import mongoose from "mongoose";

const financialRecordSchema = new mongoose.Schema(
  {
    athlete: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Athlete",
      required: true,
    },

    type: {
      type: String,
      enum: ["Income", "Expense"],
      required: true,
    },

    category: {
      type: String,
      enum: [
        // Income Categories
        "Salary/Stipend",
        "Prize Money Allocation",
        "Sponsorship Deals",

        // Expense Categories
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
      default: "INR",  // ✅ Default currency set to INR
    },

    date: {
      type: Date,
      default: Date.now,
    },
    isDeleted: { type: Boolean, default: false },
    deletedAt: { type: Date }, // ✅ Timestamp of deletion

    // If linked to a sponsorship or prize money, reference it
    referenceId: {
      type: mongoose.Schema.Types.ObjectId,
      refPath: "referenceModel",
    },
    referenceModel: {
      type: String,
      enum: ["SponsorshipContract", "Competition"], // Dynamic reference
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

    balanceAfterTransaction: {
      type: Number, // Tracks balance after the record is added
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
