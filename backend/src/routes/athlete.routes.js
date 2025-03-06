import { Router } from "express";
import {
    getAthletes,
    // loginAthlete,
    // logoutAthlete
} from "../controllers/athlete.controllers.js";
import {
    registerIndependentAthlete,
    loginIndependentAthlete,
    getAthleteDetails
} from "../controllers/athlete.controllers.js";

import {verifyJWTAthlete} from "../middlewares/auth.middleware.js"


const router = Router()


router.get("/", verifyJWTAthlete, getAthletes); // Fetch all athletes with filters
router.post("/register/individual", registerIndependentAthlete);
router.post("/login/individual", loginIndependentAthlete);

router.get("/:athleteId/details", getAthleteDetails);



// router.post("/login", loginAthlete);
// router.post("/logout", verifyAthleteJWT, logoutAthlete);

export default router;