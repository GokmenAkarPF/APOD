//
//  APOD.swift
//  APOD
//
//  Created by Gokmen Akar on 5.09.2023.
//

import Foundation

struct APOD: Codable {
    var id = UUID().uuidString
    var date, explanation: String
    var hdurl: String?
    var mediaType: String?
    var serviceVersion: String?
    var title: String
    var url: String
    var copyright: String?
    var isLiked: Bool = false

    enum CodingKeys: String, CodingKey {
        case date, explanation, hdurl
        case mediaType = "media_type"
        case serviceVersion = "service_version"
        case title, url, copyright
    }
}
