import { Router } from "express";
import {
    getCoaches,
    // loginAdmin,
    logoutUser
} from "../controllers/coach.controllers.js";
import { verifyJWTCoach } from "../middlewares/auth.middleware.js";
import { authorize } from "../middlewares/authorize.middleware.js"; // New middleware for role-based access

const router = Router()



router.get("/", verifyJWTCoach, authorize(["coach"]), getCoaches); // Fetch all coaches with filters

// router.post("/login", loginAdmin);
router.post("/logout", verifyJWTCoach, logoutUser); //connected

export default router;