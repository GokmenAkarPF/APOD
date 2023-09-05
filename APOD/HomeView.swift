//
//  ContentView.swift
//  APOD
//
//  Created by Gokmen Akar on 5.09.2023.
//

import SwiftUI
import SDWebImageSwiftUI
import Combine

struct HomeView: View {
    @EnvironmentObject var likeManager: LikeManager
    @State private var showDetail: Bool = false
    @State private var url: URL? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(likeManager.models, id: \.date) { apod in
                        APODCard(apod: apod) {
                            likeManager.like(apod: apod)
                        }
                        .onAppear {
                            if apod.date == likeManager.models.last!.date, !likeManager.isFilterActive {
                                Task {
                                    await likeManager.getPhotos()
                                }
                            }
                        }
                        .onTapGesture {
                            url = URL(string: apod.hdurl!)!
                            showDetail = true
                        }
                    }

                    if !likeManager.isFilterActive {
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
                        if likeManager.isFilterActive {
                        Button("Remove Filters") {
                            likeManager.reset()
                        }
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        DatePicker("", selection: $likeManager.date1, in: ...Date(), displayedComponents: .date)
                        DatePicker("", selection: $likeManager.date2, displayedComponents: .date)
                    }
                }
            }
            .task {
                await likeManager.getPhotos()
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
    let completion: () -> ()

    var body: some View {
        VStack(spacing: .zero) {
            // TODO: Image
            WebImage(url: URL(string: apod.url))
                .onSuccess { pImage, data, _ in

                }
                .resizable()
                .indicator(.progress)
                .scaledToFill()
                .frame(height: 220)
                .clipped()
                .overlay(alignment: .topTrailing) {
                    Button {
                        completion()
                    } label: {
                        Image(systemName: apod.isLiked ? "heart.fill" : "heart")
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
