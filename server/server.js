const http = require("http");
const express = require("express");
const cors = require("cors");
const mongoose = require("mongoose");
require("dotenv").config();
const { Server } = require("socket.io");

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*",
  },
});

mongoose
  .connect(process.env.MONGO_DB_URL, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  })
  .then(() => {
    console.log("MongoDB Connection Succeeded.");
  })
  .catch((error) => {
    console.log("Error in DB connection:", error);
  });

app.use(cors({ origin: "*" }));
app.use(express.json());

const user = require("./routes/userRoutes");
const payment = require("./routes/paymentRoutes");
const course = require("./routes/courseRoutes");
const chat = require("./routes/chatRoutes");
const Message = require("./models/Message");

app.use("/api", user);
app.use("/api", payment);
app.use("/api", course);
app.use("/api", chat);

io.on("connection", (socket) => {
  console.log("User connected:", socket.id);

  socket.on("joinRoom", (userId) => {
    socket.join(userId);
    console.log(`User ${userId} joined room: ${userId}`);
  });

  socket.on("sendMessage", async ({ senderId, receiverId, content }) => {
    const newMessage = new Message({
      senderId,
      receiverId,
      content,
      timestamp: new Date(),
    });

    try {
      await newMessage.save();

      io.to(senderId).emit("receiveMessage", newMessage);
      io.to(receiverId).emit("receiveMessage", newMessage);
    } catch (error) {
      console.error("Error saving message:", error);
    }
  });

  socket.on("disconnect", () => {
    console.log("User disconnected:", socket.id);
  });
});

const PORT = process.env.PORT || 5000;
server.listen(PORT, () => {
  console.log("App running on port:", PORT);
});
