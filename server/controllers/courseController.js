const catchAsyncError = require("../middlewares/catchAsyncError.js");
const { Course } = require("../models/Course.js");
const getDataUri = require("../utils/dataUri.js");
const ErrorHandler = require("../utils/errorHandler.js");
const cloudinary = require("cloudinary");
const { Stats } = require("../models/Stats.js");

const getAllCourses = catchAsyncError(async (req, res, next) => {
  const keyword = req.query.keyword || "";
  const category = req.query.category || "";
  const courses = await Course.find({
    title: {
      $regex: keyword,
      $options: "i",
    },
    category: {
      $regex: category,
      $options: "i",
    },
  }).select("-lectures");
  res.status(200).json({
    success: true,
    courses,
  });
});

const createCourse = catchAsyncError(async (req, res, next) => {
  const { title, description, category, createdBy } = req.body;
  if (!title || !description || !category || !createdBy) {
    return next(new ErrorHandler("Please add all fields", 400));
  }

  const file = req.file;

  const fileUri = getDataUri(file);

  const mycloud = await cloudinary.v2.uploader.upload(fileUri.content, {
    folder: "elearning",
  });

  await Course.create({
    title,
    description,
    category,
    createdBy,
    poster: {
      public_id: mycloud.public_id,
      url: mycloud.secure_url,
    },
  });

  res.status(201).json({
    success: true,
    message: "Course Created Successfully. You can add lectures now.",
  });
});

const getCourseLectures = catchAsyncError(async (req, res, next) => {
  const course = await Course.findById(req.params.id);

  if (!course) return next(new ErrorHandler("Course not found", 404));

  course.views += 1;

  await course.save();

  res.status(200).json({
    success: true,
    lectures: course.lectures,
  });
});

// // Max video size 100mb
const addLecture = catchAsyncError(async (req, res, next) => {
  const { id } = req.params;
  const { title, description } = req.body;

  const course = await Course.findById(id);

  if (!course) return next(new ErrorHandler("Course not found", 404));

  const file = req.file;
  const fileUri = getDataUri(file);

  const mycloud = await cloudinary.v2.uploader.upload(fileUri.content, {
    resource_type: "video",
    folder: "elearning",
  });

  course.lectures.push({
    title,
    description,
    video: {
      public_id: mycloud.public_id,
      url: mycloud.secure_url,
    },
  });

  course.numOfVideos = course.lectures.length;
  console.log("courtse lectures : ", course.lectures);

  await course.save();

  res.status(200).json({
    success: true,
    message: "Lecture added in Course",
  });
});

const deleteCourse = catchAsyncError(async (req, res, next) => {
  const { id } = req.params;

  const course = await Course.findById(id);

  if (!course) {
    return next(new ErrorHandler("Course not found", 404));
  }

  // Delete course poster from cloudinary
  await cloudinary.v2.uploader.destroy(course.poster.public_id);

  // Delete all lectures' videos from cloudinary
  for (let i = 0; i < course.lectures.length; i++) {
    const singleLecture = course.lectures[i];
    await cloudinary.v2.uploader.destroy(singleLecture.video.public_id, {
      resource_type: "video",
    });
  }

  await Course.findByIdAndDelete(id);

  res.status(200).json({
    success: true,
    message: "Course Deleted Successfully",
  });
});

const deleteLecture = catchAsyncError(async (req, res, next) => {
  const { courseId, lectureId } = req.query;

  const course = await Course.findById(courseId);
  if (!course) return next(new ErrorHandler("Course not found", 404));

  const lecture = course.lectures.find((item) => {
    if (item._id.toString() === lectureId.toString()) return item;
  });
  await cloudinary.v2.uploader.destroy(lecture.video.public_id, {
    resource_type: "video",
  });

  course.lectures = course.lectures.filter((item) => {
    if (item._id.toString() !== lectureId.toString()) return item;
  });

  course.numOfVideos = course.lectures.length;

  await course.save();

  res.status(200).json({
    success: true,
    message: "Lecture Deleted Successfully",
  });
});

const editCourse = catchAsyncError(async (req, res, next) => {
  const { id } = req.params;
  const { title, description, category, createdBy } = req.body;

  // Find the course by ID
  let course = await Course.findById(id);

  if (!course) {
    return next(new ErrorHandler("Course not found", 404));
  }

  // Update the course details
  course.title = title || course.title;
  course.description = description || course.description;
  course.category = category || course.category;
  course.createdBy = createdBy || course.createdBy;

  // If a new poster is provided, update it in Cloudinary
  if (req.file) {
    const file = req.file;
    const fileUri = getDataUri(file);

    // Delete the old poster from Cloudinary
    await cloudinary.v2.uploader.destroy(course.poster.public_id);

    // Upload the new poster to Cloudinary
    const mycloud = await cloudinary.v2.uploader.upload(fileUri.content, {
      folder: "elearning",
    });

    course.poster = {
      public_id: mycloud.public_id,
      url: mycloud.secure_url,
    };
  }

  // Save the updated course
  await course.save();

  res.status(200).json({
    success: true,
    message: "Course updated successfully",
    course,
  });
});

Course.watch().on("change", async () => {
  let stat_size = await Stats.countDocuments();
  if (stat_size === 0) await Stats.create({});

  const stats = await Stats.find({}).sort({ createdAt: "desc" }).limit(1);

  const courses = await Course.find({});

  let totalViews = 0;

  for (let i = 0; i < courses.length; i++) {
    totalViews += courses[i].views;
  }
  stats[0].views = totalViews;
  stats[0].createdAt = new Date(Date.now());

  await stats[0].save();
});

module.exports = {
  getAllCourses,
  addLecture,
  getCourseLectures,
  createCourse,
  deleteCourse,
  deleteLecture,
  editCourse,
};
