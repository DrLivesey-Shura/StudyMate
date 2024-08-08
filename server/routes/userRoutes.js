const express = require("express");
const {
  deleteUser,
  getAllUsers,
  getMyProfile,
  login,
  logout,
  register,
  updateProfile,
  updateprofilepicture,
  updateUserRole,
  tokenIsValid,
} = require("../controllers/userController.js");
const { authorizeAdmin, isAuthenticated } = require("../middlewares/auth.js");
const singleUpload = require("../middlewares/multer.js");

const router = express.Router();

// To register a new user
router.route("/register").post(singleUpload, register);

// Login
router.route("/login").post(login);
router.route("/tokenIsValid").post(tokenIsValid);

// logout
router.route("/logout").get(logout);

// Get my profile
router.route("/profile").get(isAuthenticated, getMyProfile);

// UpdateProfile
router.route("/updateprofile").put(isAuthenticated, updateProfile);

// UpdateProfilePicture
router
  .route("/updateprofilepicture")
  .put(isAuthenticated, singleUpload, updateprofilepicture);

// Admin Routes
router.route("/admin/users").get(isAuthenticated, authorizeAdmin, getAllUsers);

router
  .route("/admin/user/:id")
  .put(isAuthenticated, authorizeAdmin, updateUserRole)
  .delete(isAuthenticated, authorizeAdmin, deleteUser);

module.exports = router;
