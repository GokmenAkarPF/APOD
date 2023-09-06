//
//  FavoritesView.swift
//  APOD
//
//  Created by Gokmen Akar on 6.09.2023.
//

import SwiftUI

struct FavoritesView: View {

    @EnvironmentObject var apodManager: APODManager

    var body: some View {
        NavigationStack {
            VStack {
                if apodManager.likedModels.isEmpty {
                    Text("No favorites... 👽")
                } else {
                    ScrollView {
                        LazyVStack {
                            ForEach(apodManager.likedModels, id: \.date) { apod in
                                APODCard(apod: apod) {
                                    apodManager.unliked(apod: apod)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Favorites")
        }
    }
}
