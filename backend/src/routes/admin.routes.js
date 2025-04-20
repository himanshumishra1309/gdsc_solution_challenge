import { Router } from "express";
import {
  registerOrganizationAthlete,
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
  getOrganizationStats,
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
  getAthleteFullDetails,
  getAllSponsors,
} from "../controllers/admin.controllers.js";
import {
  verifyJWTAdmin,
  verifyJWTCoach,
} from "../middlewares/auth.middleware.js";
import { upload } from "../middlewares/multer.middleware.js";

const router = Router();

router.route("/register").post(upload.single("avatar"), registerAdmin);

router.put(
  "/update-admin/:adminId",
  verifyJWTAdmin,
  upload.single("avatar"),
  updateAdmin
);

router.post(
  "/register-organization-athlete",
  verifyJWTAdmin,
  upload.fields([
    { name: "avatar", maxCount: 1 },
    { name: "uploadSchoolId", maxCount: 1 },
    { name: "latestMarksheet", maxCount: 1 },
  ]),
  registerOrganizationAthlete
);

router.put(
  "/update-athlete/:athleteId",
  verifyJWTAdmin,
  upload.fields([
    { name: "avatar", maxCount: 1 },
    { name: "uploadSchoolId", maxCount: 1 },
    { name: "latestMarksheet", maxCount: 1 },
  ]),
  updateOrganizationAthlete
);

router.post(
  "/register-coach",
  verifyJWTAdmin,
  upload.fields([
    { name: "profilePhoto", maxCount: 1 },
    { name: "idProof", maxCount: 1 },
    { name: "certificates", maxCount: 1 },
  ]),
  registerCoach
);

router.get("/profile", verifyJWTAdmin, getAdminProfile);

router.put(
  "/update-coach/:coachId",
  verifyJWTAdmin,
  upload.fields([
    { name: "profilePhoto", maxCount: 1 },
    { name: "idProof", maxCount: 1 },
    { name: "certificates", maxCount: 1 },
  ]),
  updateCoach
);

router.get("/organization-stats", verifyJWTAdmin, getOrganizationStats);
router.get("/athletes", verifyJWTAdmin, getAllAthletes);
router.get("/administrators", verifyJWTAdmin, getAllAdmins);
router.get("/coaches", verifyJWTAdmin, getAllCoaches);
router.post("/logout", verifyJWTAdmin, logoutAdmin);

const sportEnum = ["Football", "Badminton", "Cricket", "Basketball", "Tennis"];
router.get("/allowed-sports", (req, res) => {
  res.json({ allowedSports: sportEnum });
});

router.post("/sponsors/invite", verifyJWTAdmin, sendSponsorInvitation);

router.post("/sponsors/request", verifyJWTAdmin, sendPotentialSponsorRequest);
router.get("/sponsors/potential", verifyJWTAdmin, getPotentialSponsors);
router.get("/sponsors/current", verifyJWTAdmin, getCurrentSponsors);

router.delete(
  "/sponsors/request/:sponsorId",
  verifyJWTAdmin,
  deleteSponsorRequest
);

router.get("/sponsors/requests", verifyJWTAdmin, getRequestsLog);

router.post("/stats/add-sport", verifyJWTAdmin, addSportStats);
router.get("/stats/sport-stats/:sportId", verifyJWTAdmin, getSportStats);
router.post("/stats/athlete-stats", verifyJWTAdmin, addAthleteStats);

router.get(
  "/athletes/:athleteId/details",
  verifyJWTAdmin,
  getAthleteFullDetails
);

router.get(
  "/coach-get-athletes/:athleteId/details",
  verifyJWTCoach,
  getAthleteFullDetails
);

router.get("/sponsors", verifyJWTAdmin, getAllSponsors);

export default router;
