//
//  AboutViewController.swift
//  EcoChef
//
//  Created by Jonathan Birge on 6/20/17.
//  Copyright © 2017 Birge Clocks. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var eggTextView: UITextView!
    @IBOutlet var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let appVersionString: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        versionLabel.text = appVersionString
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.transition(
            with: titleLabel, duration: 3,
            options: .transitionCrossDissolve,
            animations:
                { self.titleLabel.textColor = .systemRed },
            completion: nil
        )
        doEgg()
    }
    
    @IBAction func doLongPress(_ sender: UILongPressGestureRecognizer) {
        hideEgg()
    }
    
    func doEgg() {
        print("Hi, Nathy and Alex!")
        UIView.transition(
            with: eggTextView, duration: 5,
            options: .transitionCrossDissolve,
            animations:
                { self.eggTextView.isHidden = false
                    self.eggTextView.textColor = .label
                },
            completion: nil
        )
    }
    
    func hideEgg() {
        print("Hi, Nathy and Alex!")
        UIView.transition(
            with: eggTextView, duration: 5,
            options: .transitionCrossDissolve,
            animations:
                { self.eggTextView.textColor = .systemBackground },
            completion: nil
        )
    }
}
