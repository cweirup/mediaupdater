//
//  ShowResponse.swift
//  mediaupdater
//
//  Created by Chris Weirup on 1/21/21.
//

import Foundation

struct ShowResponse: Decodable {
    let score: Double
    let show: ShowInfo
}
