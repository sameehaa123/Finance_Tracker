import 'package:ai_poweredfinancetracker/features/payment/view/payment_failed_screen.dart';
import 'package:flutter/material.dart';
import 'package:ai_poweredfinancetracker/core/Services/navigation_service.dart';
import 'package:ai_poweredfinancetracker/features/payment/view/payment_success_screen.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../features/payment/controller/payment_controller.dart';


class PaymentService {
  static late Razorpay _razorpay;

static final PaymentController _paymentController = PaymentController();
 
      static String? _paymentDocId;
      static String? _selectedPlan;
      static int? _selectedAmount;

  static void init() {
    _razorpay = Razorpay();
    

    _razorpay.on(
      Razorpay.EVENT_PAYMENT_SUCCESS,
      handlePaymentSuccess,
    );

    _razorpay.on(
      Razorpay.EVENT_PAYMENT_ERROR,
      handlePaymentError,
    );

    _razorpay.on(
      Razorpay.EVENT_EXTERNAL_WALLET,
      handleExternalWallet,
    );
  }


  static Future<void> openCheckout({
    required int amount,
    required String planName,
    required String userEmail,
    required String userContact,
  }) async {
    _selectedPlan = planName;
    _selectedAmount = amount;

    _paymentDocId = await _paymentController.createPendingPayment(
      planName: planName,
      amount: amount,
    );
    
    var options = {
      'key': 'rzp_test_RQX7adT0U42yu4',
      'amount': amount,
      'name': 'Spendly',
      'description': planName,
      'prefill': {
        'contact': userContact,
        'email': userEmail,
      },
    };

    _razorpay.open(options);
  }

  static void handlePaymentSuccess(PaymentSuccessResponse response) async {
    print("Success");

if ( _paymentDocId == null) return;

NavigationService.navigatorKey.currentState?.pushReplacement(
  MaterialPageRoute(
    builder: (_) => const PaymentSuccessScreen(),
  ),
);

    await _paymentController.markPaymentSuccess(
      paymentDocId: _paymentDocId!,
      paymentId: response.paymentId ?? "",
      orderId: response.orderId ?? "",
      signature: response.signature ?? "",
      planName: _selectedPlan!,
    );


  }

  static void handlePaymentError(PaymentFailureResponse response) async{
    print("Failed");

    NavigationService.navigatorKey.currentState?.pushReplacement(
  MaterialPageRoute(
    builder: (_) => const PaymentFailedScreen(),
  ),
);

 if (_paymentDocId == null) return;

    await _paymentController.markPaymentFailed(
      paymentDocId: _paymentDocId!,
      errorCode: response.code.toString(),
      errorMessage: response.message ?? "",
    );

  }

  static void handleExternalWallet(ExternalWalletResponse response) {
    print(response.walletName);
  }

  static void dispose() {
    _razorpay.clear();
  }
}