import express from "express";
import { createTrainingPlan, assignAthletesToPlan, createTrainingSession, getAllTrainingPlans, getAthleteSessions } from "../controllers/trainingPlan.controller.js";
import { verifyJWT } from "../middlewares/auth.middleware.js";
import { authorize } from "../middlewares/authorize.middleware.js";  // Import authorize middleware

const router = express.Router();

router.post("/plan/create", verifyJWT, authorize(["admin", "coach"]), createTrainingPlan);
router.post("/plan/assign", verifyJWT, authorize(["admin", "coach"]), assignAthletesToPlan);
router.post("/session/create", verifyJWT, authorize(["admin", "coach"]), createTrainingSession);
router.get("/plan/all", verifyJWT, authorize(["admin", "coach"]), getAllTrainingPlans);
router.get("/session/athlete", verifyJWT, authorize(["athlete"]), getAthleteSessions);

export default router;
