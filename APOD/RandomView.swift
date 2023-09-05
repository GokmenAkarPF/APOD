//
//  RandomView.swift
//  APOD
//
//  Created by Gokmen Akar on 5.09.2023.
//

import SwiftUI

class RandomViewModel: ObservableObject {

    @Published var apod: APOD? = nil

    @MainActor func getImage() async {
        do {
            let (data, _) = try await URLSession.shared.data(from: URL(string: "https://api.nasa.gov/planetary/apod?api_key=WBd6KIwrJohInTFEi1XSZA7ERws6opS3KLm2XhSH&count=1")!)
            apod = try JSONDecoder().decode([APOD].self, from: data).first
        } catch {
            print(error.localizedDescription)
        }
    }

    func like() {
        self.apod!.isLiked = !self.apod!.isLiked

        do {
            if let modelsData = UserDefaults.standard.data(forKey: "likes") {
                var modelss = try JSONDecoder().decode([APOD].self, from: modelsData)
                if modelss.contains(where: { self.apod!.date == $0.date }) {
                    modelss.removeAll { self.apod!.date == $0.date }
                } else {
                    modelss.append(apod!)
                }
                let modelData = try JSONEncoder().encode(modelss)
                UserDefaults.standard.set(modelData, forKey: "likes")
            } else {
                let modelData = try JSONEncoder().encode([apod])
                UserDefaults.standard.set(modelData, forKey: "likes")

            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct RandomView: View {

    @StateObject private var viewModel: RandomViewModel = .init()

    @State private var offset: CGFloat = .zero

    var body: some View {
        NavigationStack {
            VStack(spacing: .zero) {
                if let apod = viewModel.apod {
                    APODCard(apod: apod) {
                        viewModel.like()
                    }
                        .overlay {
                            if offset == .zero {
                                EmptyView()
                            } else {
                                choiceView(forRight: offset > .zero)
                            }
                        }
                        .offset(x: offset)
                        .rotationEffect(.degrees(Double(offset / 40)))
                        .frame(height: 320)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    offset = value.translation.width
                                }
                                .onEnded { value in
                                    withAnimation {
                                        if value.translation.width > 150 {
                                            viewModel.apod = nil
                                        } else if value.translation.width < -150 {
                                            viewModel.apod = nil
                                        }
                                        offset = .zero
                                    }
                                }
                        )
                        .animation(.easeInOut, value: offset)
                        .padding(16)

                } else {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .task {
                            await viewModel.getImage()
                        }
                }
            }
        }
    }

    func choiceView(forRight: Bool) -> some View {
        HStack {
            if forRight {
                RoundedRectangle(cornerRadius: 12).hidden()
            }

            RoundedRectangle(cornerRadius: 12)
                .stroke(forRight ? .green : .red, lineWidth: 4.0)
                .background(forRight ? Color.green.opacity(0.5) : Color.red.opacity(0.5))
                .overlay {
                    Image(systemName: forRight ? "checkmark.circle.fill" : "x.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .foregroundColor(forRight ? .green : .red)
                }

            if !forRight {
                RoundedRectangle(cornerRadius: 12).hidden()
            }
        }

    }
}



struct RandomView_Previews: PreviewProvider {
    static var previews: some View {
        RandomView()
    }
}
