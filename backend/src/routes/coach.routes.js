import { Router } from "express";
import {
    getCoaches,
    // loginAdmin,
    // logoutCoach
} from "../controllers/coach.controllers.js";
import { verifyJWT } from "../middlewares/auth.middleware.js";
import { authorize } from "../middlewares/authorize.middleware.js"; // New middleware for role-based access

const router = Router()



router.get("/", verifyJWT, authorize(["coach"]), getCoaches); // Fetch all coaches with filters

// router.post("/login", loginAdmin);
// router.post("/logout", verifyCoachJWT, logoutCoach);

export default router;