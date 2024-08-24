const express = require("express");
const { isAuthenticated } = require("../middlewares/auth.js");
const {
  createSubscription,
  cancelSubscription,
} = require("../controllers/paymentController.js");

const router = express.Router();

// Buy Subscription
router.route("/subscribe").post(isAuthenticated, createSubscription);

// Verify Payment and save reference in database
// router.route("/paymentverification").post(isAuthenticated, paymentVerification);

// // Get Braintree Client Token
// router.route("/braintree/token").get(getBraintreeClientToken);

// Cancel Subscription
router.route("/subscribe/cancel").post(isAuthenticated, cancelSubscription);

module.exports = router;
