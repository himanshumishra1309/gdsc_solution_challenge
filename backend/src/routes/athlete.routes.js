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


const router = Router()


router.get("/profile", verifyJWTAthlete, getAthletes);
router.get("/logout", verifyJWTAthlete, logoutUser); //connected

router.get("/:athleteId/details", getAthleteDetails);

export default router;