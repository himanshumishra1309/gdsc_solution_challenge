import { Router } from "express";
import { registerOrganizationAthlete, registerCoach, getAllUsers } from "../controllers/admin.controllers.js";
import { verifyJWT } from "../middlewares/auth.middleware.js";
import { authorize } from "../middlewares/authorize.middleware.js"; // New middleware for role-based access


const router = Router()



router.post("/register-athlete",verifyJWT,authorize(["admin"]), registerOrganizationAthlete);
router.post("/register-coach",verifyJWT,authorize(["admin"]), registerCoach);


const sportEnum = ["Football", "Badminton", "Cricket", "Basketball", "Tennis"];
router.get("/allowed-sports", (req, res) => {
  res.json({ allowedSports: sportEnum });
});

// router.get("/users", verifyJWTAdmin, getAllUsers);
// router.post("/login", loginAdmin);
// router.post("/logout", verifyAdminJWT, logoutAdmin);

export default router;


