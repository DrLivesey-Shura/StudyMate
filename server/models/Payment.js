const mongoose = require("mongoose");

const schema = new mongoose.Schema({
  bt_signature: {
    type: String,
    required: true,
  },
  bt_payment_id: {
    type: String,
    required: true,
  },
  bt_subscription_id: {
    type: String,
    required: true,
  },

  createdAt: {
    type: Date,
    default: Date.now,
  },
});

const Payment = mongoose.model("Payment", schema);
module.exports = { Payment };
