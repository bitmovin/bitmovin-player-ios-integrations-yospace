import UIKit
import Yospace
import BitmovinPlayer

extension YSTimedMetadata {
    public static func createFromMetadata (event: MetadataEvent) -> YSTimedMetadata {
        let meta = YSTimedMetadata()
        for entry: MetadataEntry in event.metadata.entries {
            if entry.metadataType == BMPMetadataType.ID3 {
                guard let metadata = entry as? AVMetadataItem else {
                    continue
                }

                guard let key = metadata.key, let data = metadata.dataValue else {
                    continue
                }

                switch key.description {
                case "YPRG":
                    NSLog("Programme metadata - ignoring")
                case "YTYP":
                    if let type  = String(data: data, encoding: String.Encoding.utf8) {
                        meta.type = String(type[type.index(type.startIndex, offsetBy: 1)...])
                    }
                case "YSEQ":
                    if let seq = String(data: data, encoding: String.Encoding.utf8) {
                        meta.setSequenceFrom(String(seq[seq.index(seq.startIndex, offsetBy: 1)...]))
                    }

                case "YMID":
                    if let mediaID = String(data: data, encoding: String.Encoding.utf8) {
                        meta.mediaId = String(mediaID[mediaID.index(mediaID.startIndex, offsetBy: 1)...])
                    }
                case "YDUR":
                    if let offset = String(data: data, encoding: String.Encoding.utf8) {
                        if let offset = Double(String(offset[offset.index(offset.startIndex, offsetBy: 1)...])) {
                            meta.offset = offset
                        }
                    }
                default:
                    continue
                }
            } else if entry.metadataType == BMPMetadataType.daterange {
                guard let metadata = entry as? AVMetadataItem else {
                    continue
                }
                guard let key = metadata.key, let value = metadata.value else {
                    continue
                }

                print("Key: \(key) - \(value)")
                switch key.description {
                case "X-COM-YOSPACE-YMID":
                    print("Case: \(key) - \(value)")
                    // swiftlint:disable force_cast
                    meta.mediaId = value as! String
                default:
                    continue
                }

            }
        }
        return meta
    }
}

class YospaceUtil {
    // swiftlint:disable cyclomatic_complexity
    static func trackingEventString(event: YSETrackingEvent) -> String {
        switch event {
        case .creativeViewEvent:
            return "creativeViewEvent"
        case .acceptInvitationEvent:
            return "acceptInvitationEvent"
        case .acceptInvitationLinearEvent:
            return "acceptInvitationLinearEvent"
        case .clickTrackingEvent:
            return "clickTrackingEvent"
        case .closeEvent:
            return "closeEvent"
        case .closeLinearEvent:
            return "closeLinearEvent"
        case .collapseEvent:
            return "collapseEvent"
        case .completeEvent:
            return "completeEvent"
        case .exitfullscreenEvent:
            return "exitfullscreenEvent"
        case .expandEvent:
            return "expandEvent"
        case .firstQuartileEvent:
            return "firstQuartileEvent"
        case .fullscreenEvent:
            return "fullscreenEvent"
        case .iconClickTrackingEvent:
            return "iconClickTrackingEvent"
        case .iconViewTrackingEvent:
            return "iconViewTrackingEvent"
        case .impressionEvent:
            return "impressionEvent"
        case .midpointEvent:
            return "midpointEvent"
        case .muteEvent:
            return "muteEvent"
        case .generalTrackingEvent:
            return "generalTrackingEvent"
        case .startEvent:
            return "startEvent"
        case .thirdQuartileEvent:
            return "thirdQuartileEvent"
        case .unmuteEvent:
            return "unmuteEvent"
        case .pauseEvent:
            return "pauseEvent"
        case .rewindEvent:
            return "rewindEvent"
        case .resumeEvent:
            return "resumeEvent"
        case .skipEvent:
            return "skipEvent"
        case .progressEvent:
            return "progressEvent"
        case .nonLinearClickTrackingEvent:
            return "nonLinearClickTrackingEvent"
        }
    }
    // swiftlint:enable cyclomatic_complexity

}
