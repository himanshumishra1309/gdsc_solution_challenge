import { Router } from "express";
import {
    getAthletes,
    // loginAthlete,
    logoutUser,
    getAthleteDetails,
    getAthleteStats
} from "../controllers/athlete.controllers.js";


import { verifyJWTAthlete } from "../middlewares/auth.middleware.js";


const router = Router()


router.get("/profile", verifyJWTAthlete, getAthletes);
router.get("/logout", verifyJWTAthlete, logoutUser); //connected

router.get("/:athleteId/details", getAthleteDetails);
// Athlete can view their own stats
router.get("/my-stats", verifyJWTAthlete, getAthleteStats);

export default router;