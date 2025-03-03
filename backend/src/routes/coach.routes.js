import { Router } from "express";
import {
    getCoaches,
    // loginAdmin,
    // logoutCoach
} from "../controllers/coach.controllers.js";
import {verifyJWTCoach} from "../middlewares/auth.middleware.js"


const router = Router()



router.get("/", verifyJWTCoach, getCoaches); // Fetch all coaches with filters

// router.post("/login", loginAdmin);
// router.post("/logout", verifyCoachJWT, logoutCoach);

export default router;