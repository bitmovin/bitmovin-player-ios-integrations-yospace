//
//  BitmovinTruexAdRendererDelegate.swift
//  BitmovinYospaceModule-iOS
//
//  Created by Cory Zachman on 2/14/19.
//

import Foundation
import TruexAdRenderer
import Yospace
import BitmovinPlayer

class BitmovinTruexAdRenderer: NSObject, TruexAdRendererDelegate {
    var truexAdRenderer: TruexAdRenderer?
    weak var bitmovinPlayer: BitmovinYospacePlayer?
    var view: UIView
    var vastConfigUrl: String
    var userId: String

    var adFree = false

    init(bitmovinPlayer: BitmovinYospacePlayer, view: UIView, userId: String = "", vastConfigUrl: String = "") {
        self.bitmovinPlayer = bitmovinPlayer
        self.view = view
        self.userId = userId
        self.vastConfigUrl = vastConfigUrl
    }

    func resetAdRenderer() {
        adFree = false
    }

    func renderTruex(adverts: [Any]) -> Bool {
        guard let truex: YSAdvert = parseTruexAd(adverts) else {
            return false
        }

        guard let trueXUrl: URL = truex.linearCreativeElement().interactiveUnit()?.unitSource() else {
            return false
        }

        let params: [String: String] = generateParams(placementHash: "07d5fe7cc7f9b5ab86112433cf0a83b6fb41b092")
        self.truexAdRenderer = TruexAdRenderer(url: trueXUrl.absoluteString, adParameters: params, slotType: "midroll")
        self.truexAdRenderer?.delegate = self
        self.truexAdRenderer?.start(view)
        return true
    }

    public func onAdCompleted(_ timeSpent: Int) {
        NSLog("Truex onAdCompleted")
        exitTrueXAd()
    }

    public func onAdError(_ errorMessage: String!) {
        NSLog("Truex onAdError \(String(describing: errorMessage))")
        exitTrueXAd()
    }

    public func onNoAdsAvailable() {
        NSLog("Truex onNoAdsAvailable")
        exitTrueXAd()
    }

    func exitTrueXAd() {
        guard let advertisement: Ad = self.bitmovinPlayer?.getActiveAd() else {
            fireAdCompletionEvents()
            return
        }

        self.bitmovinPlayer?.forceSeek(time: advertisement.absoluteEnd+1)
        fireAdCompletionEvents()
        self.bitmovinPlayer?.play()
    }

    func fireAdCompletionEvents() {
        guard let listeners = self.bitmovinPlayer?.listeners else {
            return
        }

        for listener: PlayerListener in listeners {
            listener.onAdFinished?(AdFinishedEvent())
        }

        for listener: PlayerListener in listeners {
            listener.onAdBreakFinished?(AdBreakFinishedEvent())
        }
    }

    public func onAdFreePod() {
        NSLog("Truex onAdFreePod")
        adFree = true
    }

    public func onPopupWebsite(_ url: String!) {
        NSLog("Truex onPopupWebsite \(String(describing: url))")
    }

    public func onAdStarted(_ campaignName: String!) {
        NSLog("Truex onAdStarted \(String(describing: campaignName))")
        self.bitmovinPlayer?.pause()

        let adBreakStartEvent = AdBreakStartedEvent()
        let ad = self.bitmovinPlayer?.getActiveAd()

        let adStartedEvent: YospaceAdStartedEvent = YospaceAdStartedEvent(clickThroughUrl: nil,
                                                            clientType: .unknown, indexInQueue: 0,
                                                            duration: ad?.duration ?? 0,
                                                            timeOffset: ad?.relativeStart ?? 0,
                                                            skipOffset: 1,
                                                            position: "0")
        adStartedEvent.truexAd = true

        guard let listeners = self.bitmovinPlayer?.listeners else {
            return
        }

        for listener: PlayerListener in listeners {
            listener.onAdBreakStarted?(adBreakStartEvent)
        }

        for listener: PlayerListener in listeners {
            listener.onAdStarted?(adStartedEvent)
        }

    }

    func generateParams(placementHash: String) -> [String: String] {
        let params = ["user_id": self.userId,
                      "placement_hash": placementHash,
                      "vast_config_url": self.vastConfigUrl]
        return params
    }

    func parseTruexAd(_ adverts: [Any]) -> YSAdvert? {
        var trueXAd: YSAdvert? = nil
        for advert in adverts {
            guard let ysAdvert: YSAdvert = advert as? YSAdvert else {
                continue
            }

            if ysAdvert.hasLinearInteractiveUnit() {
                trueXAd = ysAdvert
                break
            }
        }
        return trueXAd
    }

}
