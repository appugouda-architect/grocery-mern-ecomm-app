import express from 'express';
import cors from 'cors';
import cookieParser from 'cookie-parser';
import dotenv from 'dotenv';
import { connectDB } from './config/connectDB.js';
dotenv.config();
import userRoutes from './routes/user.routes.js';
import sellerRoutes from './routes/seller.routes.js';
import productRoutes from './routes/product.routes.js';
import cartRoutes from './routes/cart.routes.js';
import addressRoutes from './routes/address.routes.js';
import orderRoutes from './routes/order.routes.js';

import { connectCloudinary } from './config/cloudinary.js';

const app = express();

await connectCloudinary();

// allow multiple origins
const allowedOrigins = process.env.ALLOWED_ORIGINS
	? process.env.ALLOWED_ORIGINS.split(',')
	: [
		'http://localhost:5173',
		'http://localhost:8081',
		'http://localhost:9000',
	];
//middlewares
app.use(cors({ origin: allowedOrigins, credentials: true }));
app.use(cookieParser());
app.use(express.json());

// Api endpoints
app.get('/api', (req, res) => {
	res.send('API is running...');
});
app.use('/images', express.static('uploads'));
app.use('/api/user', userRoutes);
app.use('/api/seller', sellerRoutes);
app.use('/api/product', productRoutes);
app.use('/api/cart', cartRoutes);
app.use('/api/address', addressRoutes);
app.use('/api/order', orderRoutes);

const PORT = process.env.PORT || 9000;
app.listen(PORT, () => {
	connectDB();
	console.log(process.env.NODE_ENV);
	console.log(`Server is running on port ${PORT}`);
});
