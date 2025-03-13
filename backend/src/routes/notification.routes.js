import express from "express";
import { getNotifications, markNotificationAsRead } from "../controllers/notification.controller.js";
import { verifyJWT } from "../middlewares/auth.middleware.js";

const router = express.Router();

// ✅ Fetch Notifications for Logged-in User
router.get("/", verifyJWT, getNotifications);

// ✅ Mark Notification as Read
router.patch("/:id/read", verifyJWT, markNotificationAsRead);

export default router;
