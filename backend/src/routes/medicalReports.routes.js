import { Router } from "express";
import {
  createMedicalReport,
  getMedicalReportsByDate,
  getMedicalReportDates,
  updateMedicalReport,
  getAthleteReports,
  getMedicalReportById,    // Add this function
  deleteMedicalReport      // Add this function
} from "../controllers/medicalReports.controllers.js";
import { verifyJWTCoach } from "../middlewares/auth.middleware.js";
import { upload } from "../middlewares/multer.middleware.js";

const router = Router();

router.use(verifyJWTCoach);

// Create a new report
router.post("/", upload.array("medicalFiles", 5), createMedicalReport);

// Get reports by date
router.get("/by-date", getMedicalReportsByDate);

// Get unique dates with reports
router.get("/dates", getMedicalReportDates);

// Update a report
router.patch(
  "/:reportId",
  upload.array("medicalFiles", 5),
  updateMedicalReport
);

// Get all reports for an athlete
router.get("/athlete/:athleteId", getAthleteReports);

// GET SINGLE REPORT BY ID - Add this route
router.get("/:reportId", getMedicalReportById);

// DELETE REPORT - Add this route
router.delete("/:reportId", deleteMedicalReport);

export default router;