//
//  FieldsView.swift
//  Gr4vy SwiftUI Sample App
//
//

import SwiftUI
import gr4vy_swift

enum PaymentMethodType: String, CaseIterable {
    case card = "card"
    case clickToPay = "click_to_pay"
    case id = "id"
    
    var displayName: String {
        switch self {
        case .card: return "Card"
        case .clickToPay: return "Click to Pay"
        case .id: return "ID"
        }
    }
}

struct FieldsView: View {
    @AppStorage("fields_checkout_session_id") private var checkoutSessionId: String = ""
    @AppStorage("fields_payment_method_type") private var selectedPaymentMethodType: String = PaymentMethodType.card.rawValue
    
    @AppStorage("fields_card_number") private var cardNumber: String = ""
    @AppStorage("fields_expiration_date") private var expirationDate: String = ""
    @AppStorage("fields_security_code") private var securityCode: String = ""
    
    @AppStorage("fields_merchant_transaction_id") private var merchantTransactionId: String = ""
    @AppStorage("fields_src_correlation_id") private var srcCorrelationId: String = ""
    
    @AppStorage("fields_payment_method_id") private var paymentMethodId: String = ""
    @AppStorage("fields_id_security_code") private var idSecurityCode: String = ""
    
    // Admin settings
    @AppStorage("merchantId") private var merchantId: String = ""
    @AppStorage("gr4vyId") private var gr4vyId: String = ""
    @AppStorage("serverURL") private var server: String = ""
    @AppStorage("apiToken") private var token: String = ""
    @AppStorage("serverEnvironment") private var serverEnvironment: String = "sandbox"
    @AppStorage("timeout") private var timeout: String = ""
    
    @State private var isLoading = false
    @State private var responseData: Data?
    @State private var errorMessage: String?
    @State private var showingResponse = false
    @State private var showingErrorResponse = false
    @State private var errorResponseData: Data?
    @State private var errorStatusCode: Int?
    
    var body: some View {
        VStack {
            Form {
                Section {
                    TextField("checkout_session_id", text: $checkoutSessionId)
                        .textContentType(.none)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                } header: {
                    Text("Session")
                }
                
                Section {
                    Picker("Payment Method Type", selection: $selectedPaymentMethodType) {
                        ForEach(PaymentMethodType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                } header: {
                    Text("Payment Method Type")
                }
                
                if selectedPaymentMethodType == PaymentMethodType.card.rawValue {
                    Section {
                        TextField("number", text: $cardNumber)
                            .keyboardType(.numberPad)
                            .textContentType(.none)
                            .autocorrectionDisabled()
                        
                        TextField("expiration_date", text: $expirationDate)
                            .keyboardType(.numberPad)
                            .textContentType(.none)
                            .autocorrectionDisabled()
                        
                        TextField("security_code", text: $securityCode)
                            .keyboardType(.numberPad)
                            .textContentType(.none)
                            .autocorrectionDisabled()
                    } header: {
                        Text("Card Details")
                    }
                }
                
                if selectedPaymentMethodType == PaymentMethodType.clickToPay.rawValue {
                    Section {
                        TextField("merchant_transaction_id", text: $merchantTransactionId)
                            .textContentType(.none)
                            .autocorrectionDisabled()
                            .autocapitalization(.none)
                        
                        TextField("src_correlation_id", text: $srcCorrelationId)
                            .textContentType(.none)
                            .autocorrectionDisabled()
                            .autocapitalization(.none)
                    } header: {
                        Text("Click to Pay Details")
                    }
                }
                
                if selectedPaymentMethodType == PaymentMethodType.id.rawValue {
                    Section {
                        TextField("id", text: $paymentMethodId)
                            .textContentType(.none)
                            .autocorrectionDisabled()
                            .autocapitalization(.none)
                        
                        TextField("security_code", text: $idSecurityCode)
                            .keyboardType(.numberPad)
                            .textContentType(.none)
                            .autocorrectionDisabled()
                    } header: {
                        Text("ID Details")
                    }
                }
            }
            
            if isLoading {
                ProgressView("Sending request...")
                    .padding()
            }
            
            if let errorMessage = errorMessage {
                Button(action: {
                    if errorStatusCode != nil {
                        showingErrorResponse = true
                    }
                }) {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }
                .disabled(errorStatusCode == nil)
            }
        }
        .navigationTitle("Fields")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button("PUT") {
                    Task {
                        await sendRequest()
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .font(.title3)
                .fontWeight(.bold)
                .cornerRadius(8)
                .disabled(isLoading)
            }
        }
        .navigationDestination(isPresented: $showingResponse) {
            if let responseData = responseData {
                JSONResponseView(
                    jsonString: formatJSON(responseData),
                    title: "Fields Response"
                )
            }
        }
        .navigationDestination(isPresented: $showingErrorResponse) {
            if let errorResponseData = errorResponseData {
                JSONResponseView(
                    jsonString: formatJSON(errorResponseData),
                    title: "Error Response (Status: \(errorStatusCode ?? 0))"
                )
            }
        }
    }
    
    private func sendRequest() async {
        isLoading = true
        errorMessage = nil
        
        let paymentMethod: Gr4vyPaymentMethod
        
        switch selectedPaymentMethodType {
        case PaymentMethodType.card.rawValue:
            let cardMethod = CardPaymentMethod(
                number: cardNumber.trimmingCharacters(in: .whitespacesAndNewlines),
                expirationDate: expirationDate.trimmingCharacters(in: .whitespacesAndNewlines),
                securityCode: securityCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : securityCode.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            paymentMethod = .card(cardMethod)
            
        case PaymentMethodType.clickToPay.rawValue:
            let clickToPayMethod = ClickToPayPaymentMethod(
                merchantTransactionId: merchantTransactionId.trimmingCharacters(in: .whitespacesAndNewlines),
                srcCorrelationId: srcCorrelationId.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            paymentMethod = .clickToPay(clickToPayMethod)
            
        case PaymentMethodType.id.rawValue:
            let idMethod = IdPaymentMethod(
                id: paymentMethodId.trimmingCharacters(in: .whitespacesAndNewlines),
                securityCode: idSecurityCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : idSecurityCode.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            paymentMethod = .id(idMethod)
            
        default:
            errorMessage = "Invalid payment method type"
            isLoading = false
            return
        }
        
        let cardData = Gr4vyCardData(paymentMethod: paymentMethod)
        
        let gr4vyID = gr4vyId.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedToken = token.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !gr4vyID.isEmpty else {
            errorMessage = "Please configure Gr4vy ID in Admin settings"
            isLoading = false
            return
        }
        
        guard !trimmedToken.isEmpty else {
            errorMessage = "Please configure API Token in Admin settings"
            isLoading = false
            return
        }
        
        let server: Gr4vyServer = serverEnvironment == "production" ? .production : .sandbox
        
        let gr4vy: Gr4vy?
        if let timeoutValue = Double(timeout.trimmingCharacters(in: .whitespacesAndNewlines)), 
           timeoutValue > 0, 
           !timeout.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let timeoutInterval = TimeInterval(timeoutValue)
            gr4vy = try? Gr4vy(
                gr4vyId: gr4vyID,
                token: trimmedToken,
                server: server,
                timeout: timeoutInterval)
        } else {
            gr4vy = try? Gr4vy(
                gr4vyId: gr4vyID,
                token: trimmedToken,
                server: server)
        }
        
        guard let gr4vy = gr4vy else {
            errorMessage = "Failed to configure Gr4vy SDK"
            isLoading = false
            return
        }
        
        gr4vy.tokenize(checkoutSessionId: checkoutSessionId.trimmingCharacters(in: .whitespacesAndNewlines), cardData: cardData) { result in
            Task { @MainActor in
                isLoading = false
                
                switch result {
                case .success(let options):
                    // Handle 204 No Content response - tokenization successful
                    let successResponse = [
                        "status": "success",
                        "message": "Payment method tokenized successfully",
                        "method": "tokenize",
                        "timestamp": ISO8601DateFormatter().string(from: Date()),
                        "details": "The payment method has been securely tokenized and stored"
                    ]
                    
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: successResponse, options: .prettyPrinted)
                        self.responseData = jsonData
                        self.showingResponse = true
                    } catch {
                        self.errorMessage = "Success, but failed to format response: \(error.localizedDescription)"
                    }
                    
                case .failure(let error):
                    if let gr4vyError = error as? Gr4vyError {
                        switch gr4vyError {
                        case .invalidGr4vyId:
                            self.errorMessage = "Invalid Gr4vy ID: \(gr4vyError.localizedDescription)"
                        case .badURL(let url):
                            self.errorMessage = "Bad URL: \(url)"
                        case .httpError(let statusCode, let responseData, let message):
                            self.errorStatusCode = statusCode
                            self.errorResponseData = responseData
                            
                            if statusCode == 400 {
                                self.errorMessage = "Bad Request (400) - Tap to view details"
                                self.showingErrorResponse = true
                            } else {
                                self.errorMessage = "HTTP Error \(statusCode) - Tap to view details"
                                self.showingErrorResponse = true
                            }
                        case .networkError(let urlError):
                            self.handleNetworkError(urlError, gr4vyID: gr4vyID)
                        case .decodingError(let message):
                            self.errorMessage = "Decoding error: \(message)"
                        }
                    } else {
                        self.handleNetworkError(error, gr4vyID: gr4vyID)
                    }
                }
            }
        }
    }
    
    private func handleNetworkError(_ error: Error, gr4vyID: String) {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .cannotFindHost:
                self.errorMessage = "Cannot find server. Please check your Merchant ID (\(gr4vyID)). The URL being called is: https://api.\(gr4vyID).gr4vy.app/tokenize"
            case .notConnectedToInternet:
                self.errorMessage = "No internet connection. Please check your network settings."
            case .timedOut:
                self.errorMessage = "Request timed out. Please try again."
            case .badServerResponse:
                self.errorMessage = "Server error. Please check your API token and try again."
            default:
                self.errorMessage = "Network error: \(urlError.localizedDescription)"
            }
        } else {
            self.errorMessage = "Failed to tokenize payment method: \(error.localizedDescription)"
        }
    }
    
    private func formatJSON(_ data: Data) -> String {
        if let jsonObject = try? JSONSerialization.jsonObject(with: data),
           let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            return prettyString
        }
        return String(data: data, encoding: .utf8) ?? "Unable to format response"
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    NavigationStack {
        FieldsView()
    }
}
