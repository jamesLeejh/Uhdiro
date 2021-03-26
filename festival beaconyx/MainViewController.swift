//
//  MainViewController.swift
//  festival beaconyx
//
//  Created by Beaconyx Corp. on 12/08/2019.
//  Copyright © 2019 Beaconyx Corp. All rights reserved.
//

import UIKit
import Parse
import SideMenu

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, SLPopViewControllerDelegate {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var collectionView: UICollectionView!
    var collectionDic = [parseContent]()
    
    @IBOutlet weak var topView          : UIView!
    @IBOutlet weak var bottomView       : UIView!
    @IBOutlet weak var alphaView        : UIView!
    @IBOutlet weak var contentView      : UIView!
    @IBOutlet weak var thisWeekEventView: UIView!
    @IBOutlet weak var mainBtn1View     : UIView!
    @IBOutlet weak var mainBtn2View     : UIView!
    @IBOutlet weak var mainBtn3View     : UIView!
    @IBOutlet weak var mainBtn4View     : UIView!
    
    @IBOutlet weak var thisweekEventHeight: NSLayoutConstraint!
    
    @IBOutlet weak var welcomeLabel     : UILabel!
    @IBOutlet weak var mainText1Label   : UILabel!
    @IBOutlet weak var mainText2Label   : MarqueeLabel!
    @IBOutlet weak var mainList1Label   : UILabel!
    @IBOutlet weak var mainList2Label   : UILabel!
    @IBOutlet weak var mainBtn1Label    : UILabel!
    @IBOutlet weak var mainBtn2Label    : UILabel!
    @IBOutlet weak var scrapCountLabel: UILabel!
    
    @IBOutlet weak var languageButton   : UIButton!
    
    @IBOutlet weak var urlImageView     : URLLoadImageView!
    
    var sideMenu: SideMenuViewController!
    var scrapEnabled : Bool = false
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if appDelegate.selectedLanguage! == "Kor" {
            self.scrapEnabled = true
            self.mainBtn4View.isHidden = false
        } else {
            self.scrapEnabled = false
            self.mainBtn4View.isHidden = true
        }
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
                
        // 각 객체의 색, 텍스트 등을 정의
        getUIDataSet()
        
        // SideMenu 라이브러리 설정
        self.setUpSideMenu()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 스크랩 개수 표시
        self.scrapCountLabel.text = String(format: "%ld", appDelegate.scrapArray.count)
    }
    
    // MARK:- ** CollectionView Delegate **
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionDic.count > 0 {
            self.thisweekEventHeight.constant = 100
            return collectionDic.count
        } else {
            self.thisweekEventHeight.constant = 0
            return 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hCell", for: indexPath) as! horizontalCell
        
        cell.cellLabel.text = collectionDic[indexPath.row].title!
        
        // 이미지 설정 -> 캐싱이 아직 안되었을 때는 url로 가져오고 캐싱된 후 리로드 부터 캐싱된 이미지로 로드
        if AFImageCache.image(withIdentifier: self.collectionDic[indexPath.row].contentid) == nil {
            cell.cellImageView.af_setImage(withURL: URL(string: collectionDic[indexPath.row].firstimage)!)
        }
        else {
            cell.cellImageView.image = AFImageCache.image(withIdentifier: self.collectionDic[indexPath.row].contentid)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let nextView = self.storyboard?.instantiateViewController(withIdentifier: "EventDetailViewController") as! EventDetailViewController
        
        nextView.contentId = collectionDic[indexPath.row].contentid!
        nextView.eventTitle = collectionDic[indexPath.row].title!
        
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
        
    // 랜더링 부분은 해당 함수에서 구현
    override func viewDidLayoutSubviews() {
        self.topView.roundConers([.bottomLeft], radius: 60)
        self.bottomView.roundConers([.topLeft], radius: 20)
        self.welcomeLabel.roundConers([.topLeft], radius: 50)
        self.languageButton.roundConers([.topLeft, .bottomLeft], radius: self.languageButton.frame.size.height/2)
        self.mainBtn1View.roundConers([.topLeft, .bottomLeft], radius: self.mainBtn1View.frame.size.height/2)
        self.mainBtn2View.roundConers([.topLeft, .bottomLeft], radius: self.mainBtn2View.frame.size.height/2)
        self.mainBtn3View.roundConers([.topLeft, .bottomLeft], radius: self.mainBtn3View.frame.size.height/2)
        self.mainBtn4View.roundConers([.topLeft, .bottomLeft], radius: self.mainBtn4View.frame.size.height/2)
    }
    
    @IBAction func langButtonTapped(_ sender: UIButton) {
        let pop = SLPopViewController()
        pop.delegate = self
        
        // 아래의 코드를 해주지 않으면 검정색 백그라운드가 무조건 적용됨
        pop.providesPresentationContextTransitionStyle = true
        pop.definesPresentationContext = true
        pop.modalPresentationStyle = .overCurrentContext
        
        self.navigationController?.present(pop, animated: true, completion: nil)
        
    }
    
    func getUIDataSet() {
        var imageUrl: String?
        // get image url
        let table = parseTable.viewContentsTableKey.self
        let query = PFQuery(className: table.tableName)
        
        query.findObjectsInBackground(block: {(objects: [PFObject]?, error: Error?) in

            if error == nil {
                for object in objects! {
                    if object.value(forKey: table.viewName) as? String == "mainImg" {
                        if let urlObject = object.value(forKey: table.url) {
                            imageUrl = urlObject as? String
                        }
                    }
                }
            }
            userprint(output: "메인 이미지를 다운로드 하였습니다.")
            self.urlImageView.loadURLImage(imageUrlStr: imageUrl!)
        })
        
        self.mainText1Label.text = appDelegate.languageDic["main_text_1"]
        self.welcomeLabel.text = appDelegate.languageDic["main_text_3"]
        
        // Marquee Configuration
        self.mainText2Label.text = appDelegate.languageDic["main_text_2"]
        self.mainText2Label.type = .continuous
        self.mainText2Label.animationCurve = .linear
        
        // 스토리보드에서 알파를 설정하게되면 하위 모든 뷰가 알파적용이 들어감
        self.alphaView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        self.thisWeekEventView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        self.mainList1Label.text = appDelegate.languageDic["main_list"]
        self.mainList2Label.text = appDelegate.languageDic["main_list2"]
        
        self.mainBtn1Label.text = appDelegate.languageDic["main_button_1"]
        self.mainBtn2Label.text = appDelegate.languageDic["main_button_2"]
        
        self.languageButton.setTitle(appDelegate.osLanguageLocale, for: .normal)
        
        // 스크랩 개수 표시
        self.scrapCountLabel.text = String(format: "%ld", appDelegate.scrapArray.count)
    }
        
    // delegate callback function
    func sendData(data: String) {
        userprint(output: "user Selected Language is \(data)")
        self.appDelegate.selectedLanguage = data
        
        let viewcontroller = self.storyboard?.instantiateViewController(withIdentifier: "LoadingViewController") as! LoadingViewController
        self.navigationController?.pushViewController(viewcontroller, animated: false)
    }
    
    // SideMenu 라이브러리 설정
    func setUpSideMenu() {
        sideMenu = SideMenuViewController(nibName: "SideMenuViewController", bundle: nil)
        let sideNavi = SideMenuNavigationController(rootViewController: self.sideMenu)
        
        SideMenuManager.default.leftMenuNavigationController = sideNavi
        SideMenuManager.default.addPanGestureToPresent(toView: self.view)
        
        sideNavi.statusBarEndAlpha = 0
        sideNavi.navigationBar.isHidden = true
        sideNavi.presentationStyle = .menuSlideIn
        sideNavi.menuWidth = self.view.frame.width
        
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: self.view)
    }
}

extension MainViewController: SideMenuNavigationControllerDelegate {
    func sideMenuDidAppear(menu: SideMenuNavigationController, animated: Bool) {
        UIView.animate(withDuration: 1.0) {
            self.sideMenu.alphaView.backgroundColor = UIColor(white: 0, alpha: 0.6)
        }
        print("SideMenu Appeared! (animated: \(animated))")
    }

    func sideMenuWillDisappear(menu: SideMenuNavigationController, animated: Bool) {
        self.sideMenu.alphaView.backgroundColor = .clear
        print("SideMenu Disappearing! (animated: \(animated))")
    }
}

class horizontalCell: UICollectionViewCell {
    
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var cellImageView: UIImageView!
}
