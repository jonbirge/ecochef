//
//  AboutViewController.swift
//  EcoChef
//
//  Created by Jonathan Birge on 6/20/17.
//  Copyright © 2017 Birge Clocks. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var eggTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        titleLabel.textColor = .black
        eggTextView.textColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.transition(with: titleLabel, duration: 3,
                          options: .transitionCrossDissolve,
                          animations:
            { self.titleLabel.textColor = .red },
                          completion: nil)
    }

    @IBAction func swipeUp(_ sender: UISwipeGestureRecognizer) {
        UIView.transition(with: eggTextView, duration: 5,
                          options: .transitionCrossDissolve,
                          animations:
            { self.eggTextView.textColor = .red },
                          completion: nil)
    }
}
