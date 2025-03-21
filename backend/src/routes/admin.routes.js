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
  getOrganizationStats ,
  getOrganizationOverview,
  sendSponsorInvitation,
  sendPotentialSponsorRequest,
  getPotentialSponsors,
  getCurrentSponsors,
  deleteSponsorRequest,
  getRequestsLog,
  addSportStats,
  getSportStats,
  addAthleteStats,
  updateAdmin,
  updateOrganizationAthlete,
  updateCoach,
} from "../controllers/admin.controllers.js";
import {verifyJWTAdmin, verifyJWTCoach} from "../middlewares/auth.middleware.js"
import { upload } from "../middlewares/multer.middleware.js";


const router = Router()

router.route("/register").post(
  upload.single("avatar"),
  registerAdmin
); //connected

router.put(
  "/update-admin/:adminId",
  verifyJWTAdmin, // Ensure only authorized admins can update
  upload.single("avatar"), // Handle single file upload for avatar
  updateAdmin
);

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

router.put(
  "/update-athlete/:athleteId",
  verifyJWTAdmin, // Ensure only admins can update athlete details
  upload.fields([
    { name: "avatar", maxCount: 1 },
    { name: "uploadSchoolId", maxCount: 1 },
    { name: "latestMarksheet", maxCount: 1 }
  ]),
  updateOrganizationAthlete
);

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

router.put(
  "/update-coach/:coachId",
  verifyJWTAdmin,
  upload.fields([
      { name: "profilePhoto", maxCount: 1 },
      { name: "idProof", maxCount: 1 },
      { name: "certificates", maxCount: 1 }
  ]),
  updateCoach
);


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

// Get Organization Overview Count of athletes,sponsors,coaches (Admin Only)
router.get("/overview",  verifyJWTAdmin, getOrganizationOverview);


//Direct invitation
router.post("/sponsors/invite", verifyJWTAdmin, sendSponsorInvitation);
//invitation via potential sponsors list
router.post("/sponsors/request", verifyJWTAdmin, sendPotentialSponsorRequest);
router.get("/sponsors/potential",verifyJWTAdmin, getPotentialSponsors);
router.get("/sponsors/current",verifyJWTAdmin,  getCurrentSponsors);
// ✅ Delete a sponsor request (Only for pending sponsors)
router.delete("/sponsors/request/:sponsorId", verifyJWTAdmin, deleteSponsorRequest);
//log of all request sent
router.get("/sponsors/requests",verifyJWTAdmin, getRequestsLog);



router.post("/stats/add-sport", verifyJWTAdmin, addSportStats);
router.get("/stats/sport-stats/:sportId", verifyJWTAdmin, getSportStats);
router.post("/stats/athlete-stats", verifyJWTAdmin, addAthleteStats);


export default router;



