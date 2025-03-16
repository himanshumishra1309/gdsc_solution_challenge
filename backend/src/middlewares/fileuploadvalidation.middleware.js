const fileUploadValidationMiddleware = (req, res, next) => {
  if (!req.file) {
    return res.status(400).json({ message: "No file uploaded." });
  }

  const allowedTypes = ["image/jpeg", "image/png"];
  if (!allowedTypes.includes(req.file.mimetype)) {
    return res
      .status(400)
      .json({ message: "Invalid file type. Only JPEG and PNG are allowed." });
  }

  next();
};

export { fileUploadValidationMiddleware };
