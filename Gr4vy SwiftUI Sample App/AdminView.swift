//
//  AdminView.swift
//  Gr4vy SwiftUI Sample App
//
//

import SwiftUI

struct AdminView: View {
    @AppStorage("merchantId") private var merchantId: String = ""
    @AppStorage("gr4vyId") private var gr4vyId: String = ""
    @AppStorage("serverURL") private var serverURL: String = ""
    @AppStorage("apiToken") private var token: String = ""
    @AppStorage("serverEnvironment") private var serverEnvironment: String = "sandbox"
    @AppStorage("timeout") private var timeout: String = ""
    
    @State private var showingSaveConfirmation = false
    
    var body: some View {
        Form {
            Section {
                TextField("merchantId", text: $merchantId)
                    .textContentType(.none)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                
                TextField("gr4vyId", text: $gr4vyId)
                    .textContentType(.none)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                
                TextField("token", text: $token)
                    .textContentType(.none)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                
                Picker("server", selection: $serverEnvironment) {
                    Text("sandbox").tag("sandbox")
                    Text("production").tag("production")
                }
                .pickerStyle(MenuPickerStyle())
                
                TextField("timeout (seconds)", text: $timeout)
                    .keyboardType(.numberPad)
                    .textContentType(.none)
                    .autocorrectionDisabled()
            } header: {
                Text("API Configuration")
            }
            
            Section {
                Button("Save") {
                    saveSettings()
                }
                .frame(maxWidth: .infinity)
                .controlSize(.large)
            }
        }
        .navigationTitle("Admin")
        .navigationBarTitleDisplayMode(.large)
        .alert("Settings Saved", isPresented: $showingSaveConfirmation) {
            Button("OK") { }
        }
    }
    
    private func saveSettings() {
        showingSaveConfirmation = true
    }
}

#Preview {
    NavigationStack {
        AdminView()
    }
} 
