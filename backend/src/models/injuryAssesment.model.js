import mongoose from 'mongoose';
import { Schema } from 'mongoose';

const InjuryAssessmentSchema = new mongoose.Schema({
    injury: { type: Schema.Types.ObjectId, ref: 'InjuryReport', required: true },
    doctor: { type: Schema.Types.ObjectId, ref: 'Coach', required: true },
    diagnosis: { type: String, required: true },
    diagnosisDetails: { type: String },
    severity: { type: String, enum: ['MINOR', 'MODERATE', 'SEVERE', 'CRITICAL'], required: true },
    treatmentPlan: { type: String, required: true },
    medications: [{
      name: String,
      dosage: String,
      frequency: String,
      duration: String
    }],
    rehabilitationProtocol: { type: String },
    restrictionsList: [String],
    estimatedRecoveryTime: { // In weeks or days
      value: Number,
      unit: { type: String, enum: ['DAYS', 'WEEKS', 'MONTHS'] }
    },
    followUpRequired: { type: Boolean, default: true },
    appointmentScheduled: {
      date: Date,
      location: String,
      notes: String
    },
    clearanceStatus: { 
      type: String, 
      enum: ['NO_ACTIVITY', 'LIMITED_ACTIVITY', 'FULL_CLEARANCE_PENDING', 'FULLY_CLEARED'],
      default: 'NO_ACTIVITY'
    },
    testResults: [{ // For any medical tests ordered
      testType: String,
      date: Date,
      results: String,
      attachments: [String] // URLs
    }],
    notes: { type: String },
    createdAt: { type: Date, default: Date.now },
    updatedAt: { type: Date, default: Date.now }
  });

  export const InjuryAssessment = mongoose.model('InjuryAssessment', InjuryAssessmentSchema);