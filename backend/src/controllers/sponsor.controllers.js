import asyncHandler from "../utils/asyncHandler.js"
import {ApiError} from "../utils/ApiError.js"
import {Sponsor} from "../models/sponsor.model.js"
import jwt from 'jsonwebtoken'
import {ApiResponse} from "../utils/ApiResponse.js"


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
            new ApiResponse(
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
            new ApiResponse(
                200, {
                    user: loggedInSponsor
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
            new ApiResponse(200, {}, "User Logged Out")
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
            new ApiResponse(
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
        // Get current sponsor to access existing values
        const currentSponsor = await Sponsor.findById(req.sponsor?._id);
        
        updateFields.sponsorshipRange = {
            start: sponsorshipStart !== undefined ? 
                parseInt(sponsorshipStart) : 
                currentSponsor.sponsorshipRange.start,
            end: sponsorshipEnd !== undefined ? 
                parseInt(sponsorshipEnd) : 
                currentSponsor.sponsorshipRange.end
        };
    }

    // Handle file/avatar upload if provided
    if (req.file) {
        updateFields.avatar = req.file.path;
    }

    // Update the sponsor profile with new data
    const updatedSponsor = await Sponsor.findByIdAndUpdate(
        req.sponsor?._id,
        { $set: updateFields },
        { new: true, runValidators: true }
    ).select("-password -refreshToken");

    if (!updatedSponsor) {
        throw new ApiError(404, "Sponsor not found");
    }

    return res
        .status(200)
        .json(
            new ApiResponse(
                200,
                { sponsor: updatedSponsor },
                "Sponsor profile updated successfully"
            )
        );
});

export {
    registerSponsor,
    loginSponsor,
    logoutSponsor,
 getSponsorProfile, updateSponsorProfile}