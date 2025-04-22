import mongoose, {Schema} from "mongoose";

const InjuryShortMessageSchema = new mongoose.Schema({
    injury_id: { 
        type: Schema.Types.ObjectId, 
        ref: 'InjuryReport', 
        required: true 
    },
    response: { 
        type: String, 
        required: true 
    },
    medication: { 
        type: String, 
        required: true 
    },
    responseDate: { 
        type: Date, 
        default: Date.now()
    },
    doctorNote: { 
        type: String, 
        required: true 
    },
    appointmentDate: { 
        type: Date, 
        required: true 
    },
    appointmentTime: { 
        type: String, 
        required: true 
    },
}, {timestamps: true});

export const InjuryShortMessage = mongoose.model("InjuryShortMessage", InjuryShortMessageSchema);