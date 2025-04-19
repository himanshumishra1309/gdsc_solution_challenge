import { Router } from "express";
import {
    getCoaches,
    getCoachProfile,
    logoutUser,
    getAllAssignedAthletes,
} from "../controllers/coach.controllers.js";
import { addAthleteStats } from "../controllers/admin.controllers.js";
import { verifyJWTCoach } from "../middlewares/auth.middleware.js";
import { authorize } from "../middlewares/authorize.middleware.js"; // New middleware for role-based access

const router = Router()



router.get("/", verifyJWTCoach, authorize(["coach"]), getCoaches);

router.get("/profile", verifyJWTCoach, getCoachProfile); //connected
router.get("/", verifyJWTCoach, verifyJWTCoach, getCoaches); // Fetch all coaches with filters




// router.post("/login", loginAdmin);
router.post("/logout", verifyJWTCoach, logoutUser); //connected


// Coach can add/update athlete stats
router.post("/athlete-stats", verifyJWTCoach, addAthleteStats);

router.get("/assigned-athletes", verifyJWTCoach, getAllAssignedAthletes);

export default router;