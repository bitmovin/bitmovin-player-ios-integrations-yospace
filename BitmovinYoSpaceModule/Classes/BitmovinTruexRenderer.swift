//
//  BitmovinTruexRenderer.swift
//  BitmovinYospaceModule-iOS
//
//  Created by Cory Zachman on 2/14/19.
//

import Foundation
import TruexAdRenderer
import Yospace
import BitmovinPlayer

class BitmovinTruexRenderer: NSObject, TruexAdRendererDelegate {

    private let configuration: TruexConfiguration
    private weak var eventDelegate: TruexAdRendererEventDelegate?
    private var renderer: TruexAdRenderer?
    private var interactiveUnit: YSInteractiveUnit?
    private var adBreakPosition: AdBreakPosition = .preroll
    private var adFree = false
    private var sessionAdFree = false

    init(configuration: TruexConfiguration, eventDelegate: TruexAdRendererEventDelegate? = nil) {
        self.configuration = configuration
        self.eventDelegate = eventDelegate
    }
    
    func renderTruexAd(ad: YSAdvert, adBreakPosition: AdBreakPosition) {
        guard let interactiveUnit = ad.linearCreativeElement().interactiveUnit() else {
            return
        }
        
        guard let unitAdParameters = interactiveUnit.unitAdParameters() else {
            return
        }

        guard var adParams: Dictionary = YospaceUtil.convertToDictionary(text: unitAdParameters) else {
            return
        }
        
        BitLog.d("Rendering TrueX ad: \(interactiveUnit.unitSource())")
        
        self.interactiveUnit = interactiveUnit
        self.adBreakPosition = adBreakPosition

        if !configuration.vastConfigUrl.isEmpty {
            adParams["vast_config_url"] = configuration.vastConfigUrl
        }

        if !configuration.userId.isEmpty {
            adParams["user_id"] = configuration.userId
        }
      
        renderer = TruexAdRenderer(
            url: interactiveUnit.unitSource().absoluteString,
            adParameters: adParams,
            slotType: adBreakPosition.rawValue
        )
        renderer!.delegate = self
        renderer!.start(configuration.view)

        BitLog.d("TrueX rendering completed")
    }
    
    func stopRenderer() {
        // Reset state
        renderer?.stop()
        interactiveUnit = nil
        adBreakPosition = .preroll
        adFree = false
        sessionAdFree = false
    }

    func onAdStarted(_ campaignName: String?) {
        BitLog.d("TrueX ad started: \(campaignName ?? "")")
        
        // Reset ad free
        adFree = false
        
        // Notify YoSpace for ad tracking
        interactiveUnit?.notifyAdStarted()
        interactiveUnit?.notifyAdVideoStarted()
        interactiveUnit?.notifyAdImpression()
    }

    func onAdCompleted(_ timeSpent: Int) {
        BitLog.d("TrueX ad completed with \(timeSpent) seconds spent on engagement")
        
        // Notify YoSpace for ad tracking
        interactiveUnit?.notifyAdVideoComplete()
        interactiveUnit?.notifyAdStopped()
        interactiveUnit?.notifyAdUserClose()
        
        // Skip current ad break if:
        //   1. Preroll ad free has been satisfied
        //   2. Midroll ad free has been satisfied
        if sessionAdFree || adFree {
            eventDelegate?.skipAdBreak()
        } else {
            eventDelegate?.skipTruexAd()
        }
        
        // Reset state
        finishRendering()
    }

    func onAdFreePod() {
        BitLog.d("TrueX ad free")
        
        adFree = true
        
        // We are session ad free if ad free is fired on a preroll
        if !sessionAdFree {
            sessionAdFree = (adBreakPosition == .preroll)
            if sessionAdFree {
                eventDelegate?.sessionAdFree()
            }
        }
    }
    
    func onOpt(in campaignName: String!, adId: Int) {
        BitLog.d("TrueX user opt in: \(campaignName ?? ""), creativeId=\(adId)")
    }
    
    func onOptOut(_ userInitiated: Bool) {
        BitLog.d("TrueX user opt out")
    }
    
    func onSkipCardShown() {
        BitLog.d("TrueX skip card shown")
    }
    
    func onUserCancel() {
        BitLog.d("TrueX user cancelled")
    }

    func onAdError(_ errorMessage: String?) {
        BitLog.e("TrueX ad error: \(errorMessage ?? "")")
        handleError()
    }
    
    func onPopupWebsite(_ url: String!) {
        BitLog.d("TrueX popup website")
    }

    func onNoAdsAvailable() {
        BitLog.d("TrueX no ads available")
        handleError()
    }

    private func handleError() {
        BitLog.d("Handling TrueX error...")
        
        // Treat error state like complete state
        if sessionAdFree {
            // Skip ad break as preroll ad free has been satisfied
            eventDelegate?.skipAdBreak()
        } else {
            // Skip truex ad filler and show linear ads
            eventDelegate?.skipTruexAd()
        }
        
        // Reset state
        finishRendering()
    }
    
    private func finishRendering() {
        renderer?.stop()
        interactiveUnit = nil
    }
}
