import BitmovinPlayerCore
import UIKit
import YOAdManagement

public extension YOTimedMetadata {
    static func createFromMetadata(event: MetadataEvent) -> YOTimedMetadata? {
        var (ntype, nseq, nmediaId) = ("", "", "")
        var noffset = 0.0
        for entry: MetadataEntry in event.metadata.entries where entry.metadataType == MetadataType.ID3 {
            guard let metadata = entry as? AVMetadataItem else {
                continue
            }

            guard let key = metadata.key, let data = metadata.dataValue else {
                continue
            }

            switch key.description {
            case "YPRG":
                BitLog.d("Programme metadata - ignoring")
            case "YTYP":
                if let type = String(data: data, encoding: String.Encoding.utf8) {
                    ntype = String(type[type.index(type.startIndex, offsetBy: 1)...])
                }
            case "YSEQ":
                if let seq = String(data: data, encoding: String.Encoding.utf8) {
                    nseq = String(seq[seq.index(seq.startIndex, offsetBy: 1)...])
                }

            case "YMID":
                if let mediaID = String(data: data, encoding: String.Encoding.utf8) {
                    nmediaId = String(mediaID[mediaID.index(mediaID.startIndex, offsetBy: 1)...])
                }
            case "YDUR":
                if let offset = String(data: data, encoding: String.Encoding.utf8) {
                    if let offset = Double(String(offset[offset.index(offset.startIndex, offsetBy: 1)...])) {
                        noffset = offset
                    }
                }
            default:
                continue
            }
        }
        let meta = YOTimedMetadata.create(withMediaId: nmediaId, sequence: nseq, type: ntype, offset: noffset.description, playhead: event.timestamp)

        return meta
    }
}

enum YospaceUtil {
    static func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}
