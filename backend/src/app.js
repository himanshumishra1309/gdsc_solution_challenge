import express from "express";
import cookieParser from "cookie-parser";
import cors from "cors";
import errorHandler from "./middlewares/errorHandler.middleware.js";
import express from "express";
import cookieParser from "cookie-parser";
import cors from "cors";
import errorHandler from "./middlewares/errorHandler.middleware.js";

const app = express();

app.use(
  cors({
    origin: "http://localhost:5173",
    credentials: true,
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

app.use("/api/v1/admins", adminRouter);
app.use("/api/v1/athletes", athleteRouter);
app.use("/api/v1/independent-athletes", individualAthleteRouter);
app.use("/api/v1/coaches", coachRouter);
app.use("/api/v1/sponsors", sponsorRouter);
app.use("/api/v1/organizations", organizationRouter);
app.use("/api/v1/auth", authRouter);

export { app };