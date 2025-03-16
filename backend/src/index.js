import { app } from "./app.js";
import dotenv from "dotenv";
import connectDB from "./db/index.js";

dotenv.config({ path: "./.env" });

connectDB()
  .then(() => {
    // Listen on all network interfaces (0.0.0.0) instead of just localhost
    // Add logging to debug server startup issues
    app.listen(process.env.PORT || 8000, "0.0.0.0", () => {
      console.log(`Server is running at port : ${process.env.PORT || 8000}`);
      console.log("Server bound to all interfaces (0.0.0.0)");
      console.log(`For Android emulators: http://10.0.2.2:${process.env.PORT || 8000}`);
      console.log(`For localhost web access: http://localhost:${process.env.PORT || 8000}`);
    });

    app.on("error", (error) => {
      console.log("Error :", error);
      throw error;
    });
  })
  .catch((err) => {
    console.log("MongoDB connection failed !! ", err);
  });