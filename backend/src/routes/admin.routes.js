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
  sendSponsorInvitation,
  sendPotentialSponsorRequest,
  getPotentialSponsors,
  getCurrentSponsors,
  deleteSponsorRequest,
  getRequestsLog,} from "../controllers/admin.controllers.js";
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

router.get('/profile', verifyJWTAdmin, getAdminProfile); //connected

router.get('/organization-stats', verifyJWTAdmin, getOrganizationStats);
router.get('/athletes', verifyJWTAdmin, getAllAthletes); //connected
router.get('/administrators', verifyJWTAdmin, getAllAdmins); //connected
router.get('/coaches', verifyJWTAdmin, getAllCoaches); //connected
router.post('/logout', verifyJWTAdmin, logoutAdmin); //connected

const sportEnum = ["Football", "Badminton", "Cricket", "Basketball", "Tennis"];
router.get("/allowed-sports", (req, res) => {
  res.json({ allowedSports: sportEnum });
});


//direct invitation
router.post("/sponsors/invite", verifyJWTAdmin, sendSponsorInvitation);
//invitation via potential sponsors list
router.post("/sponsors/request", verifyJWTAdmin, sendPotentialSponsorRequest);


router.get("/sponsors/potential",verifyJWTAdmin, getPotentialSponsors);
router.get("/sponsors/current",verifyJWTAdmin,  getCurrentSponsors);
// ✅ Delete a sponsor request (Only for pending sponsors)
router.delete("/sponsors/request/:sponsorId", verifyJWTAdmin, deleteSponsorRequest);
//log of all request sent
router.get("/sponsors/requests",verifyJWTAdmin, getRequestsLog);

export default router;



