//
//  APOD.swift
//  APOD
//
//  Created by Gokmen Akar on 5.09.2023.
//

import Foundation

struct APOD: Codable {
    let id = UUID().uuidString
    let date, explanation: String
    let hdurl: String?
    let mediaType: String?
    let serviceVersion: String?
    let title: String
    let url: String
    let copyright: String?

    enum CodingKeys: String, CodingKey {
        case date, explanation, hdurl
        case mediaType = "media_type"
        case serviceVersion = "service_version"
        case title, url, copyright
    }
}
