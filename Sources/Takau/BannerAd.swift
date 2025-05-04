//
//  BannerAd.swift
//  Takau
//
//  Created by ikhwan on 04/05/25.
//

import GoogleMobileAds
import SwiftUI
import UIKit

@available(iOS 14.0, *)
public struct BannerAdView: View {
    @EnvironmentObject var proService: ProService
    @State var height: CGFloat = 0
    @State var width: CGFloat = 0
    private var adUnitId: String = "ca-app-pub-3940256099942544/2435281174" // Default is test ad id
    
    public init(adUnitId: String) {
        if !adUnitId.isEmpty {
            self.adUnitId = adUnitId
        }
    }
    
    public var body: some View {
        if proService.hasPro {
            EmptyView()
        } else {
            BannerAd(adUnitId: adUnitId)
                .frame(width: width, height: height, alignment: .center)
                .onAppear {
                    setFrame()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                    setFrame()
                }
        }
    }
    
    func setFrame() {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let safeAreaInsets = windowScene?.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets ?? .zero
        let frame = UIScreen.main.bounds.inset(by: safeAreaInsets)
        
        let adSize = currentOrientationAnchoredAdaptiveBanner(width: frame.width)
        
        self.width = UIScreen.main.bounds.width - 32
        self.height = adSize.size.height
    }
}

class BannerAdVC: UIViewController {
    let adUnitId: String
    
    init(adUnitId: String) {
        self.adUnitId = adUnitId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var bannerView: BannerView = BannerView()
    
    override func viewDidLoad() {
        bannerView.adUnitID = adUnitId
        bannerView.rootViewController = self
        view.addSubview(bannerView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadBannerAd()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { _ in
            self.bannerView.isHidden = true //So banner doesn't disappear in middle of animation
        } completion: { _ in
            self.bannerView.isHidden = false
            self.loadBannerAd()
        }
    }
    
    func loadBannerAd() {
        let frame = view.frame.inset(by: view.safeAreaInsets)
        let viewWidth = frame.size.width
        
        bannerView.adSize = currentOrientationAnchoredAdaptiveBanner(width: viewWidth)
        
        bannerView.load(Request())
    }
}

@available(iOS 14.0, *)
struct BannerAd: UIViewControllerRepresentable {
    let adUnitId: String
    
    init(adUnitId: String) {
        self.adUnitId = adUnitId
    }
    
    
    func makeUIViewController(context: Context) -> BannerAdVC {
        return BannerAdVC(adUnitId: adUnitId)
    }
    
    func updateUIViewController(_ uiViewController: BannerAdVC, context: Context) {
        
    }
}
