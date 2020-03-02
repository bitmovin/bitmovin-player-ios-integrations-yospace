//
//  FairplayConfiguration+Perpare.swift
//  Tub_Example
//
//  Created by aneurinc on 2/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import BitmovinPlayer

extension FairplayConfiguration {
    public func prepare() {
        prepareCertificate = { (data: Data) -> Data in
            guard let certString = String(data: data, encoding: .utf8),
                let certResult = Data(base64Encoded: certString.replacingOccurrences(of: "\"", with: "")) else {
                    return data
            }
            return certResult
        }
        prepareContentId = { (contentId: String) -> String in
            let prepared = contentId.replacingOccurrences(of: "skd://", with: "")
            let components: [String] = prepared.components(separatedBy: "/")
            return components[2]
        }
        prepareMessage = { (spcData: Data, assetID: String) -> Data in
            return spcData
        }
        prepareLicense = { (ckcData: Data) -> Data in
            guard let ckcString = String(data: ckcData, encoding: .utf8),
                let ckcResult = Data(base64Encoded: ckcString.replacingOccurrences(of: "\"", with: "")) else {
                    return ckcData
            }
            return ckcResult
        }
    }
}
