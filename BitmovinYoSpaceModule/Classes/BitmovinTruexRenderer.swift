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

class BitmovinTruexRenderer: NSObject, TruexAdRendererDelegate {
    private var renderer: TruexAdRenderer?
    private weak var rendererDelegate: BitmovinTruexRendererDelegate?
    private let configuration: TruexConfiguration
    private var interactiveUnit: YSInteractiveUnit?

    init(configuration: TruexConfiguration, rendererDelegate: BitmovinTruexRendererDelegate? = nil) {
        self.configuration = configuration
        self.rendererDelegate = rendererDelegate
    }

    func stop() {
        renderer?.stop()
        interactiveUnit = nil
    }

    func renderAd(advert: YSAdvert) {
        BitLog.d("TrueX - rendering ad: \(advert)")
        interactiveUnit = advert.linearCreativeElement().interactiveUnit()

        guard let truexUrl: String = interactiveUnit?.unitSource().absoluteString else {
            return
        }

        guard let unitAdParameters: String = interactiveUnit?.unitAdParameters() else {
            return
        }

        guard var adParameters: Dictionary = YospaceUtil.convertToDictionary(text: unitAdParameters) else {
            return
        }

        if !configuration.vastConfigUrl.isEmpty {
            adParameters["vast_config_url"] = configuration.vastConfigUrl
        }

        if !configuration.userId.isEmpty {
            adParameters["user_id"] = configuration.vastConfigUrl
        }

        renderer = TruexAdRenderer(url: truexUrl, adParameters: adParameters, slotType: "midroll")
        renderer?.delegate = self
        renderer?.start(configuration.view)

        BitLog.d("TrueX - ad rendering completed")
    }

    public func onAdStarted(_ campaignName: String!) {
        BitLog.d("TrueX - ad started: \(campaignName ?? "")")
        interactiveUnit?.notifyAdStarted()
        interactiveUnit?.notifyAdVideoStarted()
        interactiveUnit?.notifyAdImpression()
    }

    public func onAdCompleted(_ timeSpent: Int) {
        BitLog.d("TrueX - ad completed: \(timeSpent) seconds spent on engagement")
        interactiveUnit?.notifyAdVideoComplete()
        interactiveUnit?.notifyAdStopped()
        interactiveUnit?.notifyAdUserClose()
        rendererDelegate?.truexAdComplete()
        stop()
    }

    public func onAdFreePod() {
        BitLog.d("TrueX - ad free")
        rendererDelegate?.truexAdFree()
    }

    public func onAdError(_ errorMessage: String!) {
        BitLog.e("TrueX - ad error: error_message=\(errorMessage ?? "N/A")")
        interactiveUnit?.notifyAdStopped()
        rendererDelegate?.truexAdError()
        stop()
    }

    public func onNoAdsAvailable() {
        BitLog.d("TrueX - no ads available")
        rendererDelegate?.truexNoAds()
        stop()
    }

    public func onPopupWebsite(_ url: String!) {
        BitLog.d("TrueX - popup website: url=\(url ?? "N/A")")
    }
}
