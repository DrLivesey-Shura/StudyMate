const express = require("express");
const {
  addLecture,
  deleteLecture,
  getAllCourses,
  createCourse,
  getCourseLectures,
  deleteCourse,
  editCourse,
} = require("../controllers/courseController.js");

const {
  authorizeAdmin,
  isAuthenticated,
  authorizeSubscribers,
} = require("../middlewares/auth.js");

const singleUpload = require("../middlewares/multer.js");
const createRecommendation = require("../controllers/recommendationController.js");

const router = express.Router();

// Get All courses without lectures
router.route("/courses").get(getAllCourses);

// create new course - only admin
router
  .route("/createcourse")
  .post(isAuthenticated, authorizeAdmin, singleUpload, createCourse);

// Add lecture, Delete Course, Get Course Details
router
  .route("/course/:id")
  .get(isAuthenticated, getCourseLectures)
  .post(isAuthenticated, authorizeAdmin, singleUpload, addLecture)
  .delete(isAuthenticated, authorizeAdmin, deleteCourse)
  .put(isAuthenticated, authorizeAdmin, singleUpload, editCourse);

// Create Recommendation based on User's Playlist
router.route("/recommend").post(createRecommendation);

// Delete Lecture
router.route("/lecture").delete(isAuthenticated, authorizeAdmin, deleteLecture);

module.exports = router;
