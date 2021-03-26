//
//  ViewController.swift
//  festival beaconyx
//
//  Created by Beaconyx Corp. on 12/08/2019.
//  Copyright © 2019 Beaconyx Corp. All rights reserved.
//

import UIKit
import Parse

class LoadingViewController: BaseViewController {
        
    @IBOutlet weak var welcomeLabel: UILabel!
    var selectedLanguage: String!
    
    var appVersionUrl: String = "http://itunes.apple.com/lookup?bundleId=com.beaconyx.festivalapp"
    var appDownloadUrl: String = "https://itunes.apple.com/kr/app/id1490219040?mt=8"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        welcomeLabel.isHidden = true
        
        if isAppVersionUpdateAvailable() { // true : have to update
            let alert = UIAlertController(title: "앱 업데이트 공지", message: "\n새로운 서비스 이용을 위해 앱을 업데이트 해주세요.\n더욱 다양한 서비스 이용이 가능합니다.", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "업데이트 하기", style: .cancel) { (action) in
                guard let url = URL(string: self.appDownloadUrl) else { return }
                
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            
            let cancelAction = UIAlertAction(title: "다음에 하기", style: .default, handler: nil)
            
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true, completion: nil)
        }
        
        selectLanguage()
    }
    
    // TODO:- 루트화면으로 이동 시, 스택 레이어 제거
//    override func viewWillAppear(_ animated: Bool) {
//        view.subviews.forEach{ $0.removeFromSuperview() }
//    }
    
    // Func app version checking
    func isAppVersionUpdateAvailable() -> Bool {
        // 출처: https://zeddios.tistory.com/372 [ZeddiOS]
        guard
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            let url = URL(string: appVersionUrl),
            let data = try? Data(contentsOf: url),
            let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
            let results = json["results"] as? [[String: Any]],

            results.count > 0,

            let appStoreVersion = results[0]["version"] as? String

            else { return false }

        userprint(output: "appVersion: \(version), appStoreVersion: \(appStoreVersion)")
        
//        if !(version == appStoreVersion) { return true }
        if (version < appStoreVersion) { return true}

        else{ return false }
    }
    
    // MARK:- DeviceUUID check by Keychain
    func checkRegisterUser() {
        let table = parseTable.AccountTablekey.self
        let query = PFQuery(className: table.tableName)

        query.whereKey(table.userId, equalTo: appDelegate.keyChain!)
        query.findObjectsInBackground(block: {(objects: [PFObject]?, error: Error?) in

            if error == nil {
                if objects?.count == 0 {
                    // 등록된 유저가 없음. 등록 진행
                    userprint(output: "등록되지 않은 유저이므로 유저 등록을 진행합니다.")
                    
                    let pfObject = PFObject(className: table.tableName)
                    
                    pfObject[table.userId] = self.appDelegate.keyChain
                    pfObject[table.device] = UIDevice.customModelName
                    pfObject[table.osVer] = UIDevice.current.systemVersion
                    pfObject[table.osType] = UIDevice.current.systemName
                    pfObject[table.pushToken] = UserDefaults.standard.object(forKey: "FCMtoken")
                    
                    pfObject.saveInBackground{ (success: Bool, error: Error?) in
                        if success { userprint(output: "USER ENROLLMENT DONE!") }
                        else { userprint(output: "USER ENROLLMENT FAILED : \(error!)") }
                    }
                } else { // 등록된 유저의 경우 pushToken 재확인
                    userprint(output: "이미 해당 유저가 등록되어 있습니다. fcm token을 확인합니다.")
                    
                    query.getObjectInBackground(withId: objects![0].objectId!) { (object, error) in
                        if let error = error {
                            // Error
                            print(error.localizedDescription)
                        } else if let object = object {
                            // Find
                            let token = UserDefaults.standard.object(forKey: "FCMtoken")
                            
                            if token != nil {
                                object[table.pushToken] = token as! String
                                object.saveInBackground()
                            }
                        }
                    }
                }
            }
            
            // 모든 작업이 끝난 뒤 다음 함수로 이동
            self.aroundParsing()
        })
    }
    
    // MARK:- FUNCTION about checking policy
    func checkPolicy() {
        // location policy
        let status = CLLocationManager.authorizationStatus()
        
        userprint(output: "위치정보 권한 상태 : \(status)")
        
        if status == CLAuthorizationStatus.denied || status == CLAuthorizationStatus.restricted {
            // 동의 안함 -> 동의 팝업
            let alert = UIAlertController(title: "위치 권한 요청", message: "위치 권한을 허용해야만 앱을 사용하실 수 있습니다. 앱이 실행되는 동안만 위치권한을 사용합니다.", preferredStyle: UIAlertController.Style.alert)
            
            let okAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default) { (UIAlertAction) in
                // 권한 설정 페이지로 이동
                if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
                    
                    self.welcomeLabel.text = self.appDelegate.languageDic["LocationPolicyMsg"]
                }
            }
            
            let noAction = UIAlertAction(title: "취소", style: UIAlertAction.Style.default) { (UIAlertAction) in
                exit(0)
            }
            
            alert.addAction(okAction)
            alert.addAction(noAction)
            
            self.present(alert, animated: true, completion: nil)
            
        } else {
            mCoordinate = appDelegate.getLocation()
            if self.appDelegate.selectedLanguage == "Kor" {
                getScrapesParsing(uid: self.appDelegate.keyChain!, coor: self.mCoordinate)
            }
            checkRegisterUser() // 유저 확인
        }
    }
    
    func selectLanguage() {

        if appDelegate.selectedLanguage == nil {
            // 선택된 언어가 없으면 OS 언어로 설정
            let locale = Locale.preferredLanguages[0]
            let localeArr = locale.components(separatedBy: "-")
            
            userprint(output: "OS language : \(locale)")
            var language = ""
            
            /* OS에서의 언어 표현 방식
             * korean       : ko
             * english      : en
             * spanish      : es
             * japanese     : ja
             * french       : fr
             * german       : de
             * russian      : ru
             * chinese      : zh-Hans(simplified) / zh-Hant(Tranditional)
             */
            
            switch localeArr[0] {
                
            case "ko": // 한국어
                language = "Kor"
                appDelegate.osLanguageLocale = "한국어"
                break
            case "en": // 영어
                language = "Eng"
                appDelegate.osLanguageLocale = "English"
                break
            case "es": // 스페인어
                language = "Spn"
                appDelegate.osLanguageLocale = "Espanol"
                break
            case "ja": // 일본어
                language = "Jpn"
                appDelegate.osLanguageLocale = "日本"
                break
                
            case "fr": // 프랑스어
                language = "Fre"
                appDelegate.osLanguageLocale = "Français"
                break
                
            case "de": // 독일어
                language = "Ger"
                appDelegate.osLanguageLocale = "Deutsch"
                break
                
            case "ru": // 러시아어
                language = "Rus"
                appDelegate.osLanguageLocale = "русский"
                break
                
            case "zh": // 중국어
                if localeArr[1] == "Hans" { // 중국어 간체
                    language = "Chs"
                    appDelegate.osLanguageLocale = "中文(简)"
                } else {                    // 그 외 중국어 번체, 홍콩어 = 번체
                    language = "Cht"
                    appDelegate.osLanguageLocale = "中文(繁)"
                }
                break
                
            default:
                language = "Eng"
                appDelegate.osLanguageLocale = "English"
                break
            }
            
            appDelegate.selectedLanguage = language
            getLanguageToParse(language: language)
        }
        else {
            self.appDelegate.osLanguageLocale = self.appDelegate.selectedLanguageText
            getLanguageToParse(language: appDelegate.selectedLanguage)
        }
    }
    
    func getLanguageToParse(language: String) {
        let table = parseTable.languageTableKey.self
        let query = PFQuery(className: table.tableName)
        
        query.limit = 1000

        query.findObjectsInBackground(block: {(objects: [PFObject]?, error: Error?) in
            
            if error == nil {
                for object in objects! {
                    // 선택된 언어의 값과 키 값이 존재할 때 이 두 값으로 딕셔너리 생성
                    if let dataObject: String = object.value(forKey: language) as? String {
                        if let keyObject: String = object.value(forKey: "key") as? String {
                            
                            self.appDelegate.languageDic[keyObject] = dataObject
                        }
                    }
                }
                
                userprint(output: "서버에서 \"\(language)\" 언어 \(self.appDelegate.languageDic.count)개를 다운로드 하였습니다.")
                
                self.welcomeLabel.text = self.appDelegate.languageDic["main_text_3"]
                self.welcomeLabel.isHidden = false
            }
            
            self.checkPolicy()
//            // 모든 작업이 끝난 뒤 다음 함수로 이동
//            if self.appDelegate.selectedLanguage == "Kor" {
//                getScrapesParsing(uid: self.appDelegate.keyChain!, coor: self.mCoordinate)
//            }
//            self.aroundParsing()
        })
    }
    
    // 내주변에서 진행중인 행사 찾기
    func aroundParsing() {
       
        relationParsingOnGoing(coor: self.mCoordinate, qLimit: 100, kmLimit: 10, qSkip: 0) { (result) in
            let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
            
            switch result {
            case .success(let data):
                userprint(output: "relationParsing(main)Success, go to MainViewController")
                mainVC.collectionDic = data
                
            case .zeroData: userprint(output: "there is zero data")
                
            case .fail(let error):
                userprint(output: "relationParsing(main)Error: \(error)")
            }
            
            // 백그라운드 파싱을 사용하는 쿼리로 인해 여유시간을 주고 다음 화면으로 이동
            // 값을 가져왔지만, 이미 화면이 넘어가버린 경우 반영이 되지 않음.
            // 블록으로 리턴할 경우 너무 많은 소스가 변경되어 우선 딜레이로 진행
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.navigationController?.pushViewController(mainVC, animated: true)
            }
            
        }
    }
}

