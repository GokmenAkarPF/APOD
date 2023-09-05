//
//  ContentView.swift
//  APOD
//
//  Created by Gokmen Akar on 5.09.2023.
//

import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var models: [APOD] = [.init(date: "11-03-2023", explanation: "Test test test", hdurl: "url", mediaType: nil, serviceVersion: nil, title: "Title", url: "url", copyright: nil)]

    func getPhotos() async {

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
        }
    }
}

struct APODCard: View {
    let apod: APOD

    var body: some View {
        VStack {
            // TODO: Image
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(.red)
                .frame(height: 230)

            Text(apod.title)
            Text(apod.explanation)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
