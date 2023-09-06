//
//  APODApp.swift
//  APOD
//
//  Created by Gokmen Akar on 5.09.2023.
//

import SwiftUI

@main
struct APODApp: App {

    @StateObject private var apodManager = APODManager()
    var body: some Scene {
        WindowGroup {
            TabbarView()
                .environmentObject(apodManager)
        }
    }
}
