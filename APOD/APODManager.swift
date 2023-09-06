//
//  APODManager.swift
//  APOD
//
//  Created by Gokmen Akar on 6.09.2023.
//

import Foundation
import Combine

class APODManager: ObservableObject {

    var upperDate: Date
    var lowerDate: Date
    @Published var date1: Date = Date()
    @Published var date2: Date = Date()
    @Published var isFilterActive: Bool = false
    @Published var isConnected: Bool = false

    @Published var randomApod: APOD? = nil
    @Published var models: [APOD] = []
    @Published var likedModels: [APOD] = []
    var cancellable = Set<AnyCancellable>()
    var networkManager = NetworkManager()

    init() {
        upperDate = Date()
        lowerDate = Calendar.current.date(byAdding: .day, value: -10, to: Date())!
        bindDates()
        bindFavorites()
        bindNetworkConnection()
        getModels()
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

    func getModels() {
        if let likesData = UserDefaults.standard.data(forKey: "likes") {
            do {
                let models = try JSONDecoder().decode([APOD].self, from: likesData)

                self.likedModels = models.map { apod in
                    var _apod = apod
                    _apod.isLiked = true
                    return _apod
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func like(apod: APOD) {
        if let index = models.firstIndex(where: { $0.date == apod.date }) {
            models[index].isLiked = !models[index].isLiked
        }

        do {
            if let modelsData = UserDefaults.standard.data(forKey: "likes") {
                var modelss = try JSONDecoder().decode([APOD].self, from: modelsData)
                if modelss.contains(where: { apod.date == $0.date }) {
                    modelss.removeAll { apod.date == $0.date }
                } else {
                    modelss.append(apod)
                }

                likedModels = modelss.map({ apod in
                    var _apod = apod
                    _apod.isLiked = true
                    return _apod
                })
                let modelData = try JSONEncoder().encode(modelss)
                UserDefaults.standard.set(modelData, forKey: "likes")
            } else {
                var likedAPOD = apod
                likedAPOD.isLiked = true
                let modelData = try JSONEncoder().encode([likedAPOD])
                likedModels = [likedAPOD]
                UserDefaults.standard.set(modelData, forKey: "likes")
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    func bindFavorites() {
        $likedModels
            .sink { likes  in
                self.models = self.models.map { apod in
                    var _apod = apod
                    _apod.isLiked = likes.contains { apod.date == $0.date }
                    return _apod
                }
            }
            .store(in: &cancellable)
    }

    private func bindNetworkConnection() {
        networkManager.$isConnectedChanged
            .sink { isConnected in
                self.isConnected = isConnected
                if !isConnected {
                    if let cachedData = UserDefaults.standard.data(forKey: "cachedData") {
                        do {
                            let cachedModels = try JSONDecoder().decode([APOD].self, from: cachedData)
                            self.models = cachedModels.map { apod in
                                var _apod = apod
                                _apod.isLiked = self.likedModels.contains { $0.date == apod.date }
                                return _apod
                            }

                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }.store(in: &cancellable)
    }

    func unliked(apod: APOD) {
        likedModels.removeAll { apod.date == $0.date }
        let modelData = try! JSONEncoder().encode(likedModels)
        UserDefaults.standard.set(modelData, forKey: "likes")
    }

    @MainActor func getPhotos() async {
        let upperBoundString = upperDate.formatted(.iso8601).description.split(separator: "T").first!.description
        let lowerBoundString = lowerDate.formatted(.iso8601).description.split(separator: "T").first!.description

        do {
            let (data, _) = try await URLSession.shared.data(from: URL(string: "https://api.nasa.gov/planetary/apod?api_key=WBd6KIwrJohInTFEi1XSZA7ERws6opS3KLm2XhSH&start_date=\(lowerBoundString)&end_date=\(upperBoundString)")!)
            var modelss = try JSONDecoder().decode([APOD].self, from: data)

            if let likedData = UserDefaults.standard.data(forKey: "likes") {
                let likedModels = try JSONDecoder().decode([APOD].self, from: likedData)

                modelss = modelss.map { apod in
                    var _apod = apod
                    _apod.isLiked = likedModels.contains { apod.date == $0.date }
                    return _apod
                }
            }

            models += modelss

            let cacheData = try JSONEncoder().encode(models)
            UserDefaults.standard.set(cacheData, forKey: "cachedData")

            upperDate = lowerDate
            lowerDate = Calendar.current.date(byAdding: .day, value: -19, to: lowerDate)!
        } catch {
            print(error.localizedDescription)
        }
    }

    @MainActor func getImage() async {
        do {
            let (data, _) = try await URLSession.shared.data(from: URL(string: "https://api.nasa.gov/planetary/apod?api_key=WBd6KIwrJohInTFEi1XSZA7ERws6opS3KLm2XhSH&count=1")!)
            randomApod = try JSONDecoder().decode([APOD].self, from: data).first
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
