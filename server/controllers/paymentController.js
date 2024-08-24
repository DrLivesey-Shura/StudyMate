const { User } = require("../models/User");

const stripe = require("stripe")(process.env.STRIPE_SECRET_KEY);

const createSubscription = async (req, res) => {
  try {
    const { paymentMethodId, userId } = req.body;
    const user = await User.findById(userId);
    console.log("user: ", user);
    console.log("paymentMethodId: ", paymentMethodId);

    const customer = await stripe.customers.create({
      email: user.email,
      payment_method: paymentMethodId,
      invoice_settings: {
        default_payment_method: paymentMethodId,
      },
    });

    const subscription = await stripe.subscriptions.create({
      customer: customer.id,
      items: [{ plan: "price_1PnnOiC1JQ2VbTUThATEk6aE" }],
      expand: ["latest_invoice.payment_intent"],
    });

    user.subscription.id = subscription.id;
    user.subscription.status = subscription.status;
    await user.save();

    res
      .status(200)
      .json({ message: "Subscription created successfully", subscription });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Subscription creation failed" });
  }
};

const cancelSubscription = async (req, res) => {
  try {
    const { userId } = req.body;
    const user = await User.findById(userId);

    const subscription = await stripe.subscriptions.del(user.subscription.id);

    user.subscription.id = null;
    user.subscription.status = "canceled";
    await user.save();

    res.status(200).json({ message: "Subscription canceled successfully" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Subscription cancellation failed" });
  }
};

module.exports = { createSubscription, cancelSubscription };
