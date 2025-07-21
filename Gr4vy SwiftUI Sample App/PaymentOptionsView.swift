//
//  PaymentOptionsView.swift
//  Gr4vy SwiftUI Sample App
//
//

import SwiftUI
import gr4vy_swift

struct MetadataEntry: Identifiable, Codable {
    let id: UUID
    var key: String
    var value: String
    
    init(key: String, value: String) {
        self.id = UUID()
        self.key = key
        self.value = value
    }
}

struct CartItemEntry: Identifiable, Codable {
    let id: UUID
    var name: String
    var quantity: String
    var unitAmount: String
    var discountAmount: String
    var taxAmount: String
    var externalIdentifier: String
    var sku: String
    var productUrl: String
    var imageUrl: String
    var categories: String
    var productType: String
    var sellerCountry: String
    
    init(name: String, quantity: String, unitAmount: String, discountAmount: String, taxAmount: String, externalIdentifier: String, sku: String, productUrl: String, imageUrl: String, categories: String, productType: String, sellerCountry: String) {
        self.id = UUID()
        self.name = name
        self.quantity = quantity
        self.unitAmount = unitAmount
        self.discountAmount = discountAmount
        self.taxAmount = taxAmount
        self.externalIdentifier = externalIdentifier
        self.sku = sku
        self.productUrl = productUrl
        self.imageUrl = imageUrl
        self.categories = categories
        self.productType = productType
        self.sellerCountry = sellerCountry
    }
}

struct PaymentOptionsView: View {
    @AppStorage("payment_options_metadata_entries") private var metadataEntriesData: Data = Data()
    @AppStorage("payment_options_country") private var country: String = ""
    @AppStorage("payment_options_currency") private var currency: String = ""
    @AppStorage("payment_options_amount") private var amount: String = ""
    @AppStorage("payment_options_locale") private var locale: String = ""
    @AppStorage("payment_options_cart_items") private var cartItemsData: Data = Data()
    
    // Admin settings
    @AppStorage("merchantId") private var merchantId: String = ""
    @AppStorage("gr4vyId") private var gr4vyId: String = ""
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
    @State private var metadataEntries: [MetadataEntry] = []
    @State private var cartItems: [CartItemEntry] = []
    
    var body: some View {
        VStack {
            Form {
                Section("Metadata") {
                    ForEach(metadataEntries.indices, id: \.self) { index in
                        HStack {
                            TextField("Key", text: $metadataEntries[index].key)
                                .textContentType(.none)
                                .autocorrectionDisabled()
                                .autocapitalization(.none)
                                .onChange(of: metadataEntries[index].key) { _ in
                                    saveMetadataEntries()
                                }
                            
                            TextField("Value", text: $metadataEntries[index].value)
                                .textContentType(.none)
                                .autocorrectionDisabled()
                                .autocapitalization(.none)
                                .onChange(of: metadataEntries[index].value) { _ in
                                    saveMetadataEntries()
                                }
                            
                            Button(action: {
                                metadataEntries.remove(at: index)
                                saveMetadataEntries()
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    Button("Add Metadata Entry") {
                        metadataEntries.append(MetadataEntry(key: "", value: ""))
                        saveMetadataEntries()
                    }
                    .foregroundColor(.blue)
                }
                
                Section("Payment Details") {
                    TextField("country", text: $country)
                        .textContentType(.none)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                    
                    TextField("currency", text: $currency)
                        .textContentType(.none)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                    
                    TextField("amount", text: $amount)
                        .keyboardType(.numberPad)
                        .textContentType(.none)
                        .autocorrectionDisabled()
                    
                    TextField("locale", text: $locale)
                        .textContentType(.none)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                }
                
                Section("Cart Items") {
                    ForEach(cartItems.indices, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Item \(index + 1)")
                                    .font(.headline)
                                Spacer()
                                Button(action: {
                                    cartItems.remove(at: index)
                                    saveCartItems()
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                            
                            TextField("name", text: $cartItems[index].name)
                                .textContentType(.none)
                                .autocorrectionDisabled()
                                .autocapitalization(.none)
                                .onChange(of: cartItems[index].name) { _ in
                                    saveCartItems()
                                }
                            
                            TextField("quantity", text: $cartItems[index].quantity)
                                .keyboardType(.numberPad)
                                .textContentType(.none)
                                .autocorrectionDisabled()
                                .onChange(of: cartItems[index].quantity) { _ in
                                    saveCartItems()
                                }
                            
                            TextField("unit_amount", text: $cartItems[index].unitAmount)
                                .keyboardType(.numberPad)
                                .textContentType(.none)
                                .autocorrectionDisabled()
                                .onChange(of: cartItems[index].unitAmount) { _ in
                                    saveCartItems()
                                }
                            
                            TextField("discount_amount", text: $cartItems[index].discountAmount)
                                .keyboardType(.numberPad)
                                .textContentType(.none)
                                .autocorrectionDisabled()
                                .onChange(of: cartItems[index].discountAmount) { _ in
                                    saveCartItems()
                                }
                            
                            TextField("tax_amount", text: $cartItems[index].taxAmount)
                                .keyboardType(.numberPad)
                                .textContentType(.none)
                                .autocorrectionDisabled()
                                .onChange(of: cartItems[index].taxAmount) { _ in
                                    saveCartItems()
                                }
                            
                            TextField("external_identifier", text: $cartItems[index].externalIdentifier)
                                .textContentType(.none)
                                .autocorrectionDisabled()
                                .autocapitalization(.none)
                                .onChange(of: cartItems[index].externalIdentifier) { _ in
                                    saveCartItems()
                                }
                            
                            TextField("sku", text: $cartItems[index].sku)
                                .textContentType(.none)
                                .autocorrectionDisabled()
                                .autocapitalization(.none)
                                .onChange(of: cartItems[index].sku) { _ in
                                    saveCartItems()
                                }
                            
                            TextField("product_url", text: $cartItems[index].productUrl)
                                .textContentType(.URL)
                                .keyboardType(.URL)
                                .autocorrectionDisabled()
                                .autocapitalization(.none)
                                .onChange(of: cartItems[index].productUrl) { _ in
                                    saveCartItems()
                                }
                            
                            TextField("image_url", text: $cartItems[index].imageUrl)
                                .textContentType(.URL)
                                .keyboardType(.URL)
                                .autocorrectionDisabled()
                                .autocapitalization(.none)
                                .onChange(of: cartItems[index].imageUrl) { _ in
                                    saveCartItems()
                                }
                            
                            TextField("categories (comma separated)", text: $cartItems[index].categories)
                                .textContentType(.none)
                                .autocorrectionDisabled()
                                .autocapitalization(.none)
                                .onChange(of: cartItems[index].categories) { _ in
                                    saveCartItems()
                                }
                            
                            TextField("product_type", text: $cartItems[index].productType)
                                .textContentType(.none)
                                .autocorrectionDisabled()
                                .autocapitalization(.none)
                                .onChange(of: cartItems[index].productType) { _ in
                                    saveCartItems()
                                }
                            
                            TextField("seller_country", text: $cartItems[index].sellerCountry)
                                .textContentType(.none)
                                .autocorrectionDisabled()
                                .autocapitalization(.none)
                                .onChange(of: cartItems[index].sellerCountry) { _ in
                                    saveCartItems()
                                }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    Button("Add Cart Item") {
                        cartItems.append(CartItemEntry(
                            name: "",
                            quantity: "",
                            unitAmount: "",
                            discountAmount: "",
                            taxAmount: "",
                            externalIdentifier: "",
                            sku: "",
                            productUrl: "",
                            imageUrl: "",
                            categories: "",
                            productType: "",
                            sellerCountry: ""
                        ))
                        saveCartItems()
                    }
                    .foregroundColor(.blue)
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
        .navigationTitle("Payment Options")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button("POST") {
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
                    title: "Payment Options Response"
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
        .onAppear {
            loadMetadataEntries()
            loadCartItems()
        }
    }
    
    private func loadMetadataEntries() {
        if let entries = try? JSONDecoder().decode([MetadataEntry].self, from: metadataEntriesData) {
            metadataEntries = entries
        }
    }
    
    private func saveMetadataEntries() {
        if let data = try? JSONEncoder().encode(metadataEntries) {
            metadataEntriesData = data
        }
    }
    
    private func loadCartItems() {
        if let items = try? JSONDecoder().decode([CartItemEntry].self, from: cartItemsData) {
            cartItems = items
        }
    }
    
    private func saveCartItems() {
        if let data = try? JSONEncoder().encode(cartItems) {
            cartItemsData = data
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
        
        var metadata: [String: String] = [:]
        let validMetadataEntries = metadataEntries.filter {
            !$0.key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !$0.value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        
        for entry in validMetadataEntries {
            metadata[entry.key.trimmingCharacters(in: .whitespacesAndNewlines)] =
            entry.value.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        var gr4vyCartItems: [Gr4vyPaymentOptionCartItem] = []
        let validCartItems = cartItems.filter { item in
            !item.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !item.quantity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !item.unitAmount.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        
        let merchantIdValue = merchantId.trimmingCharacters(in: .whitespacesAndNewlines)
        
        for item in validCartItems {
            let categories = item.categories.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil :
            item.categories.trimmingCharacters(in: .whitespacesAndNewlines)
                .split(separator: ",")
                .map { String($0.trimmingCharacters(in: .whitespaces)) }
            
            let cartItem = Gr4vyPaymentOptionCartItem(
                name: item.name.trimmingCharacters(in: .whitespacesAndNewlines),
                quantity: Int(item.quantity.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 1,
                unitAmount: Int(item.unitAmount.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0,
                discountAmount: item.discountAmount.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil :
                    Int(item.discountAmount.trimmingCharacters(in: .whitespacesAndNewlines)),
                taxAmount: item.taxAmount.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil :
                    Int(item.taxAmount.trimmingCharacters(in: .whitespacesAndNewlines)),
                externalIdentifier: item.externalIdentifier.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil :
                    item.externalIdentifier.trimmingCharacters(in: .whitespacesAndNewlines),
                sku: item.sku.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil :
                    item.sku.trimmingCharacters(in: .whitespacesAndNewlines),
                productUrl: item.productUrl.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil :
                    item.productUrl.trimmingCharacters(in: .whitespacesAndNewlines),
                imageUrl: item.imageUrl.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil :
                    item.imageUrl.trimmingCharacters(in: .whitespacesAndNewlines),
                categories: categories,
                productType: item.productType.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil :
                    item.productType.trimmingCharacters(in: .whitespacesAndNewlines),
                sellerCountry: item.sellerCountry.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil :
                    item.sellerCountry.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            gr4vyCartItems.append(cartItem)
        }
        
        let requestBody = Gr4vyPaymentOptionRequest(
            merchantId: merchantIdValue,
            metadata: metadata,
            country: country.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil :
                country.trimmingCharacters(in: .whitespacesAndNewlines),
            currency: currency.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil :
                currency.trimmingCharacters(in: .whitespacesAndNewlines),
            amount: amount.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil :
                Int(amount.trimmingCharacters(in: .whitespacesAndNewlines)),
            locale: locale.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "en-GB" :
                locale.trimmingCharacters(in: .whitespacesAndNewlines),
            cartItems: gr4vyCartItems.isEmpty ? nil : gr4vyCartItems
        )
        
        gr4vy.paymentOptions.list(request: requestBody) { result in
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
        PaymentOptionsView()
    }
}
