//
//  RandomView.swift
//  APOD
//
//  Created by Gokmen Akar on 5.09.2023.
//

import SwiftUI

class RandomViewModel: ObservableObject {

    @Published var apod: APOD? = nil

    func getImage() async {
        do {
            let (data, _) = try await URLSession.shared.data(from: URL(string: "https://api.nasa.gov/planetary/apod?api_key=WBd6KIwrJohInTFEi1XSZA7ERws6opS3KLm2XhSH&count=1")!)

            apod = try JSONDecoder().decode(APOD.self, from: data)
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct RandomView: View {

    @StateObject private var viewModel: RandomViewModel = .init()

    var body: some View {
        if let apod = viewModel.apod {
            APODCard(apod: apod)
        } else {
            ProgressView()
                .progressViewStyle(.circular)
                .task {
                    await viewModel.getImage()
                }
        }
    }
}



struct RandomView_Previews: PreviewProvider {
    static var previews: some View {
        RandomView()
    }
}
