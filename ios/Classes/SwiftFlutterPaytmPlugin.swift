import Flutter
import PaymentSDK
import UIKit

/*
 A delegate interface that exposes all of the PayTM Payment Gateway functionality for other plugins to use.
 The below [Delegate] implementation should be used by any clients unless they need to
 override some of these functions, such as for testing.
 */
protocol IDelegate {
    
    // Initializes this delegate so that it can perform transaction operation
    func initializePaytmService(result: @escaping FlutterResult, buildVariant: String?)
    
    // Returns the PayTM transaction status without displaying any user interface.
    func startPaymentTransaction(result: @escaping FlutterResult, checkSumRequestObject: Dictionary<String, String>?)
}

/*
 Delegate class will have the code for making PayTM Transactions.
 */
class FlutterPaytmPluginDelegate : IDelegate,  PGTransactionDelegate {
    private let flutterRegistrar: FlutterPluginRegistrar
    private var serverType: ServerType?
    private var pendingOperation: PendingOperation?
    private var paytmTransactionController: PGTransactionViewController?
    
    let release = "BuildVariant.release"
    let debug = "BuildVariant.debug"
    
    //Method Constants
    let methodInitPaytmService = "initialize_paytm_service"
    let methodStartPaymentTransaction = "start_payment_transaction"
    
    //PayTM Success Response Constants
    let paytmStatus = "STATUS"
    let paytmChecksumHash = "CHECKSUMHASH"
    let paytmBankName = "BANKNAME"
    let paytmOrderId = "ORDERID"
    let paytmTransactionAmount = "TXNAMOUNT"
    let paytmTransactionDate = "TXNDATE"
    let paytmMerchantId = "MID"
    let paytmTransactionId = "TXNID"
    let paytmResponseCode = "RESPCODE"
    let paytmPaymentMode = "PAYMENTMODE"
    let paytmBankTransactionId = "BANKTXNID"
    let paytmCurrency = "CURRENCY"
    let paytmGatewayName = "GATEWAYNAME"
    let paytmResponseMessage = "RESPMSG"
    
    //Error Constants
    let errorReasonBuildVariantNotPassed = "build_variant_not_passed"
    let errorReasonChecksumObjectNotPassed = "checksum_request_object_not_passed"
    
    // These error codes must match with ones declared on iOS and Dart sides.
    let errorReasonPaytmTransactionResponseNull = "paytm_transaction_response_null"
    let errorReasonPaytmTransactionCancelled = "paytm_transaction_cancelled"
    let errorReasonPaytmMissingParameters = "paytm_missing_parameters"
    
    init(registrar: FlutterPluginRegistrar) {
        self.flutterRegistrar = registrar
    }
    
    
    
    /*
     Initializes this delegate so that it is ready to perform other operations. The Dart code
     guarantees that this will be called and completed before any other methods are invoked.
     */
    func initializePaytmService(result: @escaping FlutterResult, buildVariant: String?) {
        if buildVariant?.isEmpty ?? true {
            result(FlutterError(code: errorReasonBuildVariantNotPassed, message: "Need a build variant", details: nil))
        } else {
            serverType = buildVariant == release ? .eServerTypeProduction : .eServerTypeStaging
            result(nil)
        }
    }
    
    func startPaymentTransaction(result: @escaping FlutterResult, checkSumRequestObject: Dictionary<String, String>?) {
        
        if checkSumRequestObject?.isEmpty ?? true {
            result(FlutterError(code: errorReasonChecksumObjectNotPassed, message: "Need a build variant", details: nil))
        } else {
            checkAndSetPendingOperation(method: methodStartPaymentTransaction, result: result)
            let order = PGOrder(orderID: "", customerID: "", amount: "", eMail: "", mobile: "")
            order.params = checkSumRequestObject!
            
            self.paytmTransactionController = paytmTransactionController?.initTransaction(for: order) as? PGTransactionViewController ?? PGTransactionViewController()
            self.paytmTransactionController?.title = "Paytm Payments"
            if(serverType != .eServerTypeNone) {
                self.paytmTransactionController?.serverType = serverType;
            } else {
                return
            }
            self.paytmTransactionController?.setLoggingEnabled(serverType == .eServerTypeStaging)
            self.paytmTransactionController?.merchant = PGMerchantConfiguration.defaultConfiguration()
            self.paytmTransactionController?.delegate = self
            self.paytmTransactionController?.navigationController?.performSegue(withIdentifier: methodStartPaymentTransaction, sender: paytmTransactionController)
        }
    }
    
    private func checkAndSetPendingOperation(method: String, result: @escaping FlutterResult) {
        if (pendingOperation != nil) {
            return;
            //                throw IllegalStateException("Concurrent operations detected: " + pendingOperation!!.method + ", " + method)
        }
        pendingOperation = PendingOperation(method: method, result: result)
    }
    
    private func finishWithSuccess(data: Dictionary<String, String>?) {
        pendingOperation!.result(data)
        pendingOperation = nil
        paytmTransactionController = nil
    }
    
    private func finishWithError(errorCode: String, errorMessage: String) {
        pendingOperation!.result(FlutterError(code: errorCode, message: errorMessage, details: nil))
        pendingOperation = nil
    }
    
    /*
     PayTM Transaction Delegates
     */
    func didFinishedResponse(_ controller: PGTransactionViewController, response responseString: String) {
        var paytmSuccessResponse = Dictionary<String, String>()
        if let data = responseString.data(using: String.Encoding.utf8) {
            do {
                if let jsonresponse = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:String] , jsonresponse.count > 0{
                    paytmSuccessResponse[paytmStatus] = jsonresponse[paytmStatus] ?? ""
                    paytmSuccessResponse[paytmChecksumHash] = jsonresponse[paytmChecksumHash] ?? ""
                    paytmSuccessResponse[paytmBankName] = jsonresponse[paytmBankName] ?? ""
                    paytmSuccessResponse[paytmOrderId] = jsonresponse[paytmOrderId] ?? ""
                    paytmSuccessResponse[paytmTransactionAmount] = jsonresponse[paytmTransactionAmount] ?? ""
                    paytmSuccessResponse[paytmTransactionDate] = jsonresponse[paytmTransactionDate] ?? ""
                    paytmSuccessResponse[paytmTransactionId] = jsonresponse[paytmTransactionId] ?? ""
                    paytmSuccessResponse[paytmMerchantId] = jsonresponse[paytmMerchantId] ?? ""
                    paytmSuccessResponse[paytmResponseCode] = jsonresponse[paytmResponseCode] ?? ""
                    paytmSuccessResponse[paytmPaymentMode] = jsonresponse[paytmPaymentMode] ?? ""
                    paytmSuccessResponse[paytmBankTransactionId] = jsonresponse[paytmBankTransactionId] ?? ""
                    paytmSuccessResponse[paytmCurrency] = jsonresponse[paytmCurrency] ?? ""
                    paytmSuccessResponse[paytmGatewayName] = jsonresponse[paytmGatewayName] ?? ""
                    paytmSuccessResponse[paytmResponseMessage] = jsonresponse[paytmResponseMessage] ?? ""
                    
                    finishWithSuccess(data: paytmSuccessResponse)
                }
            } catch {
                finishWithError(errorCode: errorReasonPaytmTransactionResponseNull, errorMessage: "Paytm transaction response in null")
            }
        }
    }
    
    func didCancelTrasaction(_ controller: PGTransactionViewController) {
        finishWithError(errorCode: errorReasonPaytmTransactionCancelled, errorMessage: "Transaction cancelled.")
    }
    
    func errorMisssingParameter(_ controller: PGTransactionViewController, error: NSError?) {
        finishWithError(errorCode: errorReasonPaytmMissingParameters, errorMessage: "There are some missing parameters.")
    }
    
    private class PendingOperation {
        let method: String
        let result: FlutterResult
        
        init(method: String, result: @escaping FlutterResult) {
            self.method = method
            self.result = result
        }
    }
    
}

public class SwiftFlutterPaytmPlugin: NSObject, FlutterPlugin {
    //Channel Name Constant
    static let channelName = "flutterpaytmplugin.flutter.com/flutter_paytm_plugin"
    
    //Argument Constants
    let buildVariant = "build_variant"
    let checksumRequestObject = "checksum_request_object"
    
    //Method Constants
    let methodInitPaytmService = "initialize_paytm_service"
    let methodStartPaymentTransaction = "start_payment_transaction"
    
    var delegate : IDelegate
    init(pluginRegistrar: FlutterPluginRegistrar) {
        delegate = FlutterPaytmPluginDelegate(registrar: pluginRegistrar)
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterPaytmPlugin(pluginRegistrar: registrar)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? Dictionary<String, Any>
        switch call.method {
        case methodInitPaytmService:
            delegate.initializePaytmService(result: result, buildVariant: (arguments?[buildVariant] as? String))
        case methodStartPaymentTransaction:
            delegate.startPaymentTransaction(result: result, checkSumRequestObject: (arguments?[checksumRequestObject] as? Dictionary<String, String>))
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
