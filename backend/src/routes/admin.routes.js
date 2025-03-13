import { Router } from "express";
import { registerOrganizationAthlete,
  registerAdmin,
  registerCoach,
  getAllUsers,
  generateAccessAndRefreshToken,
  logoutAdmin,
  getAdminProfile,
  getRpeInsights, } from "../controllers/admin.controllers.js";
import {verifyJWTAdmin} from "../middlewares/auth.middleware.js"
import { upload } from "../middlewares/multer.middleware.js";


const router = Router()

router.route("/register").post(
  upload.single("avatar"), // Handle avatar image upload
  registerAdmin
);

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


