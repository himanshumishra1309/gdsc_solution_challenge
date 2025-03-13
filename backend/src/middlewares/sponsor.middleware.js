import asyncHandler from "../utils/asyncHandler.js";
import jwt from "jsonwebtoken";
import { Sponsor } from "../models/sponsor.model.js";
import { ApiError } from "../utils/ApiError.js";

export const verifySponsorJWT = asyncHandler(async (req, res, next) => {
    try {
        const token = req.cookies?.sponsorAccessToken || 
                      req.header("Authorization")?.replace("Bearer ", "");

        console.log("Extracted Token:", token); // Debugging line

        if (!token) {
            throw new ApiError(401, "Unauthorized request - No Token Found");
        }

        const decodedToken = jwt.verify(token, process.env.ACCESS_TOKEN_SECRET);
        const sponsor = await Sponsor.findById(decodedToken?._id).select("-password -refreshToken");

        if (!sponsor) {
            throw new ApiError(401, "Invalid Access Token - No Sponsor Found");
        }

        req.sponsor = sponsor; // Correct assignment
        next();
    } catch (error) {
        console.error("JWT Verification Error:", error); // Debugging line
        throw new ApiError(401, error?.message || "Invalid access token");
    }
});