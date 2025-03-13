import { Router } from "express";
import {
    getAthletes,
    // loginAthlete,
    // logoutAthlete
} from "../controllers/athlete.controllers.js";
import {
    registerIndependentAthlete,
    loginIndependentAthlete,
    getAthleteDetails,
} from "../controllers/athlete.controllers.js";

import { verifyJWT } from "../middlewares/auth.middleware.js";
import { authorize } from "../middlewares/authorize.middleware.js"; // New middleware for role-based access


const router = Router()


router.get("/", verifyJWT, authorize(["athlete"]), getAthletes); // Fetch all athletes with filters
router.post("/register/individual", registerIndependentAthlete);
router.post("/login/individual", loginIndependentAthlete);
// router.post("/logout/individual", logoutIndependentAthlete);


router.get("/:athleteId/details", getAthleteDetails);



// router.post("/login", loginAthlete);
// router.post("/logout", verifyAthleteJWT, logoutAthlete);

export default router;