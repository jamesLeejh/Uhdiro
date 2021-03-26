//
//  SLPopViewController.swift
//  festival beaconyx
//
//  Created by Beaconyx Corp. on 07/11/2019.
//  Copyright © 2019 Beaconyx Corp. All rights reserved.
//

import UIKit

protocol SLPopViewControllerDelegate {
    func sendData(data: String)
}

// Select Language Pop View Controller
class SLPopViewController: BaseViewController {
    
    var delegate: SLPopViewControllerDelegate?

    @IBOutlet weak var alphaView: UIView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var button5: UIButton!
    @IBOutlet weak var button6: UIButton!
    @IBOutlet weak var button7: UIButton!
    @IBOutlet weak var button8: UIButton!
    @IBOutlet weak var button9: UIButton!
    
    @IBOutlet weak var topTitleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var selectButton: UIButton!
    
    var btnArr : [UIButton]!
    var selectedLanguage : Int!
    var languageArr: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        btnArr = [button1, button2, button3, button4, button5, button6, button7, button8, button9]

        languageArr = [languagePack.korean.rawValue, languagePack.english.rawValue, languagePack.japanese.rawValue,
                       languagePack.chinaChs.rawValue, languagePack.chinaCht.rawValue, languagePack.french.rawValue,
                       languagePack.german.rawValue, languagePack.spanish.rawValue, languagePack.russian.rawValue]
        

        for index in 0..<btnArr.count {
            btnArr[index].addLine(position: .LINE_POSITION_BOTTOM, color: .white, width: 0.5)
            btnArr[index].setTitle(languageArr![index], for: .normal)
        }
        
        self.topTitleLabel.text = appDelegate.languageDic["dialog_lang_title"]
        self.subTitleLabel.text = appDelegate.languageDic["dialog_lang_msg"]
        self.selectButton.setTitle(appDelegate.languageDic["dialog_confirm"], for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 1.0) {
            self.alphaView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        }
        self.view.layoutIfNeeded()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func SLButtonTapped(_ sender: UIButton) {
        let tag = sender.tag
        
        selectedLanguage = tag
        
        for i in 0..<btnArr.count {
            if i == selectedLanguage {
                btnArr[i].backgroundColor = UIColor(red: 51/255, green: 141/255, blue: 235/255, alpha: 1.0)
            } else {
                btnArr[i].backgroundColor = .clear
            }
        }
    }
    
    @IBAction func selectButtonTapped(_ sender: Any) {
        
        var sendData: String!
        
        if let sl = self.selectedLanguage {
            // 선택된 언어로 변경
            switch sl {
                case 0:
                    sendData = "Kor"
                    break
                case 1:
                    sendData = "Eng"
                    break
                case 2:
                    sendData = "Jpn"
                    break
                case 3:
                    sendData = "Chs"
                    break
                case 4:
                    sendData = "Cht"
                    break
                case 5:
                    sendData = "Fre"
                    break
                case 6:
                    sendData = "Ger"
                    break
                case 7:
                    sendData = "Spn"
                    break
                case 8:
                    sendData = "Rus"
                    break
                    
                default:
                    break
            }
        }
        
        if let data = sendData {
            appDelegate.selectedLanguageText = languageArr[selectedLanguage]
            delegate?.sendData(data: data)
//            appDelegate.selectedLanguageText = languageArr[selectedLanguage]
        }
        
        self.alphaView.backgroundColor = .clear
        self.dismiss(animated: true, completion: nil)
    }
}

enum LINE_POSITION {
    case LINE_POSITION_TOP
    case LINE_POSITION_BOTTOM
}

extension UIView {
    func addLine(position: LINE_POSITION, color: UIColor, width: Double) {
        let lineView = UIView()
        lineView.backgroundColor = color
        lineView.translatesAutoresizingMaskIntoConstraints = false // This is important!
        self.addSubview(lineView)

        let metrics = ["width" : NSNumber(value: width)]
        let views = ["lineView" : lineView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[lineView]|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))

        switch position {
        case .LINE_POSITION_TOP:
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[lineView(width)]", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))
            break
        case .LINE_POSITION_BOTTOM:
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[lineView(width)]|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))
            break
        }
    }
}
