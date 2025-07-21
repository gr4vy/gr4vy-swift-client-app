//
//  Gr4vy_SwiftUI_Sample_App.swift
//  Gr4vy SwiftUI Sample App
//
//

import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UserDefaults.standard.set("GBP", forKey: "Currency")
        
        // Configure global back button title
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -1000, vertical: 0), for: .default)
        
        return true
    }
}

@main
struct Gr4vy_SwiftUI_Sample_App: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
