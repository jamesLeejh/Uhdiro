//
//  AreaSelectViewController.swift
//  festival beaconyx
//
//  Created by Beaconyx Corp. on 01/11/2019.
//  Copyright © 2019 Beaconyx Corp. All rights reserved.
//

import UIKit

class AreaSelectViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var topTitleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var emptyView: UIView!
    var imageArray: [String]!
    var dataArray = [[String:AnyObject]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.emptyView = UIView.init(frame: CGRect(x: 0, y: 0, width: self.collectionView.frame.width, height: self.collectionView.frame.height))
        self.emptyView.backgroundColor = .white
        
        self.collectionView.addSubview(emptyView)
        
        self.topTitleLabel.text = appDelegate.languageDic["area_list"]
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        let firstValue = ["rnum":0, "name":self.appDelegate.languageDic["area_all"], "code":0] as [String : AnyObject]
        dataArray.append(firstValue)
        
        imageArray = ["0 전국.png", "1 서울.png", "2 인천.png", "3 대전.png", "4 대구.png", "5 광주.png",
                      "6 부산.png", "7 울산.png", "8 세종.png", "9 경기.png", "10 강원.png", "11 충북.png",
                      "12 충남.png", "13 경북.png", "14 경남.png", "15 전북.png", "16 전남.png", "17 제주.png"]
        
        getAreaName()
    }
    
    // MARK:- ** CollectionView DataSource **
    // 셀 개수 파악
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    // 셀 구성하기
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! collectionCell
        let row = indexPath.row
        
        cell.cornerRadius = 5
        cell.cellImageView.image = UIImage(named: imageArray[row])
        cell.areaLabel.text = dataArray[row]["name"] as? String
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let nextView = self.storyboard?.instantiateViewController(withIdentifier: "AreaViewController") as! AreaViewController
        
        nextView.areaDic = dataArray[indexPath.row]
        
        self.navigationController?.pushViewController(nextView, animated: true)
        
    }
    
    // MARK:- ** CollectionView FlowLayout **
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        return UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (self.collectionView.bounds.width - 10*2) / 3.0
        
        return CGSize(width: width, height: width)
    }
    
    func getAreaName() {
        showActivityView(onView: self.view)
        
        let url = requestAreaNameUrl(language: appDelegate.selectedLanguage)
        print(url)
        
        requestTourAPI(url: url) { (result) in
            
            switch result {
            case .success(let data):
                self.dataArray.append(contentsOf: data)
                
                userprint(output: "request AreaName success. reload collectionView")
                
                self.collectionView.reloadData()
                self.view.layoutIfNeeded()
                
                self.emptyView.removeFromSuperview()
                
            case .zeroData:
                let view = NoDataView(frame: self.emptyView.bounds)
                self.emptyView.addSubview(view)
                
            case .fail(let error):
                userprint(output: "requestAreaNameError: \(error)")
            }
            self.removeActivityView()
        }
    }
    
}

class collectionCell: UICollectionViewCell {
    
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var areaLabel: UILabel!
}


