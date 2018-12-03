package com.flutter.flutterpaytmplugin

import android.os.Bundle
import com.paytm.pgsdk.PaytmOrder
import com.paytm.pgsdk.PaytmPGService
import com.paytm.pgsdk.PaytmPaymentTransactionCallback
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class FlutterPaytmPlugin(registrar: Registrar) : MethodCallHandler {

    private val delegate: IDelegate

    companion object {
        private const val CHANNEL_NAME = "flutterpaytmplugin.flutter.com/flutter_paytm_plugin"

        //Method Constants
        private const val METHOD_INIT = "init"
        private const val METHOD_START_PAYMENT_TRANSACTION = "start_payment_transaction"

        //Argument Constants
        private const val BUILD_VARIANT = "build_variant"
        private const val CHECKSUM_REQUEST_OBJECT = "checksum_request_object"

        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), CHANNEL_NAME)
            val instance = FlutterPaytmPlugin(registrar)
            channel.setMethodCallHandler(instance)
        }
    }

    init {
        delegate = Delegate(registrar)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            METHOD_INIT -> delegate.init(result, call.argument(BUILD_VARIANT))
            METHOD_START_PAYMENT_TRANSACTION -> delegate.startPaymentTransaction(result,
                    call.argument(CHECKSUM_REQUEST_OBJECT))
            else -> result.notImplemented()
        }
    }

    /**
     * A delegate interface that exposes all of the PayTM Payment Gateway functionality for other plugins to use.
     * The below [Delegate] implementation should be used by any clients unless they need to
     * override some of these functions, such as for testing.
     */
    abstract class IDelegate {
        /** Initializes this delegate so that it can perform transaction operation.  */
        abstract fun init(result: Result, buildVariant: String?)


        /**
         * Returns the PayTM transaction status without displaying any user interface.
         */
        abstract fun startPaymentTransaction(result: Result, checkSumRequestObject: HashMap<String, String>?)
    }

    /**
     * Delegate class will have the code for making PayTM Transactions.
     */
    class Delegate(private var registrar: Registrar) : IDelegate(), PaytmPaymentTransactionCallback {

        private var paytmPGService: PaytmPGService? = null
        private var pendingOperation: PendingOperation? = null

        companion object {
            private const val RELEASE = "BuildVariant.release"
            private const val DEBUG = "BuildVariant.debug"

            //PayTM Success Response Constants
            private const val PAYTM_STATUS = "STATUS"
            private const val PAYTM_CHECKSUM_HASH = "CHECKSUMHASH"
            private const val PAYTM_BANK_NAME = "BANKNAME"
            private const val PAYTM_ORDER_ID = "ORDERID"
            private const val PAYTM_TRANSACTION_AMOUNT = "TXNAMOUNT"
            private const val PAYTM_TRANSACTION_DATE = "TXNDATE"
            private const val PAYTM_MERCHANT_ID = "MID"
            private const val PAYTM_TRANSACTION_ID = "TXNID"
            private const val PAYTM_RESPONSE_CODE = "RESPCODE"
            private const val PAYTM_PAYMENT_MODE = "PAYMENTMODE"
            private const val PAYTM_BANK_TRANSACTION_ID = "BANKTXNID"
            private const val PAYTM_CURRENCY = "CURRENCY"
            private const val PAYTM_GATEWAY_NAME = "GATEWAYNAME"
            private const val PAYTM_RESPONSE_MESSAGE = "RESPMSG"


            //Error Constants
            private const val ERROR_REASON_BUILD_VARIANT_NOT_PASSED = "build_variant_not_passed"
            private const val ERROR_REASON_CHECKSUM_OBJECT_NOT_PASSED = "checksum_request_object_not_passed"

            // These error codes must match with ones declared on iOS and Dart sides.
            private const val ERROR_REASON_PAYTM_TRANSACTION_RESPONSE_NULL = "paytm_transaction_response_null"
            private const val ERROR_REASON_PAYTM_TRANSACTION_CANCELLED = "paytm_transaction_cancelled"
            private const val ERROR_REASON_PAYTM_USER_CANCELLED = "paytm_user_cancelled"
            private const val ERROR_REASON_PAYTM_USER_AUTHENTICATION = "paytm_user_authentication_error"
            private const val ERROR_REASON_PAYTM_NETWORK_UNAVAILABLE = "paytm_network_unavailable"
            private const val ERROR_REASON_PAYTM_UI_ERROR = "paytm_ui_error"
            private const val ERROR_REASON_PAYTM_WEBPAGE_ERROR = "paytm_webpage_error"
        }


        private fun checkAndSetPendingOperation(method: String, result: Result) {
            if (pendingOperation != null) {
                throw IllegalStateException(
                        "Concurrent operations detected: " + pendingOperation!!.method + ", " + method)
            }
            pendingOperation = PendingOperation(method, result)
        }

        /**
         * Initializes this delegate so that it is ready to perform other operations. The Dart code
         * guarantees that this will be called and completed before any other methods are invoked.
         */
        override fun init(result: Result, buildVariant: String?) {
            if (buildVariant.isNullOrBlank() || buildVariant.isNullOrEmpty()) {
                result.error(ERROR_REASON_BUILD_VARIANT_NOT_PASSED, "Need a build variant", null)
            } else {
                paytmPGService = if (buildVariant.equals(RELEASE))
                    PaytmPGService.getProductionService()
                else
                    PaytmPGService.getStagingService()
                result.success(null)
            }
        }

        override fun startPaymentTransaction(result: Result, checkSumRequestObject: HashMap<String, String>?) {
            checkAndSetPendingOperation(METHOD_START_PAYMENT_TRANSACTION, result)
            if (checkSumRequestObject == null || checkSumRequestObject.isEmpty()) {
                result.error(ERROR_REASON_CHECKSUM_OBJECT_NOT_PASSED, "Checksum request object not passed", null)
            } else {
                paytmPGService!!.initialize(PaytmOrder(checkSumRequestObject), null)
                paytmPGService!!.startPaymentTransaction(registrar.activeContext(), true, true,
                        this)
            }
        }

        private fun finishWithSuccess(data: Any?) {
            pendingOperation!!.result.success(data)
            pendingOperation = null
        }

        private fun finishWithError(errorCode: String, errorMessage: String) {
            pendingOperation!!.result.error(errorCode, errorMessage, null)
            pendingOperation = null
        }

        private class PendingOperation internal constructor(internal val method: String, internal val result: Result)

        //region PayTM Transaction Callbacks

        override fun onTransactionResponse(inResponse: Bundle?) {
            val paytmSuccessResponse = HashMap<String, Any>()
            if (inResponse != null) {
                paytmSuccessResponse[PAYTM_STATUS] = inResponse.getString(PAYTM_STATUS)
                paytmSuccessResponse[PAYTM_CHECKSUM_HASH] = inResponse.getString(PAYTM_CHECKSUM_HASH)
                paytmSuccessResponse[PAYTM_BANK_NAME] = inResponse.getString(PAYTM_BANK_NAME)
                paytmSuccessResponse[PAYTM_ORDER_ID] = inResponse.getString(PAYTM_ORDER_ID)
                paytmSuccessResponse[PAYTM_TRANSACTION_AMOUNT] = inResponse.getString(PAYTM_TRANSACTION_AMOUNT)
                paytmSuccessResponse[PAYTM_TRANSACTION_DATE] = inResponse.getString(PAYTM_TRANSACTION_DATE)
                paytmSuccessResponse[PAYTM_MERCHANT_ID] = inResponse.getString(PAYTM_MERCHANT_ID)
                paytmSuccessResponse[PAYTM_TRANSACTION_ID] = inResponse.getString(PAYTM_TRANSACTION_ID)
                paytmSuccessResponse[PAYTM_RESPONSE_CODE] = inResponse.getString(PAYTM_RESPONSE_CODE)
                paytmSuccessResponse[PAYTM_PAYMENT_MODE] = inResponse.getString(PAYTM_PAYMENT_MODE)
                paytmSuccessResponse[PAYTM_BANK_TRANSACTION_ID] = inResponse.getString(PAYTM_BANK_TRANSACTION_ID)
                paytmSuccessResponse[PAYTM_CURRENCY] = inResponse.getString(PAYTM_CURRENCY)
                paytmSuccessResponse[PAYTM_GATEWAY_NAME] = inResponse.getString(PAYTM_GATEWAY_NAME)
                paytmSuccessResponse[PAYTM_RESPONSE_MESSAGE] = inResponse.getString(PAYTM_RESPONSE_MESSAGE)
                finishWithSuccess(paytmSuccessResponse)
            } else {
                finishWithError(ERROR_REASON_PAYTM_TRANSACTION_RESPONSE_NULL, "Paytm transaction response in null")
            }
        }

        override fun clientAuthenticationFailed(inErrorMessage: String?) {
            /*This method gets called if client authentication
             failed. Failure may be due to following reasons
             1. Server error or downtime.
             2. Server unable to generate checksum or checksum response is not in
             proper format.
             3. Server failed to authenticate that client. That is value of paytm_STATUS is 2.
             Error Message describes the reason for failure.*/
            finishWithError(ERROR_REASON_PAYTM_USER_AUTHENTICATION, "Paytm user credentials are incorrect.")
        }

        override fun someUIErrorOccurred(inErrorMessage: String?) {
            /*Some UI Error Occurred in Payment Gateway Activity.
            This may be due to initialization of views in
            Payment Gateway Activity or may be due to
            initialization of Web View. Error Message details
            the error occurred.*/
            finishWithError(ERROR_REASON_PAYTM_UI_ERROR, "Paytm page couldn't be opened.")
        }

        override fun onTransactionCancel(inErrorMessage: String?, inResponse: Bundle?) {
            finishWithError(ERROR_REASON_PAYTM_TRANSACTION_CANCELLED, "Transaction cancelled.")
        }

        override fun networkNotAvailable() {
            // "If network is not available, then this method gets called."
            finishWithError(ERROR_REASON_PAYTM_NETWORK_UNAVAILABLE, "No Internet Access")
        }

        override fun onErrorLoadingWebPage(iniErrorCode: Int, inErrorMessage: String?, inFailingUrl: String?) {
            finishWithError(ERROR_REASON_PAYTM_WEBPAGE_ERROR, "Paytm page couldn't be opened.")
        }

        override fun onBackPressedCancelTransaction() {
            finishWithError(ERROR_REASON_PAYTM_USER_CANCELLED, "User cancelled the transaction.")
        }

        //endregion
    }


}
