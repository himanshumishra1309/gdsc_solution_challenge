import asyncHandler from "../utils/asyncHandler.js";
import ApiError from "../utils/ApiError.js";
import { Athlete } from "../models/athlete.model.js";
import { Admin } from "../models/admin.model.js";
import FinancialRecord from "../models/financialrecord.model.js";
import ApiResponse from "../utils/ApiResponse.js";
import mongoose from "mongoose";

const addFinancialRecord = asyncHandler(async (req, res) => {
  const { 
    athleteId, 
    category, 
    type, 
    amount, 
    currency, 
    isReimbursable, 
    notes,
    status,
    icon
  } = req.body;

  // Check authorization: allow both admins and the individual athlete
  let authorized = false;
  let userRole = '';
  
  if (req.user instanceof Admin) {
    authorized = true;
    userRole = 'admin';
  } else if (req.user && req.user.role === 'athlete') {
    if (req.user._id.toString() === athleteId) {
      authorized = true;
      userRole = 'athlete';
    }
  }

  if (!authorized) {
    throw new ApiError(
      403,
      "Access denied. Only admins or the athlete themselves can add financial records."
    );
  }

  // Validate required fields
  if (!athleteId || !category || !amount || !type) {
    throw new ApiError(
      400,
      "Missing required fields: athleteId, category, amount, type."
    );
  }
  
  if (amount <= 0) {
    throw new ApiError(400, "Amount must be a positive number.");
  }

  if (!["Income", "Expense"].includes(type)) {
    throw new ApiError(400, "Invalid type. Must be 'Income' or 'Expense'.");
  }

  // Validate category against enum values from the UI
  const validCategories = [
    // Income Categories
    "Salary/Stipend",
    "Prize Money Allocation",
    "Sponsorship Deals",
    "Training and Facility Sponsorship",
    "Travel and Accomodation Support",
    "Medical And Insurance Coverage",
    "Team/Club Budget Allocation",
    "Funding Request and Approval",
    "Financial Aid and Loan",
    "Salary and Payment Statement",
    "Annual Financial Summary",
    
    // Expense Categories
    "Coaching Fees",
    "Team Equipment and Gear Cost",
    "Medical and Physiotherapy",
    "Nutrition and Supplements",
    "Tax Deductions",
    "Fines and Penalties",
    "Expense Breakdown",
    "Pending Approval"
  ];

  if (!validCategories.includes(category)) {
    throw new ApiError(400, `Invalid category. Valid categories are: ${validCategories.join(', ')}`);
  }

  // Find the athlete
  const athlete = await Athlete.findById(athleteId);
  if (!athlete) {
    throw new ApiError(404, "Athlete not found.");
  }

  // Athletes can only add records with specific statuses
  if (userRole === 'athlete') {
    if (status && !['Pending'].includes(status)) {
      throw new ApiError(403, "Athletes can only create records with 'Pending' status.");
    }
    // Force pending status for athlete-created records
    status = 'Pending';
  }

  // Calculate balance after transaction
  let balanceAfterTransaction;
  const lastRecord = await FinancialRecord.findOne({ athlete: athleteId })
    .sort({ createdAt: -1 });
  
  const lastBalance = lastRecord ? lastRecord.balanceAfterTransaction || 0 : 0;
  balanceAfterTransaction = lastBalance + (type === 'Income' ? amount : -amount);

  // Set appropriate icon based on category
  let defaultIcon = type === 'Income' ? 'attach_money' : 'money_off';
  
  // Create the financial record
  const financialRecord = await FinancialRecord.create({
    athlete: athleteId,
    type,
    category,
    amount,
    currency: currency || "INR",
    status: status || (userRole === 'athlete' ? 'Pending' : 'Completed'),
    isReimbursable: isReimbursable || false,
    reimbursementStatus: isReimbursable ? 'Pending' : undefined,
    notes: notes || "",
    icon: icon || defaultIcon,
    balanceAfterTransaction,
    // Add organization reference if available
    ...(athlete.organization && { 
      referenceId: athlete.organization,
      referenceModel: 'Organization'
    })
  });

  res.status(201).json(
    new ApiResponse(
      201,
      financialRecord,
      "Financial record added successfully."
    )
  );
});

const getFinancialRecords = asyncHandler(async (req, res) => {
  const { user } = req;
  const { athleteId } = req.params;
  const {
    page = 1,
    limit = 10,
    startDate,
    endDate,
    category,
    type,
    status,
    minAmount,
    maxAmount,
    sort = "-date",
    pending = false // New filter for pending transactions
  } = req.query;

  const pageSize = Math.max(1, parseInt(limit));
  const skip = (Math.max(1, parseInt(page)) - 1) * pageSize;

  let query = { isDeleted: false };

  // Authorization check
  if (user.role === 'admin') {
    // Admin can view any athlete's records within their organization
    if (athleteId) {
      query.athlete = athleteId;
    } else {
      // If no athlete specified, limit to admin's organization
      const adminOrganization = user.organization;
      if (!adminOrganization) {
        throw new ApiError(403, "Access Denied. No organization linked.");
      }
      
      // Find athletes in this organization
      const athletesInOrg = await Athlete.find({ organization: adminOrganization }).select('_id');
      const athleteIds = athletesInOrg.map(a => a._id);
      
      query.athlete = { $in: athleteIds };
    }
  } else if (user.role === 'athlete') {
    // Athletes can only view their own records
    if (athleteId && athleteId !== user._id.toString()) {
      throw new ApiError(403, "Access Denied. Athletes can only view their own records.");
    }
    query.athlete = user._id;
  } else {
    throw new ApiError(403, "Access Denied.");
  }

  // Apply filters
  if (startDate && endDate) {
    query.date = { $gte: new Date(startDate), $lte: new Date(endDate) };
  }

  if (category) {
    query.category = category;
  }

  if (type) {
    query.type = type;
  }

  if (status) {
    query.status = status;
  }

  // Handle pending filter (combining status and reimbursement status)
  if (pending === 'true') {
    query.$or = [
      { status: 'Pending' },
      { reimbursementStatus: 'Pending' }
    ];
  }

  if (minAmount || maxAmount) {
    query.amount = {};
    if (minAmount) query.amount.$gte = parseFloat(minAmount);
    if (maxAmount) query.amount.$lte = parseFloat(maxAmount);
  }

  // Execute query
  const [financialRecords, totalCount] = await Promise.all([
    FinancialRecord.find(query)
      .sort(sort)
      .skip(skip)
      .limit(pageSize)
      .populate('athlete', 'name avatar')
      .lean(),
    FinancialRecord.countDocuments(query)
  ]);

  // Calculate summary statistics
  const summaryStats = await calculateFinancialSummary(query);

  // Response
  res.status(200).json(
    new ApiResponse(
      200,
      {
        records: financialRecords,
        pagination: {
          total: totalCount,
          pages: Math.ceil(totalCount / pageSize),
          page: parseInt(page),
          limit: pageSize
        },
        summary: summaryStats
      },
      "Financial records retrieved successfully."
    )
  );
});

// Helper function to calculate financial summary
const calculateFinancialSummary = async (query) => {
  const summary = await FinancialRecord.aggregate([
    { $match: query },
    {
      $group: {
        _id: '$type',
        total: { $sum: '$amount' }
      }
    }
  ]);

  const income = summary.find(item => item._id === 'Income')?.total || 0;
  const expense = summary.find(item => item._id === 'Expense')?.total || 0;
  const balance = income - expense;

  return { income, expense, balance };
};

const updateFinancialRecord = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const updates = req.body;
  const { user } = req;

  // Find record first to check authorization
  const financialRecord = await FinancialRecord.findById(id);
  if (!financialRecord) {
    throw new ApiError(404, "Financial record not found");
  }

  // Authorization check
  let authorized = false;
  
  if (user.role === 'admin') {
    // Admin can update any record in their organization
    authorized = true;
  } else if (user.role === 'athlete' && user._id.toString() === financialRecord.athlete.toString()) {
    // Athletes can only update their own records with Pending status
    if (financialRecord.status !== 'Pending') {
      throw new ApiError(403, "Athletes can only update pending records");
    }
    
    // Athletes can only update certain fields
    const allowedFields = ['notes', 'category', 'amount', 'isReimbursable'];
    const attemptedFields = Object.keys(updates);
    
    const unauthorizedFields = attemptedFields.filter(field => !allowedFields.includes(field));
    if (unauthorizedFields.length > 0) {
      throw new ApiError(403, `Athletes cannot update the following fields: ${unauthorizedFields.join(', ')}`);
    }
    
    authorized = true;
  }

  if (!authorized) {
    throw new ApiError(403, "Access denied");
  }

  // Validate category if provided
  if (updates.category) {
    const validCategories = [
      "Salary/Stipend", "Prize Money Allocation", "Sponsorship Deals",
      "Training & Facility Sponsorship", "Travel & Accommodation Support",
      "Medical & Insurance Coverage", "Team/Club Budget Allocation",
      "Funding Requests & Approvals", "Financial Aid & Loans",
      "Salary & Payment Statements", "Annual Financial Summary",
      "Coaching Fees", "Team Equipment & Gear Costs", "Medical & Physiotherapy",
      "Nutrition & Supplements", "Tax Deductions", "Fines & Penalties",
      "Expense Breakdown"
    ];

    if (!validCategories.includes(updates.category)) {
      throw new ApiError(400, "Invalid category.");
    }
  }

  // Update the record
  const updatedRecord = await FinancialRecord.findByIdAndUpdate(id, updates, {
    new: true,
    runValidators: true
  });

  res.status(200).json(
    new ApiResponse(
      200,
      updatedRecord,
      "Financial record updated successfully."
    )
  );
});

const softDeleteFinancialRecord = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const { user } = req;

  const financialRecord = await FinancialRecord.findById(id);
  if (!financialRecord) {
    throw new ApiError(404, "Financial record not found.");
  }

  // Authorization check
  if (user.role === 'admin') {
    // Admin can delete any record
  } else if (user.role === 'athlete' && user._id.toString() === financialRecord.athlete.toString()) {
    // Athletes can only delete their own Pending records
    if (financialRecord.status !== 'Pending') {
      throw new ApiError(403, "Athletes can only delete pending records");
    }
  } else {
    throw new ApiError(403, "Access denied");
  }

  financialRecord.isDeleted = true;
  financialRecord.deletedAt = new Date();
  await financialRecord.save();

  // If you have AuditLog functionality
  if (typeof AuditLog !== 'undefined') {
    await AuditLog.create({
      action: "DELETED",
      entityType: "FinancialRecord",
      entityId: id,
      performedBy: user._id,
      details: {
        amount: financialRecord.amount,
        category: financialRecord.category,
      },
    });
  }

  // If you have Notification functionality
  if (typeof Notification !== 'undefined') {
    await Notification.create({
      recipientId: financialRecord.athlete,
      recipientType: "athlete",
      message: `Your financial record (${financialRecord.category}, ${financialRecord.amount} ${financialRecord.currency}) has been deleted.`,
    });
  }

  res.status(200).json(
    new ApiResponse(
      200,
      null,
      "Financial record deleted successfully (soft delete)."
    )
  );
});

const restoreFinancialRecord = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const { user } = req;

  const financialRecord = await FinancialRecord.findById(id);
  if (!financialRecord) {
    throw new ApiError(404, "Financial record not found.");
  }

  // Only admins can restore records
  if (user.role !== 'admin') {
    throw new ApiError(403, "Access denied. Only admins can restore records.");
  }

  if (!financialRecord.isDeleted) {
    throw new ApiError(400, "Financial record is already active.");
  }

  financialRecord.isDeleted = false;
  financialRecord.deletedAt = null;
  await financialRecord.save();

  // If you have AuditLog functionality
  if (typeof AuditLog !== 'undefined') {
    await AuditLog.create({
      action: "RESTORED",
      entityType: "FinancialRecord",
      entityId: id,
      performedBy: user._id,
    });
  }

  // If you have Notification functionality
  if (typeof Notification !== 'undefined') {
    await Notification.create({
      recipientId: financialRecord.athlete,
      recipientType: "athlete",
      message: `Your financial record (${financialRecord.category}, ${financialRecord.amount} ${financialRecord.currency}) has been restored.`,
    });
  }

  res.status(200).json(
    new ApiResponse(
      200, 
      null, 
      "Financial record restored successfully."
    )
  );
});

const getAuditLogs = asyncHandler(async (req, res) => {
  let {
    page = 1,
    limit = 10,
    sortBy = "timestamp",
    order = "desc",
  } = req.query;

  page = parseInt(page);
  limit = parseInt(limit);
  order = order === "asc" ? 1 : -1;

  const logs = await AuditLog.find()
    .sort({ [sortBy]: order })
    .skip((page - 1) * limit)
    .limit(limit)
    .lean();

  const totalLogs = await AuditLog.countDocuments();

  res
    .status(200)
    .json(
      new ApiResponse(
        200,
        { logs, totalPages: Math.ceil(totalLogs / limit) },
        "Audit logs retrieved successfully."
      )
    );
});

export {
  addFinancialRecord,
  getFinancialRecords,
  updateFinancialRecord,
  softDeleteFinancialRecord,
  restoreFinancialRecord,
  getAuditLogs,
};
