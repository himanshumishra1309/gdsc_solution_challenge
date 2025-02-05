import mongoose, {Schema} from "mongoose";

const AnnoncementSchema = new mongoose.Schema({
  title: { type: String, required: true },
  content: { type: String, required: true},
  createddBy: {type: Schema.Types.ObjectId, ref: "Coach"},
  attachment: [{type: String}]

}, { timestamps: true });

module.exports = mongoose.model('Announcement', AnnouncementSchema);
