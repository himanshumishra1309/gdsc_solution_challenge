import { Router } from "express";
import { registerOrganizationAthlete, registerCoach, getAllUsers } from "../controllers/admin.controllers.js";
import {verifyJWTAdmin} from "../middlewares/auth.middleware.js"
// import {verifyJWTCoach} from "../middlewares/auth.middleware.js"
// import { verifyAdmin } from "../middlewares/admin.middleware.js";


const router = Router()



router.post("/register-athlete",verifyJWTAdmin, registerOrganizationAthlete);
router.post("/register-coach",verifyJWTAdmin, registerCoach);


const sportEnum = ["Football", "Badminton", "Cricket", "Basketball", "Tennis"];
router.get("/allowed-sports", (req, res) => {
  res.json({ allowedSports: sportEnum });
});

// router.get("/users", verifyJWTAdmin, getAllUsers);
// router.post("/login", loginAdmin);
// router.post("/logout", verifyAdminJWT, logoutAdmin);

export default router;


