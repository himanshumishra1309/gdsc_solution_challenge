import { Router } from "express";
import {
  createInjuryTicket,
  getAllInjuryTickets,
  getInjuryDetails,
  getAthleteInjuryTickets,
  getDoctorInjuryTickets,
  getMyInjuryTickets,
  getMyInjuryTicketDetails,
  updateInjuryReport,
  addShortMessage,
  updateShortMessage,
  addInjuryAssessment,
  updateInjuryAssessment,
  deleteInjuryTicket,
  getInjuryMessages,
  getInjuryShortMessages,
  getInjuryAssessmentForAthlete,
} from "../controllers/injury.controller.js";
import { verifyJWT } from "../middlewares/auth.middleware.js";
import { verifyJWTAthlete } from "../middlewares/auth.middleware.js";
import { verifyJWTCoach } from "../middlewares/auth.middleware.js";

const router = Router();

router.post("/create", verifyJWTAthlete, createInjuryTicket);
router.get("/all", verifyJWT, getAllInjuryTickets);
router.get("/:ticketId/details", verifyJWT, getInjuryDetails);
router.get("/athlete/:athleteId", verifyJWT, getAthleteInjuryTickets);
router.get("/doctor/:doctorId?", verifyJWTCoach, getDoctorInjuryTickets);
router.get("/my-tickets", verifyJWTAthlete, getMyInjuryTickets);
router.get("/my-tickets/:ticketId", verifyJWTAthlete, getMyInjuryTicketDetails);

router.get("/athlete/tickets/:ticketId/messages", verifyJWTAthlete, getInjuryShortMessages);
router.get("/athlete/tickets/:ticketId/assessment", verifyJWTAthlete, getInjuryAssessmentForAthlete);

router.put("/report/:reportId", verifyJWTAthlete, updateInjuryReport);

router.post("/:ticketId/short-message", verifyJWTCoach, addShortMessage);

router.put("/short-message/:messageId", verifyJWTCoach, updateShortMessage);

router.post("/:ticketId/assessment", verifyJWTCoach, addInjuryAssessment);

router.put("/assessment/:assessmentId", verifyJWTCoach, updateInjuryAssessment);

router.delete("/:ticketId", verifyJWTAthlete, deleteInjuryTicket);

router.get("/:injuryId/messages", verifyJWT, getInjuryMessages);

export default router;
