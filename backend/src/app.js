import express from "express";
import cookieParser from "cookie-parser";
import cors from "cors";
import errorHandler from "./middlewares/errorHandler.middleware.js";

const app = express();

// ✅ CORS Configuration
app.use(cors({
    origin: process.env.CORS_ORIGIN,
    credentials: true
}));

// ✅ Body Parsing
app.use(express.json({ limit: "16kb" }));
app.use(express.urlencoded({ extended: true, limit: "16kb" }));

// ✅ Static Files & Cookies
app.use(express.static("public"));
app.use(cookieParser());

// ✅ Importing Routes
import adminRouter from "./routes/admin.routes.js";
import athleteRouter from "./routes/athlete.routes.js";
import coachRouter from "./routes/coach.routes.js";
import organizationRouter from "./routes/organization.routes.js";
import authRouter from "./routes/auth.routes.js"; // Common auth routes for login/logout
import sponsorRouter from "./routes/sponsor.routes.js";
import financesRouter from "./routes/finance.routes.js";
import notificationRoutes from "./routes/notification.routes.js";

// ✅ Declaring Routes
app.use("/api/v1/admins", adminRouter);
app.use("/api/v1/athletes", athleteRouter);
app.use("/api/v1/coaches", coachRouter);
app.use("/api/v1/sponsors", sponsorRouter);
app.use("/api/v1/organizations", organizationRouter);
app.use("/api/v1/auth", authRouter); 
app.use("/api/v1/finances", financesRouter); 
app.use("/api/v1/notifications", notificationRoutes);

// ✅ Global Error Handler (Moved to Bottom)
app.use(errorHandler);

export { app };
