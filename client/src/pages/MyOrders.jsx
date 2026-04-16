import { useContext, useEffect, useState } from 'react';
import { AppContext } from '../context/AppContext';
import toast from 'react-hot-toast';
import { API_BASE_URL } from '../constants';

// Payment badge — colour-coded so users instantly know payment status
const PaymentBadge = ({ paymentType, isPaid }) => {
	if (paymentType === 'COD') {
		return (
			<span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-700 border border-gray-300">
				💵 Cash on Delivery
			</span>
		);
	}
	if (isPaid) {
		return (
			<span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-50 text-green-700 border border-green-300">
				✅ Paid Online
			</span>
		);
	}
	// Shouldn't appear in the list (filtered server-side) but defensive fallback
	return (
		<span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-50 text-red-700 border border-red-300">
			⏳ Payment Pending
		</span>
	);
};

const MyOrders = () => {
	const [myOrders, setMyOrders] = useState([]);
	const { axios, user } = useContext(AppContext);

	const fetchOrders = async () => {
		try {
			const { data } = await axios.get('/api/order/user');
			if (data.success) {
				setMyOrders(data.orders);
			} else {
				toast.error(data.message);
			}
		} catch (error) {
			toast.error(error.message);
		}
	};

	useEffect(() => {
		if (user) {
			fetchOrders();
		}
	}, [user]);

	return (
		<div className="mt-12 pb-16 max-w-4xl mx-auto px-4">
			<p className="text-2xl md:text-3xl font-medium mb-2">My Orders</p>

			{myOrders.length === 0 && (
				<p className="text-gray-400 mt-10 text-center">No orders yet.</p>
			)}

			{myOrders.map((order, index) => (
				<div
					key={index}
					className="my-6 border border-gray-200 rounded-xl shadow-sm overflow-hidden"
				>
					{/* Order header */}
					<div className="flex flex-wrap items-center justify-between gap-3 bg-gray-50 px-5 py-3 border-b border-gray-200">
						<div className="flex flex-col">
							<span className="text-xs text-gray-400 uppercase tracking-wide">Order ID</span>
							<span className="text-sm font-mono text-gray-600">{order._id}</span>
						</div>

						<PaymentBadge paymentType={order.paymentType} isPaid={order.isPaid} />

						<div className="flex flex-col items-end">
							<span className="text-xs text-gray-400 uppercase tracking-wide">Total</span>
							<span className="text-sm font-semibold text-gray-800">
								₹{order.amount}
							</span>
						</div>
					</div>

					{/* Order items */}
					{order.items.map((item, idx) => (
						<div
							key={idx}
							className={`flex flex-col md:flex-row md:items-center justify-between gap-4 bg-white px-5 py-4 ${
								idx !== order.items.length - 1 ? 'border-b border-gray-100' : ''
							}`}
						>
							{/* Product info */}
							<div className="flex items-center gap-4">
								<div className="w-16 h-16 flex-shrink-0 rounded-lg overflow-hidden border border-gray-100 bg-gray-50 flex items-center justify-center">
									<img
										src={`${API_BASE_URL}/images/${item.product.image[0]}`}
										alt={item.product.name}
										className="w-full h-full object-cover"
									/>
								</div>
								<div>
									<h2 className="text-base font-medium text-gray-800">
										{item.product.name}
									</h2>
									<p className="text-sm text-gray-400">{item.product.category}</p>
								</div>
							</div>

							{/* Order meta */}
							<div className="flex flex-wrap gap-6 text-sm text-gray-500">
								<div>
									<span className="text-xs text-gray-400 block">Qty</span>
									<span className="font-medium text-gray-700">{item.quantity}</span>
								</div>
								<div>
									<span className="text-xs text-gray-400 block">Status</span>
									<span className="font-medium text-indigo-600">{order.status}</span>
								</div>
								<div>
									<span className="text-xs text-gray-400 block">Date</span>
									<span className="font-medium text-gray-700">
										{new Date(order.createdAt).toLocaleDateString('en-IN', {
											day: '2-digit',
											month: 'short',
											year: 'numeric',
										})}
									</span>
								</div>
							</div>

							{/* Item total */}
							<div className="text-right">
								<span className="text-xs text-gray-400 block">Item Total</span>
								<span className="text-base font-semibold text-gray-800">
									₹{item.product.offerPrice * item.quantity}
								</span>
							</div>
						</div>
					))}
				</div>
			))}
		</div>
	);
};
export default MyOrders;
