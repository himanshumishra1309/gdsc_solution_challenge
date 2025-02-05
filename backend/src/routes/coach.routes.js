import { Router } from "express";
import {upload} from "../middlewares/multer.middleware.js"
import { 
    loginUser, 
    logoutUser, 
    refreshAccessToken,
} from "../controllers/user.controller.js";
import {verifyCoachJWT} from "../middlewares/coach.middleware.js"


const router = Router()




router.post("/login", loginAdmin);
router.post("/logout", verifyCoachJWT, logoutCoach);