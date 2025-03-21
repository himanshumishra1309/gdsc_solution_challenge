import { Router } from "express";
import {
    getCoaches,
    logoutUser,
    getCoachProfile
} from "../controllers/coach.controllers.js";
import { verifyJWTCoach } from "../middlewares/auth.middleware.js";
import { authorize } from "../middlewares/authorize.middleware.js"; // New middleware for role-based access

const router = Router()



router.get("/", verifyJWTCoach, authorize(["coach"]), getCoaches);

router.get("/profile", verifyJWTCoach, getCoachProfile); //connected

// router.post("/login", loginAdmin);
router.post("/logout", verifyJWTCoach, logoutUser); //connected

export default router;