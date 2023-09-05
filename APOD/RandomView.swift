//
//  RandomView.swift
//  APOD
//
//  Created by Gokmen Akar on 5.09.2023.
//

import SwiftUI
struct RandomView: View {

    @EnvironmentObject var likeManager: LikeManager

    @State private var offset: CGFloat = .zero

    var body: some View {
        NavigationStack {
            VStack(spacing: .zero) {
                if let apod = likeManager.randomApod {
                    APODCard(apod: apod) { likeManager.like(apod: apod) }
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
                                            likeManager.like(apod: apod)
                                            likeManager.randomApod = nil
                                        } else if value.translation.width < -150 {
                                            likeManager.randomApod = nil
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
                            await likeManager.getImage()
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
