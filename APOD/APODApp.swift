//
//  APODApp.swift
//  APOD
//
//  Created by Gokmen Akar on 5.09.2023.
//

import SwiftUI

@main
struct APODApp: App {

    @StateObject private var likeManager = LikeManager()
    var body: some Scene {
        WindowGroup {
            TabbarView()
                .environmentObject(likeManager)
        }
    }
}
