//
//  TodaysPlayerApp.swift
//  TodaysPlayer
//
//  Created by J on 9/24/25.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct TodaysPlayerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var favoriteViewModel = FavoriteViewModel()
    @StateObject private var userSessionManager = UserSessionManager.shared
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(favoriteViewModel)
                .environmentObject(userSessionManager)
        }
    }

}
