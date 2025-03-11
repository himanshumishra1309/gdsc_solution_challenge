const achievementSchema = new mongoose.Schema({
    athleteId: { type: mongoose.Schema.Types.ObjectId, ref: "Athlete", required: true },
    title: { type: String, required: true },
    description: { type: String },
    date: { type: Date, required: true },
  });
  
  export const AthleteAchievement = mongoose.model("AthleteAchievement", achievementSchema);
  