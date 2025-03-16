import cors from "cors";
import express from "express";
import cookieParser from "cookie-parser";
import errorHandler from "./middlewares/errorHandler.middleware.js";

const app = express();

// Add this middleware before your cors configuration
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl} from ${req.ip}`);
  next();
});

// Better CORS configuration for Flutter and web clients
app.use(
  cors({
    origin: function(origin, callback) {
      // Allow requests with no origin (like mobile apps, Postman)
      if (!origin) return callback(null, true);
      
      // Define allowed origins for web clients
      const allowedOrigins = [
        'http://localhost:5173',
        'http://localhost:3000',
        'http://127.0.0.1:5173',
        '*'
        // Add your production domains when ready
      ];
      
      if (allowedOrigins.includes(origin)) {
        return callback(null, true);
      }
      
      // During development, you might want to allow all origins
      return callback(null, true);
      
      // In production, use this instead:
      // return callback(new Error('Not allowed by CORS'), false);
    },
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization']
  })
);


app.use(
  express.json({
    limit: "16kb",
  })
);

app.use(
  express.urlencoded({
    extended: true,
    limit: "16kb",
  })
);

app.use(express.static("public"));

app.use(cookieParser());

app.use(errorHandler);

import adminRouter from "./routes/admin.routes.js";
import athleteRouter from "./routes/athlete.routes.js";
import coachRouter from "./routes/coach.routes.js";
import individualAthleteRouter from "./routes/individualAthlete.routes.js";
import organizationRouter from "./routes/organization.routes.js";
import authRouter from "./routes/auth.routes.js";
import sponsorRouter from "./routes/sponsor.routes.js";
import financesRouter from "./routes/finance.routes.js";
import notificationRoutes from "./routes/notification.routes.js";
import trainingPlanrouter from "./routes/trainingPlan.routes.js";

app.get("/api/v1/health", (req, res) => {
  res.status(200).json({
    success: true,
    message: "Server is running",
    timestamp: new Date().toISOString()
  });
});

// Add this near the top of your route definitions, before all other routes
app.get("/test", (req, res) => {
  console.log("Basic test endpoint hit!");
  res.send("Server is working");
});

app.get("/", (req, res) => {
  res.send("API is running");
});

app.use("/api/v1/admins", adminRouter);
app.use("/api/v1/athletes", athleteRouter);
app.use("/api/v1/independent-athletes", individualAthleteRouter);
app.use("/api/v1/coaches", coachRouter);
app.use("/api/v1/sponsors", sponsorRouter);
app.use("/api/v1/organizations", organizationRouter);
app.use("/api/v1/auth", authRouter);
app.use("/api/v1/finances", financesRouter); 
app.use("/api/v1/notifications", notificationRoutes);
app.use("/api/v1/training", trainingPlanrouter);

// ✅ Global Error Handler (Moved to Bottom)
app.use(errorHandler);

export { app };