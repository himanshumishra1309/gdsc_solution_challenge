import { Router } from "express";
import {
    getAthletes,
    // loginAthlete,
    // logoutAthlete
} from "../controllers/athlete.controllers.js";
import {
    getAthleteDetails,
} from "../controllers/athlete.controllers.js";

import {verifyJWTAthlete} from "../middlewares/auth.middleware.js"


const router = Router()


router.get("/", verifyJWTAthlete, getAthletes);


router.get("/:athleteId/details", getAthleteDetails);

export default router;