import { Router } from "express";
import {upload} from "../middlewares/multer.middleware.js"
import {verifySponsorJWT} from "../middlewares/sponsor.middleware.js"
import {registerSponsor, loginSponsor, logoutSponsor, getSponsorProfile, updateSponsorProfile, getSportsList, addSportToSelection, removeSportFromSelection, getSelectedSports, 
    getSponsorRequests, markRequestAsViewed, updateRequestStatus, getNewMessages, getUnreadInvitations
} from "../controllers/sponsor.controllers.js";

const router = Router()

router.post("/register", upload.single("avatar"), registerSponsor); //connected
router.post("/login", loginSponsor); //connected
router.post("/logout", verifySponsorJWT, logoutSponsor); //connected

// Profile routes
router.get("/profile", verifySponsorJWT, getSponsorProfile);
router.patch("/profile", verifySponsorJWT, upload.single("avatar"), updateSponsorProfile);

//Interested Sports routes
router.get("/sports", verifySponsorJWT, getSportsList);
router.get("/selected-sports", verifySponsorJWT, getSelectedSports);
router.post("/select-sport", verifySponsorJWT, addSportToSelection);
router.post("/remove-sport",verifySponsorJWT, removeSportFromSelection);

// Get all sponsorship requests (filtered by status if provided)
router.get("/requests", verifySponsorJWT, getSponsorRequests);

// Mark a request as viewed
router.patch("/requests/:requestId/viewed", verifySponsorJWT, markRequestAsViewed);

// Accept/Decline a sponsorship request
router.patch("/requests/:requestId/status", verifySponsorJWT, updateRequestStatus);

// Get new messages from the last 24 hours
router.get("/messages/new", verifySponsorJWT, getNewMessages);

// Get unread invitations
router.get("/invitations/unread", verifySponsorJWT, getUnreadInvitations);
export default router;