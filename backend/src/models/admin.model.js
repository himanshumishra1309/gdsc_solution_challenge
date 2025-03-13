import mongoose, {Schema} from "mongoose";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";


const adminSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: [true, "Password is Required"]},
  avatar: {
    type: String,
  },
  organization: {
    type: Schema.Types.ObjectId,
    ref: "Organization",
    required: true,

  },
  role : {
    type: String, 
    default: "admin"
  },
  refreshToken: {
    type: "String"
  }
}, { timestamps: true });

adminSchema.pre('save', async function (next) {
  if(!this.isModified("password")) return next();
  this.password = await bcrypt.hash(this.password, 10);
  next();
})

adminSchema.methods.isPasswordCorrect = async function (password) {
  return await bcrypt.compare(password, this.password); 
}

adminSchema.methods.generateAccessToken = function (){
  return jwt.sign(
      {
          _id: this.id,
          email: this.email
      },
      process.env.ACCESS_TOKEN_SECRET,
      {
          expiresIn: process.env.ACCESS_TOKEN_EXPIRY
      }
  )
}

adminSchema.methods.generateRefreshToken = function (){
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

export const Admin = mongoose.model('Admin', adminSchema);