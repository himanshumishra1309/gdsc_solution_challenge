import express from "express";

import { Router } from "express";
import { loginAthlete, loginCoach, loginAdmin } from "../controllers/auth.controller.js";

const router = express.Router();



router.post("/athlete/login", loginAthlete); //connected
router.post("/coach/login", loginCoach); //connected
router.post("/admin/login", loginAdmin); //connected




export default router;