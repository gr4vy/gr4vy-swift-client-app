//
//  HomeView.swift
//  Gr4vy SwiftUI Sample App
//
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Spacer()
                    .frame(height: 24)
                
                NavigationLink(destination: PaymentOptionsView()) {
                    ButtonView(title: "Payment Options", systemImage: "creditcard.fill")
                }
                
                NavigationLink(destination: FieldsView()) {
                    ButtonView(title: "Fields", systemImage: "textformat")
                }
                
                NavigationLink(destination: CardDetailsView()) {
                    ButtonView(title: "Card Details", systemImage: "creditcard")
                }
                
                NavigationLink(destination: PaymentMethodsView()) {
                    ButtonView(title: "Payment Methods", systemImage: "list.bullet")
                }
                
                Spacer()
            }
            .padding(.horizontal)
        }
        .navigationTitle("Gr4vy Native SDK")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct ButtonView: View {
    let title: String
    let systemImage: String
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .font(.title2)
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 80)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
        .foregroundColor(.primary)
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
