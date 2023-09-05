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

    var upperDate: Date
    var lowerDate: Date
    var currentDate = Date()

    init() {
        upperDate = currentDate
        lowerDate = Calendar.current.date(byAdding: .day, value: -10, to: currentDate)!
    }

    @MainActor func getPhotos() async {
        let upperBoundString = upperDate.formatted(.iso8601).description.split(separator: "T").first!.description
        let lowerBoundString = lowerDate.formatted(.iso8601).description.split(separator: "T").first!.description

        do {
            let (data, _) = try await URLSession.shared.data(from: URL(string: "https://api.nasa.gov/planetary/apod?api_key=WBd6KIwrJohInTFEi1XSZA7ERws6opS3KLm2XhSH&start_date=\(lowerBoundString)&end_date=\(upperBoundString)")!)
            models += try JSONDecoder().decode([APOD].self, from: data)

            upperDate = lowerDate
            lowerDate = Calendar.current.date(byAdding: .day, value: -19, to: lowerDate)!
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct HomeView: View {

    @StateObject private var viewModel: HomeViewModel = .init()

    @State private var showDetail: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.models, id: \.id) { apod in
                            APODCard(apod: apod)
                                .onAppear {
                                    if apod.id == viewModel.models.last!.id {
                                        Task {
                                            await viewModel.getPhotos()
                                        }
                                    }
                                }
                                .onTapGesture {
                                    showDetail = true
                                }
                    }

                    ProgressView()
                        .progressViewStyle(.circular)
                        .frame(height: 120)
                }

                NavigationLink("", destination: Text("s"), isActive: $showDetail)
            }
            .task {
                await viewModel.getPhotos()
            }
        }
    }
}

struct HighResolutionImage: View {
    let url: URL
    var body: some View {
        Text("s")
    }
}

// MARK: - Card
struct APODCard: View {
    let apod: APOD

    var body: some View {
        VStack(spacing: .zero) {
            // TODO: Image
            WebImage(url: URL(string: apod.url))
                .onSuccess { pImage, data, _ in

                }
                .resizable()
                .indicator(.activity(style: .large))
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
            .padding(8)
            .background(Color.black)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 5)
        }
        .padding(.horizontal, 12)

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
