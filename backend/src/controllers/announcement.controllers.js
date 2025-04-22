import asyncHandler from "../utils/asyncHandler.js";
import ApiError from "../utils/ApiError.js";
import ApiResponse from "../utils/ApiResponse.js";
import { Announcement } from "../models/announcements.model.js";
import { Coach } from "../models/coach.model.js"; // Assuming you have a Coach model
import { Athlete } from "../models/athlete.model.js"; // Assuming you have an Athlete model
import mongoose from "mongoose";


const createAnnouncement = asyncHandler(async (req, res) => {
  const { title, content, sports = [] } = req.body;

  // Validate required fields
  if (!title || !content) {
    throw new ApiError(400, "Title and content are required");
  }

  const coach = req.coach;
  if (!coach) {
    throw new ApiError(401, "Unauthorized access");
  }

  // Create announcement object
  const announcementData = {
    title,
    content,
    createddBy: coach._id, // Note: Using the field name as defined in your model
  };

  // Add sports if provided
  if (sports.length > 0) {
    announcementData.sports = sports;
  }

  // Save the announcement
  const announcement = await Announcement.create(announcementData);

  return res.status(201).json(
    new ApiResponse(201, announcement, "Announcement created successfully")
  );
});


const updateAnnouncement = asyncHandler(async (req, res) => {
  const { announcementId } = req.params;
  const { title, content, sports } = req.body;

  // Validate announcement ID
  if (!mongoose.Types.ObjectId.isValid(announcementId)) {
    throw new ApiError(400, "Invalid announcement ID");
  }

  // Find the announcement
  const announcement = await Announcement.findById(announcementId);
  if (!announcement) {
    throw new ApiError(404, "Announcement not found");
  }

  // Verify ownership - only creator can update
  if (announcement.createddBy.toString() !== req.coach._id.toString()) {
    throw new ApiError(403, "You can only update your own announcements");
  }

  // Update fields if provided
  if (title) announcement.title = title;
  if (content) announcement.content = content;
  if (sports) announcement.sports = sports;

  // Save the updated announcement
  await announcement.save();

  return res.status(200).json(
    new ApiResponse(200, announcement, "Announcement updated successfully")
  );
});


const deleteAnnouncement = asyncHandler(async (req, res) => {
  const { announcementId } = req.params;

  // Validate announcement ID
  if (!mongoose.Types.ObjectId.isValid(announcementId)) {
    throw new ApiError(400, "Invalid announcement ID");
  }

  // Find the announcement
  const announcement = await Announcement.findById(announcementId);
  if (!announcement) {
    throw new ApiError(404, "Announcement not found");
  }

  // Verify ownership - only creator can delete
  if (announcement.createddBy.toString() !== req.coach._id.toString()) {
    throw new ApiError(403, "You can only delete your own announcements");
  }

  // Delete the announcement
  await Announcement.findByIdAndDelete(announcementId);

  return res.status(200).json(
    new ApiResponse(200, null, "Announcement deleted successfully")
  );
});


const athleteGetAnnouncements = asyncHandler(async (req, res) => {
    const { page = 1, limit = 10, search } = req.query;
    const skip = (parseInt(page) - 1) * parseInt(limit);
    
    // Verify athlete exists in the request
    if (!req.athlete) {
      throw new ApiError(401, "Unauthorized access");
    }
  
    // Get coaches assigned to this athlete using the correct field names from the model
    const headCoach = req.athlete.headCoachAssigned;
    const assistantCoach = req.athlete.assistantCoachAssigned;
    const medicalStaff = req.athlete.medicalStaffAssigned;
    const gymTrainer = req.athlete.gymTrainerAssigned;
  
    // Check if athlete has any coaches - return empty result instead of error
    if(!headCoach && !assistantCoach && !medicalStaff && !gymTrainer) {
      return res.status(200).json(
        new ApiResponse(
          200, 
          {
            announcements: [],
            pagination: {
              currentPage: parseInt(page),
              totalPages: 0,
              totalAnnouncements: 0
            }
          },
          "No coaches assigned to this athlete yet"
        )
      );
    }
  
    // Create an array of coach IDs, filtering out undefined values
    const coachIds = [headCoach, assistantCoach, medicalStaff, gymTrainer].filter(id => id);
  
    // Build query to find announcements from the athlete's coaches
    let query = { createddBy: { $in: coachIds } };
    
    // Add search functionality if provided
    if (search) {
      query.$or = [
        { title: { $regex: search, $options: 'i' } },
        { content: { $regex: search, $options: 'i' } }
      ];
    }
  
    try {
      // Find announcements with pagination
      const announcements = await Announcement.find(query)
        .populate('createddBy', 'name avatar designation')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(parseInt(limit));
  
      // Get total count for pagination
      const totalAnnouncements = await Announcement.countDocuments(query);
  
      // Return successful response
      return res.status(200).json(
        new ApiResponse(
          200, 
          {
            announcements,
            pagination: {
              currentPage: parseInt(page),
              totalPages: Math.ceil(totalAnnouncements / parseInt(limit)),
              totalAnnouncements
            }
          },
          "Announcements from your coaches retrieved successfully"
        )
      );
    } catch (error) {
      throw new ApiError(500, "Error retrieving announcements: " + error.message);
    }
});


const coachGetTheirSportsAnnouncements = asyncHandler(async (req, res) => {
    const { page = 1, limit = 10, search } = req.query;
    const skip = (parseInt(page) - 1) * parseInt(limit);
    
    // Verify coach exists in the request
    const coach = req.coach;
    console.log("Coach ID:", coach._id);
    if (!coach) {
      throw new ApiError(401, "Unauthorized access");
    }
  
    // Get coach's sports
    const coachSports = coach.sports || [];
    console.log("Coach Sports:", coachSports);
    
    if (coachSports.length === 0) {
      return res.status(200).json(
        new ApiResponse(
          200, 
          {
            announcements: [],
            pagination: {
              currentPage: parseInt(page),
              totalPages: 0,
              totalAnnouncements: 0
            }
          },
          "No sports assigned to this coach"
        )
      );
    }
  
    // Build query to find:
    // 1. Announcements with no sports (visible to all)
    // 2. Announcements with at least one sport matching coach's sports
    // 3. Announcements created by the coach themselves
    let query = {
      $or: [
        { sports: { $size: 0 } }, // Announcements with no sports specified
        { sports: { $in: coachSports } }, // Announcements with matching sports
        { createddBy: coach._id } // Announcements created by this coach
      ]
    };
    
    // Add search functionality if provided
    if (search) {
      query = {
        $and: [
          query,
          {
            $or: [
              { title: { $regex: search, $options: 'i' } },
              { content: { $regex: search, $options: 'i' } }
            ]
          }
        ]
      };
    }
  
    try {
      // Find announcements with pagination
      const announcements = await Announcement.find(query)
        .populate('createddBy', 'name avatar designation')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(parseInt(limit));
  
      // Get total count for pagination
      const totalAnnouncements = await Announcement.countDocuments(query);
      
      // Add flag to indicate which announcements were created by the current coach
      const enhancedAnnouncements = announcements.map(announcement => {
        const announcementObj = announcement.toObject();
        announcementObj.isOwnAnnouncement = 
          announcement.createddBy && 
          announcement.createddBy._id.toString() === coach._id.toString();
        return announcementObj;
      });
  
      // Return successful response
      return res.status(200).json(
        new ApiResponse(
          200, 
          {
            announcements: enhancedAnnouncements,
            pagination: {
              currentPage: parseInt(page),
              totalPages: Math.ceil(totalAnnouncements / parseInt(limit)),
              totalAnnouncements
            },
            coachSports // Include the coach's sports for reference
          },
          "Sports-related announcements retrieved successfully"
        )
      );
    } catch (error) {
      throw new ApiError(500, "Error retrieving announcements: " + error.message);
    }
  });

const getMyAnnouncements = asyncHandler(async (req, res) => {
  const coach = req.coach;
  if (!coach) {
    throw new ApiError(401, "Unauthorized access");
  }

  const { page = 1, limit = 10, search } = req.query;
  const skip = (parseInt(page) - 1) * parseInt(limit);
  
  const query = { createddBy: coach._id };
  
  // Add search if provided
  if (search) {
    query.$or = [
      { title: { $regex: search, $options: 'i' } },
      { content: { $regex: search, $options: 'i' } }
    ];
  }

  // Execute query with pagination
  const announcements = await Announcement.find(query)
    .sort({ createdAt: -1 })
    .skip(skip)
    .limit(parseInt(limit));

  // Get total count for pagination
  const totalAnnouncements = await Announcement.countDocuments(query);

  return res.status(200).json(
    new ApiResponse(
      200, 
      {
        announcements,
        pagination: {
          currentPage: parseInt(page),
          totalPages: Math.ceil(totalAnnouncements / parseInt(limit)),
          totalAnnouncements
        }
      },
      "Your announcements retrieved successfully"
    )
  );
});


const getAnnouncements = asyncHandler(async (req, res) => {
  const { page = 1, limit = 10, search, sport } = req.query;
  const skip = (parseInt(page) - 1) * parseInt(limit);
  
  const user = req.coach || req.athlete;
  if (!user) {
    throw new ApiError(401, "Unauthorized access");
  }

  let query = {};
  
  // If user is an athlete, find their coach(es) and get announcements from those coaches
  if (req.athlete) {
    // Assuming athletes have a reference to their coach(es)
    const coachIds = req.athlete.coaches || [];
    if (coachIds.length === 0) {
      // If athlete has no coaches, return empty result
      return res.status(200).json(
        new ApiResponse(
          200, 
          {
            announcements: [],
            pagination: {
              currentPage: parseInt(page),
              totalPages: 0,
              totalAnnouncements: 0
            }
          },
          "No announcements available"
        )
      );
    }
    query.createddBy = { $in: coachIds };
  } 
  else if (req.medicalStaff || req.trainer) {
    // For medical staff and trainers, get all announcements from their organization
    // This assumes you have a way to identify coaches in the same organization
    // You might need to adjust this based on your actual data model
    const organizationId = user.organization;
    if (!organizationId) {
      return res.status(200).json(
        new ApiResponse(
          200, 
          {
            announcements: [],
            pagination: {
              currentPage: parseInt(page),
              totalPages: 0,
              totalAnnouncements: 0
            }
          },
          "No announcements available"
        )
      );
    }
    
    // Find all coaches in this organization
    const coaches = await Coach.find({ organization: organizationId }).select('_id');
    const coachIds = coaches.map(coach => coach._id);
    
    query.createddBy = { $in: coachIds };
  }
  
  // Add sport filter if provided
  if (sport) {
    query.sports = sport;
  }
  
  // Add search if provided
  if (search) {
    query.$or = [
      { title: { $regex: search, $options: 'i' } },
      { content: { $regex: search, $options: 'i' } }
    ];
  }

  // Execute query with pagination
  const announcements = await Announcement.find(query)
    .populate('createddBy', 'name avatar designation') // Populate coach info
    .sort({ createdAt: -1 })
    .skip(skip)
    .limit(parseInt(limit));

  // Get total count for pagination
  const totalAnnouncements = await Announcement.countDocuments(query);

  return res.status(200).json(
    new ApiResponse(
      200, 
      {
        announcements,
        pagination: {
          currentPage: parseInt(page),
          totalPages: Math.ceil(totalAnnouncements / parseInt(limit)),
          totalAnnouncements
        }
      },
      "Announcements retrieved successfully"
    )
  );
});


const getAnnouncementById = asyncHandler(async (req, res) => {
  const { announcementId } = req.params;

  // Validate announcement ID
  if (!mongoose.Types.ObjectId.isValid(announcementId)) {
    throw new ApiError(400, "Invalid announcement ID");
  }

  // Find the announcement
  const announcement = await Announcement.findById(announcementId)
    .populate('createddBy', 'name avatar designation');

  if (!announcement) {
    throw new ApiError(404, "Announcement not found");
  }

  const user = req.coach || req.athlete || req.medicalStaff || req.trainer;
  if (!user) {
    throw new ApiError(401, "Unauthorized access");
  }

  // Check permissions - this would need to be adapted to your specific requirements
  // For example, checking if an athlete's coach created this announcement
  if (req.athlete) {
    // Assuming athletes have a reference to their coach(es)
    const coachIds = req.athlete.coaches?.map(c => c.toString()) || [];
    if (!coachIds.includes(announcement.createddBy.toString())) {
      throw new ApiError(403, "You don't have permission to view this announcement");
    }
  }

  return res.status(200).json(
    new ApiResponse(200, announcement, "Announcement retrieved successfully")
  );
});


const getAnnouncementsByCoach = asyncHandler(async (req, res) => {
  const { coachId } = req.params;
  const { page = 1, limit = 10 } = req.query;
  
  // Validate coach ID
  if (!mongoose.Types.ObjectId.isValid(coachId)) {
    throw new ApiError(400, "Invalid coach ID");
  }

  const skip = (parseInt(page) - 1) * parseInt(limit);
  
  // Get announcements for this coach
  const announcements = await Announcement.find({ createddBy: coachId })
    .populate('createddBy', 'name avatar designation')
    .sort({ createdAt: -1 })
    .skip(skip)
    .limit(parseInt(limit));

  // Get total count for pagination
  const totalAnnouncements = await Announcement.countDocuments({ createddBy: coachId });

  return res.status(200).json(
    new ApiResponse(
      200, 
      {
        announcements,
        pagination: {
          currentPage: parseInt(page),
          totalPages: Math.ceil(totalAnnouncements / parseInt(limit)),
          totalAnnouncements
        }
      },
      "Coach announcements retrieved successfully"
    )
  );
});


const getCoachesWithSharedAthletes = asyncHandler(async (req, res) => {
    const coach = req.coach;
    
    // Find all athletes assigned to this coach
    const athletes = await Athlete.find({ 
      $or: [
        { headCoach: coach._id },
        { assistantCoach: coach._id },
        { medicalStaff: coach._id },
        { gymTrainer: coach._id }
      ]
    }).select('_id headCoach assistantCoach medicalStaff gymTrainer');
    
    // Extract all coach IDs who share these athletes
    const coachIds = new Set();
    
    athletes.forEach(athlete => {
      if (athlete.headCoach && athlete.headCoach.toString() !== coach._id.toString()) {
        coachIds.add(athlete.headCoach.toString());
      }
      if (athlete.assistantCoach && athlete.assistantCoach.toString() !== coach._id.toString()) {
        coachIds.add(athlete.assistantCoach.toString());
      }
      if (athlete.medicalStaff && athlete.medicalStaff.toString() !== coach._id.toString()) {
        coachIds.add(athlete.medicalStaff.toString());
      }
      if (athlete.gymTrainer && athlete.gymTrainer.toString() !== coach._id.toString()) {
        coachIds.add(athlete.gymTrainer.toString());
      }
    });
    
    return res.status(200).json(
      new ApiResponse(
        200, 
        {
          coachIds: Array.from(coachIds)
        },
        "Coaches with shared athletes retrieved successfully"
      )
    );
  });


export {
  createAnnouncement,
  updateAnnouncement,
  deleteAnnouncement,
  getMyAnnouncements,
  getAnnouncements,
  getAnnouncementById,
  getAnnouncementsByCoach,
  athleteGetAnnouncements,
  coachGetTheirSportsAnnouncements,
  getCoachesWithSharedAthletes
};