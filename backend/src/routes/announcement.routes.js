import { Router } from "express";
import {
  createAnnouncement,
  updateAnnouncement,
  deleteAnnouncement,
  getMyAnnouncements,
  getAnnouncements,
  getAnnouncementById,
  getAnnouncementsByCoach,
  getCoachesWithSharedAthletes,
  athleteGetAnnouncements,
  coachGetTheirSportsAnnouncements
} from "../controllers/announcement.controllers.js";
import { verifyJWTCoach, verifyJWTAthlete } from "../middlewares/auth.middleware.js";

const router = Router();

// Routes that require any authenticated user
router.get("/", verifyJWTCoach, getAnnouncements);
// router.get("/:announcementId", verifyAnyUser, getAnnouncementById);
router.get("/coach-announcements", verifyJWTAthlete, getAnnouncements);
// Routes specifically for coaches
router.post("/make-announcement", verifyJWTCoach, createAnnouncement);
router.patch("/:announcementId", verifyJWTCoach, updateAnnouncement);
router.delete("/:announcementId", verifyJWTCoach, deleteAnnouncement);
router.get("/coach/me", verifyJWTCoach, getMyAnnouncements);
router.get("/coach/:coachId", verifyJWTAthlete, getAnnouncementsByCoach);
// Add this route
router.get("/with-shared-athletes", verifyJWTCoach, getCoachesWithSharedAthletes);
router.get("/athlete-announcements", verifyJWTAthlete, athleteGetAnnouncements);
// In your announcement.routes.js file
router.get("/coach-get-announcements/sports", verifyJWTCoach, coachGetTheirSportsAnnouncements);

export default router;