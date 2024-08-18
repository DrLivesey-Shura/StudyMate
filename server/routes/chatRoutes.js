const express = require("express");
const { isAuthenticated } = require("../middlewares/auth.js");
const {
  sendMessage,
  getMessages,
} = require("../controllers/chatController.js");

const router = express.Router();

router.route("/messages").post(isAuthenticated, sendMessage);
router
  .route("/messages/:senderId/:receiverId")
  .get(isAuthenticated, getMessages);

module.exports = router;
