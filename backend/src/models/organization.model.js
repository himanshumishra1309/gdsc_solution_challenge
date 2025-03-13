import mongoose, {Schema} from "mongoose";

const organizationTypeEnum = [
  "sports_club",
  "education",
  "pro_team",
  "youth",
  "association",
  "government",
  "nonprofit", 
  "company"
];

const organizationSchema = new mongoose.Schema({
  name: { 
    type: String, 
    required: true, 
    unique: true
  },
  email: { 
    type: String, 
    required: true, 
    unique: true,
    trim: true,
    lowercase: true
  },
  logo: { 
    type: String // URL or path to logo image
  },
  organizationType: { 
    type: String, 
    enum: organizationTypeEnum, 
    required: true 
  },
  certificates: {
    type: String // URL or path to certificates file
  },
  address: {
    type: String,
    required: true
  },
  country: { 
    type: String,
    required: true
  },
  state: { 
    type: String,
    required: true
  },
  admin: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: "Admin", 
    required: true
  }
}, {
  timestamps: true
});

export const Organization = mongoose.model("Organization", organizationSchema);