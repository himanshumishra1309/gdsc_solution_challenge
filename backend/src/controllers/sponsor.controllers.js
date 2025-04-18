import asyncHandler from "../utils/asyncHandler.js"
import ApiError from "../utils/ApiError.js"
import {Sponsor} from "../models/sponsor.model.js"
import jwt from 'jsonwebtoken'
import ApiResponse  from "../utils/ApiResponse.js"
import sportsList from "../utils/sportsData.js"

const registerSponsor = asyncHandler(async (req, res) => {
    // Debug what's being received
    console.log("Request body received:", req.body);
    console.log("Request file:", req.file);

    const { 
      name, 
      email, 
      password, 
      dob, 
      address, 
      state, 
      contactName, 
      contactNo,
      sponsorshipStart,
      sponsorshipEnd
    } = req.body;

    // Create sponsorshipRange from individual fields if they exist
    const sponsorshipRange = {
      start: sponsorshipStart || 0,
      end: sponsorshipEnd || 0
    };

    console.log("Extracted fields:", { 
      name, email, password, dob, address, state, 
      contactName, contactNo, sponsorshipRange 
    });

    // Validate required fields with better feedback
    const missingFields = [];
    if (!name) missingFields.push("name");
    if (!email) missingFields.push("email");
    if (!password) missingFields.push("password");
    if (!dob) missingFields.push("dob");
    if (!address) missingFields.push("address");
    if (!state) missingFields.push("state");
    if (!contactName) missingFields.push("contactName");
    if (!contactNo) missingFields.push("contactNo");

    if (missingFields.length > 0) {
        console.error("Missing required fields:", missingFields);
        throw new ApiError(400, `Missing required fields: ${missingFields.join(", ")}`);
    }

    // Check if sponsor already exists with this email
    const existingSponsor = await Sponsor.findOne({ email });
    if (existingSponsor) {
        throw new ApiError(400, "Sponsor with this email already exists");
    }

    // Handle file upload if avatar is provided
    let avatarPath;
    if (req.file) {
        avatarPath = req.file.path;
    }

    // Create new sponsor
    const newSponsor = new Sponsor({
        name,              // Company name
        email,
        password,
        dob,               // Date of birth
        address,           // Company address
        state,
        contactName,       // Contact person's name
        contactNo,         // Contact number
        avatar: avatarPath,
        sponsorshipRange: {
            start: parseInt(sponsorshipRange.start) || 0,
            end: parseInt(sponsorshipRange.end) || 0
        }
    });

    // Save sponsor to database
    await newSponsor.save();

    // Generate tokens
    const sponsorAccessToken = newSponsor.generateAccessToken();
    const sponsorRefreshToken = newSponsor.generateRefreshToken();

    // Save refresh token
    newSponsor.refreshToken = sponsorRefreshToken;
    await newSponsor.save({ validateBeforeSave: false });

    // Remove password from response
    const sponsorToReturn = newSponsor.toObject();
    delete sponsorToReturn.password;
    delete sponsorToReturn.refreshToken;

    // Set cookie options
    const options = {
        httpOnly: true,
        secure: process.env.NODE_ENV === "production",
        sameSite: "Strict"
    };

    // Return response
    return res
        .status(201)
        .cookie("sponsorAccessToken", sponsorAccessToken, options)
        .cookie("sponsorRefreshToken", sponsorRefreshToken, options)
        .json(
            new ApiResponse (
                201,
                {
                    user: sponsorToReturn
                },
                "Sponsor registered successfully"
            )
        );
});

const loginSponsor = asyncHandler(async (req, res) => {
    const { email, password } = req.body;
    
    if (!email || !password) {
        throw new ApiError(400, "Email and password are required");
    }
    
    const sponsor = await Sponsor.findOne({ email });
    
    if (!sponsor) {
        throw new ApiError(400, "Invalid credentials");
    }
    
    const isPasswordValid = await sponsor.isPasswordCorrect(password);
    
    if (!isPasswordValid) {
        throw new ApiError(401, "Invalid credentials");
    }
    
    const { sponsorRefreshToken, sponsorAccessToken } = await generateAccessAndRefreshToken(sponsor._id);
    
    const loggedInSponsor = await Sponsor.findById(sponsor._id)
        .select("-refreshToken -password");
    
    const options = {
        httpOnly: true,
        secure: process.env.NODE_ENV === "production",
        sameSite: "Strict"
    };
    
    return res
        .status(200)
        .cookie("sponsorAccessToken", sponsorAccessToken, options)
        .cookie("sponsorRefreshToken", sponsorRefreshToken, options)
        .json(
            new ApiResponse (
                200, {
                    user: loggedInSponsor, sponsorRefreshToken, sponsorAccessToken
                },
                "Sponsor logged in Successfully"
            )
        );
});

const generateAccessAndRefreshToken = async (sponsorId) => {
    try {
        const sponsor = await Sponsor.findById(sponsorId);
        const sponsorAccessToken = sponsor.generateAccessToken();
        const sponsorRefreshToken = sponsor.generateRefreshToken();
        
        sponsor.refreshToken = sponsorRefreshToken;
        await sponsor.save({ validateBeforeSave: false });
        
        return { sponsorAccessToken, sponsorRefreshToken };
    } catch (error) {
        throw new ApiError(500, "Something went wrong while generating tokens");
    }
};

const logoutSponsor = asyncHandler( async(req,res) => {
    await Sponsor.findByIdAndUpdate(
        req.sponsor._id,
        {
            $unset: {
              refreshToken: 1, // Correct field name
            },
        },
        { new: true }
    );
    
    
        const options = {
                httpOnly: true,
                secure: true
         }
    
         return res
         .status(200)
         .clearCookie("sponsorAccessToken", options)
         .clearCookie("sponsorRefreshToken", options)
         .json(
            new ApiResponse (200, {}, "User Logged Out")
         )
    
    
})

const getSponsorProfile = asyncHandler(async (req, res) => {
    // Get the sponsor profile using the ID from the authenticated request
    const sponsor = await Sponsor.findById(req.sponsor?._id).select(
        "-password -refreshToken"
    );

    if (!sponsor) {
        throw new ApiError(404, "Sponsor not found");
    }
    
    return res
        .status(200)
        .json(
            new ApiResponse (
                200, 
                { sponsor }, 
                "Sponsor profile fetched successfully"
            )
        );
});

const updateSponsorProfile = asyncHandler(async (req, res) => {
    // Get fields to update from request body
    const {
        name,
        email,
        address,
        state,
        contactName,
        contactNo,
        sponsorshipStart,
        sponsorshipEnd
    } = req.body;

    try {
        // Get current sponsor to check email uniqueness and access existing values
        const currentSponsor = await Sponsor.findById(req.sponsor?._id);
        
        if (!currentSponsor) {
            throw new ApiError(404, "Sponsor not found");
        }

        // Check email uniqueness if it's being updated
        if (email && email !== currentSponsor.email) {
            const existingEmailSponsor = await Sponsor.findOne({ email, _id: { $ne: req.sponsor._id } });
            if (existingEmailSponsor) {
                throw new ApiError(400, "Email already in use by another sponsor");
            }
        }

        // Create update object with only provided fields
        const updateFields = {};
        
        if (name) updateFields.name = name;
        if (email) updateFields.email = email;
        if (address) updateFields.address = address;
        if (state) updateFields.state = state;
        if (contactName) updateFields.contactName = contactName;
        if (contactNo) updateFields.contactNo = contactNo;
        
        // Handle sponsorship range updates if either value is provided
        if (sponsorshipStart !== undefined || sponsorshipEnd !== undefined) {
            const start = sponsorshipStart !== undefined ? 
                parseInt(sponsorshipStart) : 
                currentSponsor.sponsorshipRange.start;
                
            const end = sponsorshipEnd !== undefined ? 
                parseInt(sponsorshipEnd) : 
                currentSponsor.sponsorshipRange.end;
                
            // Validate that start is less than end
            if (start > end) {
                throw new ApiError(400, "Sponsorship start amount cannot be greater than end amount");
            }
            
            updateFields.sponsorshipRange = { start, end };
        }

        // Handle file/avatar upload if provided
        if (req.file) {
            updateFields.avatar = req.file.path;
        }

        // Update the sponsor profile with new data
        const updatedSponsor = await Sponsor.findByIdAndUpdate(
            req.sponsor._id,
            { $set: updateFields },
            { new: true, runValidators: true }
        ).select("-password -refreshToken");

        return res
            .status(200)
            .json(
                new ApiResponse(
                    200,
                    { sponsor: updatedSponsor },
                    "Sponsor profile updated successfully"
                )
            );
    } catch (error) {
        // Handle Mongoose validation errors
        if (error.name === 'ValidationError') {
            const validationErrors = Object.keys(error.errors).map(field => ({
                field,
                message: error.errors[field].message
            }));
            
            throw new ApiError(400, "Validation failed", validationErrors);
        }
        
        // Rethrow other errors
        throw error;
    }
});


//Interested Sports
// Get all sports categorized
const getSportsList = asyncHandler(async (req, res) => {
    const teamSports = sportsList.filter(sport => sport.type === "Team");
    const individualSports = sportsList.filter(sport => sport.type === "Individual");
  
    return res.status(200).json(new ApiResponse(200, {
      allSports: sportsList,
      teamSports,
      individualSports
    }, "Sports data fetched successfully"));
  });

const getSelectedSports = asyncHandler(async (req, res) => {
    const sponsor = await Sponsor.findById(req.sponsor._id);
    if (!sponsor) throw new ApiError(404, "Sponsor not found");
  
    return res.status(200).json(new ApiResponse(200, {
      selectedSports: sponsor.interestedSports
    }, "Selected sports fetched successfully"));
  });
  
const addSportToSelection = asyncHandler(async (req, res) => {
    const sponsorId = req.sponsor._id; // Get sponsor ID from logged-in user
    const { sport, type } = req.body;

    // Validate input
    if (!sport || !type) {
        throw new ApiError(400, "Sport and Type are required.");
    }

    // Validate type value
    if (!["Team", "Individual"].includes(type)) {
        throw new ApiError(400, "Invalid sport type. Allowed: 'Team' or 'Individual'.");
    }

    // Update sponsor document without replacing it
    const sponsor = await Sponsor.findByIdAndUpdate(
        sponsorId,
        { $push: { interestedSports: { sport, type } } }, // Push sport to array
        { new: true, context: 'query' } // Return updated document & validate
    );

    if (!sponsor) {
        throw new ApiError(404, "Sponsor not found.");
    }

    res.status(200).json(new ApiResponse(200, {}, "Sport added successfully"));
});

const removeSportFromSelection = asyncHandler(async (req, res) => {
    const sponsorId = req.sponsor._id;
    const { sport } = req.body;

    if (!sport) {
        throw new ApiError(400, "Sport is required.");
    }

    // Update sponsor by pulling the sport from the array
    const sponsor = await Sponsor.findByIdAndUpdate(
        sponsorId,
        { $pull: { interestedSports: { sport } } }, // Remove the sport
        { new: true, context: 'query' } // Prevents validation errors
    );

    if (!sponsor) {
        throw new ApiError(404, "Sponsor not found.");
    }

    res.status(200).json(new ApiResponse(200, {}, "Sport removed successfully"));
});


//Sponsor Requests

const getSponsorInvitations = asyncHandler(async (req, res) => {
    const sponsors = await Sponsor.find({ status: "Pending" });
    res.status(200).json(new ApiResponse(200, sponsors, "Sponsor invitations fetched successfully"));
});

const acceptSponsorRequest = asyncHandler(async (req, res, next) => {
    const sponsor = await Sponsor.findById(req.params.sponsorId);

    if (!sponsor) {
        return next(new ApiError(404, "Sponsor not found"));
    }

    if (sponsor.status === "Accepted") {
        return next(new ApiError(400, "Sponsor is already accepted"));
    }

    sponsor.status = "Accepted";
    await sponsor.save();

    res.status(200).json(new ApiResponse(200, sponsor, "Sponsorship request accepted successfully"));
});



const getSponsorRequests = asyncHandler(async (req, res, next) => {
    const sponsorId = req.sponsor._id;
    const { status } = req.query;

    let filter = { sponsor: sponsorId };
    if (status) filter.status = status;

    const requests = await SponsorRequest.find(filter).populate("organization", "name").select("title message notes status createdAt requestType viewed");
    
    res.status(200).json(new ApiResponse(200, requests, "Sponsorship requests retrieved successfully"));
});

// Controller: Mark Request as Viewed
const markRequestAsViewed = asyncHandler(async (req, res, next) => {
    const { requestId } = req.params;
    const sponsorId = req.sponsor._id;

    const request = await SponsorRequest.findOneAndUpdate(
        { _id: requestId, sponsor: sponsorId },
        { viewed: true },
        { new: true }
    );

    if (!request) {
        return next(new ApiError(404, "Request not found"));
    }

    res.status(200).json(new ApiResponse(200, request, "Request marked as viewed"));
});

// Controller: Accept/Decline Sponsorship Request
const updateRequestStatus = asyncHandler(async (req, res, next) => {
    const { requestId } = req.params;
    const { status } = req.body;
    const sponsorId = req.sponsor._id;

    if (!["Accepted", "Declined"].includes(status)) {
        return next(new ApiError(400, "Invalid status"));
    }

    const request = await SponsorRequest.findOneAndUpdate(
        { _id: requestId, sponsor: sponsorId },
        { status },
        { new: true }
    );

    if (!request) {
        return next(new ApiError(404, "Request not found"));
    }

    res.status(200).json(new ApiResponse(200, request, `Request ${status.toLowerCase()} successfully`));
});

//messages in last 24 hours
const getNewMessages = asyncHandler(async (req, res, next) => {
    const sponsorId = req.sponsor._id;
    const twentyFourHoursAgo = new Date();
    twentyFourHoursAgo.setHours(twentyFourHoursAgo.getHours() - 24);

    const messages = await SponsorRequest.find({
        sponsor: sponsorId,
        createdAt: { $gte: twentyFourHoursAgo }
    }).select("title message createdAt requestType viewed");

    res.status(200).json(new ApiResponse(200, messages, "New messages retrieved successfully"));
});

// Controller: Fetch Unread Invitations
const getUnreadInvitations = asyncHandler(async (req, res, next) => {
    const sponsorId = req.sponsor._id;

    const unreadInvitations = await SponsorRequest.find({
        sponsor: sponsorId,
        viewed: false
    }).select("title message createdAt requestType viewed");

    res.status(200).json(new ApiResponse(200, unreadInvitations, "Unread invitations retrieved successfully"));
});

export {
    registerSponsor,
    loginSponsor,
    logoutSponsor,
 getSponsorProfile,
  updateSponsorProfile,
 

getSportsList,
getSelectedSports,
addSportToSelection,
removeSportFromSelection,

getSponsorInvitations,
acceptSponsorRequest,
getSponsorRequests,
markRequestAsViewed,
updateRequestStatus,
getNewMessages,
getUnreadInvitations,
}