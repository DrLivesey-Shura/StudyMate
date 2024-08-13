const express = require("express");
const {
  buySubscription,
  cancelSubscription,
  getBraintreeClientToken,
  paymentVerification,
} = require("../controllers/paymentController.js");
const { isAuthenticated } = require("../middlewares/auth.js");

const router = express.Router();

// Buy Subscription
router.route("/subscribe").post(isAuthenticated, buySubscription);

// Verify Payment and save reference in database
router.route("/paymentverification").post(isAuthenticated, paymentVerification);

// Get Braintree Client Token
router.route("/braintree/token").get(getBraintreeClientToken);

// Cancel Subscription
router.route("/subscribe/cancel").delete(isAuthenticated, cancelSubscription);

module.exports = router;
