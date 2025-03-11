import { Router } from "express";
import {upload} from "../middlewares/multer.middleware.js"
import { 
    loginUser, 
    logoutUser, 
    refreshAccessToken,
} from "../controllers/user.controller.js";
import {verifySponsorJWT} from "../middlewares/sponsor.middleware.js"
import {registerSponsor, loginSponsor, logoutSponsor} from "../controllers/sponsor.controllers.js";

const router = Router()

router.post("/register",registerSponsor);
router.post("/login", loginSponsor);
router.post("/logout", verifySponsorJWT, logoutSponsor);

export default router;