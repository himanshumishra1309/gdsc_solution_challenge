import Notification from "../models/notification.model.js";
import ApiResponse  from "../utils/ApiResponse.js";
import {Athlete} from "../models/athlete.model.js";
import {Coach} from "../models/coach.model.js";
import {Admin} from "../models/admin.model.js";
import asyncHandler from "../utils/asyncHandler.js";




const getNotifications = asyncHandler(async (req, res) => {
    let recipientType;

    if (await Athlete.exists({ _id: req.user._id })) {
        recipientType = "athlete";
    } else if (await Coach.exists({ _id: req.user._id })) {
        recipientType = "coach";
    } else if (await Admin.exists({ _id: req.user._id })) {
        recipientType = "admin";
    } else {
        return res.status(403).json(new ApiResponse (403, null, "Unauthorized: User type not recognized."));
    }

    const notifications = await Notification.find({
        recipientId: req.user._id,
        recipientType: recipientType
    }).sort({ createdAt: -1 });

    res.status(200).json(new ApiResponse (200, notifications, "Notifications retrieved successfully."));
});

// ✅ Mark Notification as Read
const markNotificationAsRead = asyncHandler(async (req, res) => {
    const { id } = req.params;
    const notification = await Notification.findById(id);

    if (!notification) {
        return res.status(404).json(new ApiResponse (404, null, "Notification not found."));
    }

    if (notification.recipientId.toString() !== req.user._id.toString()) {
        return res.status(403).json(new ApiResponse (403, null, "Unauthorized: Cannot mark others' notifications."));
    }

    notification.isRead = true;
    await notification.save();

    res.status(200).json(new ApiResponse (200, notification, "Notification marked as read."));
});


export{
    getNotifications,
    markNotificationAsRead
}