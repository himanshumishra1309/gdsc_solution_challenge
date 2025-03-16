
import ApiError from "../utils/ApiError.js";



const authorize = (allowedRoles) => (req, res, next) => {
    if (!allowedRoles.includes(req.user.role)) {
      const rolesList = allowedRoles.join(", "); // Convert allowed roles to a readable string
      throw new ApiError(403, `Access Denied. This action is restricted to: ${rolesList}.`);
    }
    next();
  };

  export{
    authorize
  }