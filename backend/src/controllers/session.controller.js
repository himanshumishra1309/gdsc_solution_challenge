import ApiError from "../utils/ApiError.js";
import ApiResponse from "../utils/ApiResponse.js";


const getSessionRPE = async (req, res, next) => {
    try {
      const { sessionId } = req.params;
  
      const session = await Session.findById(sessionId);
      if (!session) {
        return next(new ApiError(404, "Session not found"));
      }
  
      return res
        .status(200)
        .json(new ApiResponse(200, { sessionRPE: session.sessionRPE || null }, "RPE fetched successfully"));
    } catch (error) {
      next(new ApiError(500, "Internal server error"));
    }
  };


  export{
    getSessionRPE
  }