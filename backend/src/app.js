import express from "express"
import cookieParser from "cookie-parser"
import cors from "cors"
import errorHandler from "./middlewares/errorHandler.middleware.js"

const app = express()

app.use(cors({
    origin: process.env.CORS_ORIGIN,
    credentials: true
}))

app.use(express.json({
limit: "16kb"
}))

app.use(express.urlencoded({
    extended: true,
    limit: "16kb"
}))

app.use(express.static("public"))

app.use(cookieParser())

app.use(errorHandler)


//routes import
import adminRouter from "./routes/admin.routes.js";
import athleteRouter from "./routes/athlete.routes.js";
import coachRouter from "./routes/coach.routes.js";
import organizationRouter from "./routes/organization.routes.js";
import authRouter from "./routes/auth.routes.js"; // Common auth routes for login/logout


//routes declaration
app.use("/api/v1/admins", adminRouter);
app.use("/api/v1/athletes", athleteRouter);
app.use("/api/v1/coaches", coachRouter);
console.log("Organization routes loaded");
app.use("/api/v1/organizations", organizationRouter);
app.use("/api/v1/auth", authRouter); 
// Handles login/logout for all users
//userRouter goes takes you to that router file and there's the methods
// http://localhost:8000/api/v1/users/register

export {app}