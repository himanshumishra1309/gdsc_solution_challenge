

import express from "express";
import { submitSessionRPE, getSessionRPE } from "../controllers/sessionController.js";

const router = express.Router();

router.get("/:sessionId/rpe", authenticateUser, authorizeRoles(["athlete", "coach"]), getSessionRPE);

~
router.get("/:sessionId/rpe", getSessionRPE); // Fetch RPE data

export default router;
