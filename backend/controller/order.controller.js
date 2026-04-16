import crypto from 'crypto';
import Order from '../models/order.model.js';
import Product from '../models/product.model.js';
import User from '../models/user.model.js';
import razorpay from '../config/razorpay.js';

// Shared helper: calculate order amount from items array (returns INR, includes 2% tax)
const calculateOrderAmount = async (items) => {
  let amount = await items.reduce(async (acc, item) => {
    const product = await Product.findById(item.product);
    if (!product) throw new Error(`Product not found: ${item.product}`);
    return (await acc) + product.offerPrice * item.quantity;
  }, 0);
  // Add 2% tax
  amount += Math.floor((amount * 2) / 100);
  return amount;
};

// Place order COD: POST /api/order/cod
export const placeOrderCOD = async (req, res) => {
  try {
    const userId = req.user;
    const { items, address } = req.body;
    if (!address || !items || items.length === 0) {
      return res.status(400).json({ message: 'Invalid order details', success: false });
    }
    const amount = await calculateOrderAmount(items);
    await Order.create({
      userId,
      items,
      address,
      amount,
      paymentType: 'COD',
      isPaid: false,
    });
    res.status(201).json({ message: 'Order placed successfully', success: true });
  } catch (error) {
    console.error('Error placing COD order:', error);
    res.status(500).json({ message: 'Internal Server Error', success: false });
  }
};

// Step 1 — Create Razorpay order + pending DB record: POST /api/order/razorpay/create
export const createRazorpayOrder = async (req, res) => {
  try {
    const userId = req.user;
    const { items, address } = req.body;
    if (!address || !items || items.length === 0) {
      return res.status(400).json({ message: 'Invalid order details', success: false });
    }

    const amount = await calculateOrderAmount(items);

    // Save a pending order in DB. It stays isPaid:false until the payment is verified.
    // getUserOrders filters it out (paymentType=COD OR isPaid=true), so the user
    // never sees it in My Orders unless payment succeeds.
    const order = await Order.create({
      userId,
      items,
      address,
      amount,
      paymentType: 'Online',
      isPaid: false,
    });

    // Create the order on Razorpay. Amount must be in paise (1 INR = 100 paise).
    const razorpayOrder = await razorpay.orders.create({
      amount: Math.round(amount * 100),
      currency: 'INR',
      receipt: order._id.toString(), // ties the Razorpay order to our DB record
    });

    res.status(201).json({
      success: true,
      orderId: order._id,
      razorpayOrderId: razorpayOrder.id,
      amount: razorpayOrder.amount,       // paise — passed directly to checkout modal
      currency: razorpayOrder.currency,
      keyId: process.env.RAZORPAY_KEY_ID, // safe to expose; this is the public key
    });
  } catch (error) {
    console.error('Error creating Razorpay order:', error);
    res.status(500).json({ message: 'Internal Server Error', success: false });
  }
};

// Step 2 — Verify payment signature + mark order paid: POST /api/order/razorpay/verify
export const verifyRazorpayPayment = async (req, res) => {
  try {
    const userId = req.user;
    const { razorpayOrderId, razorpayPaymentId, razorpaySignature, orderId } = req.body;

    if (!razorpayOrderId || !razorpayPaymentId || !razorpaySignature || !orderId) {
      return res.status(400).json({ message: 'Missing payment details', success: false });
    }

    // Razorpay signature verification: HMAC-SHA256 of "orderId|paymentId" using KEY_SECRET.
    // This is the only way to prove the payment was authorised by Razorpay and not spoofed.
    const body = `${razorpayOrderId}|${razorpayPaymentId}`;
    const expectedSignature = crypto
      .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET)
      .update(body)
      .digest('hex');

    if (expectedSignature !== razorpaySignature) {
      // Signature mismatch — tampered or replayed request. Delete the pending order.
      await Order.findByIdAndDelete(orderId);
      return res.status(400).json({ message: 'Payment verification failed', success: false });
    }

    // Signature is valid. Mark order as paid and clear the user's cart atomically.
    await Promise.all([
      Order.findByIdAndUpdate(orderId, { isPaid: true }),
      User.findByIdAndUpdate(userId, { cartItems: {} }),
    ]);

    res.status(200).json({ message: 'Payment successful', success: true });
  } catch (error) {
    console.error('Error verifying Razorpay payment:', error);
    res.status(500).json({ message: 'Internal Server Error', success: false });
  }
};

// Order details for individual user: GET /api/order/user
export const getUserOrders = async (req, res) => {
  try {
    const userId = req.user;
    const orders = await Order.find({
      userId,
      $or: [{ paymentType: 'COD' }, { isPaid: true }],
    })
      .populate('items.product address')
      .sort({ createdAt: -1 });
    res.status(200).json({ success: true, orders });
  } catch (error) {
    res.status(500).json({ message: 'Internal Server Error', success: false });
  }
};

// Get all orders for admin: GET /api/order/seller
export const getAllOrders = async (req, res) => {
  try {
    const orders = await Order.find({
      $or: [{ paymentType: 'COD' }, { isPaid: true }],
    })
      .populate('items.product address')
      .sort({ createdAt: -1 });
    res.status(200).json({ success: true, orders });
  } catch (error) {
    res.status(500).json({ message: 'Internal Server Error', success: false });
  }
};
