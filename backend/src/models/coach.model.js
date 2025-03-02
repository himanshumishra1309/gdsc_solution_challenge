import mongoose, {Schema} from "mongoose";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";


const coachSchema = new mongoose.Schema(
  {
    name: { 
      type: String, required: true
     },
    email: { 
      type: String,
       required: true, 
       unique: true
       },
    password: { type: String,
       required: [true, "Password is required"]
       },
    avatar: { type: String, required: false },
    organization: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Organization",
      required: true,
    },
    coachingExperience: { type: "String" },
    totalExperience: { type: String },
    pastOrganization: { type: String },
    dob: { type: String }, //cross check, calculate age from this
    sex: { type: String, enum: ["Male", "Female", "Other"] },
    joined_date: {
      type: Date,
      validate: {
        validator: (value) => value <= new Date(),
        message: "Date cannot be in the future.",
      },
    },
    designation: {
      type: String,
      enum: [
        "Head Coach",
        "Assistant Coach",
        "Athletes",
        "Training and Conditioning Staff",
      ],
    },
    sport: { type: String },
    specialization: { type: String },
    qualification: [{ type: String }],
    certifications: [{type: String}],
    highestLevelPlayed: {
      type: String,
      enum: ["District", "State", "National"],
    },

    assignedAthletes:[{ type: mongoose.Schema.Types.ObjectId,ref: "Athlete" }],
    refreshToken: {
      type: "String",
    },
  },
  { timestamps: true }
);

coachSchema.pre('save', async function (next) {
  if(!this.isModified("password")) return next();
  this.password = await bcrypt.hash(this.password, 10);
  next();
})

coachSchema.methods.isPasswordCorrect = async function (password) {
  return await bcrypt.compare(password, this.password); 
}

coachSchema.methods.generateAccessToken = function (){
  return jwt.sign(
      {
          _id: this.id,
          email: this.email
      },
      process.env.ACCESS_TOKEN_SECRET,
      {
          expiresIn: process.env.ACCESS_TOKEN_EXPIRY
      },
  )
}

coachSchema.methods.generateRefreshToken = function (){
  return jwt.sign(
      {
          _id: this.id,
          email: this.email
      },
      process.env.REFRESH_TOKEN_SECRET,
      {
          expiresIn: process.env.REFRESH_TOKEN_EXPIRY
      }
  )
}

export const Coach = mongoose.model("Coach", coachSchema);
