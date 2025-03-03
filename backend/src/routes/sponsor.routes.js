import { Router } from "express";
import {upload} from "../middlewares/multer.middleware.js"
import { 
    loginUser, 
    logoutUser, 
    refreshAccessToken,
} from "../controllers/user.controller.js";
import {verifySponsorJWT} from "../middlewares/sponsor.middleware.js"


const router = Router()

router.post("/login", loginSponsor);
router.post("/logout", verifySponsorJWT, logoutSponsor);

export default router;