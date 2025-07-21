//
//  PaymentMethodsView.swift
//  Gr4vy SwiftUI Sample App
//
//

import SwiftUI
import gr4vy_swift

struct PaymentMethodsView: View {
    @AppStorage("payment_methods_buyer_id") private var buyer_id: String?
    @AppStorage("payment_methods_buyer_external_identifier") private var buyer_external_identifier: String?
    @AppStorage("payment_methods_sort_by") private var sort_by: Gr4vySortBy?
    @AppStorage("payment_methods_order_by") private var order_by: String = "desc"
    @AppStorage("payment_methods_country") private var country: String?
    @AppStorage("payment_methods_currency") private var currency: String?
    
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
                TextField("buyer_id", text: Binding(
                    get: { buyer_id ?? "" },
                    set: { buyer_id = $0.isEmpty ? nil : $0 }
                ))
                .textContentType(.none)
                .autocorrectionDisabled()
                .autocapitalization(.none)
                
                TextField("buyer_external_identifier", text: Binding(
                    get: { buyer_external_identifier ?? "" },
                    set: { buyer_external_identifier = $0.isEmpty ? nil : $0 }
                ))
                .textContentType(.none)
                .autocorrectionDisabled()
                .autocapitalization(.none)
                
                Picker("sort_by", selection: $sort_by) {
                    Text("None").tag(nil as Gr4vySortBy?)
                    ForEach(Gr4vySortBy.allCases, id: \.self) { sortBy in
                        Text(sortBy.rawValue).tag(sortBy as Gr4vySortBy?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                Picker("order_by", selection: $order_by) {
                    Text("desc").tag("desc")
                    Text("asc").tag("asc")
                }
                .pickerStyle(MenuPickerStyle())
                
                TextField("country", text: Binding(
                    get: { country ?? "" },
                    set: { country = $0.isEmpty ? nil : $0 }
                ))
                .textContentType(.none)
                .autocorrectionDisabled()
                .autocapitalization(.none)
                
                TextField("currency", text: Binding(
                    get: { currency ?? "" },
                    set: { currency = $0.isEmpty ? nil : $0 }
                ))
                .textContentType(.none)
                .autocorrectionDisabled()
                .autocapitalization(.none)
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
        .navigationTitle("Payment Methods")
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
                .disabled(isLoading)
            }
        }
        .navigationDestination(isPresented: $showingResponse) {
            if let responseData = responseData {
                JSONResponseView(
                    jsonString: formatJSON(responseData),
                    title: "Payment Methods Response"
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
        
        var queryParams: [String: String] = [
            "order_by": order_by
        ]
        
        if let buyerId = buyer_id, !buyerId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            queryParams["buyer_id"] = buyerId.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        if let buyerExtId = buyer_external_identifier, !buyerExtId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            queryParams["buyer_external_identifier"] = buyerExtId.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        if let sortBy = sort_by {
            queryParams["sort_by"] = sortBy.rawValue
        }
        
        if let countryVal = country, !countryVal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            queryParams["country"] = countryVal.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        if let currencyVal = currency, !currencyVal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            queryParams["currency"] = currencyVal.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        let buyerId = buyer_id?.trimmingCharacters(in: .whitespacesAndNewlines)
        let buyerExtId = buyer_external_identifier?.trimmingCharacters(in: .whitespacesAndNewlines)
        let countryVal = country?.trimmingCharacters(in: .whitespacesAndNewlines)
        let currencyVal = currency?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let paymentMethods = Gr4vyBuyersPaymentMethods(
            buyerId: buyerId?.isEmpty == false ? buyerId : nil, // optional
            buyerExternalIdentifier: buyerExtId?.isEmpty == false ? buyerExtId : nil,
            sortBy: sort_by,
            orderBy: Gr4vyOrderBy(rawValue: order_by),
            country: countryVal?.isEmpty == false ? countryVal : nil,
            currency: currencyVal?.isEmpty == false ? currencyVal : nil
        )
        
        let requestBody = Gr4vyBuyersPaymentMethodsRequest(
            paymentMethods: paymentMethods
        )
        
        gr4vy.paymentMethods.list(request: requestBody) { result in
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
                self.errorMessage = "Cannot find server. Please check your Merchant ID (\(gr4vyID)). The URL being called is: https://api.\(gr4vyID).gr4vy.app/payment-options"
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
            self.errorMessage = "Failed to get payment options: \(error.localizedDescription)"
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
        PaymentMethodsView()
    }
}
