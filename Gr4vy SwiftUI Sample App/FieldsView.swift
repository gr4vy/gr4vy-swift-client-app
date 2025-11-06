//
//  FieldsView.swift
//  Gr4vy SwiftUI Sample App
//
//

import SwiftUI
import gr4vy_swift

enum PaymentMethodType: String, CaseIterable {
    case card = "card"
    case id = "id"
    
    var displayName: String {
        switch self {
        case .card: return "Card"
        case .id: return "ID"
        }
    }
}

// Theme selection for tokenize
private enum ThemeOption: String, CaseIterable, Identifiable {
    case none
    case redBlue
    case orangePurple
    case greenYellow
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .none: return "No Theme"
        case .redBlue: return "Red / Blue"
        case .orangePurple: return "Orange / Purple"
        case .greenYellow: return "Green / Yellow"
        }
    }
}

// Test card selection for tokenize
private enum TestCard: String, CaseIterable, Identifiable {
    case custom

    // Frictionless (AUTHENTICATED_APPLICATION_FRICTIONLESS)
    case visaFrictionless
    case mastercardFrictionless
    case amexFrictionless
    case dinersFrictionless
    case jcbFrictionless

    // Challenge (APPLICATION_CHALLENGE)
    case visaChallenge
    case mastercardChallenge
    case amexChallenge
    case dinersChallenge
    case jcbChallenge

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .custom: return "Custom"
        case .visaFrictionless: return "Visa Frictionless Test Card"
        case .visaChallenge: return "Visa Challenge Test Card"
        case .mastercardFrictionless: return "Mastercard Frictionless Test Card"
        case .mastercardChallenge: return "Mastercard Challenge Test Card"
        case .amexFrictionless: return "Amex Frictionless Test Card"
        case .amexChallenge: return "Amex Challenge Test Card"
        case .dinersFrictionless: return "Diners Frictionless Test Card"
        case .dinersChallenge: return "Diners Challenge Test Card"
        case .jcbFrictionless: return "JCB Frictionless Test Card"
        case .jcbChallenge: return "JCB Challenge Test Card"
        }
    }

    var cardNumber: String {
        switch self {
        case .custom: return ""

        // AUTHENTICATED_APPLICATION_FRICTIONLESS
        case .visaFrictionless: return "4556557955726624"
        case .mastercardFrictionless: return "5333259155643223"
        case .amexFrictionless: return "341502098634895"
        case .dinersFrictionless: return "36000000000008"
        case .jcbFrictionless: return "3528000000000056"

        // APPLICATION_CHALLENGE
        case .visaChallenge: return "4024007189449340"
        case .mastercardChallenge: return "5267648608924299"
        case .amexChallenge: return "349531373081938"
        case .dinersChallenge: return "36000002000048"
        case .jcbChallenge: return "3528000000000148"
        }
    }

    var expirationDate: String {
        switch self {
        case .custom: return ""
        default: return "01/30"
        }
    }

    var cvv: String {
        switch self {
        case .custom: return ""
        // frictionless
        case .visaFrictionless, .mastercardFrictionless, .amexFrictionless,
             .dinersFrictionless, .jcbFrictionless:
            return "123"
        // challenge
        case .visaChallenge, .mastercardChallenge, .amexChallenge,
             .dinersChallenge, .jcbChallenge:
            return "456"
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
    
    @AppStorage("fields_authenticate") private var authenticate: Bool = true
    @AppStorage("fields_test_card") private var selectedTestCardRaw: String = TestCard.custom.rawValue
    @AppStorage("fields_theme") private var selectedThemeRaw: String = ThemeOption.none.rawValue
    @AppStorage("fields_sdk_max_timeout") private var sdkMaxTimeout: String = "300"
    
    private var selectedTestCard: TestCard {
        TestCard(rawValue: selectedTestCardRaw) ?? .custom
    }
    
    private var selectedTheme: ThemeOption {
        ThemeOption(rawValue: selectedThemeRaw) ?? .none
    }
    
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
    @State private var showingGeneralError = false
    @State private var generalErrorData: Data?
    
    var body: some View {
        VStack {
            Form {
                Section {
                    HStack {
                        TextField("checkout_session_id", text: $checkoutSessionId)
                            .textContentType(.none)
                            .autocorrectionDisabled()
                            .autocapitalization(.none)
                        
                        if !checkoutSessionId.isEmpty {
                            Button(action: {
                                checkoutSessionId = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                } header: {
                    Text("Session")
                }
                
                Section(header: Text("3DS Theme")) {
                    Picker("Theme", selection: $selectedThemeRaw) {
                        ForEach(ThemeOption.allCases) { option in
                            Text(option.displayName).tag(option.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section(header: Text("SDK Settings")) {
                    TextField("SDK Max Timeout (seconds)", text: $sdkMaxTimeout)
                        .keyboardType(.numberPad)
                        .autocorrectionDisabled()
                        .onChange(of: sdkMaxTimeout) { newValue in
                            // Only allow numeric characters
                            let filtered = newValue.filter { $0.isNumber }
                            sdkMaxTimeout = String(filtered.prefix(5)) // Max 99999 seconds
                        }
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
                    Section(header: Text("Authentication")) {
                        Toggle("Authenticate", isOn: $authenticate)
                    }
                    
                    Section(header: Text("Test Cards")) {
                        Picker("Test Card", selection: $selectedTestCardRaw) {
                            ForEach(TestCard.allCases) { testCard in
                                Text(testCard.displayName).tag(testCard.rawValue)
                            }
                        }
                        .pickerStyle(.menu)
                        .onChange(of: selectedTestCardRaw) { _ in
                            populateTestCardData()
                        }
                        
                        if selectedTestCard != .custom {
                            Button("Clear Form") {
                                clearForm()
                            }
                            .foregroundColor(.red)
                        }
                    }
                    
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
        .navigationTitle("Tokenize")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button {
                    Task {
                        await sendRequest()
                    }
                } label: {
                    HStack(spacing: 8) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        }
                        Text(isLoading ? "Sending..." : "PUT")
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
                    title: "Complete"
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
        .navigationDestination(isPresented: $showingGeneralError) {
            if let generalErrorData = generalErrorData {
                JSONResponseView(
                    jsonString: formatJSON(generalErrorData),
                    title: "Error"
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
            let cleanCardNumber = cardNumber.replacingOccurrences(of: " ", with: "")
            let cardMethod = CardPaymentMethod(
                number: cleanCardNumber.trimmingCharacters(in: .whitespacesAndNewlines),
                expirationDate: expirationDate.trimmingCharacters(in: .whitespacesAndNewlines),
                securityCode: securityCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : securityCode.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            paymentMethod = .card(cardMethod)
            
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
                timeout: timeoutInterval,
                debugMode: true)
        } else {
            gr4vy = try? Gr4vy(
                gr4vyId: gr4vyID,
                token: trimmedToken,
                server: server,
                debugMode: true)
        }
        
        guard let gr4vy = gr4vy else {
            errorMessage = "Failed to configure Gr4vy SDK"
            isLoading = false
            return
        }
        
        // Convert seconds to minutes for the SDK parameter
        let timeoutSeconds = Int(sdkMaxTimeout.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 300
        let timeoutMinutes = timeoutSeconds / 60
        
        gr4vy.tokenize(
            checkoutSessionId: checkoutSessionId.trimmingCharacters(in: .whitespacesAndNewlines),
            cardData: cardData,
            sdkMaxTimeoutMinutes: timeoutMinutes,
            authenticate: authenticate,
            uiCustomization: uiCustomizationForTheme(selectedTheme)
        ) { result in
            Task { @MainActor in
                isLoading = false
                
                switch result {
                case .success(let tokenizeResult):
                    self.showCompleteResponse(tokenizeResult: tokenizeResult)
                    
                case .failure(let error):
                    if let gr4vyError = error as? Gr4vyError {
                        switch gr4vyError {
                        case .invalidGr4vyId:
                            self.showErrorResponse(errorMessage: "Invalid Gr4vy ID", errorDetails: ["description": gr4vyError.localizedDescription])
                        case .badURL(let url):
                            self.showErrorResponse(errorMessage: "Bad URL", errorDetails: ["url": url])
                        case .httpError(let statusCode, let responseData, _):
                            self.errorStatusCode = statusCode
                            self.errorResponseData = responseData
                            self.errorMessage = statusCode == 400 ? "Bad Request (400) - Tap to view details" : "HTTP Error \(statusCode) - Tap to view details"
                            self.showingErrorResponse = true
                        case .networkError(let urlError):
                            self.handleNetworkError(urlError, gr4vyID: gr4vyID)
                        case .decodingError(let message):
                            self.showErrorResponse(errorMessage: "Decoding error", errorDetails: ["description": message])
                        case .threeDSError(let message):
                            self.showErrorResponse(errorMessage: "3DS error", errorDetails: ["description": message])
                        case .uiContextError(let message):
                            self.showErrorResponse(errorMessage: "UI error", errorDetails: ["description": message])
                        }
                    } else {
                        self.handleNetworkError(error, gr4vyID: gr4vyID)
                    }
                }
            }
        }
    }
    
    /// Shows complete response using only data from tokenizeResult
    private func showErrorResponse(errorMessage: String, errorDetails: [String: Any]? = nil) {
        var errorResponse: [String: Any] = [
            "error": errorMessage
        ]
        
        if let details = errorDetails {
            errorResponse.merge(details) { (_, new) in new }
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: errorResponse, options: .prettyPrinted)
            self.generalErrorData = jsonData
            self.showingGeneralError = true
        } catch {
            // Fallback to simple error display
            self.errorMessage = "Error: \(errorMessage)"
        }
    }
    
    private func showCompleteResponse(tokenizeResult: Gr4vyTokenizeResult) {
        // Create response using the new tokenizeResult structure
        var completeResponse: [String: Any] = [:]
        
        // Always include tokenized status
        completeResponse["tokenized"] = tokenizeResult.tokenized
        
        // Add authentication data if present
        if let authentication = tokenizeResult.authentication {
            var authenticationResponse: [String: Any] = [:]
            
            authenticationResponse["attempted"] = authentication.attempted
            authenticationResponse["user_cancelled"] = authentication.hasCancelled
            authenticationResponse["timed_out"] = authentication.hasTimedOut
            authenticationResponse["type"] = authentication.type ?? NSNull()
            authenticationResponse["transaction_status"] = authentication.transactionStatus ?? NSNull()
            
            completeResponse["authentication"] = authenticationResponse
        } else {
            completeResponse["authentication"] = NSNull()
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: completeResponse, options: [.prettyPrinted, .sortedKeys])
            self.responseData = jsonData
            self.showingResponse = true
        } catch {
            self.errorMessage = "Failed to encode response: \(error.localizedDescription)"
        }
    }
    
    private func handleNetworkError(_ error: Error, gr4vyID: String) {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .cannotFindHost:
                self.showErrorResponse(
                    errorMessage: "Cannot find server",
                    errorDetails: [
                        "description": "Please check your Merchant ID (\(gr4vyID))",
                        "url": "https://api.\(gr4vyID).gr4vy.app",
                        "error_code": "cannotFindHost"
                    ]
                )
            case .notConnectedToInternet:
                self.showErrorResponse(
                    errorMessage: "No internet connection",
                    errorDetails: [
                        "description": "Please check your network settings",
                        "error_code": "notConnectedToInternet"
                    ]
                )
            case .timedOut:
                self.showErrorResponse(
                    errorMessage: "Request timed out",
                    errorDetails: [
                        "description": "Please try again",
                        "error_code": "timedOut"
                    ]
                )
            case .badServerResponse:
                self.showErrorResponse(
                    errorMessage: "Server error",
                    errorDetails: [
                        "description": "Please check your API token and try again",
                        "error_code": "badServerResponse"
                    ]
                )
            default:
                self.showErrorResponse(
                    errorMessage: "Network error",
                    errorDetails: [
                        "description": urlError.localizedDescription,
                        "error_code": String(urlError.code.rawValue)
                    ]
                )
            }
        } else {
            self.showErrorResponse(
                errorMessage: "Failed to tokenize payment method",
                errorDetails: ["description": error.localizedDescription]
            )
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
    
    private func populateTestCardData() {
        let testCard = selectedTestCard
        if testCard != .custom {
            cardNumber = testCard.cardNumber
            expirationDate = testCard.expirationDate
            securityCode = testCard.cvv
        }
    }
    
    private func clearForm() {
        selectedTestCardRaw = TestCard.custom.rawValue
        cardNumber = ""
        expirationDate = ""
        securityCode = ""
    }
    
    private func uiCustomizationForTheme(_ option: ThemeOption) -> Gr4vyThreeDSUiCustomizationMap? {
        switch option {
        case .none:
            return nil
        case .redBlue:
            return buildRedBlueTheme()
        case .orangePurple:
            return buildOrangePurpleTheme()
        case .greenYellow:
            return buildGreenYellowTheme()
        }
    }
    
    // MARK: - Theme builders covering all customization knobs
    private func buildRedBlueTheme() -> Gr4vyThreeDSUiCustomizationMap {
        let light = Gr4vyThreeDSUiCustomization(
            label: .init(
                textFontName: "HelveticaNeue",
                textFontSize: 16,
                textColorHex: "#1c1c1e",
                headingTextFontName: "HelveticaNeue-Bold",
                headingTextFontSize: 24,
                headingTextColorHex: "#0a0a0a"
            ),
            toolbar: .init(
                textFontName: "AvenirNext-DemiBold",
                textFontSize: 17,
                textColorHex: "#ffffff",
                backgroundColorHex: "#007aff",
                headerText: "Secure Checkout",
                buttonText: "Cancel"
            ),
            textBox: .init(
                textFontName: "HelveticaNeue",
                textFontSize: 16,
                textColorHex: "#000000",
                borderWidth: 2,
                borderColorHex: "#e4e4e4",
                cornerRadius: 12
            ),
            view: .init(
                challengeViewBackgroundColorHex: "#ffffff",
                progressViewBackgroundColorHex: "#ffffff"
            ),
            buttons: [
                .submit: .init(textFontName: "AvenirNext-Bold", textFontSize: 16, textColorHex: "#ffffff", backgroundColorHex: "#ff3b30", cornerRadius: 18),
                .continue: .init(textFontSize: 16, textColorHex: "#ffffff", backgroundColorHex: "#007aff", cornerRadius: 14),
                .next: .init(textFontSize: 16, textColorHex: "#ffffff", backgroundColorHex: "#5ac8fa", cornerRadius: 12),
                .resend: .init(textFontSize: 14, textColorHex: "#000000", backgroundColorHex: "#bbdbff", cornerRadius: 10),
                .openOobApp: .init(textFontSize: 16, textColorHex: "#ffffff", backgroundColorHex: "#007aff", cornerRadius: 14),
                .addCardholder: .init(textFontSize: 14, textColorHex: "#000000", backgroundColorHex: "#bbdbff", cornerRadius: 10),
                .cancel: .init(textFontSize: 16, textColorHex: "#ffffff")
            ]
        )
        let dark = Gr4vyThreeDSUiCustomization(
            label: .init(
                textFontName: "HelveticaNeue",
                textFontSize: 16,
                textColorHex: "#ffffff",
                headingTextFontName: "HelveticaNeue-Bold",
                headingTextFontSize: 24,
                headingTextColorHex: "#ffffff"
            ),
            toolbar: .init(
                textFontName: "AvenirNext-DemiBold",
                textFontSize: 17,
                textColorHex: "#ffffff",
                backgroundColorHex: "#0a84ff",
                headerText: "SECURE CHECKOUT",
                buttonText: "Close"
            ),
            textBox: .init(
                textFontName: "HelveticaNeue",
                textFontSize: 16,
                textColorHex: "#ffffff",
                borderWidth: 2,
                borderColorHex: "#565a5c",
                cornerRadius: 12
            ),
            view: .init(
                challengeViewBackgroundColorHex: "#000000",
                progressViewBackgroundColorHex: "#000000"
            ),
            buttons: [
                .submit: .init(textFontName: "AvenirNext-Bold", textFontSize: 16, textColorHex: "#ffffff", backgroundColorHex: "#ff0a0a", cornerRadius: 18),
                .continue: .init(textFontSize: 16, textColorHex: "#ffffff", backgroundColorHex: "#0a84ff", cornerRadius: 14),
                .next: .init(textFontSize: 16, textColorHex: "#ffffff", backgroundColorHex: "#64d2ff", cornerRadius: 12),
                .resend: .init(textFontSize: 14, textColorHex: "#ffffff", backgroundColorHex: "#515154", cornerRadius: 10),
                .openOobApp: .init(textFontSize: 16, textColorHex: "#ffffff", backgroundColorHex: "#0a84ff", cornerRadius: 14),
                .addCardholder: .init(textFontSize: 14, textColorHex: "#ffffff", backgroundColorHex: "#515154", cornerRadius: 10),
                .cancel: .init(textFontSize: 16, textColorHex: "#ffffff")
            ]
        )
        
        return Gr4vyThreeDSUiCustomizationMap(default: light, dark: dark)
    }
    
    private func buildOrangePurpleTheme() -> Gr4vyThreeDSUiCustomizationMap {
        // Emphasize headings and toolbar; rounded inputs
        let light = Gr4vyThreeDSUiCustomization(
            label: .init(
                textFontName: "Georgia",
                textFontSize: 15,
                textColorHex: "#222222",
                headingTextFontName: "Georgia-Bold",
                headingTextFontSize: 26,
                headingTextColorHex: "#111111"
            ),
            toolbar: .init(
                textFontName: "AvenirNext-Heavy",
                textFontSize: 18,
                textColorHex: "#ffffff",
                backgroundColorHex: "#af52de",
                headerText: "Strong Auth",
                buttonText: "Dismiss"
            ),
            textBox: .init(
                textFontName: "Georgia",
                textFontSize: 16,
                textColorHex: "#000000",
                borderWidth: 3,
                borderColorHex: "#ff9500",
                cornerRadius: 20
            ),
            view: .init(
                challengeViewBackgroundColorHex: "#ffffff",
                progressViewBackgroundColorHex: "#ffffff"
            ),
            buttons: [
                .submit: .init(textFontName: "AvenirNext-Heavy", textFontSize: 15, textColorHex: "#ffffff", backgroundColorHex: "#ff9500", cornerRadius: 20),
                .continue: .init(textFontSize: 15, textColorHex: "#ffffff", backgroundColorHex: "#af52de", cornerRadius: 16),
                .next: .init(textFontSize: 15, textColorHex: "#ffffff", backgroundColorHex: "#bf5af2", cornerRadius: 14),
                .resend: .init(textFontSize: 13, textColorHex: "#000000", backgroundColorHex: "#f5e3ff", cornerRadius: 12),
                .openOobApp: .init(textFontSize: 15, textColorHex: "#ffffff", backgroundColorHex: "#af52de", cornerRadius: 16),
                .addCardholder: .init(textFontSize: 13, textColorHex: "#000000", backgroundColorHex: "#f5e3ff", cornerRadius: 12),
                .cancel: .init(textFontSize: 15, textColorHex: "#ffffff")
            ]
        )
        let dark = Gr4vyThreeDSUiCustomization(
            label: .init(
                textFontName: "Georgia",
                textFontSize: 15,
                textColorHex: "#ffffff",
                headingTextFontName: "Georgia-Bold",
                headingTextFontSize: 26,
                headingTextColorHex: "#ffffff"
            ),
            toolbar: .init(
                textFontName: "AvenirNext-Heavy",
                textFontSize: 18,
                textColorHex: "#ffffff",
                backgroundColorHex: "#6e32a8",
                headerText: "STRONG AUTH",
                buttonText: "Dismiss"
            ),
            textBox: .init(
                textFontName: "Georgia",
                textFontSize: 16,
                textColorHex: "#ffffff",
                borderWidth: 3,
                borderColorHex: "#ff9f0a",
                cornerRadius: 20
            ),
            view: .init(
                challengeViewBackgroundColorHex: "#000000",
                progressViewBackgroundColorHex: "#000000"
            ),
            buttons: [
                .submit: .init(textFontName: "AvenirNext-Heavy", textFontSize: 15, textColorHex: "#000000", backgroundColorHex: "#ff9f0a", cornerRadius: 20),
                .continue: .init(textFontSize: 15, textColorHex: "#000000", backgroundColorHex: "#bf5af2", cornerRadius: 16),
                .next: .init(textFontSize: 15, textColorHex: "#000000", backgroundColorHex: "#af52de", cornerRadius: 14),
                .resend: .init(textFontSize: 13, textColorHex: "#000000", backgroundColorHex: "#e6ccff", cornerRadius: 12),
                .openOobApp: .init(textFontSize: 15, textColorHex: "#000000", backgroundColorHex: "#bf5af2", cornerRadius: 16),
                .addCardholder: .init(textFontSize: 13, textColorHex: "#000000", backgroundColorHex: "#e6ccff", cornerRadius: 12),
                .cancel: .init(textFontSize: 15, textColorHex: "#ffffff")
            ]
        )
        
        return Gr4vyThreeDSUiCustomizationMap(default: light, dark: dark)
    }
    
    private func buildGreenYellowTheme() -> Gr4vyThreeDSUiCustomizationMap {
        // Minimalist text; strong input borders; high-contrast submit
        let light = Gr4vyThreeDSUiCustomization(
            label: .init(
                textFontName: "AvenirNext-Regular",
                textFontSize: 16,
                textColorHex: "#1f1f1f",
                headingTextFontName: "AvenirNext-Bold",
                headingTextFontSize: 20,
                headingTextColorHex: "#111111"
            ),
            toolbar: .init(
                textFontName: "AvenirNext-Regular",
                textFontSize: 16,
                textColorHex: "#000000",
                backgroundColorHex: "#ffcc00",
                headerText: "3DS Challenge",
                buttonText: "Back"
            ),
            textBox: .init(
                textFontName: "AvenirNext-Regular",
                textFontSize: 16,
                textColorHex: "#000000",
                borderWidth: 4,
                borderColorHex: "#34c759",
                cornerRadius: 6
            ),
            view: .init(
                challengeViewBackgroundColorHex: "#ffffff",
                progressViewBackgroundColorHex: "#f8f8f8"
            ),
            buttons: [
                .submit: .init(textFontName: "AvenirNext-Bold", textFontSize: 17, textColorHex: "#ffffff", backgroundColorHex: "#34c759", cornerRadius: 8),
                .continue: .init(textFontSize: 16, textColorHex: "#000000", backgroundColorHex: "#ffcc00", cornerRadius: 8),
                .next: .init(textFontSize: 15, textColorHex: "#000000", backgroundColorHex: "#ffe066", cornerRadius: 8),
                .resend: .init(textFontSize: 13, textColorHex: "#000000", backgroundColorHex: "#e7ffd6", cornerRadius: 6),
                .openOobApp: .init(textFontSize: 16, textColorHex: "#ffffff", backgroundColorHex: "#34c759", cornerRadius: 8),
                .addCardholder: .init(textFontSize: 13, textColorHex: "#000000", backgroundColorHex: "#e7ffd6", cornerRadius: 6),
                .cancel: .init(textFontSize: 16, textColorHex: "#000000")
            ]
        )
        let dark = Gr4vyThreeDSUiCustomization(
            label: .init(
                textFontName: "AvenirNext-Regular",
                textFontSize: 16,
                textColorHex: "#ffffff",
                headingTextFontName: "AvenirNext-Bold",
                headingTextFontSize: 20,
                headingTextColorHex: "#ffffff"
            ),
            toolbar: .init(
                textFontName: "AvenirNext-Regular",
                textFontSize: 16,
                textColorHex: "#000000",
                backgroundColorHex: "#ffd60a",
                headerText: "3DS CHALLENGE",
                buttonText: "Back"
            ),
            textBox: .init(
                textFontName: "AvenirNext-Regular",
                textFontSize: 16,
                textColorHex: "#ffffff",
                borderWidth: 4,
                borderColorHex: "#30d158",
                cornerRadius: 6
            ),
            view: .init(
                challengeViewBackgroundColorHex: "#000000",
                progressViewBackgroundColorHex: "#000000"
            ),
            buttons: [
                .submit: .init(textFontName: "AvenirNext-Bold", textFontSize: 17, textColorHex: "#000000", backgroundColorHex: "#30d158", cornerRadius: 8),
                .continue: .init(textFontSize: 16, textColorHex: "#000000", backgroundColorHex: "#ffd60a", cornerRadius: 8),
                .next: .init(textFontSize: 15, textColorHex: "#000000", backgroundColorHex: "#ffe066", cornerRadius: 8),
                .resend: .init(textFontSize: 13, textColorHex: "#000000", backgroundColorHex: "#2e2e2e", cornerRadius: 6),
                .openOobApp: .init(textFontSize: 16, textColorHex: "#000000", backgroundColorHex: "#30d158", cornerRadius: 8),
                .addCardholder: .init(textFontSize: 13, textColorHex: "#000000", backgroundColorHex: "#2e2e2e", cornerRadius: 6),
                .cancel: .init(textFontSize: 16, textColorHex: "#000000")
            ]
        )
        
        return Gr4vyThreeDSUiCustomizationMap(default: light, dark: dark)
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
