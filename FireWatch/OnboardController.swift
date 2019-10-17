//
//  ViewController.swift
//  FireWatch
//
//  Created by mac on 10/18/18.
//  Copyright © 2018 Ali Kelkawi. All rights reserved.
//

import UIKit
import OnboardKit

class OnboardController: UIViewController {
    
    lazy var onboardingPages: [OnboardPage] = {
        let pageOne = OnboardPage(title: "Welcome to FireWatch",
                                  imageName: "Onboarding1",
                                  description: "A useful tool that allows users to report wildfires quickly and efficiently.")
        
        let pageTwo = OnboardPage(title: "Report Easily",
                                  imageName: "Onboarding2",
                                  description: "Simply login, pin fire location on the map, take a picture and submit.")
        
        let pageThree = OnboardPage(title: "Permissions",
                                       imageName: "Onboarding4",
                                       description: "Turn on your location and allow notification. FireWatch will handle the rest!",
                                       advanceButtonTitle: "Decide Later",
                                       actionButtonTitle: "Enable Notifications",
                                       action: { [weak self] completion in
                                        self?.showAlert(completion)
        })
        
        let pageFour = OnboardPage(title: "All Ready",
                                   imageName: "Onboarding5",
                                   description: "You are all set up and ready to use Habitat. Begin by adding your first habit.",
                                   advanceButtonTitle: "Done")
        
        return [pageOne, pageTwo, pageThree, pageFour]
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if UserDefaults.standard.value(forKey: "firstIn") == nil {
            showOnboardingTapped()
        }
    }
    
    func showOnboardingTapped() {
        //save first time use log
        UserDefaults.standard.set(true, forKey: "firstIn")
        
        let onboardingVC = OnboardViewController(pageItems: onboardingPages)
        onboardingVC.modalPresentationStyle = .formSheet
        onboardingVC.presentFrom(self, animated: false)
    }
    
    private func showAlert(_ completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        let alert = UIAlertController(title: "Allow Notifications?",
                                      message: "Habitat wants to send you notifications",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion(true, nil)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completion(false, nil)
        })
        presentedViewController?.present(alert, animated: true)
    }
}

