import mongoose, {Schema} from "mongoose";

const athleteSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    password: { type: String, required: [true, "Password is Required"] },
    avatar: { type: String, required: true },
    organization: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Organization",
      required: true,
    },
    totalExperience: { type: String },
    dob: { type: String }, //cross check, calculate age from this
    sex: { type: String, enum: ["Male", "Female", "Other"] },
    joined_date: { type: Date },
    sport: { type: String, enum: ["Cricket", "Basketball"] },
    currentLevel: {
      type: String,
      enum: ["Club", "District", "State", "National", "International"],
    },
    highestLevelPlayed: {
      type: String,
      enum: ["District", "State", "National"],
    
    },
    jerseyNo: {type: Number},
    teamRole: {type: String},
    qualifications: [{
      type: String,
      
    }],
    achievements: [{type: String}],

    InjuryRecords: [{type: String}],

    coach: {
      type: Schema.Types.ObjectId,
      ref: 'Coach'
    },
    refreshToken: {
      type: "String"
    }
  },

  { timestamps: true }
);

athleteSchema.pre('save', async function (next) {
  if(!this.isModified("password")) return next();
  this.password = await bcrypt.hash(this.password, 10);
  next();
})

athleteSchema.methods.isPasswordCorrect = async function (password) {
  return await bcrypt.compare(password, this.password); 
}

athleteSchema.methods.generateAccessToken = function (){
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

athleteSchema.methods.generateRefreshToken = function (){
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

module.exports = mongoose.model("Athlete", athleteSchema);
