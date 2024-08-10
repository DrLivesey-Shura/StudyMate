const catchAsyncError = require("../middlewares/catchAsyncError.js");
const { User } = require("../models/User.js");
const ErrorHandler = require("../utils/errorHandler.js");
const { Payment } = require("../models/Payment.js");
const braintree = require("braintree");
const dotenv = require("dotenv");

dotenv.config();

const gateway = new braintree.BraintreeGateway({
  environment: braintree.Environment.Sandbox,
  merchantId: process.env.BRAINTREE_MERCHANT_ID,
  publicKey: process.env.BRAINTREE_PUBLIC_KEY,
  privateKey: process.env.BRAINTREE_PRIVATE_KEY,
});

const buySubscription = catchAsyncError(async (req, res, next) => {
  const user = await User.findById(req.user._id);

  if (user.role === "admin") {
    return next(new ErrorHandler("Admin can't buy subscription", 400));
  }

  const { paymentMethodNonce } = req.body;
  const planId = process.env.BRAINTREE_PLAN_ID;

  if (!planId) {
    return next(new ErrorHandler("Plan ID not configured", 400));
  }

  gateway.customer.create(
    {
      paymentMethodNonce,
      email: user.email,
    },
    (err, result) => {
      if (err || !result.success) {
        return next(new ErrorHandler(err ? err.message : result.message, 400));
      }

      const customerId = result.customer.id;
      const paymentMethodToken = result.customer.paymentMethods[0].token;

      gateway.subscription.create(
        {
          paymentMethodToken,
          planId,
        },
        async (err, result) => {
          console.log("Braintree Response:", result);

          if (err || !result.success) {
            return next(
              new ErrorHandler(err ? err.message : result.message, 400)
            );
          }

          user.subscription.id = result.subscription.id;
          user.subscription.status = result.subscription.status;
          await user.save();

          res.status(201).json({
            success: true,
            subscriptionId: result.subscription.id,
          });
        }
      );
    }
  );
});

const paymentVerification = catchAsyncError(async (req, res, next) => {
  const { bt_signature, bt_payment_id, bt_subscription_id } = req.body;

  const user = await User.findById(req.user._id);

  const subscription_id = user.subscription.id;

  // Verify payment details using a webhook or another method
  const isAuthentic = bt_signature === your_verification_logic_here;

  if (!isAuthentic) {
    return res.redirect(`${process.env.FRONTEND_URL}/paymentfail`);
  }

  await Payment.create({
    bt_signature,
    bt_payment_id,
    bt_subscription_id,
  });

  user.subscription.status = "active";

  await user.save();

  res.redirect(
    `${process.env.FRONTEND_URL}/paymentsuccess?reference=${bt_payment_id}`
  );
});

const getBraintreeClientToken = catchAsyncError(async (req, res, next) => {
  gateway.clientToken.generate({}, (err, response) => {
    if (err) {
      return next(new ErrorHandler(err.message, 500));
    }

    res.status(200).json({
      success: true,
      token: response.clientToken,
    });
  });
});

const cancelSubscription = catchAsyncError(async (req, res, next) => {
  const user = await User.findById(req.user._id);

  const subscriptionId = user.subscription.id;
  let refund = false;

  gateway.subscription.cancel(subscriptionId, async (err, result) => {
    if (err || !result.success) {
      return next(new ErrorHandler(err.message, 400));
    }

    const payment = await Payment.findOne({
      bt_subscription_id: subscriptionId,
    });

    const gap = Date.now() - payment.createdAt;
    const refundTime = process.env.REFUND_DAYS * 24 * 60 * 60 * 1000;

    if (refundTime > gap) {
      await gateway.transaction.refund(payment.bt_payment_id);
      refund = true;
    }

    await payment.remove();
    user.subscription.id = undefined;
    user.subscription.status = undefined;
    await user.save();

    res.status(200).json({
      success: true,
      message: refund
        ? "Subscription cancelled. You will receive a full refund within 7 days."
        : "Subscription cancelled. No refund initiated as subscription was cancelled after 7 days.",
    });
  });
});

module.exports = {
  buySubscription,
  paymentVerification,
  getBraintreeClientToken,
  cancelSubscription,
};
