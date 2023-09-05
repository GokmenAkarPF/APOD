//
//  NetworkManager.swift
//  APOD
//
//  Created by Gokmen Akar on 6.09.2023.
//

import Foundation
import Network

class NetworkManager: ObservableObject {
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "NetworkManager")

    @Published var isConnected = true
    @Published var isConnectedChanged = false

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnectedChanged = path.status == .satisfied
                if self?.isConnected != (path.status == .satisfied) {
                    self?.isConnected = path.status == .satisfied
                }
            }
        }
        monitor.start(queue: queue)
    }
}
