import { MedicalReport } from "../models/medicalReport.models.js";
import { Athlete } from "../models/athlete.model.js";
import asyncHandler from "../utils/asyncHandler.js";
import ApiError from "../utils/ApiError.js";
import ApiResponse from "../utils/ApiResponse.js";
import mongoose from "mongoose";

const createMedicalReport = asyncHandler(async (req, res) => {
  const {
    // Required fields
    athleteId,
    
    // Report metadata
    testName,
    testDate,
    nextCheckupDate,
    
    // Medical status
    medicalStatus,
    medicalClearance,
    chronicMedicalCondition,
    prescribedMedication,
    
    // Vitals
    vitals,
    
    // Performance metrics
    performanceMetrics,
    
    // Injury details
    injuryDetails,
    
    // Test results
    testResults,
    
    // Nutrition
    nutrition,
    
    // Mental health
    mentalHealth,
    
    // Notes and recommendations
    doctorsNotes,
    physicianNotes,
    recommendations,
    
    // Additional data
    additionalData,
    isArchived
  } = req.body;

  // Check if all required fields are present
  if (!athleteId) {
    throw new ApiError(400, "Athlete ID is required");
  }

  // Check if athlete exists
  const athlete = await Athlete.findById(athleteId);
  if (!athlete) {
    throw new ApiError(404, "Athlete not found");
  }

  // Extract medical staff ID from the authenticated user
  const medicalStaffId = req.coach._id;
  
  // Prepare data for creating the medical report
  const reportData = {
    // Core relationships
    athleteId,
    medicalStaffId,
    organizationId: req.coach.organization,
    
    // Report metadata
    reportDate: new Date(),
    nextCheckupDate: nextCheckupDate ? new Date(nextCheckupDate) : undefined,
    testName,
    testDate,
    
    // Medical status
    medicalStatus: medicalStatus || "Active",
    medicalClearance: medicalClearance || "Pending Evaluation",
    chronicMedicalCondition,
    prescribedMedication,
    
    // Other sections - only include if provided
    ...(vitals && { vitals }),
    ...(performanceMetrics && { performanceMetrics }),
    ...(injuryDetails && { injuryDetails }),
    ...(testResults && { testResults }),
    ...(nutrition && { nutrition }),
    ...(mentalHealth && { mentalHealth }),
    
    // Notes and recommendations
    doctorsNotes,
    physicianNotes,
    recommendations: recommendations ? (Array.isArray(recommendations) ? recommendations : [recommendations]) : [],
    
    // Additional data
    ...(additionalData && { additionalData }),
    isArchived: isArchived || false,
    
    // Creator reference
    createdBy: medicalStaffId
  };
  
  // Create the medical report
  const newMedicalReport = await MedicalReport.create(reportData);
  
  // Handle file uploads
  if (req.files && req.files.length > 0) {
    // Process attachments with proper metadata
    const attachments = req.files.map(file => ({
      name: file.originalname || file.filename,
      fileUrl: file.path,
      type: file.mimetype?.split('/')[0] || 'document',
      uploadDate: new Date()
    }));
    
    // Add attachments and reportFileUrl
    const fileUrls = req.files.map(file => file.path);
    
    newMedicalReport.attachments = attachments;
    newMedicalReport.reportFileUrl = fileUrls;
    await newMedicalReport.save();
  }

  // Fetch the complete report with populated references
  const populatedReport = await MedicalReport.findById(newMedicalReport._id)
    .populate("athleteId", "name email sports")
    .populate("medicalStaffId", "name email designation");

  return res
    .status(201)
    .json(new ApiResponse(201, populatedReport, "Medical report created successfully"));
});

const getMedicalReportsByDate = asyncHandler(async (req, res) => {
  const { date, athleteId } = req.query;

  if (!date) {
    throw new ApiError(400, "Date is required");
  }

  // Create date objects for the start and end of the specified day
  const startDate = new Date(date);
  startDate.setHours(0, 0, 0, 0);
  
  const endDate = new Date(date);
  endDate.setHours(23, 59, 59, 999);

  const query = {
    reportDate: {
      $gte: startDate,
      $lte: endDate
    }
  };

  // Filter by athlete if provided
  if (athleteId) {
    query.athleteId = athleteId;
  }

  // If the user is a medical staff, only show reports for their organization
  if (req.coach && req.coach.organization) {
    query.organizationId = req.coach.organization;
  }

  const medicalReports = await MedicalReport.find(query)
    .populate("athleteId", "name email sports")
    .populate("medicalStaffId", "name email designation")
    .populate("prescribedMedication")
    .sort({ reportDate: -1 });

  if (medicalReports.length === 0) {
    return res
      .status(200)
      .json(new ApiResponse(200, [], "No medical reports found for this date"));
  }

  return res
    .status(200)
    .json(new ApiResponse(
      200, 
      medicalReports, 
      `${medicalReports.length} medical reports found for ${date}`
    ));
});

const getMedicalReportDates = asyncHandler(async (req, res) => {
  const { athleteId, startDate, endDate } = req.query;

  const query = {};

  // Filter by athlete if provided
  if (athleteId) {
    query.athleteId = athleteId;
  }

  // Filter by organization if user is a coach
  if (req.coach && req.coach.organization) {
    query.organizationId = req.coach.organization;
  }

  // Add date range filter if provided
  if (startDate && endDate) {
    query.reportDate = {
      $gte: new Date(startDate),
      $lte: new Date(endDate)
    };
  }

  // Use MongoDB aggregation to get unique dates
  const reportDates = await MedicalReport.aggregate([
    { $match: query },
    {
      $project: {
        date: {
          $dateToString: { format: "%Y-%m-%d", date: "$reportDate" }
        },
        testName: 1,
        athleteId: 1,
        medicalStatus: 1
      }
    },
    {
      $group: {
        _id: "$date",
        count: { $sum: 1 },
        tests: { 
          $push: { 
            test: "$testName", 
            athlete: "$athleteId",
            status: "$medicalStatus" 
          } 
        }
      }
    },
    { $sort: { _id: -1 } } // Sort by date descending
  ]);

  // If athlete IDs are present, populate athlete names
  if (reportDates.length > 0 && reportDates[0].tests && reportDates[0].tests.length > 0) {
    // Get all athlete IDs
    const athleteIds = [...new Set(
      reportDates.flatMap(date => date.tests.map(test => test.athlete))
    )];
    
    // Fetch athlete names in one query
    const athletes = await Athlete.find({ _id: { $in: athleteIds } })
      .select('_id name')
      .lean();
    
    // Create a map of ID to name for quick lookup
    const athleteMap = {};
    athletes.forEach(athlete => {
      athleteMap[athlete._id.toString()] = athlete.name;
    });
    
    // Add athlete names to the response
    reportDates.forEach(date => {
      date.tests.forEach(test => {
        if (test.athlete) {
          const athleteIdStr = test.athlete.toString();
          test.athleteName = athleteMap[athleteIdStr] || 'Unknown';
        }
      });
    });
  }

  return res
    .status(200)
    .json(new ApiResponse(
      200, 
      reportDates, 
      `Found reports on ${reportDates.length} different dates`
    ));
});

const updateMedicalReport = asyncHandler(async (req, res) => {
  const { reportId } = req.params;
  
  // Find the report
  const report = await MedicalReport.findById(reportId);
  
  if (!report) {
    throw new ApiError(404, "Medical report not found");
  }
  
  // Check if the report was created by the current user
  if (report.medicalStaffId.toString() !== req.coach._id.toString()) {
    throw new ApiError(403, "You are not authorized to update this report");
  }
  
  // Check if the report is less than 24 hours old
  const reportCreationTime = report.createdAt || report.reportDate;
  const currentTime = new Date();
  const timeDifference = currentTime - reportCreationTime;
  const hoursDifference = timeDifference / (1000 * 60 * 60);
  
  if (hoursDifference > 24) {
    throw new ApiError(
      403, 
      "Medical reports can only be updated within 24 hours of creation"
    );
  }
  
  // Extract all fields to update from request body
  const {
    // Report metadata
    testName,
    testDate,
    nextCheckupDate,
    
    // Medical status
    medicalStatus,
    medicalClearance,
    chronicMedicalCondition,
    prescribedMedication,
    
    // Vitals
    vitals,
    
    // Performance metrics
    performanceMetrics,
    
    // Injury details
    injuryDetails,
    
    // Test results
    testResults,
    
    // Nutrition
    nutrition,
    
    // Mental health
    mentalHealth,
    
    // Notes and recommendations
    doctorsNotes,
    physicianNotes,
    recommendations,
    
    // Additional data
    additionalData,
    isArchived
  } = req.body;
  
  // Create update object with only the fields that are provided
  const updateData = {};
  
  // Report metadata
  if (testName !== undefined) updateData.testName = testName;
  if (testDate !== undefined) updateData.testDate = testDate;
  if (nextCheckupDate !== undefined) updateData.nextCheckupDate = new Date(nextCheckupDate);
  
  // Medical status
  if (medicalStatus !== undefined) updateData.medicalStatus = medicalStatus;
  if (medicalClearance !== undefined) updateData.medicalClearance = medicalClearance;
  if (chronicMedicalCondition !== undefined) updateData.chronicMedicalCondition = chronicMedicalCondition;
  if (prescribedMedication !== undefined) updateData.prescribedMedication = prescribedMedication;
  
  // Vitals - handle as nested object
  if (vitals) {
    updateData.vitals = {
      ...report.vitals || {},
      ...vitals
    };
  }
  
  // Performance metrics - handle as nested object
  if (performanceMetrics) {
    updateData.performanceMetrics = {
      ...report.performanceMetrics || {},
      ...performanceMetrics
    };
  }
  
  // Injury details - handle as nested object
  if (injuryDetails) {
    updateData.injuryDetails = {
      ...report.injuryDetails || {},
      ...injuryDetails
    };
    
    // Special handling for arrays within injuryDetails
    if (injuryDetails.currentInjuries) {
      updateData.injuryDetails.currentInjuries = injuryDetails.currentInjuries;
    }
  }
  
  // Test results - handle as nested object
  if (testResults) {
    updateData.testResults = {
      ...report.testResults || {},
      ...testResults
    };
    
    // Special handling for arrays within testResults
    if (testResults.additionalResults) {
      updateData.testResults.additionalResults = testResults.additionalResults;
    }
  }
  
  // Nutrition - handle as nested object
  if (nutrition) {
    updateData.nutrition = {
      ...report.nutrition || {},
      ...nutrition
    };
    
    // Special handling for arrays within nutrition
    if (nutrition.supplements) {
      updateData.nutrition.supplements = nutrition.supplements;
    }
    if (nutrition.dietaryRestrictions) {
      updateData.nutrition.dietaryRestrictions = nutrition.dietaryRestrictions;
    }
  }
  
  // Mental health - handle as nested object
  if (mentalHealth) {
    updateData.mentalHealth = {
      ...report.mentalHealth || {},
      ...mentalHealth
    };
  }
  
  // Notes and recommendations
  if (doctorsNotes !== undefined) updateData.doctorsNotes = doctorsNotes;
  if (physicianNotes !== undefined) updateData.physicianNotes = physicianNotes;
  if (recommendations !== undefined) {
    updateData.recommendations = Array.isArray(recommendations) ? recommendations : [recommendations];
  }
  
  // Additional data
  if (additionalData !== undefined) updateData.additionalData = additionalData;
  if (isArchived !== undefined) updateData.isArchived = isArchived;
  
  // Add new attachments if any
  if (req.files && req.files.length > 0) {
    // Process new attachments
    const newAttachments = req.files.map(file => ({
      name: file.originalname || file.filename,
      fileUrl: file.path,
      type: file.mimetype?.split('/')[0] || 'document',
      uploadDate: new Date()
    }));
    
    // Add to existing attachments if any
    updateData.attachments = [
      ...(report.attachments || []),
      ...newAttachments
    ];
    
    // Update reportFileUrl
    const fileUrls = req.files.map(file => file.path);
    updateData.reportFileUrl = [
      ...(report.reportFileUrl || []),
      ...fileUrls
    ];
  }
  
  // Update the report
  const updatedReport = await MedicalReport.findByIdAndUpdate(
    reportId,
    { $set: updateData },
    { new: true }
  )
  .populate("athleteId", "name email sports")
  .populate("medicalStaffId", "name email designation")
  .populate("prescribedMedication");
  
  return res
    .status(200)
    .json(new ApiResponse(
      200, 
      updatedReport, 
      "Medical report updated successfully"
    ));
});

const getAthleteReports = asyncHandler(async (req, res) => {
  const { athleteId } = req.params;
  const { startDate, endDate, limit = 10, page = 1, testName, medicalStatus } = req.query;
  
  // Check if athlete exists
  const athlete = await Athlete.findById(athleteId);
  if (!athlete) {
    throw new ApiError(404, "Athlete not found");
  }
  
  // Build query object
  const query = { athleteId };
  
  // Add date range if provided
  if (startDate && endDate) {
    query.reportDate = {
      $gte: new Date(startDate),
      $lte: new Date(endDate)
    };
  }
  
  // Add test name filter if provided
  if (testName) {
    query.testName = { $regex: testName, $options: 'i' }; // Case-insensitive search
  }
  
  // Add medical status filter if provided
  if (medicalStatus) {
    query.medicalStatus = medicalStatus;
  }
  
  // Calculate pagination
  const skip = (parseInt(page) - 1) * parseInt(limit);
  
  // Execute query with pagination
  const reports = await MedicalReport.find(query)
    .populate("medicalStaffId", "name email designation")
    .populate("prescribedMedication")
    .sort({ reportDate: -1 })
    .skip(skip)
    .limit(parseInt(limit));
  
  // Get total count for pagination
  const totalReports = await MedicalReport.countDocuments(query);
  
  return res.status(200).json(
    new ApiResponse(
      200,
      {
        reports,
        pagination: {
          currentPage: parseInt(page),
          totalPages: Math.ceil(totalReports / parseInt(limit)),
          totalReports,
          hasMore: skip + reports.length < totalReports
        }
      },
      `Retrieved ${reports.length} medical reports for athlete`
    )
  );
});

const getMedicalReportById = asyncHandler(async (req, res) => {
  const { reportId } = req.params;
  
  const report = await MedicalReport.findById(reportId)
    .populate("athleteId", "name email sports gender dob")
    .populate("medicalStaffId", "name email designation")
    .populate("prescribedMedication");
  
  if (!report) {
    throw new ApiError(404, "Medical report not found");
  }
  
  // Check if user has access to this report
  if (req.coach && req.coach.organization) {
    // Medical staff can only access reports from their organization
    if (report.organizationId.toString() !== req.coach.organization.toString()) {
      throw new ApiError(403, "You don't have permission to access this report");
    }
  }
  
  return res
    .status(200)
    .json(new ApiResponse(200, report, "Medical report retrieved successfully"));
});

const deleteMedicalReport = asyncHandler(async (req, res) => {
  const { reportId } = req.params;
  
  const report = await MedicalReport.findById(reportId);
  
  if (!report) {
    throw new ApiError(404, "Medical report not found");
  }
  
  // Check if the report was created by the current user
  if (report.medicalStaffId.toString() !== req.coach._id.toString()) {
    throw new ApiError(403, "You are not authorized to delete this report");
  }
  
  // Check if the report is less than 24 hours old
  const reportCreationTime = report.createdAt || report.reportDate;
  const currentTime = new Date();
  const timeDifference = currentTime - reportCreationTime;
  const hoursDifference = timeDifference / (1000 * 60 * 60);
  
  if (hoursDifference > 24) {
    throw new ApiError(
      403, 
      "Medical reports can only be deleted within 24 hours of creation"
    );
  }
  
  await MedicalReport.findByIdAndDelete(reportId);
  
  return res
    .status(200)
    .json(new ApiResponse(
      200, 
      null, 
      "Medical report deleted successfully"
    ));
});


const getMyMedicalReports = asyncHandler(async (req, res) => {
  // Get athlete ID from authenticated user
  const athleteId = req.athlete?._id;
  console.log("Athlete ID:", athleteId);
  
  if (!athleteId) {
    throw new ApiError(401, "Authentication as athlete required");
  }
  
  // Parse query parameters for filtering and pagination
  const { 
    startDate, 
    endDate, 
    limit = 10, 
    page = 1, 
    testName, 
    medicalStatus,
    sortBy = "reportDate",
    sortOrder = "desc" 
  } = req.query;
  
  // Build query object
  const query = { athleteId };
  
  // Add date range filter if provided
  if (startDate && endDate) {
    query.reportDate = {
      $gte: new Date(startDate),
      $lte: new Date(endDate)
    };
  }
  
  // Add test name filter if provided
  if (testName) {
    query.testName = { $regex: testName, $options: 'i' }; // Case-insensitive search
  }
  
  // Add medical status filter if provided
  if (medicalStatus) {
    query.medicalStatus = medicalStatus;
  }
  
  // Calculate pagination
  const skip = (parseInt(page) - 1) * parseInt(limit);
  
  // Determine sort order
  const sort = {};
  sort[sortBy] = sortOrder === "asc" ? 1 : -1;
  
  try {
    // Execute query with pagination
    const reports = await MedicalReport.find(query)
      .populate("medicalStaffId", "name avatar email designation specialization")
      .populate("prescribedMedication", "name dosage frequency")
      .sort(sort)
      .skip(skip)
      .limit(parseInt(limit));
    
    // Get total count for pagination
    const totalReports = await MedicalReport.countDocuments(query);
    
    // Format reports for list view (simplified version with key information)
    const formattedReports = reports.map(report => ({
      id: report._id,
      testName: report.testName || "General Checkup",
      reportDate: report.reportDate,
      testDate: report.testDate,
      medicalStatus: report.medicalStatus,
      medicalClearance: report.medicalClearance,
      doctorInfo: {
        name: report.medicalStaffId?.name || "Unknown",
        avatar: report.medicalStaffId?.avatar,
        specialization: report.medicalStaffId?.specialization
      },
      hasAttachments: (report.attachments?.length > 0) || (report.reportFileUrl?.length > 0),
      nextCheckupDate: report.nextCheckupDate,
      hasInjuries: report.injuryDetails?.currentInjuries?.length > 0,
      hasRecommendations: report.recommendations?.length > 0,
      createdAt: report.createdAt
    }));
    
    return res.status(200).json(
      new ApiResponse(
        200,
        {
          reports: formattedReports,
          pagination: {
            currentPage: parseInt(page),
            totalPages: Math.ceil(totalReports / parseInt(limit)),
            totalReports,
            hasMore: skip + reports.length < totalReports
          }
        },
        `Retrieved ${reports.length} medical reports`
      )
    );
  } catch (error) {
    throw new ApiError(500, `Error retrieving medical reports: ${error.message}`);
  }
});


const getMyMedicalReportDetails = asyncHandler(async (req, res) => {
  const { reportId } = req.params;
  const athleteId = req.athlete?._id;
  
  if (!athleteId) {
    throw new ApiError(401, "Authentication as athlete required");
  }
  
  // Validate report ID
  if (!mongoose.Types.ObjectId.isValid(reportId)) {
    throw new ApiError(400, "Invalid report ID");
  }
  
  try {
    // Find the report with populated references
    const report = await MedicalReport.findById(reportId)
      .populate("medicalStaffId", "name avatar email designation specialization contactNumber")
      .populate("prescribedMedication", "name dosage frequency sideEffects instructions");
    
    if (!report) {
      throw new ApiError(404, "Medical report not found");
    }
    
    // Verify ownership - athlete can only view their own reports
    if (report.athleteId.toString() !== athleteId.toString()) {
      throw new ApiError(403, "You don't have permission to view this report");
    }
    
    // Format the report for detailed view with all necessary sections
    const formattedReport = {
      id: report._id,
      
      // Report metadata
      testName: report.testName || "General Checkup",
      testDate: report.testDate,
      reportDate: report.reportDate,
      nextCheckupDate: report.nextCheckupDate,
      
      // Medical staff info
      doctorInfo: {
        name: report.medicalStaffId?.name,
        avatar: report.medicalStaffId?.avatar,
        email: report.medicalStaffId?.email,
        designation: report.medicalStaffId?.designation,
        specialization: report.medicalStaffId?.specialization,
        contactNumber: report.medicalStaffId?.contactNumber
      },
      
      // Medical status
      medicalStatus: report.medicalStatus,
      medicalClearance: report.medicalClearance,
      chronicMedicalCondition: report.chronicMedicalCondition,
      prescribedMedication: report.prescribedMedication,
      
      // Detailed sections - only include non-empty sections
      ...(hasValidData(report.vitals) && { vitals: report.vitals }),
      ...(hasValidData(report.performanceMetrics) && { performanceMetrics: report.performanceMetrics }),
      ...(hasValidData(report.injuryDetails) && { injuryDetails: report.injuryDetails }),
      ...(hasValidData(report.testResults) && { testResults: report.testResults }),
      ...(hasValidData(report.nutrition) && { nutrition: report.nutrition }),
      ...(hasValidData(report.mentalHealth) && { mentalHealth: report.mentalHealth }),
      
      // Notes and recommendations
      doctorsNotes: report.doctorsNotes,
      physicianNotes: report.physicianNotes,
      recommendations: report.recommendations || [],
      
      // Attachments
      attachments: report.attachments || [],
      reportFileUrl: report.reportFileUrl || [],
      
      // Timestamps
      createdAt: report.createdAt,
      updatedAt: report.updatedAt
    };
    
    return res.status(200).json(
      new ApiResponse(
        200,
        formattedReport,
        "Medical report details retrieved successfully"
      )
    );
  } catch (error) {
    if (error instanceof ApiError) throw error;
    throw new ApiError(500, `Error retrieving medical report details: ${error.message}`);
  }
});

// Helper function to check if an object has valid data
const hasValidData = (obj) => {
  if (!obj) return false;
  
  // For arrays, check if they have any elements
  if (Array.isArray(obj)) return obj.length > 0;
  
  // For objects, check if they have any properties with non-null/undefined values
  if (typeof obj === 'object') {
    return Object.values(obj).some(val => 
      val !== null && 
      val !== undefined && 
      (typeof val !== 'string' || val.trim() !== '')
    );
  }
  
  return false;
};

// Make sure to add these controllers to your exports
export {
  createMedicalReport,
  getMedicalReportsByDate,
  getMedicalReportDates,
  updateMedicalReport,
  getAthleteReports,
  getMedicalReportById,
  deleteMedicalReport,
  getMyMedicalReports,          // Add this
  getMyMedicalReportDetails     // Add this
};