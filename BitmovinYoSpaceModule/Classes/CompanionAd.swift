//
//  CompanionAd.swift
//  Pods
//
//  Created by aneurinc on 10/29/20.
//

import Foundation

public struct CompanionAd {
    let id: String?
    let width: Int?
    let height: Int?
    let source: String?
    
    var debugDescription: String {
        return "id=\(id), width=\(width), height=\(height), source=\(source)"
    }
}
