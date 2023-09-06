//
//  ContentView.swift
//  APOD
//
//  Created by Gokmen Akar on 5.09.2023.
//

import SwiftUI
import SDWebImageSwiftUI

struct HomeView: View {
    @EnvironmentObject var apodManager: APODManager
    @State private var showDetail: Bool = false
    @State private var url: URL? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                if apodManager.showError {
                    Text("Error occured 🛩️💥")
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(apodManager.models, id: \.date) { apod in
                            APODCard(apod: apod) {
                                apodManager.like(apod: apod)
                            }
                            .onAppear {
                                if apod.date == apodManager.models.last!.date, !apodManager.isFilterActive {
                                    Task {
                                        await apodManager.getPhotos()
                                    }
                                }
                            }
                            .onTapGesture {
                                url = URL(string: apod.hdurl!)!
                                showDetail = true
                            }
                        }

                        if !apodManager.isFilterActive {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .frame(height: 120)
                        }
                    }

                    NavigationLink("",
                                   destination: HighResolutionImage(url: url),
                                   isActive: $showDetail)
                }
            }
            .navigationTitle("Home")
            .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        if apodManager.isFilterActive {
                        Button("Remove Filters") {
                            apodManager.reset()
                        }
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        DatePicker("", selection: $apodManager.date1, in: ...Date(), displayedComponents: .date)
                        DatePicker("", selection: $apodManager.date2, displayedComponents: .date)
                    }
                }
            }
            .task {
                await apodManager.getPhotos()
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

    @State private var selectedModel: APOD?

    var body: some View {
        VStack(spacing: .zero) {
            // TODO: Image
            WebImage(url: URL(string: apod.url))
                .resizable()
                .placeholder(content: {
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(.gray)
                        .overlay {
                            Text("No Image")
                                .foregroundColor(.white)
                        }
                })
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
                .contextMenu {
                    Button("Share") {
                        selectedModel = self.apod
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
        .sheet(item: $selectedModel) { item in
            ShareSheetView(activityItems: [item.title + "\n" + item.explanation + "\n" + item.url])
        }

    }




}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
