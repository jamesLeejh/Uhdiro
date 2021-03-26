//
//  BaseViewController.swift
//  festival beaconyx
//
//  Created by Beaconyx Corp. on 22/10/2019.
//  Copyright © 2019 Beaconyx Corp. All rights reserved.
//

import UIKit
import Foundation
import JGProgressHUD
import Parse
import Foundation
import SystemConfiguration

class BaseViewController: UIViewController {

    @IBOutlet weak var titleView: UIView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let definePinkColor = UIColor(red: 232/255, green: 102/255, blue: 112/255, alpha: 1.0)
    let definePurpleColor = UIColor(red: 52/255, green: 28/255, blue: 74/255, alpha: 0.6)
    
    let queryLimit: Int = 10 // default limit
    var mActivityView: UIView?
    var hud: JGProgressHUD?
    
    var loadMoreFinish: Bool = true
    var mCoordinate: CLLocationCoordinate2D!
        
    enum languagePack: String {
        case korean     = "한국어"
        case english    = "English"
        case japanese   = "日本"
        case chinaChs   = "中文(简)"
        case chinaCht   = "中文(繁)"
        case french     = "Français"
        case german     = "Deutsch"
        case spanish    = "Espanol"
        case russian    = "русский"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 뒤로가기 제스처
        let edgePanGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenEdgeSwiped))
        edgePanGesture.edges = .left
        // 등록
        self.view.addGestureRecognizer(edgePanGesture)
                
        mCoordinate = appDelegate.mCoor
        
        // Internet checking
        if Reachability.isConnectedToNetwork() {
            userprint(output: "Internet connection available")
        } else {
            userprint(output: "Internet connection not available")
            notAvailableAlert()
        }
    }
    
    func notAvailableAlert() {
        // 인터넷 연결되지 않음. 이전 화면으로 돌아감
        let alert = UIAlertController(title: "네트워크 알림", message: "현재 네트워크에 정상적으로 연결되어 있지 않습니다.\n설정을 확인한 후 재시도 버튼을 눌러주세요. 같은 현상이 반복되면 앱을 재실행 해주시기 바랍니다.", preferredStyle: .actionSheet)
        let shutdown = UIAlertAction(title: "앱 종료", style: .cancel) { (action) in
            exit(0)
        }
        
        let retry = UIAlertAction(title: "재시도", style: .default) { (action) in
//            self.navigationController?.popViewController(animated: true)
            if Reachability.isConnectedToNetwork() {
                userprint(output: "Internet connection available")
            } else {
                userprint(output: "Internet connection not available")
                self.notAvailableAlert()
            }
        }
        
        alert.addAction(shutdown)
        alert.addAction(retry)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func screenEdgeSwiped(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        if recognizer.state == .recognized {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

func userprint(line: Int = #line, funcname: String = #function, output:Any) {
    NSLog("[\(funcname)] [Line \(line)] :: \(output)")
}

extension BaseViewController {
    
    // 데이터 로딩동안 보여줄 액티비티화면
    func showActivityView(onView: UIView) {
        // Create hud
        hud = JGProgressHUD(style: .dark)
        hud?.textLabel.text = "Loading"
        
        DispatchQueue.main.async {
            self.hud?.show(in: onView)
        }
    }
    
    func removeActivityView() {
        DispatchQueue.main.async {
            self.hud?.dismiss(animated: false)
        }
    }
    // SNS 연동 기능
    func snsLink(snsType: String, title: String) {
        switch snsType {
            
        case "instagram":
            openInstagram(title: title)
            break
            
        case "youtube":
            openYoutube(title: title)
            break
            
        case "naver":
            openNaver(title: title)
            break
            
        default:
            break
        }
    }
    
    func openInstagram(title: String) {
        let replaceArray = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        var convert = title.replacingOccurrences(of: " ", with: "") // 공백 제거
        
        for index in 0..<replaceArray.count {
            // 숫자 제거
            convert = convert.replacingOccurrences(of: replaceArray[index], with: "")
        }
        let handle = "explore/tags/\(convert)"
        // query를 쓰기전에 항상 Encoding을 해주어야함 ***** 중요 *****
        let query = handle.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        guard let url = URL(string: "https://instagram.com/\(query)") else { return }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func openNaver(title: String) {
        
        let convert = title.replacingOccurrences(of: " ", with: "+")
        let handle = "search.naver?where=post&query=\(convert)"
        // query를 쓰기전에 항상 Encoding을 해주어야함 ***** 중요 *****
        let query = handle.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        print(query)
        
        guard let url = URL(string: "https://search.naver.com/\(query)") else { return }

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func openYoutube(title: String) {
        let replace = title.replacingOccurrences(of: " ", with: "+")
        let handle = "results?search_query=\(replace)"
        // query를 쓰기전에 항상 Encoding을 해주어야함 **** 중요 ****
        let query = handle.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        guard let url = URL(string: "https://youtube.com/\(query)") else { return }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    // 스크랩
    func findScrapedValue(cid: String) -> Bool{
        for array in appDelegate.scrapArray {
            if array.contentid == cid {
                return true
            }
        }
        return false
    }
}


// MARK:- Extension Custom UIView
// Adding a Border, Corner Radius, and Shadow to a UIView with Interface Builder.

extension UIView {
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    // 원하는 모서리만 둥글게 하는 함수
    func roundConers(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}

extension UIViewController {

    class func displaySpinner(onView: UIView) -> UIView {

        let spinnerView = UIView.init(frame: onView.bounds)

        

        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)

        let ai = UIActivityIndicatorView.init(style: .whiteLarge)

        ai.startAnimating()

        ai.center = spinnerView.center

        

        DispatchQueue.main.async {

            spinnerView.addSubview(ai)

            onView.addSubview(spinnerView)

        }

        

        return spinnerView

    }

    

    class func removeSpinner(spinner : UIView) {

        DispatchQueue.main.async {

            spinner.removeFromSuperview()

        }

    }

}

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        // 네비게이션 컨트롤러 일때
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        
        // 일반 컨트롤러일 때
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
