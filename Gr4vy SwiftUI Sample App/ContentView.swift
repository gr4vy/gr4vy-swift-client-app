//
//  ContentView.swift
//  Gr4vy SwiftUI Sample App
//
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            
            NavigationStack {
                AdminView()
            }
            .tabItem {
                Image(systemName: "gearshape.fill")
                Text("Admin")
            }
        }
    }
}

#Preview {
    ContentView()
} 