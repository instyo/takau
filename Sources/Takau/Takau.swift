// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import GoogleMobileAds
import SwiftUI

@available(iOS 14.0, *)
public class Takau: NSObject, ObservableObject {
    @MainActor static let shared = Takau()
    
    private var interstitialManager: InterstitialAdsManager?
    private var bannerAdView: BannerAdView?
    private var proService: ProService?
    
    public var bannerAdId: String?
    public var interstitialAdId: String?
    
    private override init() {
        super.init()
    }
    
    @MainActor public func initialize(bannerAdId: String, interstitialAdId: String) {
        self.bannerAdId = bannerAdId
        self.interstitialAdId = interstitialAdId
        self.interstitialManager = InterstitialAdsManager(adId: interstitialAdId)
        self.bannerAdView = BannerAdView(adUnitId: bannerAdId)
        self.proService = ProService()
    }
    
    @MainActor public func showInterstitial(onClosed: @escaping () -> Void, onFailed: @escaping () -> Void) {
        interstitialManager?.displayInterstitialAd(onClosed: onClosed, onFailed: onFailed)
    }
    
    public func BannerAd() -> some View {
        Group {
            if let bannerAdView = bannerAdView, let proService = proService {
                bannerAdView.environmentObject(proService)
            } else {
                EmptyView()
            }
        }
    }
    
    public func isPro() -> Bool {
        return proService?.hasPro == true
    }
    
    public func togglePro(isPro: Bool) {
        proService?.hasPro = isPro
    }
}
