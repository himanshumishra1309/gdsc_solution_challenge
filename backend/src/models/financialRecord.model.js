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
        "Training and Facility Sponsorship",
        "Travel and Accomodation Support",
        "Medical And Insurance Coverage",
        "Team/Club Budget Allocation",
        "Funding Request and Approval",
        "Financial Aid and Loan",
        "Salary and Payment Statement",
        "Annual Financial Summary",
        
        // Expense Categories
        "Coaching Fees",
        "Team Equipment and Gear Cost",
        "Medical and Physiotherapy",
        "Nutrition and Supplements",
        "Tax Deductions",
        "Fines and Penalties",
        "Expense Breakdown",
        "Pending Approval"
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
      default: "INR",
    },

    date: {
      type: Date,
      default: Date.now,
    },

    status: {
      type: String,
      enum: ["Completed", "Pending", "Approved", "Rejected"],
      default: "Completed",
    },

    isDeleted: { 
      type: Boolean, 
      default: false 
    },
    
    deletedAt: { 
      type: Date 
    },

    // If linked to a sponsorship or prize money, reference it
    referenceId: {
      type: mongoose.Schema.Types.ObjectId,
      refPath: "referenceModel",
    },
    
    referenceModel: {
      type: String,
      enum: ["SponsorshipContract", "Competition", "Organization"], 
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
    
    icon: {
      type: String,
      default: "attach_money" // Default icon name for the UI
    }
  },
  { timestamps: true }
);

// Add index for efficient filtering
financialRecordSchema.index({ athlete: 1, type: 1, status: 1, isDeleted: 1 });
financialRecordSchema.index({ category: 1 });

// Virtual property to determine if transaction is pending
financialRecordSchema.virtual('isPending').get(function() {
  return this.status === 'Pending' || this.reimbursementStatus === 'Pending' || this.category === 'Pending Approval';
});

const FinancialRecord = mongoose.model("FinancialRecord", financialRecordSchema);

export default FinancialRecord;