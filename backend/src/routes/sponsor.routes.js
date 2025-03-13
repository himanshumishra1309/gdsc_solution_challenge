import { Router } from "express";
import {upload} from "../middlewares/multer.middleware.js"
import {verifySponsorJWT} from "../middlewares/sponsor.middleware.js"
import {registerSponsor, loginSponsor, logoutSponsor, getSponsorProfile, updateSponsorProfile} from "../controllers/sponsor.controllers.js";

const router = Router()

router.post("/register", upload.single("avatar"), registerSponsor);
router.post("/login", loginSponsor);
router.post("/logout", verifySponsorJWT, logoutSponsor);

// Profile routes
router.get("/profile", verifySponsorJWT, getSponsorProfile);
router.patch("/profile", verifySponsorJWT, upload.single("avatar"), updateSponsorProfile);

export default router;