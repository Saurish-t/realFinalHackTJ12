//
//  hacktj12App.swift
//  hacktj12
//
//  Created by Saurish Tripathi on 3/8/25.
//

import SwiftUI
import FirebaseCore

@main
struct YourApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

