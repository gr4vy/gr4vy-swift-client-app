//
//  JSONResponseView.swift
//  Gr4vy SwiftUI Sample App
//
//

import SwiftUI

struct JSONResponseView: View {
    let jsonString: String
    let title: String
    
    @State private var showingCopiedAlert = false
    
    var body: some View {
        ScrollView {
            Text(jsonString)
                .font(.system(.body, design: .monospaced))
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(.secondarySystemBackground))
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: copyToClipboard) {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                    
                    Button(action: shareResponse) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .alert("Copied to Clipboard", isPresented: $showingCopiedAlert) {
            Button("OK") { }
        }
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = jsonString
        showingCopiedAlert = true
    }
    
    private func shareResponse() {
        let activityVC = UIActivityViewController(
            activityItems: [jsonString],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
}

#Preview {
    NavigationStack {
        JSONResponseView(
            jsonString: """
            {
                "status": "success",
                "data": {
                    "id": "12345",
                    "message": "Payment processed successfully"
                }
            }
            """,
            title: "Response"
        )
    }
} 