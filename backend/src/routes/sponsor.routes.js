import { Router } from "express";
import {upload} from "../middlewares/multer.middleware.js"
import {verifySponsorJWT} from "../middlewares/sponsor.middleware.js"
import {registerSponsor, loginSponsor, logoutSponsor, getSponsorProfile, updateSponsorProfile} from "../controllers/sponsor.controllers.js";

const router = Router()

router.post("/register", upload.single("avatar"), registerSponsor); //connected
router.post("/login", loginSponsor); //connected
router.post("/logout", verifySponsorJWT, logoutSponsor); //connected

// Profile routes
router.get("/profile", verifySponsorJWT, getSponsorProfile);
router.patch("/profile", verifySponsorJWT, upload.single("avatar"), updateSponsorProfile);

export default router;