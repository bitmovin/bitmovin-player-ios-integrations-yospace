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
        self.truexAdRenderer?.stop()
    }

    func renderTruex(adverts: [Any]) -> Bool {
        guard let truex: YSAdvert = parseTruexAd(adverts) else {
            return false
        }

        guard let trueXUrl: URL = truex.linearCreativeElement().interactiveUnit()?.unitSource() else {
            return false
        }

        guard let unitAdParameters: String = truex.linearCreativeElement().interactiveUnit()?.unitAdParameters() else {
            return false
        }

        guard var adParameters: Dictionary = YospaceUtil.convertToDictionary(text: unitAdParameters) else {
            return false
        }

        if !self.vastConfigUrl.isEmpty {
            adParameters["vast_config_url"] = self.vastConfigUrl
        }

        if !self.userId.isEmpty {
            adParameters["user_id"] = self.vastConfigUrl
        }

        self.truexAdRenderer = TruexAdRenderer(url: trueXUrl.absoluteString, adParameters: adParameters, slotType: "midroll")
        self.truexAdRenderer?.delegate = self
        self.truexAdRenderer?.start(view)
        return true
    }

    public func onAdCompleted(_ timeSpent: Int) {
        BitLog.d("Truex onAdCompleted")
        exitTrueXAd()
    }

    public func onAdError(_ errorMessage: String!) {
        BitLog.e("Truex onAdError \(String(describing: errorMessage))")
        exitTrueXAd()
    }

    public func onNoAdsAvailable() {
        BitLog.d("Truex onNoAdsAvailable")
        exitTrueXAd()
    }

    func exitTrueXAd() {
        fireAdFinished()
        self.bitmovinPlayer?.trueXRendering = false
        self.bitmovinPlayer?.play()

        if !adFree {
            guard let advertisement = self.bitmovinPlayer?.getActiveAd() else {
                return
            }
            let adStartedEvent: YospaceAdStartedEvent = YospaceAdStartedEvent(clickThroughUrl: advertisement.clickThroughUrl,
                                                                              clientType: .unknown, indexInQueue: 0,
                                                                              duration: advertisement.duration,
                                                                              timeOffset: advertisement.relativeStart,
                                                                              skipOffset: 1,
                                                                              position: "0")
            fireAdStarted(adStartedEvent)
        }
    }

    public func onAdFreePod() {
        BitLog.d("Truex onAdFreePod")
        adFree = true
        guard let adBreak: AdBreak = self.bitmovinPlayer?.getActiveAdBreak() else {
            return
        }
        self.bitmovinPlayer?.forceSeek(time: adBreak.absoluteEnd+1)

        if adBreak.absoluteStart == 0 {
            BitLog.d("TrueX adFree granted on preroll, firing adFree listener")
            self.bitmovinPlayer?.handleTrueXAdFree()
        }

    }

    public func onPopupWebsite(_ url: String!) {
       BitLog.d("Truex onPopupWebsite \(String(describing: url))")
    }

    public func onAdStarted(_ campaignName: String!) {
        BitLog.d("Truex onAdStarted \(String(describing: campaignName))")
        self.bitmovinPlayer?.pause()
        let adBreakStartEvent = AdBreakStartedEvent()
        let advertisement = self.bitmovinPlayer?.getActiveAd()
        let adStartedEvent: YospaceAdStartedEvent = YospaceAdStartedEvent(clickThroughUrl: nil,
                                                            clientType: .unknown, indexInQueue: 0,
                                                            duration: advertisement?.duration ?? 0,
                                                            timeOffset: advertisement?.relativeStart ?? 0,
                                                            skipOffset: 1,
                                                            position: "0")
        adStartedEvent.truexAd = true
        fireAdBreakStarted(adBreakStartEvent)
        fireAdStarted(adStartedEvent)

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

    private func fireAdStarted(_ adStartedEvent: AdStartedEvent) {
        guard let listeners = self.bitmovinPlayer?.listeners else {
            return
        }

        for listener: PlayerListener in listeners {
            listener.onAdStarted?(adStartedEvent)
        }

        bitmovinPlayer?.adPlaying = true
    }

    private func fireAdBreakStarted(_ adBreakStartedEvent: AdBreakStartedEvent) {
        guard let listeners = self.bitmovinPlayer?.listeners else {
            return
        }

        for listener: PlayerListener in listeners {
            listener.onAdBreakStarted?(adBreakStartedEvent)
        }
    }

    func fireAdFinished() {
        guard let listeners = self.bitmovinPlayer?.listeners else {
            return
        }

        for listener: PlayerListener in listeners {
            listener.onAdFinished?(AdFinishedEvent())
        }
    }

}
