/// Encapsulation of the fields that represent a Paytm Success Transanction Response.
abstract class TransactionResponse {
  /// Paytm payment status.
  ///
  String get paytmStatus;

  /// Paytm Checksum Hash.
  ///
  String get paytmChecksumHash;

  /// Paytm Bank Name.
  ///
  String get paytmBankName;

  /// Paytm Order Id.
  ///
  String get paytmOrderId;

  /// Paytm Transaction Amount.
  ///
  String get paytmTransactionAmount;

  /// Paytm Transaction Date.
  ///
  String get paytmTransactionDate;

  /// Paytm Transaction Id.
  ///
  String get paytmTransactionId;

  /// Paytm Merchant Id.
  ///
  String get paytmMerchantId;

  /// Paytm Response Code.
  ///
  String get paytmResponseCode;

  /// Paytm Payment Mode.
  ///
  String get paytmPaymentMode;

  /// Paytm Bank Transaction Id.
  ///
  String get paytmBankTransactionId;

  /// Paytm Currency.
  ///
  String get paytmCurrency;

  /// Paytm gateway Name.
  ///
  String get paytmGatewayName;

  /// Paytm Response Message.
  ///
  String get paytmResponseMessage;
}
