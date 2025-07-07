// features/payment/services/payment_service.dart
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/material.dart';

class PaymentService {
  late Razorpay _razorpay;

  PaymentService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<void> initiatePayment({
    required double amount,
    required String bookingId,
    required String userEmail,
    required String userPhone,
    required Function(String) onSuccess,
    required Function(String) onError,
  }) async {
    final options = {
      'key': 'YOUR_RAZORPAY_KEY',
      'amount': (amount * 100).toInt(), // Amount in paise
      'name': 'FitBook',
      'description': 'Facility Booking Payment',
      'order_id': bookingId,
      'prefill': {
        'contact': userPhone,
        'email': userEmail,
      },
      'theme': {
        'color': '#1E88E5',
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      onError('Payment initialization failed: ${e.toString()}');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Handle successful payment
    debugPrint('Payment Success: ${response.paymentId}');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Handle payment failure
    debugPrint('Payment Error: ${response.code} - ${response.message}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Handle external wallet
    debugPrint('External Wallet: ${response.walletName}');
  }

  void dispose() {
    _razorpay.clear();
  }
}