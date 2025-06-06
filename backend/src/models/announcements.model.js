import mongoose, {Schema} from "mongoose";

const AnnouncementSchema = new mongoose.Schema({
  title: { type: String, required: true },
  content: { type: String, required: true},
  createddBy: {type: Schema.Types.ObjectId, ref: "Coach"},
  sports: [{type: String}]

}, { timestamps: true });

export const Announcement = mongoose.model('Announcement', AnnouncementSchema);
