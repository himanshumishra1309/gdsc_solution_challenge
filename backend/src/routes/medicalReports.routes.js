import { Router } from "express";
import {
  createMedicalReport,
  getMedicalReportsByDate,
  getMedicalReportDates,
  updateMedicalReport,
  getAthleteReports,
  getMedicalReportById,
  deleteMedicalReport,
  getMyMedicalReports, 
  getMyMedicalReportDetails 
} from "../controllers/medicalReports.controllers.js";
import { verifyJWTCoach, verifyJWTAthlete } from "../middlewares/auth.middleware.js";
import { upload } from "../middlewares/multer.middleware.js";

const router = Router();

// ATHLETE ROUTES - These must come BEFORE the wildcard routes!
router.get("/me", verifyJWTAthlete, getMyMedicalReports);
router.get("/me/:reportId", verifyJWTAthlete, getMyMedicalReportDetails);

// Apply coach JWT verification for remaining routes
router.use(verifyJWTCoach);

// Create a new report
router.post("/", upload.array("medicalFiles", 5), createMedicalReport);

// Get reports by date
router.get("/by-date", getMedicalReportsByDate);

// Get unique dates with reports
router.get("/dates", getMedicalReportDates);

// Update a report
router.patch("/:reportId", upload.array("medicalFiles", 5), updateMedicalReport);

// Get all reports for an athlete
router.get("/athlete/:athleteId", getAthleteReports);

// These wildcard routes should come LAST
router.get("/:reportId", getMedicalReportById);
router.delete("/:reportId", deleteMedicalReport);

export default router;