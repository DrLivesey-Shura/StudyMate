const express = require("express");
const { fetchCourseStats } = require("../controllers/statsController");

const router = express.Router();

router.get("/course-stats", fetchCourseStats);

module.exports = router;
