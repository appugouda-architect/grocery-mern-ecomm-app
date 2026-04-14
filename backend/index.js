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
	? process.env.ALLOWED_ORIGINS.split(',').map((o) => o.trim())
	: ['http://localhost:5173', 'http://localhost:8080'];
//middlewares
// app.use(cors({ origin: allowedOrigins, credentials: true }));

app.use(
	cors({
		origin: (origin, callback) => {
			// allow server-to-server (origin undefined) and whitelisted origins
			if (!origin || allowedOrigins.includes(origin)) {
				callback(null, true);
			} else {
				callback(new Error('CORS: origin not allowed'));
			}
		},
		credentials: true,
		methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
		allowedHeaders: ['Content-Type', 'Authorization'],
	}),
);
app.use(cookieParser());
app.use(express.json());
// app.options("*", cors());

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
app.get('/api/health', (req, res) => {
	res.status(200).json({ status: 'ok' });
});

const PORT = process.env.PORT || 9000;
app.listen(PORT, '0.0.0.0', () => {
	connectDB();
	console.log(process.env.NODE_ENV);
	console.log(`Server is running on port ${PORT}`);
});

process.on('SIGTERM', () => {
	console.log('SIGTERM received — closing HTTP server');
	server.close(() => {
		mongoose.connection.close(false, () => process.exit(0));
	});
});
