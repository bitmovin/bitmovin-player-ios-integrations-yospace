//
//  Stream.swift
//  BitmovinYospaceModule_Example
//
//  Created by aneurinc on 4/14/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import BitmovinYospaceModule

struct Stream {
    var title: String
    var contentUrl: String
    var fairplayLicenseUrl: String?
    var fairplayCertUrl: String?
    var drmHeader: String?
    var yospaceSourceConfig: YospaceSourceConfiguration?
}

let streams = [
    Stream(
        title: "Metadata fix",
        contentUrl: "https://csm-e-cetuusexaws208j8-6lppcszb2ede.bln1.yospace.com/csm/extlive/turner01,timed-tbseast-cbcs.m3u8?yo.pst=true&yo.av=2&yo.pdt=true&yo.t.jt=1000&yo.me=true&yo.ap=https://vod-media-aka.warnermediacdn.com&yo.po=-4&yo.up=https://live-media-aka.warnermediacdn.com&yo.asd=true&yo.pdt=true&yo.dr=true&_fw_ae=53da17a30bd0d3c946a41c86cb5873f1&_fw_ar=1&afid=180483280&conf_csid=tbs.com_desktop_live_east&nw=42448&prof=48804:tbs_ios_live",
        fairplayLicenseUrl: "https://fairplay.license.istreamplanet.com/api/license/de4c1d30-ac22-4669-8824-19ba9a1dc128",
        fairplayCertUrl: "https://fairplay.license.istreamplanet.com/api/AppCert/de4c1d30-ac22-4669-8824-19ba9a1dc128",
        drmHeader: "eyJ2ZXIiOjEsInR5cCI6IkpXVCIsImVuYyI6IkExMjhHQ00ifQ._Y3KGenESJE86od8bU5R0w.QxjBP2BQ9LPDwHKs839wikSGAzZXoSivLVMC_z4o_ONF2PlbKZQ0xTF46m7mNBj2Ps7q53tT_cmNqvJV8SXwoeVDUwpUOt5aiRsVGBDX8760SPwBpEKqVM9N5OFZOPIi8jTuVmh04cfVLzLOdvesEa_00A4OmIJ1jFryDX_qobdLmmiR8ILvAiKHOutTQSI00sRdE86Z4xJsmfAY3yeShWQiFJVRuKyMTDuAwfzCWOOcTqYwPCYiAyt9w_woO8OdiygHeQ.1BRXjxq4OHcxsgjbqCbt9g"
    ),
    Stream(
        title: "MML live",
        contentUrl: "https://live-manifests-att-qa.warnermediacdn.com/csmp/cmaf/live/2018448/mml000-cbcs/master_fp_ph.m3u8?_fw_ae=%5Bfw_ae%5D&_fw_ar=%5B_fw_ar%5D&_fw_did=%5B_fw_did%5D&_fw_is_lat=%5B_fw_is_lat%5D&_fw_nielsen_app_id=P923E8EA9-9B1B-4F15-A180-F5A4FD01FE38&_fw_us_privacy=%5B_fw_us_privacy%5D&_fw_vcid2=%5B_fw_vcid2%5D&afid=180494037&caid=hylda_beta_test_asset&conf_csid=ncaa.com_mml_iphone&nw=42448&playername=top-2.1.2&prct=text%252Fhtml_doc_lit_mobile%252Ctext%252Fhtml_doc_ref&prof=48804%3Amml_ios_live&yo.asd=true&yo.dnt=false&yo.pst=true",
        fairplayLicenseUrl: "https://fairplay.license.istreamplanet.com/api/license/e892c6cc-2f78-4a9f-beae-556a36167bb1",
        fairplayCertUrl: "https://fairplay.license.istreamplanet.com/api/AppCert/e892c6cc-2f78-4a9f-beae-556a36167bb1",
        drmHeader: "eyJ2ZXIiOjEsInR5cCI6IkpXVCIsImVuYyI6IkExMjhHQ00ifQ.hcU9wETKG96GJKUW5Vb7mQ.JeEpL1BSu85sEOvLi72fLAibF58_uk01pdwbghvtzfTnh4HG88mB7GHEqTYz--kWgBeL0gfIapqENku2P8eSOAeDWculu85dOdHDGbZKZS_m4Ut_4B18cE362R_U6rVz1J9uDPL4TCvniO6I-pv8xwHdIdYxmkk4R9sz5mvASlWtqSa4EwNp5cSrmPXxFHvRLdNmxzA2WNxzqI-S3t1KXxgy5wBQj2nxCVcJrrRFgFoIiZJgJqXyaA.5CeKW7zibMN4iqCqGkZcug",
        yospaceSourceConfig: .init(yospaceAssetType: .linear)
    ),
    Stream(
        title: "MML live - Safari",
        contentUrl: "https://live-manifests-aka-qa.warnermediacdn.com/csmp/cmaf/live/2018448/mml000-cbcs/master_fp_de.m3u8?_fw_ae=&_fw_ar=&_fw_did=&_fw_is_lat=&_fw_nielsen_app_id=P923E8EA9-9B1B-4F15-A180-F5A4FD01FE38&_fw_us_privacy=&_fw_vcid2=&afid=180494037&caid=hylda_beta_test_asset&conf_csid=ncaa.com_mml_iphone&nw=42448&playername=top-2.1.2&prct=text%2Fhtml_doc_lit_mobile%2Ctext%2Fhtml_doc_ref&prof=48804:mml_ios_live&yo.asd=true&yo.dnt=false&yo.pst=true&yo.dr=true&yo.ad=true",
        fairplayLicenseUrl: "https://fairplay.license.istreamplanet.com/api/license/e892c6cc-2f78-4a9f-beae-556a36167bb1",
        fairplayCertUrl: "https://fairplay.license.istreamplanet.com/api/AppCert/e892c6cc-2f78-4a9f-beae-556a36167bb1",
        drmHeader: "eyJ2ZXIiOjEsInR5cCI6IkpXVCIsImVuYyI6IkExMjhHQ00ifQ.hcU9wETKG96GJKUW5Vb7mQ.JeEpL1BSu85sEOvLi72fLAibF58_uk01pdwbghvtzfTnh4HG88mB7GHEqTYz--kWgBeL0gfIapqENku2P8eSOAeDWculu85dOdHDGbZKZS_m4Ut_4B18cE362R_U6rVz1J9uDPL4TCvniO6I-pv8xwHdIdYxmkk4R9sz5mvASlWtqSa4EwNp5cSrmPXxFHvRLdNmxzA2WNxzqI-S3t1KXxgy5wBQj2nxCVcJrrRFgFoIiZJgJqXyaA.5CeKW7zibMN4iqCqGkZcug",
        yospaceSourceConfig: .init(yospaceAssetType: .linear)
    ),
    Stream(
        title: "MML live - no ads",
        contentUrl: "https://mml-live-media-aka-qa.warnermediacdn.com/cmaf/live/2018448/mml000-cbcs/master_fp_de.m3u8",
        fairplayLicenseUrl: "https://fairplay.license.istreamplanet.com/api/license/e892c6cc-2f78-4a9f-beae-556a36167bb1",
        fairplayCertUrl: "https://fairplay.license.istreamplanet.com/api/AppCert/e892c6cc-2f78-4a9f-beae-556a36167bb1",
        drmHeader: "eyJ2ZXIiOjEsInR5cCI6IkpXVCIsImVuYyI6IkExMjhHQ00ifQ.hcU9wETKG96GJKUW5Vb7mQ.JeEpL1BSu85sEOvLi72fLAibF58_uk01pdwbghvtzfTnh4HG88mB7GHEqTYz--kWgBeL0gfIapqENku2P8eSOAeDWculu85dOdHDGbZKZS_m4Ut_4B18cE362R_U6rVz1J9uDPL4TCvniO6I-pv8xwHdIdYxmkk4R9sz5mvASlWtqSa4EwNp5cSrmPXxFHvRLdNmxzA2WNxzqI-S3t1KXxgy5wBQj2nxCVcJrrRFgFoIiZJgJqXyaA.5CeKW7zibMN4iqCqGkZcug"
    ),
    Stream(
        title: "Montage FP",
        contentUrl: "https://live-montage-aka-qa.warnermediacdn.com/int/manifest/me-drm-cbcs/master_de.m3u8",
        fairplayLicenseUrl: "https://fairplay.license.istreamplanet.com/api/license/a229afbf-e1d3-499e-8127-c33cd7231e58",
        fairplayCertUrl: "https://fairplay.license.istreamplanet.com/api/AppCert/a229afbf-e1d3-499e-8127-c33cd7231e58"
    ),
    Stream(
        title: "Bones",
        contentUrl: "https://vod-manifests-aka-qa.warnermediacdn.com/csm/tcm/clear/3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c/master_cl.m3u8?afid=222591187&caid=2100555&conf_csid=tbs.com_mobile_iphone&context=182883174&nw=42448&prof=48804%3Aturner_ssai&vdur=1800&yo.vp=true&yo.av=2",
        yospaceSourceConfig: .init(yospaceAssetType: .vod)
    )
]
