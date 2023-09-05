//
//  ContentView.swift
//  APOD
//
//  Created by Gokmen Akar on 5.09.2023.
//

import SwiftUI
import SDWebImageSwiftUI

class HomeViewModel: ObservableObject {
    @Published var models: [APOD] = []

    func getPhotos() async {
        do {
            let (data, _) = try await URLSession.shared.data(from: URL(string: "https://api.nasa.gov/planetary/apod?api_key=WBd6KIwrJohInTFEi1XSZA7ERws6opS3KLm2XhSH&count=5")!)
            models += try JSONDecoder().decode([APOD].self, from: data)
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct HomeView: View {

    @StateObject private var viewModel: HomeViewModel = .init()

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.models, id: \.id) { apod in
                        APODCard(apod: apod)
                    }
                }
            }
            .task {
                await viewModel.getPhotos()
            }
        }
    }
}

struct APODCard: View {
    let apod: APOD

    var body: some View {
        VStack {
            // TODO: Image
            WebImage(url: URL(string: apod.url))
                .onSuccess { pImage, data, _ in

                }
                .resizable()
                .scaledToFill()
                .frame(height: 230)
                .clipped()

            VStack(alignment: .leading) {
                Text(apod.title)
                    .font(.headline)

                Text(apod.explanation)
                    .font(.callout)
                    .lineLimit(3)
            }
            .foregroundColor(Color.white)
            .background(Color.black)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
