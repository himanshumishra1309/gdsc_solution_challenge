

import express from "express";
import { getSessionRPE } from "../controllers/session.controller.js";
import { authorize } from "../middlewares/authorize.middleware.js";
const router = express.Router();


router.get("/:sessionId/rpe", authorize(["athlete", "coach"]), getSessionRPE);


export default router;
