import { Router } from "express";
import { registerOrganizationAthlete,
  getAllAthletes,
  registerAdmin,
  registerCoach,
  getAllUsers,
  generateAccessAndRefreshToken,
  logoutAdmin,
  getAdminProfile,
  getRpeInsights,
  getAllCoaches,
  getAllAdmins,
  getAthleteById,
  getOrganizationStats } from "../controllers/admin.controllers.js";
import {verifyJWTAdmin} from "../middlewares/auth.middleware.js"
import { upload } from "../middlewares/multer.middleware.js";


const router = Router()

router.route("/register").post(
  upload.single("avatar"),
  registerAdmin
); //connected

router.post(
  "/register-organization-athlete",
  verifyJWTAdmin, // Ensure only admins can register athletes
  upload.fields([
    { name: "avatar", maxCount: 1 },
    { name: "uploadSchoolId", maxCount: 1 },
    { name: "latestMarksheet", maxCount: 1 }
  ]),
  registerOrganizationAthlete
); //connected

router.post(
  '/register-coach',
  verifyJWTAdmin,
  upload.fields([
    { name: 'profilePhoto', maxCount: 1 },
    { name: 'idProof', maxCount: 1 },
    { name: 'certificates', maxCount: 1 }
  ]),
  registerCoach
); // connected
// Add this route with your other admin routes

router.get('/organization-stats', verifyJWTAdmin, getOrganizationStats);
router.get('/athletes', verifyJWTAdmin, getAllAthletes); //connected
router.get('/administrators', verifyJWTAdmin, getAllAdmins); //connected
router.get('/coaches', verifyJWTAdmin, getAllCoaches); //connected
router.post('/logout', verifyJWTAdmin, logoutAdmin); //connected

const sportEnum = ["Football", "Badminton", "Cricket", "Basketball", "Tennis"];
router.get("/allowed-sports", (req, res) => {
  res.json({ allowedSports: sportEnum });
});

export default router;


