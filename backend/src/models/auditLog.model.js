const auditLogSchema = new mongoose.Schema({
    action: { type: String, enum: ["CREATED", "UPDATED", "DELETED", "RESTORED"], required: true },
    entityType: { type: String, required: true }, // e.g., "FinancialRecord"
    entityId: { type: mongoose.Schema.Types.ObjectId, required: true },
    performedBy: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    timestamp: { type: Date, default: Date.now },
    details: { type: Object }, // Optional: Stores extra details like previous values
});
const AuditLog = mongoose.model("AuditLog", auditLogSchema);

export default AuditLog;