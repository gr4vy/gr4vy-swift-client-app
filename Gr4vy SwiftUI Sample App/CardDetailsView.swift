//
//  CardDetailsView.swift
//  Gr4vy SwiftUI Sample App
//
//

import SwiftUI
import gr4vy_swift

struct CardDetailsView: View {
    @AppStorage("card_details_currency") private var currency: String = ""
    @AppStorage("card_details_amount") private var amount: String = ""
    @AppStorage("card_details_bin") private var bin: String = ""
    @AppStorage("card_details_country") private var country: String = ""
    @AppStorage("card_details_intent") private var intent: String = ""
    @AppStorage("card_details_is_subsequent_payment") private var is_subsequent_payment: Bool = false
    @AppStorage("card_details_merchant_initiated") private var merchant_initiated: Bool = false
    @AppStorage("card_details_metadata") private var metadata: String = ""
    @AppStorage("card_details_payment_method_id") private var payment_method_id: String = ""
    @AppStorage("card_details_payment_source") private var payment_source: String = ""
    
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
                TextField("currency", text: $currency)
                    .textContentType(.none)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                
                TextField("amount", text: $amount)
                    .keyboardType(.numberPad)
                    .textContentType(.none)
                    .autocorrectionDisabled()
                
                TextField("bin", text: $bin)
                    .keyboardType(.numberPad)
                    .textContentType(.none)
                    .autocorrectionDisabled()
                    .onChange(of: bin) { newValue in
                        if newValue.count > 8 {
                            bin = String(newValue.prefix(8))
                        }
                    }
                
                TextField("country", text: $country)
                    .textContentType(.none)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                    .onChange(of: country) { newValue in
                        if newValue.count > 2 {
                            country = String(newValue.prefix(2))
                        }
                    }
                
                Picker("intent", selection: $intent) {
                    Text("").tag("")
                    Text("authorize").tag("authorize")
                    Text("capture").tag("capture")
                }
                .pickerStyle(MenuPickerStyle())
                
                Toggle("is_subsequent_payment", isOn: $is_subsequent_payment)
                Toggle("merchant_initiated", isOn: $merchant_initiated)
                
                TextField("metadata", text: $metadata)
                    .textContentType(.none)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                
                TextField("payment_method_id", text: $payment_method_id)
                    .textContentType(.none)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                
                Picker("payment_source", selection: $payment_source) {
                    Text("").tag("")
                    Text("ecommerce").tag("ecommerce")
                    Text("moto").tag("moto")
                    Text("recurring").tag("recurring")
                    Text("installment").tag("installment")
                    Text("card_on_file").tag("card_on_file")
                }
                .pickerStyle(MenuPickerStyle())
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
        .navigationTitle("Card Details")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button("GET") {
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
                .disabled(currency.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
            }
        }
        .navigationDestination(isPresented: $showingResponse) {
            if let responseData = responseData {
                JSONResponseView(
                    jsonString: formatJSON(responseData),
                    title: "Card Details Response"
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
        
        // Configure Gr4vy SDK
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
        
        let trimmedCurrency = currency.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedCurrency.isEmpty else {
            errorMessage = "Please enter a currency"
            isLoading    = false
            return
        }
        
        let details = Gr4vyCardDetails(
            currency: trimmedCurrency,
            amount: amount.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : amount,
            bin: bin.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty   ? nil : bin,
            country: country.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : country,
            intent: intent.isEmpty ? nil : intent,
            isSubsequentPayment: is_subsequent_payment ? true : nil,
            merchantInitiated: merchant_initiated   ? true : nil,
            metadata: metadata.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : metadata,
            paymentMethodId: payment_method_id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : payment_method_id,
            paymentSource: payment_source.isEmpty ? nil : payment_source
        )
        
        let requestBody = Gr4vyCardDetailsRequest(cardDetails: details)
        
        gr4vy.cardDetails.get(request: requestBody) { result in
            Task { @MainActor in
                isLoading = false
                
                switch result {
                case .success(let options):
                    // Convert the response to JSON for display
                    do {
                        let encoder = JSONEncoder()
                        encoder.outputFormatting = .prettyPrinted
                        let jsonData = try encoder.encode(options)
                        self.responseData = jsonData
                        self.showingResponse = true
                    } catch {
                        self.errorMessage = "Failed to encode response: \(error.localizedDescription)"
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
                self.errorMessage = "Cannot find server. Please check your Merchant ID (\(gr4vyID)). The URL being called is: https://api.\(gr4vyID).gr4vy.app/card-details"
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
            self.errorMessage = "Failed to get card details: \(error.localizedDescription)"
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

#Preview {
    NavigationStack {
        CardDetailsView()
    }
}
