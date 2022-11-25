//
//  YospaceId3MetadataEntry.swift
//  Pods
//
//  Created by aneurinc on 11/23/20.
//

import BitmovinPlayer

public class YospaceId3MetadataEntry: NSObject, MetadataEntry {
    public var metadataType: MetadataType
    public let mediaId: String
    public let type: String
    public let segmentCount: Int
    public let segmentNumber: Int
    public let offset: Double
    public let timestamp: Date

    public init(mediaId: String, type: String, segmentCount: Int, segmentNumber: Int, offset: Double, timestamp: Date) {
        self.metadataType = .ID3
        self.mediaId = mediaId
        self.type = type
        self.segmentCount = segmentCount
        self.segmentNumber = segmentNumber
        self.offset = offset
        self.timestamp = timestamp
    }

    public override var debugDescription: String {
        return "mediaId=\(mediaId), type=\(type), segmentCount=\(segmentCount), segmentNumber=\(segmentNumber), offset=\(String(format: "%.1f", offset)), timestamp=\(timestamp)"
    }
}
