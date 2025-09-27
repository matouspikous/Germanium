//
//  AdsViewController.swift
//  Germanium
//
//  Created by Matouš Pikous on 26/09/2025.
//  Copyright © 2025 Matouš Pikous. All rights reserved.
//
/*
import Foundation
import UIKit
import GoogleMobileAds

class AdsViewController: UIViewController {

    // Banner ad
    var bannerView: GADBannerView!

    // Interstitial ad
    var interstitial: GADInterstitial!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Ads"

        setupBannerAd()
        loadInterstitialAd()
        
        // Optional button to show interstitial ad
        let showAdButton = UIButton(type: .system)
        showAdButton.setTitle("Show Full Screen Ad", for: .normal)
        showAdButton.addTarget(self, action: #selector(showInterstitial), for: .touchUpInside)
        showAdButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(showAdButton)
        NSLayoutConstraint.activate([
            showAdButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            showAdButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - Banner Ad
    func setupBannerAd() {
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        bannerView.adUnitID = "YOUR_BANNER_AD_UNIT_ID" // Replace with your ID
        bannerView.rootViewController = self
        bannerView.load(GADRequest())

        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)

        NSLayoutConstraint.activate([
            bannerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    // MARK: - Interstitial Ad
    func loadInterstitialAd() {
        interstitial = GADInterstitial(adUnitID: "YOUR_INTERSTITIAL_AD_UNIT_ID") // Replace with your ID
        interstitial.load(GADRequest())
    }

    @objc func showInterstitial() {
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        } else {
            print("Interstitial ad wasn't ready")
        }
    }
}
*/
