import express from "express";
import { registerOrganization, getOrganizationDetails, getAllOrganizations } from "../controllers/organization.controller.js";

const router = express.Router();


router.get("/", getAllOrganizations); // Get list of all organizations

router.post("/register", registerOrganization);
router.get("/:orgId", getOrganizationDetails);

export default router;
