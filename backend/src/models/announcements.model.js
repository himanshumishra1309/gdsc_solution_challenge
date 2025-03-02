import mongoose, {Schema} from "mongoose";

const AnnoncementSchema = new mongoose.Schema({
  title: { type: String, required: true },
  content: { type: String, required: true},
  createddBy: {type: Schema.Types.ObjectId, ref: "Coach"},
  attachment: [{type: String}]

}, { timestamps: true });

export const Announcement = mongoose.model('Announcement', AnnouncementSchema);
