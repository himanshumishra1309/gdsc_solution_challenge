import mongoose, {Schema} from "mongoose";

const InjuryTicketSchema = new mongoose.Schema({
    injuryReport_id: { 
        type: Schema.Types.ObjectId, 
        ref: 'InjuryReport', 
        required: true 
    },

    ticketStatus: { 
        type: String, 
        enum: ['OPEN', 'IN_PROGRESS', 'CLOSED'], 
        default: 'OPEN' 
    },
}, {timestamps: true});

export const InjuryTicket = mongoose.model("InjuryTicket", InjuryTicketSchema);