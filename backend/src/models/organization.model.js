import mongoose, {Schema} from "mongoose";

const sportEnum = ["Football", "Badminton", "Cricket", "Basketball", "Tennis"];

const organizationSchema = new mongoose.Schema({
  name: { type: String, required: true , unique: true},
  sportType: { 
    type: String, 
    enum: sportEnum, 
    required: true 
  },
  country: { type: String },
  city: { type: String },
  admin: { type: mongoose.Schema.Types.ObjectId, ref: "Admin" }, // Central admin of the org
  createdAt: { type: Date, default: Date.now }
});

export const Organization = mongoose.model("Organization", organizationSchema);
