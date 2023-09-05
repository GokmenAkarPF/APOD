//
//  ContentView.swift
//  APOD
//
//  Created by Gokmen Akar on 5.09.2023.
//

import SwiftUI
import SDWebImageSwiftUI
import Combine

class HomeViewModel: ObservableObject {
    @Published var models: [APOD] = []

    var upperDate: Date
    var lowerDate: Date
    @Published var date1: Date = Date()
    @Published var date2: Date = Date()
    @Published var isFilterActive: Bool = false

    var cancellable = Set<AnyCancellable>()

    init() {
        upperDate = Date()
        lowerDate = Calendar.current.date(byAdding: .day, value: -10, to: Date())!
        bindDates()
    }

    func reset() {

        models = []
        date1 = Date()
        date2 = Date()
        upperDate = Date()
        lowerDate = Calendar.current.date(byAdding: .day, value: -10, to: Date())!
        isFilterActive = false

        Task {
            await getPhotos()
        }
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

    func bindDates() {
        $date1
            .dropFirst()
            .combineLatest($date2)
            .filter { _ in
                !self.isFilterActive
            }
            .sink { val in
                self.isFilterActive = true 
                self.models = []
                self.lowerDate = val.0
                self.upperDate = val.1
                Task {
                    await self.getPhotos()
                }
            }
            .store(in: &cancellable)
    }
}

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel = .init()

    @State private var showDetail: Bool = false
    @State private var url: URL? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.models, id: \.id) { apod in
                            APODCard(apod: apod)
                                .onAppear {
                                    if apod.id == viewModel.models.last!.id, !viewModel.isFilterActive {
                                        Task {
                                            await viewModel.getPhotos()
                                        }
                                    }
                                }
                                .onTapGesture {
                                    url = URL(string: apod.hdurl!)!
                                    showDetail = true
                                }
                    }

                    if !viewModel.isFilterActive {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .frame(height: 120)
                    }
                }

                NavigationLink("",
                               destination: HighResolutionImage(url: url),
                               isActive: $showDetail)
            }
            .navigationTitle("Home")
            .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        if viewModel.isFilterActive {
                        Button("Remove Filters") {
                            viewModel.reset()
                        }
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        DatePicker("", selection: $viewModel.date1, in: ...Date(), displayedComponents: .date)
                        DatePicker("", selection: $viewModel.date2, displayedComponents: .date)
                    }
                }
            }
            .task {
                await viewModel.getPhotos()
            }
        }
    }
}

struct HighResolutionImage: View {
    let url: URL?

    @State private var scale: CGFloat = 1.0
    var body: some View {
            WebImage(url: url)
                .resizable()
                .indicator(.progress)
                .scaledToFit()
                .scaleEffect(scale)
                .frame(height: 230)
                .gesture(
                    MagnificationGesture().onChanged { scale in
                        self.scale = min(max(scale.magnitude, 0.8), 3.0)
                    }
                )
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
                .indicator(.progress)
                .scaledToFill()
                .clipped()
                .overlay(alignment: .topTrailing) {
                    Button {

                    } label: {
                        Image(systemName: "heart")
                            .resizable()
                            .frame(width: 28, height: 24)
                            .foregroundColor(.red)
                            .padding([.top, .trailing])
                    }
                }

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
