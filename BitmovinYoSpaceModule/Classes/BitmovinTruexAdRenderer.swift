//
//  BitmovinTruexAdRendererDelegate.swift
//  BitmovinYospaceModule-iOS
//
//  Created by Cory Zachman on 2/14/19.
//

import Foundation
import TruexAdRenderer
import Yospace

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

    func renderTruex(adverts: [Any]) {
        guard let truex: YSAdvert = parseTruexAd(adverts) else {
            return
        }

        guard let trueXUrl: URL = truex.linearCreativeElement().interactiveUnit()?.unitSource() else {
            return
        }

        let params: [String: String] = generateParams(placementHash: "07d5fe7cc7f9b5ab86112433cf0a83b6fb41b092")
        self.truexAdRenderer = TruexAdRenderer(url: trueXUrl.absoluteString, adParameters: params, slotType: "midroll")
        self.truexAdRenderer?.delegate = self
        self.truexAdRenderer?.start(view)
    }

    public func onAdCompleted(_ timeSpent: Int) {
        BitmovinLogger.d(message: "Truex onAdCompleted")
        self.bitmovinPlayer?.play()
    }

    public func onAdError(_ errorMessage: String!) {
        NSLog("Truex onAdError \(String(describing: errorMessage))")
        self.bitmovinPlayer?.play()
    }

    public func onNoAdsAvailable() {
        NSLog("Truex onNoAdsAvailable")
        self.bitmovinPlayer?.play()
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
