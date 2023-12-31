//
//  TabbarView.swift
//  APOD
//
//  Created by Gokmen Akar on 5.09.2023.
//

import SwiftUI

struct TabbarView: View {
    @State private var selection: Int = .zero
    var body: some View {
        TabView(selection: $selection) {
            HomeView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                }
                .tag(0)

            RandomView()
                .tabItem {
                    Image(systemName: "infinity")
                }
                .tag(1)
            
            FavoritesView()
                .tabItem {
                    Image(systemName: "heart")
                }
                .tag(2)
        }
    }
}
