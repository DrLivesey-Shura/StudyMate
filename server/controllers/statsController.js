const { Stats } = require("../models/Stats");

const fetchCourseStats = async (req, res) => {
  try {
    // Fetch the latest statistics entry
    const stats = await Stats.find({}).sort({ createdAt: "desc" }).limit(1);

    if (!stats || stats.length === 0) {
      return res.status(404).json({
        success: false,
        message: "No statistics available",
      });
    }

    // Send the stats data to the frontend
    res.status(200).json({
      success: true,
      data: stats[0],
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "An error occurred while fetching statistics",
      error: error.message,
    });
  }
};

module.exports = { fetchCourseStats };
