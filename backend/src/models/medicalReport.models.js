import mongoose, { Schema } from "mongoose";

const medicalReportSchema = new mongoose.Schema(
  {
    // Core Relationships
    athleteId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Athlete",
      required: true,
    },
    medicalStaffId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Coach", // Assuming medical staff is stored in the Coach model
      required: true,
    },
    organizationId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Organization",
      required: true,
    },

    // Report Metadata
    reportDate: {
      type: Date,
      required: true,
      default: Date.now,
    },
    nextCheckupDate: {
      type: Date,
    },
    // Added from MedicalRecord model
    testName: { 
      type: String 
    },
    testDate: { 
      type: String 
    },

    // Medical Status
    medicalStatus: {
      type: String,
      enum: [
        "Active",
        "Injured",
        "Recovering",
        "Limited Participation",
        "Not Cleared",
      ],
      default: "Active",
    },
    medicalClearance: {
      type: String,
      enum: [
        "Fit to Play",
        "Limited Activity",
        "Not Cleared",
        "Pending Evaluation",
      ],
      default: "Pending Evaluation",
    },
    // Added from MedicalRecord model
    chronicMedicalCondition: { 
      type: String 
    },
    prescribedMedication: { 
      type: Schema.Types.ObjectId, 
      ref: "Medication" 
    },

    // General Health & Vitals
    vitals: {
      height: { type: Number }, // in cm
      weight: { type: Number }, // in kg
      bmi: { type: Number },
      bloodPressure: { type: String }, // format: "120/80"
      restingHeartRate: { type: Number }, // bpm
      oxygenSaturation: { type: Number }, // percentage
      respiratoryRate: { type: Number }, // breaths per minute
      bodyTemperature: { type: Number }, // in Celsius
    },

    // Fitness & Performance
    performanceMetrics: {
      vo2Max: { type: Number },
      sprintSpeed: { type: Number },
      agilityScore: { type: Number },
      strength: { type: Number },
      flexibilityTest: { type: Number },
      reactionTime: { type: Number },
      enduranceLevel: { type: Number },
      verticalJump: { type: Number },
      balanceTest: { type: Number },
    },

    // Injury Information
    injuryDetails: {
      currentInjuries: [
        {
          type: { type: String },
          location: { type: String },
          severity: { type: String },
          startDate: { type: Date },
          expectedRecovery: { type: Date },
          notes: { type: String },
        },
      ],
      pastInjuries: { type: String },
      ongoingTreatment: { type: String },
      returnToPlayStatus: { type: String },
    },

    // Medical Tests
    testResults: {
      bloodTest: { type: String },
      urineTest: { type: String },
      ecg: { type: String },
      eeg: { type: String },
      mriScan: { type: String },
      xray: { type: String },
      ctScan: { type: String },
      boneDensity: { type: String },
      lungFunction: { type: String },
      cholesterolLevels: { type: String },
      bloodSugarLevels: { type: String },
      hormoneLevels: { type: String },
      vitaminLevels: { type: String },
      allergyTest: { type: String },
      geneticTest: { type: String },
      covidTest: { type: String },
      visionTest: { type: String },
      hearingTest: { type: String },
      dentalCheckup: { type: String },
      skinAssessment: { type: String },
      // Added from MedicalRecord model - string array of test results
      additionalResults: [{ type: String }]
    },

    // Nutrition Information
    nutrition: {
      caloricIntake: { type: Number },
      waterIntake: { type: Number },
      nutrientDeficiencies: { type: String },
      supplements: [{ type: String }],
      dietaryRestrictions: [{ type: String }],
      dietaryRecommendations: { type: String },
    },

    // Mental Health
    mentalHealth: {
      stressLevel: { type: Number, min: 0, max: 10 },
      sleepQuality: { type: Number, min: 0, max: 10 },
      cognitiveScore: { type: Number, min: 0, max: 100 },
      mentalHealthNotes: { type: String },
    },

    // Doctor's Notes & Recommendations
    doctorsNotes: { type: String },
    // Added from MedicalRecord model
    physicianNotes: { type: String },
    recommendations: [{ type: String }],

    // Attachments (files, images, etc.)
    attachments: [
      {
        name: { type: String },
        fileUrl: { type: String },
        type: { type: String }, // e.g., "x-ray", "prescription", "lab-report"
        uploadDate: { type: Date, default: Date.now },
      },
    ],
    // Added from MedicalRecord model
    reportFileUrl: [{ type: String }],

    // Flexible field for any additional data
    additionalData: {
      type: Map,
      of: mongoose.Schema.Types.Mixed,
      default: {},
    },

    // Status tracking
    isArchived: {
      type: Boolean,
      default: false,
    },

    // Record creator reference (from MedicalRecord model)
    createdBy: { 
      type: Schema.Types.ObjectId,
      ref: "Coach" 
    }
  },
  { timestamps: true }
);

// Virtual for age calculation
medicalReportSchema.virtual("athlete.age").get(function () {
  if (this.athlete && this.athlete.dob) {
    const today = new Date();
    const birthDate = new Date(this.athlete.dob);
    let age = today.getFullYear() - birthDate.getFullYear();
    const m = today.getMonth() - birthDate.getMonth();
    if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
      age--;
    }
    return age;
  }
  return null;
});

// Index for faster queries
medicalReportSchema.index({ athleteId: 1, reportDate: -1 });
medicalReportSchema.index({ medicalStaffId: 1 });
medicalReportSchema.index({ organizationId: 1 });
medicalReportSchema.index({ medicalStatus: 1 });
medicalReportSchema.index({ testName: 1 }); // Added index for testName

// Enable virtuals in JSON
medicalReportSchema.set("toJSON", { virtuals: true });
medicalReportSchema.set("toObject", { virtuals: true });

// Methods
medicalReportSchema.methods.isNormal = function (field) {
  // Helper method to check if a test result is normal
  if (field && typeof field === "string") {
    return (
      field.toLowerCase() === "normal" || field.toLowerCase() === "healthy"
    );
  }
  return false;
};

export const MedicalReport = mongoose.model(
  "MedicalReport",
  medicalReportSchema
);