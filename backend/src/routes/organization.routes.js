import express from "express";
import { registerOrganization, getOrganizationDetails, getAllOrganizations } from "../controllers/organization.controller.js";
import { upload } from "../middlewares/multer.middleware.js";

const router = express.Router();


router.get("/", getAllOrganizations); // Get list of all organizations

router.post("/register", upload.fields([
    { name: "logo", maxCount: 1 },
    { name: "certificates", maxCount: 1 },
    { name: "adminAvatar", maxCount: 1 }
  ]), registerOrganization);
router.get("/:orgId", getOrganizationDetails);

export default router;
