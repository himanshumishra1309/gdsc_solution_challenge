import {ApiError} from "../utils/ApiError.js";

// Express error-handling middleware
const errorHandler = (err, req, res, next) => {
  let { statusCode, message, errors } = err;

  // If it's not an instance of ApiError, create a default one
  if (!(err instanceof ApiError)) {
    statusCode = 500;
    message = "Internal Server Error";
  }

  res.status(statusCode).json({
    success: false,
    statusCode,
    message,
    errors: errors || [],
  });
};

export default errorHandler;
