// to verify if user exists or not

import asyncHandler from "../utils/asyncHandler.js";
import jwt from "jsonwebtoken"
import {Coach} from "../models/coach.model.js"

//here no need of rs so we put _


const isTrainingStaffMiddleware = (req, res, next) => {
  if (req.user.designation === 'training_staff') {
    next();
  } else {
    res.status(403).json({ message: 'Access denied. Only Training and Conditioning Staff can perform this action.' });
  }
};

const isCoachMiddleware = (req, res, next) => {
  if (req.user.designation === 'head_coach' || req.user.designation === 'assistant_coach' || req.user.designation === 'training_staff') {
    next();
  } else {
    res.status(403).json({ message: 'Access denied. Only coaches can perform this action.' });
  }
};

const isAssignedAthleteMiddleware = async (req, res, next) => {
  const { athleteId } = req.params;
  const coachId = req.user._id;

  try {
    const coach = await Coach.findById(coachId);
    if (!coach || !coach.assignedAthletes.includes(athleteId)) {
      return res.status(403).json({ message: 'Access denied. Athlete is not assigned to you.' });
    }

    next();
  } catch (error) {
    res.status(500).json({ message: 'Error checking athlete assignment', error });
  }
};

const validateRpeInputMiddleware = (req, res, next) => {
  const { rpe, athleteId } = req.body;

  if (!rpe || rpe < 1 || rpe > 10) {
    return res.status(400).json({ message: 'Invalid RPE value. RPE must be between 1 and 10.' });
  }

  if (!athleteId) {
    return res.status(400).json({ message: 'Athlete ID is required.' });
  }

  next();
};

const isOrganizationMemberMiddleware = (req, res, next) => {
  const requestedOrganizationId = req.params.organizationId || req.body.organizationId;

  if (req.user.organization.toString() === requestedOrganizationId) {
    next();
  } else {
    res.status(403).json({ message: 'Access denied. You do not belong to this organization.' });
  }
};





export{
  verifyCoachJWT,
  isTrainingStaffMiddleware,
  isCoachMiddleware,
  isAssignedAthleteMiddleware,
  validateRpeInputMiddleware,
  isOrganizationMemberMiddleware
}
