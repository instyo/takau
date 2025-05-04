//
//  InterstitialAdManager.swift
//  Takau
//
//  Created by ikhwan on 04/05/25.
//

import Foundation
import GoogleMobileAds
import StoreKit

@available(iOS 14.0, *)
class InterstitialAdsManager: NSObject, FullScreenContentDelegate, ObservableObject {
    // Properties
    @Published var interstitialAdLoaded: Bool = false
    @Published var interstitialAdClosed: Bool = false
    private var onAdClosed: (() -> Void)? // Callback property
    private var onAdFailed: (() -> Void)? // Callback property
    
    var interstitialAd: InterstitialAd?
    var interstitialAdId: String = "ca-app-pub-3940256099942544/4411468910" // Default adId is testId
    
    // Default is using testIdAd
    init(adId: String) {
        super.init()
        
        if !adId.isEmpty {
            self.interstitialAdId = adId
        }
        
        self.loadInterstitialAd()
    }
    
    // Load InterstitialAd
    func loadInterstitialAd() {
        InterstitialAd.load(with: interstitialAdId, request: Request()) { [weak self] add, error in
            guard let self = self else {return}
            if let error = error{
                print("🔴: \(error.localizedDescription)")
                self.interstitialAdLoaded = false
                return
            }
            print("🟢: Loading succeeded")
            self.interstitialAdLoaded = true
            self.interstitialAd = add
            self.interstitialAd?.fullScreenContentDelegate = self
            self.interstitialAdClosed = false
        }
    }
    
    // Display InterstitialAd
    @MainActor func displayInterstitialAd(onClosed: @escaping () -> Void, onFailed: @escaping () -> Void) {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        
        guard let root = window?.rootViewController else {
            return
        }
        
        
        self.onAdClosed = onClosed
        self.onAdFailed = onFailed
        
        if let add = interstitialAd{
            add.present(from: root)
            self.interstitialAdLoaded = false
        } else {
            print("🔵: Ad wasn't ready")
            self.interstitialAdLoaded = false
            self.loadInterstitialAd()
        }
    }
    
    // Failure notification
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("🟡: Failed to display interstitial ad")
        onAdFailed?()
        self.loadInterstitialAd()
    }
    
    // Indicate notification
    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("🤩: Displayed an interstitial ad")
        self.interstitialAdLoaded = false
    }
    
    // Close notification
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("😔: Interstitial ad closed")
        onAdClosed?() // Call the callback when the ad is closed
        interstitialAdClosed = true
        loadInterstitialAd()
    }
}
