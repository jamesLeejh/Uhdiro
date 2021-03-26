//
//  SideMenuViewController.swift
//  festival beaconyx
//
//  Created by Beaconyx Corp. on 11/11/2019.
//  Copyright © 2019 Beaconyx Corp. All rights reserved.
//

import UIKit

class SideMenuViewController: UIViewController {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var alphaView: UIView!
    
    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var appVersionLabel: UILabel!
    
    @IBOutlet weak var slideLabel1: UILabel!
    @IBOutlet weak var slideLabel2: UILabel!
    @IBOutlet weak var slideLabel3: UILabel!
    @IBOutlet weak var slideLabel4: UILabel!
    @IBOutlet weak var bottomTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let dic = appDelegate.languageDic
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        
        slideLabel1.text = dic["main_slide_text_1"]
        slideLabel2.text = dic["main_slide_text_2"]
        slideLabel3.text = dic["main_slide_text_4"]
        slideLabel4.text = dic["main_slide_text_5"]
        
        bottomTextView.text = dic["main_slide_text_3"]
        appVersionLabel.text = "ver \(appVersion!)"
        
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
