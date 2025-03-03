import { Router } from "express";
import {
    getAthletes,
    // loginAthlete,
    // logoutAthlete
} from "../controllers/athlete.controllers.js";

import {verifyJWTAthlete} from "../middlewares/auth.middleware.js"


const router = Router()


router.get("/", verifyJWTAthlete, getAthletes); // Fetch all athletes with filters
// router.post("/login", loginAthlete);
// router.post("/logout", verifyAthleteJWT, logoutAthlete);

export default router;