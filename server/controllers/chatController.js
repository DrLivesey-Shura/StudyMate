const catchAsyncError = require("../middlewares/catchAsyncError");
const Message = require("../models/Message");

const sendMessage = catchAsyncError(async (req, res, next) => {
  try {
    const message = new Message(req.body);
    await message.save();
    res.status(200).send(message);
  } catch (error) {
    res.status(400).send(error);
  }
});

const getMessages = catchAsyncError(async (req, res, next) => {
  try {
    const { senderId, receiverId } = req.params;

    const messages = await Message.find({
      $or: [
        { senderId: senderId, receiverId: receiverId },
        { senderId: receiverId, receiverId: senderId },
      ],
    }).sort("timestamp");

    res.status(200).send(messages);
  } catch (error) {
    console.error("Error fetching messages:", error);
    res.status(500).send({ message: "Failed to fetch messages", error });
  }
});

module.exports = { sendMessage, getMessages };
