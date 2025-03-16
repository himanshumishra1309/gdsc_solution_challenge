import asyncHandler from "../utils/asyncHandler.js";
import ApiError from "../utils/ApiError.js";
import {Athlete} from "../models/athlete.model.js";
import {Admin} from "../models/admin.model.js";
import FinancialRecord from "../models/financialrecord.model.js"
import  ApiResponse  from "../utils/ApiResponse.js";





/**
 * @desc Add a financial record (Admin only)
 * @route POST /api/v1/finances
 * @access Private (Admins Only)
 *  * @param   {Object} req - Express request object
 * @param   {Object} req.body - Request body
 * @param   {string} req.body.athleteId - ID of the athlete
 * @param   {string} req.body.type - Type of transaction (Income or Expense)
 * @param   {string} req.body.category - Category of financial record
 * @param   {number} req.body.amount - Amount of transaction
 * @param   {string} [req.body.currency="INR"] - Currency (default: INR)
 * @param   {boolean} [req.body.isReimbursable=false] - Whether the amount is reimbursable
 * @param   {string} [req.body.notes=""] - Additional notes
 * @param   {Object} res - Express response object
 */
const addFinancialRecord = asyncHandler(async (req, res) => {
    const { athleteId, category, type, amount, currency, isReimbursable, notes } = req.body;

    // ✅ Ensure the user is an admin
    if (!(req.user instanceof Admin)) {
        throw new ApiError(403, "Access denied. Only admins can add financial records.");
    }

    // ✅ Input Validation
    if (!athleteId || !category || !amount || !type) {
        throw new ApiError(400, "Missing required fields: athleteId, category, amount.");
    }
    if (amount <= 0) {
        throw new ApiError(400, "Amount must be a positive number.");
    }
        // ✅ Validate the `type` field
        if (!["Income", "Expense"].includes(type)) {
            throw new ApiError(400, "Invalid type. Must be 'Income' or 'Expense'.");
        }

    // ✅ Check if the athlete exists
    const athlete = await Athlete.findById(athleteId);
    if (!athlete) {
        throw new ApiError(404, "Athlete not found.");
    }

    // ✅ Create the financial record
    const financialRecord = await FinancialRecord.create({
        athlete: athleteId,
        type,
        category,
        amount,
        currency, // If not provided, defaults to INR
        isReimbursable: isReimbursable || false,
        notes: notes || "",
    });

    // ✅ Return the saved record
    res.status(201).json({
        success: true,
        message: "Financial record added successfully.",
        data: financialRecord,
    });
});

/**
 * @desc    Fetch financial records with optional filters & RBAC
 * @route   GET /api/v1/finances
 * @route   GET /api/v1/finances/:athleteId
 * @access  Private (Admins see all, others see only of own organization)
 * @param   {Object} req - Express request object
 * @param   {Object} req.params - Request parameters
 * @param   {string} [req.params.athleteId] - (Optional) Filter by athlete ID
 * @param   {Object} req.query - Request query parameters
 * @param   {number} [req.query.page=1] - Page number for pagination
 * @param   {number} [req.query.limit=10] - Items per page
 * @param   {string} [req.query.startDate] - Start date filter (YYYY-MM-DD)
 * @param   {string} [req.query.endDate] - End date filter (YYYY-MM-DD)
 * @param   {string} [req.query.category] - Filter by category (e.g., Sponsorship)
 * @param   {number} [req.query.minAmount] - Minimum amount filter
 * @param   {number} [req.query.maxAmount] - Maximum amount filter
 * @param   {string} [req.query.description] - Filter by description (partial match)
 * @param   {string} [req.query.sort="-date"] - Sorting order (default: newest first)
 * @returns {Object} - JSON response with financial records
 */
const getFinancialRecords = asyncHandler(async (req, res) => {
    const { user } = req; // ✅ Authenticated user from verifyJWT
    const { athleteId } = req.params; // ✅ Optional Athlete ID (single user fetch)
    const { page = 1, limit = 10, startDate, endDate, category, minAmount, maxAmount, description, sort = "-date" } = req.query;

    // ✅ Pagination Setup
    const pageSize = Math.max(1, parseInt(limit));
    const skip = (Math.max(1, parseInt(page)) - 1) * pageSize;

    let query = { isDeleted: false }; // ✅ Ignore soft-deleted records

    // ✅ Fetch only for a specific athlete if `athleteId` is provided
    if (athleteId) {
        query.athlete = athleteId;
    }

    // ✅ 1. Filter by Date Range
    if (startDate && endDate) {
        query.date = { $gte: new Date(startDate), $lte: new Date(endDate) };
    }

    // ✅ 2. Filter by Category (Case-insensitive)
    if (category) {
        query.category = { $regex: new RegExp(category, "i") };
    }

    // ✅ 3. Filter by Amount Range
    if (minAmount || maxAmount) {
        query.amount = {};
        if (minAmount) query.amount.$gte = parseFloat(minAmount);
        if (maxAmount) query.amount.$lte = parseFloat(maxAmount);
    }

    // ✅ 4. Filter by Description (Case-insensitive, Partial Match)
    if (description) {
        query.description = { $regex: new RegExp(description, "i") };
    }

    // ✅ Role-Based Access Control (RBAC)
    if (user.role === "admin") {
        // Admins see all financial records
    } else if (["coach", "athlete"].includes(user.role)) {
        // Coaches & Athletes see only their organization's records



        if (!user.organization) {
            throw new ApiError(403, "Access Denied. No organization linked.");
        }
        query.organizationId = user.organization; // Use `user.organization`, not `user.organizationId`
        
    } else {
        throw new ApiError(403, "Access Denied.");
    }

    // ✅ Fetch records with filters, pagination, and sorting
    const financialRecords = await FinancialRecord.find(query)
        .sort(sort)
        .skip(skip)
        .limit(pageSize)
        .lean();

    if (!financialRecords.length) {
        throw new ApiError(404, "No financial records found.");
    }

    // ✅ Return API Response
    res.status(200).json(new ApiResponse(200, financialRecords, "Financial records retrieved successfully."));
});

/**
 * @desc Update a financial record
 * @route PUT /api/v1/finances/:id
 * @access Private (Admin only)
 */
const updateFinancialRecord = asyncHandler(async (req, res) => {
    const { id } = req.params; // Get the record ID from URL
    const updates = req.body; // Get updated data from request body

    const updatedRecord = await FinancialRecord.findByIdAndUpdate(id, updates, { new: true });

    if (!updatedRecord) {
        throw new ApiError(404, "Financial record not found");
    }

    res.status(200).json(new ApiResponse(200, updatedRecord, "Financial record updated successfully."));
});

/**
 * @desc Delete a financial record
 * @route DELETE /api/v1/finances/:id
 * @access Private (Admin only)
 */
const softDeleteFinancialRecord = asyncHandler(async (req, res) => {
    const { id } = req.params;

    const financialRecord = await FinancialRecord.findById(id);
    if (!financialRecord) {
        throw new ApiError(404, "Financial record not found.");
    }

    // ✅ Soft delete the record
    financialRecord.isDeleted = true;
    financialRecord.deletedAt = new Date();
    await financialRecord.save();

        // ✅ Create audit log
        await AuditLog.create({
            action: "DELETED",
            entityType: "FinancialRecord",
            entityId: id,
            performedBy: req.user._id,
            details: { amount: financialRecord.amount, category: financialRecord.category }
        });

            // ✅ Send notification to the athlete
    await Notification.create({
        recipientId: financialRecord.athlete, // The athlete's ID
        recipientType: "athlete", // Since this record belongs to an athlete
        message: `Your financial record (${financialRecord.category}, ${financialRecord.amount} ${financialRecord.currency}) has been deleted.`,
    });


    res.status(200).json(new ApiResponse(200, null, "Financial record deleted successfully (soft delete)."));
});

/**
 * @desc Restore a soft-deleted financial record
 * @route PUT /api/v1/finances/:id/restore
 * @access Private (Admin Only)
 */
const restoreFinancialRecord = asyncHandler(async (req, res) => {
    const { id } = req.params;

    const financialRecord = await FinancialRecord.findById(id);
    if (!financialRecord) {
        throw new ApiError(404, "Financial record not found.");
    }

    if (!financialRecord.isDeleted) {
        throw new ApiError(400, "Financial record is already active.");
    }

    // ✅ Restore the record
    financialRecord.isDeleted = false;
    financialRecord.deletedAt = null;
    await financialRecord.save();

     // ✅ Create audit log
     await AuditLog.create({
        action: "RESTORED",
        entityType: "FinancialRecord",
        entityId: id,
        performedBy: req.user._id
    });

        // ✅ Send notification to the athlete
        await Notification.create({
            recipientId: financialRecord.athlete,
            recipientType: "athlete",
            message: `Your financial record (${financialRecord.category}, ${financialRecord.amount} ${financialRecord.currency}) has been restored.`,
        });
        
    res.status(200).json(new ApiResponse(200, null, "Financial record restored successfully."));
});

const getAuditLogs = asyncHandler(async (req, res) => {
    let { page = 1, limit = 10, sortBy = "timestamp", order = "desc" } = req.query;

    page = parseInt(page);
    limit = parseInt(limit);
    order = order === "asc" ? 1 : -1;

    const logs = await AuditLog.find()
        .sort({ [sortBy]: order })
        .skip((page - 1) * limit)
        .limit(limit)
        .lean();

    const totalLogs = await AuditLog.countDocuments();

    res.status(200).json(
        new ApiResponse(200, { logs, totalPages: Math.ceil(totalLogs / limit) }, "Audit logs retrieved successfully.")
    );
});

export{
    addFinancialRecord,
    getFinancialRecords,
    updateFinancialRecord,
    softDeleteFinancialRecord,
    restoreFinancialRecord,
    getAuditLogs
}