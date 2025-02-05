import { Router } from "express";
import {upload} from "../middlewares/multer.middleware.js"
import { 
    loginUser, 
    logoutUser, 
    refreshAccessToken,
} from "../controllers/user.controller.js";
import {verifyAthleteJWT} from "../middlewares/athlete.middleware.js"


const router = Router()



router.post("/login", loginAthlete);
router.post("/logout", verifyAthleteJWT, logoutAthlete);