import asyncHandler from "../utils/asyncHandler.js";
import ApiError from "../utils/ApiError.js";
import { Admin } from "../models/admin.model.js";
import { Coach } from "../models/coach.model.js";
import { InjuryAssessment } from "../models/injuryAssesment.model.js";
import { InjuryReport } from "../models/injuryReport.model.js";
import { InjuryShortMessage } from "../models/injutyShortReply.model.js";
import { InjuryTicket } from "../models/injuryTicket.model.js";
import { Athlete } from "../models/athlete.model.js";
import ApiResponse from "../utils/ApiResponse.js";
import mongoose from "mongoose";

const createInjuryTicket = asyncHandler(async (req, res) => {
    // 1. Extract data from request body
    const {
        athlete,
        doctor,
        title,
        injuryType,
        bodyPart,
        painLevel,
        dateOfInjury,
        activityContext,
        symptoms,
        affectingPerformance,
        previouslyInjured,
        notes,
        images
    } = req.body;

    // 2. Validate required fields
    if (!athlete || !doctor || !title || !injuryType || !bodyPart || !painLevel || !dateOfInjury || !activityContext) {
        throw new ApiError(400, "All required fields must be provided");
    }

    // 3. Validate ObjectIds
    if (!mongoose.Types.ObjectId.isValid(athlete) || !mongoose.Types.ObjectId.isValid(doctor)) {
        throw new ApiError(400, "Invalid athlete or doctor ID");
    }

    // 4. Verify that athlete exists
    const athleteExists = await Athlete.findById(athlete);
    if (!athleteExists) {
        throw new ApiError(404, "Athlete not found");
    }

    // 5. Verify that doctor exists
    const doctorExists = await Coach.findById(doctor);
    if (!doctorExists) {
        throw new ApiError(404, "Doctor not found");
    }

    // 6. Validate pain level
    if (painLevel < 1 || painLevel > 10) {
        throw new ApiError(400, "Pain level must be between 1 and 10");
    }

    // 7. Validate date of injury
    const injuryDate = new Date(dateOfInjury);
    const currentDate = new Date();
    if (injuryDate > currentDate) {
        throw new ApiError(400, "Date of injury cannot be in the future");
    }

    // 8. Validate assignedDoctor if provided
    if (doctor && !mongoose.Types.ObjectId.isValid(doctor)) {
        throw new ApiError(400, "Invalid assigned doctor ID");
    }

    // 9. Start a database transaction
    const session = await mongoose.startSession();
    session.startTransaction();

    try {
        // 10. Create a new injury report
        const newInjuryReport = await InjuryReport.create([{
            athlete,
            doctor,
            title,
            injuryType,
            bodyPart,
            painLevel,
            dateOfInjury: injuryDate,
            activityContext,
            symptoms: symptoms || [],
            affectingPerformance: affectingPerformance || "NONE",
            previouslyInjured: previouslyInjured || false,
            notes: notes || "",
            images: images || []
        }], { session });

        // 11. Create a new injury ticket
        const newInjuryTicket = await InjuryTicket.create([{
            injuryReport_id: newInjuryReport[0]._id,
            ticketStatus: "OPEN" // Default status
        }], { session });

        // 12. Commit the transaction
        await session.commitTransaction();
        session.endSession();

        // 13. Return success response
        return res.status(201).json(
            new ApiResponse(
                201,
                {
                    injuryReport: newInjuryReport[0],
                    injuryTicket: newInjuryTicket[0]
                },
                "Injury report and ticket created successfully"
            )
        );
    } catch (error) {
        // 14. Abort transaction in case of error
        await session.abortTransaction();
        session.endSession();
        throw new ApiError(500, error.message || "Failed to create injury report");
    }
});


const getAllInjuryTickets = asyncHandler(async (req, res) => {
    const tickets = await InjuryTicket.find()
        .populate({
            path: 'injuryReport_id',
            populate: {
                path: 'athlete',
                select: 'name avatar'
            }
        })
        .sort({ createdAt: -1 });
    
    return res.status(200).json(
        new ApiResponse(
            200,
            tickets,
            "Injury tickets retrieved successfully"
        )
    );
});


const getInjuryShortMessages = asyncHandler(async (req, res) => {
    const { ticketId } = req.params;
    const athleteId = req.athlete?._id;
    
    if (!athleteId) {
        throw new ApiError(401, "Authentication as athlete required");
    }
    
    // Validate ticket ID
    if (!mongoose.Types.ObjectId.isValid(ticketId)) {
        throw new ApiError(400, "Invalid ticket ID");
    }
    
    // Find the ticket and verify it belongs to this athlete
    const ticket = await InjuryTicket.findById(ticketId)
        .populate('injuryReport_id');
    
    if (!ticket) {
        throw new ApiError(404, "Injury ticket not found");
    }
    
    // Verify ownership
    if (ticket.injuryReport_id.athlete.toString() !== athleteId.toString()) {
        throw new ApiError(403, "You don't have permission to view this data");
    }
    
    // Find all short messages for this injury
    const shortMessages = await InjuryShortMessage.find({ 
        injury_id: ticket.injuryReport_id._id 
    })
    .sort({ createdAt: -1 }) // Most recent first
    .populate({
        path: 'injury_id',
        select: 'title injuryType bodyPart'
    });
    
    if (shortMessages.length === 0) {
        return res.status(200).json(
            new ApiResponse(
                200,
                { ticketId, messages: [] },
                "No doctor messages found for this injury"
            )
        );
    }
    
    return res.status(200).json(
        new ApiResponse(
            200,
            { 
                ticketId,
                injuryDetails: {
                    title: ticket.injuryReport_id.title,
                    injuryType: ticket.injuryReport_id.injuryType,
                    bodyPart: ticket.injuryReport_id.bodyPart
                },
                messages: shortMessages.map(msg => ({
                    id: msg._id,
                    response: msg.response,
                    medication: msg.medication,
                    doctorNote: msg.doctorNote,
                    appointmentDate: msg.appointmentDate,
                    appointmentTime: msg.appointmentTime,
                    createdAt: msg.createdAt
                }))
            },
            "Doctor messages retrieved successfully"
        )
    );
});


const getInjuryAssessmentForAthlete = asyncHandler(async (req, res) => {
    const { ticketId } = req.params;
    const athleteId = req.athlete?._id;
    
    if (!athleteId) {
        throw new ApiError(401, "Authentication as athlete required");
    }
    
    // Validate ticket ID
    if (!mongoose.Types.ObjectId.isValid(ticketId)) {
        throw new ApiError(400, "Invalid ticket ID");
    }
    
    // Find the ticket and verify it belongs to this athlete
    const ticket = await InjuryTicket.findById(ticketId)
        .populate({
            path: 'injuryReport_id',
            populate: {
                path: 'doctor',
                select: 'name avatar email contactNumber specialization'
            }
        });
    
    if (!ticket) {
        throw new ApiError(404, "Injury ticket not found");
    }
    
    // Verify ownership
    if (ticket.injuryReport_id.athlete.toString() !== athleteId.toString()) {
        throw new ApiError(403, "You don't have permission to view this data");
    }
    
    // Get assessment for this injury
    const assessment = await InjuryAssessment.findOne({ 
        injury: ticket.injuryReport_id._id 
    });
    
    if (!assessment) {
        return res.status(200).json(
            new ApiResponse(
                200,
                { 
                    ticketId,
                    doctorInfo: ticket.injuryReport_id.doctor,
                    assessment: null 
                },
                "No medical assessment found for this injury"
            )
        );
    }
    
    // Format the response data for easier consumption
    return res.status(200).json(
        new ApiResponse(
            200,
            { 
                ticketId,
                injuryDetails: {
                    title: ticket.injuryReport_id.title,
                    injuryType: ticket.injuryReport_id.injuryType,
                    bodyPart: ticket.injuryReport_id.bodyPart,
                    painLevel: ticket.injuryReport_id.painLevel,
                    reportedOn: ticket.createdAt
                },
                doctorInfo: ticket.injuryReport_id.doctor,
                assessment: {
                    id: assessment._id,
                    diagnosis: assessment.diagnosis,
                    diagnosisDetails: assessment.diagnosisDetails,
                    severity: assessment.severity,
                    treatmentPlan: assessment.treatmentPlan,
                    medications: assessment.medications,
                    rehabilitationProtocol: assessment.rehabilitationProtocol,
                    restrictionsList: assessment.restrictionsList,
                    estimatedRecoveryTime: assessment.estimatedRecoveryTime,
                    clearanceStatus: assessment.clearanceStatus,
                    notes: assessment.notes,
                    createdAt: assessment.createdAt
                }
            },
            "Medical assessment retrieved successfully"
        )
    );
});



const getInjuryDetails = asyncHandler(async (req, res) => {
    const { ticketId } = req.params;
    
    if (!mongoose.Types.ObjectId.isValid(ticketId)) {
        throw new ApiError(400, "Invalid ticket ID");
    }
    
    const ticket = await InjuryTicket.findById(ticketId)
        .populate({
            path: 'injuryReport_id',
            populate: [
                {
                    path: 'athlete',
                    select: 'name avatar sports skillLevel'
                },
                {
                    path: 'doctor',
                    select: 'name avatar contactNumber'
                }
            ]
        });
    
    if (!ticket) {
        throw new ApiError(404, "Injury ticket not found");
    }
    
    // Get assessment if exists
    const assessment = await InjuryAssessment.findOne({ injury: ticket.injuryReport_id._id });
    
    return res.status(200).json(
        new ApiResponse(
            200,
            { ticket, assessment },
            "Injury details retrieved successfully"
        )
    );
});


const getAthleteInjuryTickets = asyncHandler(async (req, res) => {
    const { athleteId } = req.params;
    
    // Validate athlete ID
    if (!mongoose.Types.ObjectId.isValid(athleteId)) {
        throw new ApiError(400, "Invalid athlete ID");
    }
    
    // Verify athlete exists
    const athlete = await Athlete.findById(athleteId);
    if (!athlete) {
        throw new ApiError(404, "Athlete not found");
    }
    
    // Find all injury reports for this athlete
    const injuryReports = await InjuryReport.find({ athlete: athleteId });
    
    if (injuryReports.length === 0) {
        return res.status(200).json(
            new ApiResponse(
                200,
                [],
                "No injury reports found for this athlete"
            )
        );
    }
    
    // Get the IDs of all injury reports
    const reportIds = injuryReports.map(report => report._id);
    
    // Find all tickets associated with these reports
    const tickets = await InjuryTicket.find({ injuryReport_id: { $in: reportIds } })
        .populate({
            path: 'injuryReport_id',
            populate: [
                {
                    path: 'doctor',
                    select: 'name avatar contactNumber email'
                }
            ]
        })
        .sort({ createdAt: -1 });
    
    // Get assessments for each injury report
    const assessments = await InjuryAssessment.find({ 
        injury: { $in: reportIds } 
    });
    
    // Map assessments to their corresponding injury reports
    const assessmentMap = assessments.reduce((map, assessment) => {
        map[assessment.injury.toString()] = assessment;
        return map;
    }, {});
    
    // Combine tickets with their assessments
    const ticketsWithAssessments = tickets.map(ticket => {
        const reportId = ticket.injuryReport_id._id.toString();
        return {
            ticket,
            assessment: assessmentMap[reportId] || null
        };
    });
    
    return res.status(200).json(
        new ApiResponse(
            200,
            {
                athlete: {
                    _id: athlete._id,
                    name: athlete.name,
                    avatar: athlete.avatar
                },
                tickets: ticketsWithAssessments
            },
            "Athlete injury tickets retrieved successfully"
        )
    );
});


const getDoctorInjuryTickets = asyncHandler(async (req, res) => {
    // Get doctor ID either from params or from authenticated user
    const doctorId = req.params.doctorId || req.coach?._id;
    
    // Validate doctor ID
    if (!mongoose.Types.ObjectId.isValid(doctorId)) {
        throw new ApiError(400, "Invalid doctor ID");
    }
    
    // Verify doctor exists
    const doctor = await Coach.findById(doctorId);
    if (!doctor) {
        throw new ApiError(404, "Doctor not found");
    }
    
    // Find all injury reports where this doctor is assigned
    const injuryReports = await InjuryReport.find({ doctor: doctorId });
    
    if (injuryReports.length === 0) {
        return res.status(200).json(
            new ApiResponse(
                200,
                {
                    doctor: {
                        _id: doctor._id,
                        name: doctor.name,
                        avatar: doctor.avatar
                    },
                    tickets: []
                },
                "No injury reports assigned to this doctor"
            )
        );
    }
    
    // Get the IDs of all injury reports
    const reportIds = injuryReports.map(report => report._id);
    
    // Find all tickets associated with these reports
    const tickets = await InjuryTicket.find({ injuryReport_id: { $in: reportIds } })
        .populate({
            path: 'injuryReport_id',
            populate: [
                {
                    path: 'athlete',
                    select: 'name avatar sports skillLevel phoneNumber gender dob'
                }
            ]
        })
        .sort({ createdAt: -1 });
    
    // Get assessments for each injury report
    const assessments = await InjuryAssessment.find({ 
        injury: { $in: reportIds } 
    });
    
    // Map assessments to their corresponding injury reports
    const assessmentMap = assessments.reduce((map, assessment) => {
        map[assessment.injury.toString()] = assessment;
        return map;
    }, {});
    
    // Group tickets by status to make it easier for the doctor to manage
    const openTickets = [];
    const inProgressTickets = [];
    const closedTickets = [];
    
    tickets.forEach(ticket => {
        const reportId = ticket.injuryReport_id._id.toString();
        const ticketWithAssessment = {
            ticket,
            assessment: assessmentMap[reportId] || null
        };
        
        switch(ticket.ticketStatus) {
            case 'OPEN':
                openTickets.push(ticketWithAssessment);
                break;
            case 'IN_PROGRESS':
                inProgressTickets.push(ticketWithAssessment);
                break;
            case 'CLOSED':
                closedTickets.push(ticketWithAssessment);
                break;
        }
    });
    
    return res.status(200).json(
        new ApiResponse(
            200,
            {
                doctor: {
                    _id: doctor._id,
                    name: doctor.name,
                    avatar: doctor.avatar,
                    contactNumber: doctor.contactNumber,
                    email: doctor.email
                },
                statistics: {
                    total: tickets.length,
                    open: openTickets.length,
                    inProgress: inProgressTickets.length,
                    closed: closedTickets.length
                },
                tickets: {
                    open: openTickets,
                    inProgress: inProgressTickets,
                    closed: closedTickets
                }
            },
            "Doctor's injury tickets retrieved successfully"
        )
    );
});


const getMyInjuryTickets = asyncHandler(async (req, res) => {
    // Get the athlete ID from the authenticated user
    const athleteId = req.athlete?._id;
    
    if (!athleteId) {
        throw new ApiError(401, "Authentication required");
    }
    
    // Find all injury reports for this athlete
    const injuryReports = await InjuryReport.find({ athlete: athleteId });
    
    if (injuryReports.length === 0) {
        return res.status(200).json(
            new ApiResponse(
                200,
                {
                    tickets: []
                },
                "You have no injury reports"
            )
        );
    }
    
    // Get the IDs of all injury reports
    const reportIds = injuryReports.map(report => report._id);
    
    // Find all tickets associated with these reports
    const tickets = await InjuryTicket.find({ injuryReport_id: { $in: reportIds } })
        .populate({
            path: 'injuryReport_id',
            populate: [
                {
                    path: 'doctor',
                    select: 'name avatar contactNumber email'
                }
            ]
        })
        .sort({ createdAt: -1 });
    
    // Get assessments for each injury report
    const assessments = await InjuryAssessment.find({ 
        injury: { $in: reportIds } 
    });
    
    // Map assessments to their corresponding injury reports
    const assessmentMap = assessments.reduce((map, assessment) => {
        map[assessment.injury.toString()] = assessment;
        return map;
    }, {});
    
    // Combine tickets with their assessments and categorize by status
    const openTickets = [];
    const inProgressTickets = [];
    const closedTickets = [];
    
    tickets.forEach(ticket => {
        const reportId = ticket.injuryReport_id._id.toString();
        const ticketWithAssessment = {
            ticket,
            assessment: assessmentMap[reportId] || null
        };
        
        switch(ticket.ticketStatus) {
            case 'OPEN':
                openTickets.push(ticketWithAssessment);
                break;
            case 'IN_PROGRESS':
                inProgressTickets.push(ticketWithAssessment);
                break;
            case 'CLOSED':
                closedTickets.push(ticketWithAssessment);
                break;
        }
    });
    
    return res.status(200).json(
        new ApiResponse(
            200,
            {
                statistics: {
                    total: tickets.length,
                    open: openTickets.length,
                    inProgress: inProgressTickets.length,
                    closed: closedTickets.length
                },
                tickets: {
                    open: openTickets,
                    inProgress: inProgressTickets,
                    closed: closedTickets
                }
            },
            "Your injury tickets retrieved successfully"
        )
    );
});


const getMyInjuryTicketDetails = asyncHandler(async (req, res) => {
    const { ticketId } = req.params;
    const athleteId = req.athlete?._id;
    
    if (!athleteId) {
        throw new ApiError(401, "Authentication required");
    }
    
    if (!mongoose.Types.ObjectId.isValid(ticketId)) {
        throw new ApiError(400, "Invalid ticket ID");
    }
    
    // Find the ticket and ensure it belongs to this athlete
    const ticket = await InjuryTicket.findById(ticketId)
        .populate({
            path: 'injuryReport_id',
            populate: [
                {
                    path: 'doctor',
                    select: 'name avatar contactNumber email specialization'
                }
            ]
        });
    
    if (!ticket) {
        throw new ApiError(404, "Injury ticket not found");
    }
    
    // Verify this ticket belongs to the authenticated athlete
    if (ticket.injuryReport_id.athlete.toString() !== athleteId.toString()) {
        throw new ApiError(403, "You don't have permission to view this ticket");
    }
    
    // Get assessment if exists
    const assessment = await InjuryAssessment.findOne({ injury: ticket.injuryReport_id._id });
    
    // Get all messages related to this injury
    const messages = await InjuryShortMessage.find({ 
        injury: ticket.injuryReport_id._id 
    }).sort({ createdAt: 1 });
    
    return res.status(200).json(
        new ApiResponse(
            200,
            { 
                ticket,
                assessment,
                messages,
                statusTimeline: {
                    reported: ticket.createdAt,
                    inProgress: assessment ? assessment.createdAt : null,
                    resolved: ticket.ticketStatus === 'CLOSED' ? ticket.updatedAt : null
                }
            },
            "Injury ticket details retrieved successfully"
        )
    );
});


const updateInjuryReport = asyncHandler(async (req, res) => {
    const { reportId } = req.params;
    
    // Validate report ID
    if (!mongoose.Types.ObjectId.isValid(reportId)) {
        throw new ApiError(400, "Invalid report ID");
    }
    
    // Find the injury report
    const report = await InjuryReport.findById(reportId);
    if (!report) {
        throw new ApiError(404, "Injury report not found");
    }
    
    // Check if user has permission (either athlete who created it or medical staff)
    const isAuthorizedAthlete = req.athlete && report.athlete.toString() === req.athlete._id.toString();
    const isDoctor = req.coach && report.doctor.toString() === req.coach._id.toString();
    
    if (!isAuthorizedAthlete && !isDoctor) {
        throw new ApiError(403, "You don't have permission to update this report");
    }
    
    // Extract fields to update
    const {
        title,
        injuryType,
        bodyPart,
        painLevel,
        dateOfInjury,
        activityContext,
        symptoms,
        affectingPerformance,
        previouslyInjured,
        notes,
        images
    } = req.body;
    
    // Validate pain level if provided
    if (painLevel !== undefined && (painLevel < 1 || painLevel > 10)) {
        throw new ApiError(400, "Pain level must be between 1 and 10");
    }
    
    // Validate date of injury if provided
    if (dateOfInjury) {
        const injuryDate = new Date(dateOfInjury);
        const currentDate = new Date();
        if (injuryDate > currentDate) {
            throw new ApiError(400, "Date of injury cannot be in the future");
        }
    }
    
    // Update the report with provided fields
    const updatedReport = await InjuryReport.findByIdAndUpdate(
        reportId,
        {
            ...(title && { title }),
            ...(injuryType && { injuryType }),
            ...(bodyPart && { bodyPart }),
            ...(painLevel && { painLevel }),
            ...(dateOfInjury && { dateOfInjury: new Date(dateOfInjury) }),
            ...(activityContext && { activityContext }),
            ...(symptoms && { symptoms }),
            ...(affectingPerformance && { affectingPerformance }),
            ...(previouslyInjured !== undefined && { previouslyInjured }),
            ...(notes !== undefined && { notes }),
            ...(images && { images })
        },
        { new: true }
    );
    
    return res.status(200).json(
        new ApiResponse(
            200,
            updatedReport,
            "Injury report updated successfully"
        )
    );
});


const addShortMessage = asyncHandler(async (req, res) => {
    const { ticketId } = req.params;
    const doctorId = req.coach?._id;
    
    if (!doctorId) {
        throw new ApiError(401, "Authentication as medical staff required");
    }
    
    // Validate ticket ID
    if (!mongoose.Types.ObjectId.isValid(ticketId)) {
        throw new ApiError(400, "Invalid ticket ID");
    }
    
    // Find the ticket and related injury report
    const ticket = await InjuryTicket.findById(ticketId)
        .populate('injuryReport_id');
    
    if (!ticket) {
        throw new ApiError(404, "Injury ticket not found");
    }
    
    // Check if doctor is assigned to this injury
    if (ticket.injuryReport_id.doctor.toString() !== doctorId.toString()) {
        throw new ApiError(403, "You are not assigned to this injury case");
    }
    
    // Extract message data
    const { 
        response, 
        medication, 
        doctorNote, 
        appointmentDate, 
        appointmentTime 
    } = req.body;
    
    // Validate required fields based on model
    if (!response || !medication || !doctorNote || !appointmentDate || !appointmentTime) {
        throw new ApiError(400, "All fields (response, medication, doctorNote, appointmentDate, appointmentTime) are required");
    }
    
    // Create short message
    const shortMessage = await InjuryShortMessage.create({
        injury_id: ticket.injuryReport_id._id, // Changed from injury to injury_id per model
        response,
        medication,
        doctorNote,
        appointmentDate,
        appointmentTime
        // responseDate will default to now
    });
    
    // Update ticket status to IN_PROGRESS if it's currently OPEN
    if (ticket.ticketStatus === "OPEN") {
        await InjuryTicket.findByIdAndUpdate(ticketId, { ticketStatus: "IN_PROGRESS" });
    }
    
    return res.status(201).json(
        new ApiResponse(
            201,
            shortMessage,
            "Short message added successfully and ticket updated to in-progress"
        )
    );
});


const updateShortMessage = asyncHandler(async (req, res) => {
    const { messageId } = req.params;
    const doctorId = req.coach?._id;
    
    if (!doctorId) {
        throw new ApiError(401, "Authentication as medical staff required");
    }
    
    // Validate message ID
    if (!mongoose.Types.ObjectId.isValid(messageId)) {
        throw new ApiError(400, "Invalid message ID");
    }
    
    // Find the message
    const message = await InjuryShortMessage.findById(messageId);
    if (!message) {
        throw new ApiError(404, "Message not found");
    }
    
    // Extract message data
    const { 
        response, 
        medication, 
        doctorNote, 
        appointmentDate, 
        appointmentTime 
    } = req.body;
    
    // Validate required fields
    if ((!response && !medication && !doctorNote && !appointmentDate && !appointmentTime)) {
        throw new ApiError(400, "At least one field must be provided for update");
    }
    
    // Update the message with validation for required fields
    const updatedMessage = await InjuryShortMessage.findByIdAndUpdate(
        messageId,
        {
            ...(response && { response }),
            ...(medication && { medication }),
            ...(doctorNote && { doctorNote }),
            ...(appointmentDate && { appointmentDate }),
            ...(appointmentTime && { appointmentTime })
        },
        { new: true }
    );
    
    return res.status(200).json(
        new ApiResponse(
            200,
            updatedMessage,
            "Message updated successfully"
        )
    );
});


const addInjuryAssessment = asyncHandler(async (req, res) => {
    const { ticketId } = req.params;
    const doctorId = req.coach?._id;
    
    if (!doctorId) {
        throw new ApiError(401, "Authentication as medical staff required");
    }
    
    // Validate ticket ID
    if (!mongoose.Types.ObjectId.isValid(ticketId)) {
        throw new ApiError(400, "Invalid ticket ID");
    }
    
    // Find the ticket and related injury report
    const ticket = await InjuryTicket.findById(ticketId)
        .populate('injuryReport_id');
    
    if (!ticket) {
        throw new ApiError(404, "Injury ticket not found");
    }
    
    // Check if doctor is assigned to this injury
    if (ticket.injuryReport_id.doctor.toString() !== doctorId.toString()) {
        throw new ApiError(403, "You are not assigned to this injury case");
    }
    
    // Check if assessment already exists
    const existingAssessment = await InjuryAssessment.findOne({ 
        injury: ticket.injuryReport_id._id 
    });
    
    if (existingAssessment) {
        throw new ApiError(400, "Assessment already exists for this injury");
    }
    
    // Extract assessment data
    const { 
        diagnosis,
        diagnosisDetails,
        severity,
        treatmentPlan,
        medications,
        rehabilitationProtocol,
        restrictionsList,
        estimatedRecoveryTime,
        followUpRequired,
        appointmentScheduled,
        clearanceStatus,
        testResults,
        notes
    } = req.body;
    
    // Validate required fields based on model
    if (!diagnosis || !severity || !treatmentPlan) {
        throw new ApiError(400, "Diagnosis, severity, and treatment plan are required");
    }
    
    // Validate severity enum
    const validSeverities = ['MINOR', 'MODERATE', 'SEVERE', 'CRITICAL'];
    if (!validSeverities.includes(severity)) {
        throw new ApiError(400, `Severity must be one of: ${validSeverities.join(', ')}`);
    }
    
    // Validate clearance status if provided
    if (clearanceStatus) {
        const validStatuses = ['NO_ACTIVITY', 'LIMITED_ACTIVITY', 'FULL_CLEARANCE_PENDING', 'FULLY_CLEARED'];
        if (!validStatuses.includes(clearanceStatus)) {
            throw new ApiError(400, `Clearance status must be one of: ${validStatuses.join(', ')}`);
        }
    }
    
    // Create assessment with model-specific fields
    const assessment = await InjuryAssessment.create({
        injury: ticket.injuryReport_id._id,
        doctor: doctorId,
        diagnosis,
        diagnosisDetails: diagnosisDetails || "",
        severity,
        treatmentPlan,
        medications: medications || [],
        rehabilitationProtocol: rehabilitationProtocol || "",
        restrictionsList: restrictionsList || [],
        estimatedRecoveryTime: estimatedRecoveryTime || { value: 7, unit: "DAYS" },
        followUpRequired: followUpRequired !== undefined ? followUpRequired : true,
        appointmentScheduled: appointmentScheduled || null,
        clearanceStatus: clearanceStatus || 'NO_ACTIVITY',
        testResults: testResults || [],
        notes: notes || ""
    });
    
    // Update ticket status to CLOSED
    await InjuryTicket.findByIdAndUpdate(ticketId, { ticketStatus: "CLOSED" });
    
    return res.status(201).json(
        new ApiResponse(
            201,
            assessment,
            "Assessment added successfully and ticket marked as closed"
        )
    );
});


const updateInjuryAssessment = asyncHandler(async (req, res) => {
    const { assessmentId } = req.params;
    const doctorId = req.coach?._id;
    
    if (!doctorId) {
        throw new ApiError(401, "Authentication as medical staff required");
    }
    
    // Validate assessment ID
    if (!mongoose.Types.ObjectId.isValid(assessmentId)) {
        throw new ApiError(400, "Invalid assessment ID");
    }
    
    // Find the assessment
    const assessment = await InjuryAssessment.findById(assessmentId);
    if (!assessment) {
        throw new ApiError(404, "Assessment not found");
    }
    
    // Check if doctor created this assessment
    if (assessment.doctor.toString() !== doctorId.toString()) {
        throw new ApiError(403, "You can only edit your own assessments");
    }
    
    // Extract assessment data
    const { 
        diagnosis,
        diagnosisDetails,
        severity,
        treatmentPlan,
        medications,
        rehabilitationProtocol,
        restrictionsList,
        estimatedRecoveryTime,
        followUpRequired,
        appointmentScheduled,
        clearanceStatus,
        testResults,
        notes
    } = req.body;
    
    // Validate severity enum if provided
    if (severity) {
        const validSeverities = ['MINOR', 'MODERATE', 'SEVERE', 'CRITICAL'];
        if (!validSeverities.includes(severity)) {
            throw new ApiError(400, `Severity must be one of: ${validSeverities.join(', ')}`);
        }
    }
    
    // Validate clearance status if provided
    if (clearanceStatus) {
        const validStatuses = ['NO_ACTIVITY', 'LIMITED_ACTIVITY', 'FULL_CLEARANCE_PENDING', 'FULLY_CLEARED'];
        if (!validStatuses.includes(clearanceStatus)) {
            throw new ApiError(400, `Clearance status must be one of: ${validStatuses.join(', ')}`);
        }
    }
    
    // Update the assessment
    const updatedAssessment = await InjuryAssessment.findByIdAndUpdate(
        assessmentId,
        {
            ...(diagnosis && { diagnosis }),
            ...(diagnosisDetails !== undefined && { diagnosisDetails }),
            ...(severity && { severity }),
            ...(treatmentPlan && { treatmentPlan }),
            ...(medications && { medications }),
            ...(rehabilitationProtocol !== undefined && { rehabilitationProtocol }),
            ...(restrictionsList && { restrictionsList }),
            ...(estimatedRecoveryTime && { estimatedRecoveryTime }),
            ...(followUpRequired !== undefined && { followUpRequired }),
            ...(appointmentScheduled !== undefined && { appointmentScheduled }),
            ...(clearanceStatus && { clearanceStatus }),
            ...(testResults && { testResults }),
            ...(notes !== undefined && { notes }),
            updatedAt: new Date()
        },
        { new: true }
    );
    
    return res.status(200).json(
        new ApiResponse(
            200,
            updatedAssessment,
            "Assessment updated successfully"
        )
    );
});


const deleteInjuryTicket = asyncHandler(async (req, res) => {
    const { ticketId } = req.params;
    const athleteId = req.athlete?._id;
    
    if (!athleteId) {
        throw new ApiError(401, "Authentication required");
    }
    
    // Validate ticket ID
    if (!mongoose.Types.ObjectId.isValid(ticketId)) {
        throw new ApiError(400, "Invalid ticket ID");
    }
    
    // Find the ticket and related injury report
    const ticket = await InjuryTicket.findById(ticketId)
        .populate('injuryReport_id');
    
    if (!ticket) {
        throw new ApiError(404, "Injury ticket not found");
    }
    
    // Check if athlete created this report
    if (ticket.injuryReport_id.athlete.toString() !== athleteId.toString()) {
        throw new ApiError(403, "You can only delete your own injury reports");
    }
    
    // Check if the ticket is already in progress or closed
    if (ticket.ticketStatus !== "OPEN") {
        throw new ApiError(400, "Cannot delete an injury ticket that is already being processed or closed");
    }
    
    // Start a database transaction
    const session = await mongoose.startSession();
    session.startTransaction();
    
    try {
        // Delete any associated messages
        await InjuryShortMessage.deleteMany({ injury: ticket.injuryReport_id._id }, { session });
        
        // Delete the injury report
        await InjuryReport.findByIdAndDelete(ticket.injuryReport_id._id, { session });
        
        // Delete the ticket
        await InjuryTicket.findByIdAndDelete(ticketId, { session });
        
        // Commit the transaction
        await session.commitTransaction();
        session.endSession();
        
        return res.status(200).json(
            new ApiResponse(
                200,
                null,
                "Injury report and ticket deleted successfully"
            )
        );
    } catch (error) {
        // Abort transaction in case of error
        await session.abortTransaction();
        session.endSession();
        throw new ApiError(500, error.message || "Failed to delete injury report");
    }
});


const getInjuryMessages = asyncHandler(async (req, res) => {
    const { injuryId } = req.params;
    const userId = req.athlete?._id || req.coach?._id;
    
    if (!userId) {
        throw new ApiError(401, "Authentication required");
    }
    
    // Validate injury ID
    if (!mongoose.Types.ObjectId.isValid(injuryId)) {
        throw new ApiError(400, "Invalid injury ID");
    }
    
    // Find the injury report
    const injuryReport = await InjuryReport.findById(injuryId);
    if (!injuryReport) {
        throw new ApiError(404, "Injury report not found");
    }
    
    // Check permissions
    const isAthlete = req.athlete && injuryReport.athlete.toString() === req.athlete._id.toString();
    const isAssignedDoctor = req.coach && injuryReport.doctor.toString() === req.coach._id.toString();
    
    if (!isAthlete && !isAssignedDoctor) {
        throw new ApiError(403, "You don't have permission to view these messages");
    }
    
    // Get all messages
    const messages = await InjuryShortMessage.find({ injury_id: injuryId })
        .sort({ createdAt: 1 });
    
    return res.status(200).json(
        new ApiResponse(
            200,
            messages,
            "Messages retrieved successfully"
        )
    );
});


export {
    createInjuryTicket,
    getAllInjuryTickets,
    getInjuryDetails,
    getAthleteInjuryTickets,
    getDoctorInjuryTickets,
    getMyInjuryTickets,
    getMyInjuryTicketDetails,
    updateInjuryReport,
    addShortMessage,
    updateShortMessage,
    addInjuryAssessment,
    updateInjuryAssessment,
    deleteInjuryTicket,
    getInjuryMessages,
    getInjuryShortMessages,
    getInjuryAssessmentForAthlete
};