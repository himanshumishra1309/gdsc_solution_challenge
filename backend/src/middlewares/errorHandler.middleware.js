import ApiError  from "../utils/ApiError.js";

// Express error-handling middleware
const errorHandler = (err, req, res, next) => {
  let { statusCode, message, errors } = err;

  // If it's not an instance of ApiError, create a default one
  if (!(err instanceof ApiError)) {
    statusCode = err.statusCode || 500;
    message = err.message || "Internal Server Error";
    errors = err.errors || [];
  }

  // Include stack trace only in development mode
  const response = {
    success: false,
    statusCode,
    message,
    errors,
    ...(process.env.NODE_ENV === "development" && { stack: err.stack }),
  };

  res.status(statusCode).json(response);
};

export default errorHandler;
