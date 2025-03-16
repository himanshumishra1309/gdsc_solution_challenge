import { Router } from "express";
import {
  registerIndependentAthlete,
  loginIndependentAthlete,
  getIndependentAthleteProfile,
  updateIndependentAthleteProfile,
  logoutIndependentAthlete,
  refreshAccessToken
} from "../controllers/independentAthlete.controllers.js";
import { upload } from "../middlewares/multer.middleware.js";
import { verifyJWTIndividualAthlete } from "../middlewares/auth.middleware.js";

const router = Router();

// Public routes - no authentication required
router.route("/register").post(
  upload.single("avatar"), // Handle avatar image upload
  registerIndependentAthlete
); //connected

router.route("/login").post(loginIndependentAthlete); //connected

router.route("/refresh-token").post(refreshAccessToken);

// Protected routes - authentication required
router.route("/profile").get(
  verifyJWTIndividualAthlete, 
  getIndependentAthleteProfile
);

router.route("/profile").patch(
  verifyJWTIndividualAthlete, 
  upload.single("avatar"), // Handle avatar image update
  updateIndependentAthleteProfile
);

router.route("/logout").post(
  verifyJWTIndividualAthlete, 
  logoutIndependentAthlete
);

export default router;