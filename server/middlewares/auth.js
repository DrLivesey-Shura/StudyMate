const jwt = require("jsonwebtoken");
const ErrorHandler = require("../utils/errorHandler.js");
const catchAsyncError = require("./catchAsyncError.js");
const { User } = require("../models/User.js");

const isAuthenticated = catchAsyncError(async (req, res, next) => {
  const token = req.cookies || req.headers.authorization?.split(" ")[1];
  // const token = req.cookies || req.headers.cookie?.split("=")[1];

  if (!token) return next(new ErrorHandler("Not Logged In", 401));

  const decoded = jwt.verify(token, process.env.JWT_SECRET);

  req.user = await User.findById(decoded._id);

  next();
});

const authorizeSubscribers = (req, res, next) => {
  if (req.user.subscription.status !== "Active" && req.user.role !== "admin")
    return next(
      new ErrorHandler(`Only Subscribers can access this resource`, 403)
    );

  next();
};

const authorizeAdmin = (req, res, next) => {
  if (req.user.role !== "Teacher")
    return next(
      new ErrorHandler(
        `${req.user.role} is not allowed to access this resource`,
        403
      )
    );

  next();
};

module.exports = { authorizeAdmin, authorizeSubscribers, isAuthenticated };
