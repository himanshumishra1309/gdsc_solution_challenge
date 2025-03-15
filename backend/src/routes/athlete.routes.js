import { Router } from "express";
import {
    getAthletes,
    // loginAthlete,
    logoutUser
} from "../controllers/athlete.controllers.js";
import {
    getAthleteDetails,
} from "../controllers/athlete.controllers.js";

import { verifyJWTAthlete } from "../middlewares/auth.middleware.js";
import { authorize } from "../middlewares/authorize.middleware.js"; // New middleware for role-based access


const router = Router()


router.get("/", verifyJWTAthlete, getAthletes);
router.get("/logout", verifyJWTAthlete, logoutUser);

router.get("/:athleteId/details", getAthleteDetails);

export default router;