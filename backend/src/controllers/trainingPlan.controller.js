import asyncHandler from "../utils/asyncHandler.js";
import TrainingPlan from "../models/trainingPlan.model.js";
import ApiResponse  from "../utils/ApiResponse.js";
import ApiError from "../utils/ApiError.js";
import TrainingSession from "../models/trainingSession.model.js";
import {Athlete} from "../models/athlete.model.js";
import mongoose from "mongoose";

const createTrainingPlan = asyncHandler(async (req, res) => {
    const { title, description, sportType, durationWeeks } = req.body;
    const { user } = req;

    // Ensure user is part of an organization
    if (!user.organization) {
        throw new ApiError(400, "User must belong to an organization.");
    }

    const newPlan = await TrainingPlan.create({
        title,  // Changed from title to name
        description,
        sportType,
        durationWeeks,
        organization: user.organization,  // Corrected organization reference
        createdBy: user._id,  // Changed from coachId to createdBy
        assignedAthletes: []
    });

    res.status(201).json(new ApiResponse (201, newPlan, "Training Plan created successfully."));
});

const assignAthletesToPlan = asyncHandler(async (req, res) => {
    const { planId, athleteIds } = req.body;
    const { user } = req;

    if (!["admin", "coach"].includes(user.role)) {
        throw new ApiError(403, "Only coaches and admins can assign athletes.");
    }

    const plan = await TrainingPlan.findById(planId);
    if (!plan) throw new ApiError(404, "Training Plan not found.");

    // Ensure the coach is assigning within their organization
    if (!plan.organization || !plan.organization.equals(user.organization)) {
        throw new ApiError(403, "Unauthorized action.");
    }

    // Convert athleteIds from request to ObjectIds
    const mongooseAthleteIds = athleteIds.map(id => new mongoose.Types.ObjectId(id));

    // Fetch valid athlete IDs as ObjectId array
    const validAthletes = await Athlete.find({ _id: { $in: mongooseAthleteIds } }, "_id");

    // Convert valid athlete IDs to string for comparison
    const validAthleteIds = validAthletes.map(a => a._id.toString());

    // Find invalid athlete IDs
    const invalidIds = athleteIds.filter(id => !validAthleteIds.includes(id));
    if (invalidIds.length > 0) {
        throw new ApiError(400, `Some athletes were not found: ${invalidIds.join(", ")}`);
    }

    // Avoid duplicate assignments by using `.some()` with `.equals()`
    const newAthleteIds = validAthleteIds.filter(id => 
        !plan.assignedAthletes.some(aid => aid.equals(id))
    );

    if (newAthleteIds.length === 0) {
        throw new ApiError(400, "All athletes are already assigned.");
    }

    plan.assignedAthletes.push(...newAthleteIds);
    await plan.save();

    res.status(200).json(new ApiResponse (200, plan, "Athletes assigned successfully."));
});


const getAllTrainingPlans = asyncHandler(async (req, res) => {
    const { user } = req;

    if (!["admin", "coach"].includes(user.role)) {
        throw new ApiError(403, "Unauthorized access.");
    }

    // Fetch plans associated with the user's organization
    const plans = await TrainingPlan.find({ organization: user.organization }).lean();

    res.status(200).json(new ApiResponse (200, plans, "Training Plans retrieved successfully."));
});


const createTrainingSession = asyncHandler(async (req, res) => {
    const {
        planId,
        athlete, // Individual athlete (if session is personalized)
        date = new Date(),
        duration,
        intensity,
        exercises = [],
        videoLinks = [],
        location,
        coachNotes,
        completionStatus = "Pending", // Default
        attendance = [],
        completedByAthletes = []
    } = req.body;

    const { user } = req;

    if (!["admin", "coach"].includes(user.role)) {
        throw new ApiError(403, "Only coaches and admins can create sessions.");
    }

    let plan = null;
    if (planId) {
        plan = await TrainingPlan.findById(planId);
        if (!plan) throw new ApiError(404, "Training Plan not found.");

        // Ensure session belongs to the coach's organization
        if (!plan.organization || !plan.organization.equals(user.organization)) {
            throw new ApiError(403, "Unauthorized action.");
        }
    }

    // Validate provided athlete if session is personalized
    if (athlete) {
        const validAthlete = await Athlete.findOne({ _id: athlete, organization: user.organization });
        if (!validAthlete) throw new ApiError(400, "Athlete not found in your organization.");
    }

    // Validate attendance and completedByAthletes arrays
    if (attendance.length) {
        for (const entry of attendance) {
            const validAthlete = await Athlete.findById(entry.athlete);
            if (!validAthlete) throw new ApiError(400, `Invalid athlete in attendance: ${entry.athlete}`);
        }
    }

    if (completedByAthletes.length) {
        for (const entry of completedByAthletes) {
            const validAthlete = await Athlete.findById(entry.athlete);
            if (!validAthlete) throw new ApiError(400, `Invalid athlete in completedByAthletes: ${entry.athlete}`);
        }
    }

    const session = await TrainingSession.create({
        trainingPlan: planId || null,
        athlete: athlete || null,
        date,
        duration,
        intensity,
        exercises,
        videoLinks,
        location,
        coachNotes,
        completionStatus,
        attendance,
        completedByAthletes,
        organization: user.organization,
        createdBy: user._id
    });

    res.status(201).json(new ApiResponse (201, session, "Training Session created successfully."));
});


const getAthleteSessions = asyncHandler(async (req, res) => {
    const { user } = req;

    if (user.role !== "athlete") {
        throw new ApiError(403, "Only athletes can view their training sessions.");
    }

    const athleteId = new mongoose.Types.ObjectId(user._id);

    const testSessions = await TrainingSession.find({
        assignedAthletes: { $exists: true, $not: { $size: 0 } }
    }).lean();
    
    console.log("🔍 Sessions with assignedAthletes:", JSON.stringify(testSessions, null, 2));
    

    // 🔍 Fetch personalized sessions (where athlete is directly assigned)
    const personalizedSessions = await TrainingSession.find({ athlete: athleteId })
        .populate("trainingPlan")
        .lean();

    // 🔍 Fetch group sessions (where athlete is in assignedAthletes array)
    const groupSessions = await TrainingSession.find({ assignedAthletes: athleteId })
        .populate("trainingPlan")
        .lean();

    // 🏗️ Merge both session lists
    const allSessions = [...personalizedSessions, ...groupSessions];

    // 🐞 Debugging log
    console.log("Fetched Personalized Sessions:", JSON.stringify(personalizedSessions, null, 2));
    console.log("Fetched Group Sessions:", JSON.stringify(groupSessions, null, 2));
    console.log("Final Combined Sessions:", JSON.stringify(allSessions, null, 2));

    res.status(200).json(new ApiResponse (200, allSessions, "Filtered Training Sessions retrieved successfully."));
});


const markSessionAsCompleted = asyncHandler(async (req, res) => {
    const { sessionId } = req.params;
    const { user } = req;

    if (user.role !== "athlete") {
        throw new ApiError(403, "Only athletes can mark sessions as completed.");
    }

    const session = await TrainingSession.findById(sessionId);
    if (!session) throw new ApiError(404, "Training Session not found.");

    // Check if the athlete is assigned to this session
    const isAssigned = session.assignedAthletes.some(athleteId => athleteId.equals(user._id));
    if (!isAssigned) throw new ApiError(403, "You are not assigned to this session.");

    // Add athlete to `completedByAthletes` if not already marked
    const alreadyCompleted = session.completedByAthletes.some(entry => entry.athlete.equals(user._id));
    if (!alreadyCompleted) {
        session.completedByAthletes.push({ athlete: user._id, completedAt: new Date() });
    }

    // Check if **all assigned athletes** have completed the session
    const allCompleted = session.assignedAthletes.every(athleteId =>
        session.completedByAthletes.some(entry => entry.athlete.equals(athleteId))
    );

    // If all assigned athletes have completed it, update `completionStatus`
    session.completionStatus = allCompleted ? "Completed" : "In Progress";

    await session.save();

    res.status(200).json(new ApiResponse (200, session, "Training session marked as completed."));
});


export{
    createTrainingPlan,
    assignAthletesToPlan,
    createTrainingSession,
    getAllTrainingPlans,
    getAthleteSessions,
    markSessionAsCompleted
}