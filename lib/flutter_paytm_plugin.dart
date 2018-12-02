import 'dart:async';
import 'dart:ui' show hashValues;

import 'package:flutter/services.dart' show MethodChannel, PlatformException;
import 'package:flutter_paytm_plugin/common/paytm_transaction_response.dart';

enum BuildVariant { release, debug }

class PaytmTransactionResponse implements TransactionResponse {
  @override
  final String paytmBankName;

  @override
  final String paytmBankTransactionId;

  @override
  final String paytmChecksumHash;

  @override
  final String paytmCurrency;

  @override
  final String paytmGatewayName;

  @override
  final String paytmMerchantId;

  @override
  final String paytmOrderId;

  @override
  final String paytmPaymentMode;

  @override
  final String paytmResponseCode;

  @override
  final String paytmResponseMessage;

  @override
  final String paytmStatus;

  @override
  final String paytmTransactionAmount;

  @override
  final String paytmTransactionDate;

  @override
  final String paytmTransactionId;

  ///Paytm Success Response Constants
  static const String kPaytmStatus = "STATUS";
  static const String kPaytmChecksumHash = "CHECKSUMHASH";
  static const String kPaytmBankName = "BANKNAME";
  static const String kPaytmOrderId = "ORDERID";
  static const String kPaytmTransactionAmount = "TXNAMOUNT";
  static const String kPaytmTransactionDate = "TXNDATE";
  static const String kPaytmMerchantId = "MID";
  static const String kPaytmTransactionId = "TXNID";
  static const String kPaytmResponseCode = "RESPCODE";
  static const String kPaytmPaymentMode = "PAYMENTMODE";
  static const String kPaytmBankTransactionId = "BANKTXNID";
  static const String kPaytmCurrency = "CURRENCY";
  static const String kPaytmGatewayName = "GATEWAYNAME";
  static const String kPaytmResponseMessage = "RESPMSG";

  PaytmTransactionResponse._(Map<dynamic, dynamic> data)
      : paytmBankName = data[kPaytmBankName],
        paytmBankTransactionId = data[kPaytmBankTransactionId],
        paytmChecksumHash = data[kPaytmChecksumHash],
        paytmCurrency = data[kPaytmCurrency],
        paytmGatewayName = data[kPaytmGatewayName],
        paytmMerchantId = data[kPaytmMerchantId],
        paytmOrderId = data[kPaytmOrderId],
        paytmPaymentMode = data[kPaytmPaymentMode],
        paytmResponseCode = data[kPaytmResponseCode],
        paytmResponseMessage = data[kPaytmResponseMessage],
        paytmStatus = data[kPaytmStatus],
        paytmTransactionAmount = data[kPaytmTransactionAmount],
        paytmTransactionDate = data[kPaytmTransactionDate],
        paytmTransactionId = data[kPaytmTransactionId] {
    assert(paytmBankName != null);
    assert(paytmBankTransactionId != null);
    assert(paytmChecksumHash != null);
    assert(paytmCurrency != null);
    assert(paytmGatewayName != null);
    assert(paytmMerchantId != null);
    assert(paytmOrderId != null);
    assert(paytmPaymentMode != null);
    assert(paytmResponseCode != null);
    assert(paytmResponseMessage != null);
    assert(paytmStatus != null);
    assert(paytmTransactionAmount != null);
    assert(paytmTransactionDate != null);
    assert(paytmTransactionId != null);
  }

  @override
  String toString() {
    final Map<String, dynamic> data = <String, dynamic>{
      kPaytmBankName: paytmBankName,
      kPaytmBankTransactionId: paytmBankTransactionId,
      kPaytmChecksumHash: paytmChecksumHash,
      kPaytmCurrency: paytmCurrency,
      kPaytmGatewayName: paytmGatewayName,
      kPaytmMerchantId: paytmMerchantId,
      kPaytmOrderId: paytmOrderId,
      kPaytmPaymentMode: paytmPaymentMode,
      kPaytmResponseCode: paytmResponseCode,
      kPaytmResponseMessage: paytmResponseMessage,
      kPaytmStatus: paytmStatus,
      kPaytmTransactionAmount: paytmTransactionAmount,
      kPaytmTransactionDate: paytmTransactionDate,
      kPaytmTransactionId: paytmTransactionId,
    };
    return 'PaytmTransactionResponse:$data';
  }

  @override
  int get hashCode => hashValues(
      paytmBankName,
      paytmBankTransactionId,
      paytmChecksumHash,
      paytmCurrency,
      paytmGatewayName,
      paytmMerchantId,
      paytmOrderId,
      paytmPaymentMode,
      paytmResponseCode,
      paytmResponseMessage,
      paytmStatus,
      paytmTransactionAmount,
      paytmTransactionDate,
      paytmTransactionId);

  @override
  bool operator ==(other) {
    if (identical(this, other)) return true;
    if (other is! PaytmTransactionResponse) return false;
    final PaytmTransactionResponse otherAccount = other;
    return paytmBankName == otherAccount.paytmBankName &&
        paytmBankTransactionId == otherAccount.paytmBankTransactionId &&
        paytmChecksumHash == otherAccount.paytmChecksumHash &&
        paytmCurrency == otherAccount.paytmCurrency &&
        paytmGatewayName == otherAccount.paytmGatewayName &&
        paytmMerchantId == otherAccount.paytmMerchantId &&
        paytmOrderId == otherAccount.paytmOrderId &&
        paytmPaymentMode == otherAccount.paytmPaymentMode &&
        paytmResponseCode == otherAccount.paytmResponseCode &&
        paytmResponseMessage == otherAccount.paytmResponseMessage &&
        paytmStatus == otherAccount.paytmStatus &&
        paytmTransactionAmount == otherAccount.paytmTransactionAmount &&
        paytmTransactionDate == otherAccount.paytmTransactionDate &&
        paytmTransactionId == otherAccount.paytmTransactionId;
  }
}

class FlutterPaytmPlugin {
  FlutterPaytmPlugin({this.buildVariant});

  static const String kBuildVariant = "buildVariant";
  static const String kChecksumRequestObject = "checksum_request_object";

  ///Method Constants
  ///
  static const String kMethodInit = "init";
  static const String kMethodStartPaymentTransaction =
      "start_payment_transaction";

  /// Initial Arguments Error Constants
  ///
  static const String kBuildVariantNotPassed = 'build_variant_not_passed';
  static const String kCheckoutObjectNotPassed =
      'checksum_request_object_not_passed';

  ///Paytm Transaction, UI, Webpage, User Authentication, Network Unavailability Error Constants
  ///
  static const String kPaytmTransactionResponseNull =
      'paytm_transaction_response_null';
  static const String kPaytmTransactionCancelled =
      'paytm_transaction_cancelled';
  static const String kPaytmUserCancelled = 'paytm_user_cancelled';
  static const String kPaytmUserAuthentication =
      'paytm_user_authentication_error';
  static const String kPaytmNetworkUnAvailable = 'paytm_network_unavailable';
  static const String kPaytmUIError = 'paytm_ui_error';
  static const String kPaytmWebPageError = 'paytm_webpage_error';

  /// The [MethodChannel] over which this class communicates.
  ///
  static const MethodChannel channel =
      MethodChannel('flutterpaytmplugin.flutter.com/flutter_paytm_plugin');

  /// Option to determine the build variant in order to allow staging or
  /// production payments.
  final BuildVariant buildVariant;

  StreamController<PaytmTransactionResponse> _transactionResponseController =
      StreamController<PaytmTransactionResponse>.broadcast();

  /// Subscribe to this stream to be notified when the paytm transaction
  /// response changes.
  Stream<PaytmTransactionResponse> get onTransactionResponseChanged =>
      _transactionResponseController.stream;

  // Future that completes when we've finished calling `init` on the native side
  Future<void> _initialization;

  Future<PaytmTransactionResponse> _callMethod(
      String method, Map<String, dynamic> checksumRequestObject) async {
    await _ensureInitialized();

    final Map<dynamic, dynamic> response =
        await channel.invokeMethod(method, <String, dynamic>{
      kChecksumRequestObject: checksumRequestObject,
    });
    return _setPaytmTransactionResponse(response != null && response.isNotEmpty
        ? PaytmTransactionResponse._(response)
        : null);
  }

  PaytmTransactionResponse _setPaytmTransactionResponse(
      PaytmTransactionResponse paytmTransactionResponse) {
    if (paytmTransactionResponse != _paytmTransactionResponse) {
      _paytmTransactionResponse = paytmTransactionResponse;
      _transactionResponseController.add(_paytmTransactionResponse);
    }
    return paytmTransactionResponse;
  }

  Future<void> _ensureInitialized() {
    if (_initialization == null) {
      _initialization = channel.invokeMethod(kMethodInit, <String, dynamic>{
        kBuildVariant: buildVariant,
      })
        ..catchError((dynamic _) {
          // Invalidate initialization if it errored out.
          _initialization = null;
        });
    }
    return _initialization;
  }

  /// Keeps track of the most recently scheduled method call.
  _MethodCompleter _lastMethodCompleter;

  /// Adds call to [method] in a queue for execution.
  ///
  /// At most one in flight call is allowed to prevent concurrent (out of order)
  /// updates to [paytmTransactionResponse] and [onTransactionResponseChanged].
  Future<PaytmTransactionResponse> _addMethodCall(
      String method, Map<String, dynamic> checksumRequestObject) {
    if (_lastMethodCompleter == null) {
      _lastMethodCompleter = _MethodCompleter(method)
        ..complete(_callMethod(method, checksumRequestObject));
      return _lastMethodCompleter.future;
    }

    final _MethodCompleter completer = _MethodCompleter(method);
    _lastMethodCompleter.future.whenComplete(() {
      // If after the last completed call currentUser is not null and requested
      // method is a sign in method, re-use the same authenticated user
      // instead of making extra call to the native side.
      if (method == kMethodStartPaymentTransaction &&
          _paytmTransactionResponse != null) {
        completer.complete(_paytmTransactionResponse);
      } else {
        completer.complete(_callMethod(method, checksumRequestObject));
      }
    }).catchError((dynamic _) {
      // Ignore if previous call completed with an error.
    });
    _lastMethodCompleter = completer;
    return _lastMethodCompleter.future;
  }

  /// The current paytm transaction response.
  PaytmTransactionResponse get paytmTransactionResponse =>
      _paytmTransactionResponse;
  PaytmTransactionResponse _paytmTransactionResponse;

  /// Starts the interactive Paytm Transaction process.
  ///
  /// Returned Future resolves to an instance of [PaytmTransactionResponse] for a
  /// successful transaction or `null` in case transaction process was aborted.
  ///
  Future<PaytmTransactionResponse> startPaytmTransaction(
      Map<String, dynamic> checksumRequestObject) {
    final Future<PaytmTransactionResponse> result =
        _addMethodCall(kMethodStartPaymentTransaction, checksumRequestObject);
    bool isCanceled(dynamic error) =>
        error is PlatformException &&
        (error.code == kPaytmTransactionResponseNull ||
            error.code == kPaytmTransactionCancelled ||
            error.code == kPaytmNetworkUnAvailable ||
            error.code == kPaytmUIError ||
            error.code == kPaytmUserAuthentication ||
            error.code == kPaytmUserCancelled ||
            error.code == kPaytmWebPageError);
    return result.catchError((dynamic _) => null, test: isCanceled);
  }
}

class _MethodCompleter {
  _MethodCompleter(this.method);

  final String method;
  final Completer<PaytmTransactionResponse> _completer =
      Completer<PaytmTransactionResponse>();

  void complete(FutureOr<PaytmTransactionResponse> value) {
    if (value is Future<PaytmTransactionResponse>) {
      value.then(_completer.complete, onError: _completer.completeError);
    } else {
      _completer.complete(value);
    }
  }

  bool get isCompleted => _completer.isCompleted;

  Future<PaytmTransactionResponse> get future => _completer.future;
}
