import BitmovinPlayerCore

class BitmovinAdsApiProxy: AdvertisingApi {
    private weak var yospacePlayer: BitmovinYospacePlayer?

    var schedule: [AdBreak] {
        yospacePlayer?.timeline?.adBreaks ?? []
    }

    init(yospacePlayer: BitmovinYospacePlayer) {
        self.yospacePlayer = yospacePlayer
    }

    func skip() {
        guard let yospacePlayer, let activeAdBreak = yospacePlayer.activeAdBreak else {
            return
        }

        yospacePlayer.player.seek(time: activeAdBreak.absoluteEnd)
    }

    func schedule(adItem: AdItem) {
        BitLog.w("Scheduling client side Ads is not supported!")
    }

    func register(adContainer: UIView) {
        BitLog.w("Registering a separate AdContainer is not supported!")
    }
}
