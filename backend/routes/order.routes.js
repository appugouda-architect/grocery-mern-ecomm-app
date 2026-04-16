import express from "express";
import authUser from "../middlewares/authUser.js";
import {
  getAllOrders,
  getUserOrders,
  placeOrderCOD,
  createRazorpayOrder,
  verifyRazorpayPayment,
} from "../controller/order.controller.js";
import { authSeller } from "../middlewares/authSeller.js";

const router = express.Router();

// COD
router.post("/cod", authUser, placeOrderCOD);

// Razorpay — Step 1: create order on Razorpay + pending DB record
router.post("/razorpay/create", authUser, createRazorpayOrder);
// Razorpay — Step 2: verify signature + mark order paid + clear cart
router.post("/razorpay/verify", authUser, verifyRazorpayPayment);

// Order listings
router.get("/user", authUser, getUserOrders);
router.get("/seller", authSeller, getAllOrders);

export default router;
