//
//  EtcDetailViewController.swift
//  festival beaconyx
//
//  Created by Beaconyx Corp. on 21/11/2019.
//  Copyright © 2019 Beaconyx Corp. All rights reserved.
//

import UIKit
import GoogleMaps
import FSPagerView

class EtcDetailViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, GMSMapViewDelegate {

    @IBOutlet weak var labelView: UIView!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topTitleLabel: UILabel!
    @IBOutlet weak var mapLabel: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var mapTouchView: UIView!
    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
            self.pagerView.itemSize = FSPagerView.automaticSize
        }
    }
    
    
    @IBOutlet weak var pagecontrol: FSPageControl! {
        didSet {
            self.pagecontrol.hidesForSinglePage = true
            self.pagecontrol.setFillColor(.black, for: .selected)
            self.pagecontrol.setFillColor(.gray, for: .normal)
        }
    }
    var contentId: String!
    var contentTypeId: String!
    var eventTitle: String!
    var contents: [apiContent]!
    var mergeDic: [String:AnyObject]!
    var cachingImageList: [String]!
    
    var emptyView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.cachingImageList = [contentId!]
        
        self.emptyView = UIView.init(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: self.tableView.frame.height))
        self.emptyView.backgroundColor = .white
        
        self.tableView.addSubview(emptyView)
        
        let nibName = UINib(nibName: "EventDetailViewCell", bundle: nil)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.register(nibName, forCellReuseIdentifier: "detailCell")
        
        UIConfiguration()
        getEventDetail(id: contentId, typeId: contentTypeId)
        getEventDetailImage(id: contentId, typeId: contentTypeId)
    }
    
    // 랜더링 부분은 해당 함수에서 구현
    override func viewDidLayoutSubviews() {
        self.labelView.roundConers([.topRight, .bottomRight], radius: self.labelView.frame.size.height/2)
        self.eventTitleLabel.text = eventTitle
        
        self.labelView.backgroundColor = definePurpleColor // 설정 자체에 알파값 있음 (0.6)
    }
    
    func UIConfiguration() {
        // pagerView configuration
        self.pagerView.delegate = self
        self.pagerView.dataSource = self
        self.pagerView.transformer = FSPagerViewTransformer(type: .linear)
        self.pagerView.clipsToBounds = true
                
        self.topTitleLabel.text = appDelegate.languageDic["fest_title"]
        self.mapLabel.text = appDelegate.languageDic["fest_label_9"]
        
        // 셀 간 라인 없앰
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        // key : fest_share_txt
        let title = String(describing: self.mergeDic["title"]!)
        let text = (appDelegate.languageDic["fest_share_txt"])!.replacingOccurrences(of: "*", with: title)

        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if contents != nil {
            return contents.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell") as! EventDetailViewCell
        
        // 선택시 틴트효과 끄기
        cell.selectionStyle = .none
        
        let row = indexPath.row
        
        // 텍스트뷰 하이퍼링크 활성화
        cell.cellExplainTextView.isScrollEnabled = false
        cell.cellExplainTextView.isSelectable = true // 반드시 true로 해주어야 link가 활성화 됨.
        cell.cellExplainTextView.dataDetectorTypes = UIDataDetectorTypes.all
        
        // 컨텐츠 설정
        cell.cellImageView.image = UIImage(named: contents[row].iconName)
        cell.cellTitleLabel.text = contents[row].title
        cell.cellExplainTextView.text = contents[row].subTitle
        
        return cell
    }
    
    func getEventDetail(id: String, typeId: String) {
        showActivityView(onView: self.view)
        
        let commonUrl = requestEventDetailCommonUrl(language: appDelegate.selectedLanguage,
                                                    contentId: id, contentTypeId: typeId)
        
        
        
        var commonDic = [String:AnyObject]()
        var introDic = [String:AnyObject]()
        
        var contentTypeID = ""
        
        // Get detailCommon data
        requestTourAPI(url: commonUrl) { (result) in
            
            switch result {
            case .success(let data) :
                commonDic = data[0]
                userprint(output: "Event Detail Common Request Success.")
                
                if let ctid = commonDic["contenttypeid"] {
                    contentTypeID = String(describing: ctid)
                }
                
                let introUrl  = requestEventDetailIntroUrl(language: self.appDelegate.selectedLanguage,
                                                           contentId: self.contentId, contentTypeId: contentTypeID)
                // Get detailIntro data
                requestTourAPI(url: introUrl) { (result) in
                    
                    switch result {
                    case .success(let data) :
                        introDic = data[0]
                        userprint(output: "Event Detail Intro Request Success.")
                        
                        // 두 딕셔너리를 하나로 합치는 작업 ==> 최종데이터 추출
                        self.dictionaryMerge(common: commonDic, intro: introDic)
                        
                    case .zeroData:
                        break
                        
                    case.fail(let error) :
                        userprint(output: "error: \(error)")
                    }
                }
                
            case.fail(let error) :
                userprint(output: "error: \(error)")
            case .zeroData:
                break
            }
        }
    }
    
    func getEventDetailImage(id: String, typeId: String) {
        let url = requestEventDetailImageUrl(language: self.appDelegate.selectedLanguage,
                                             contentId: id, contentTypeId: typeId)
        
        requestTourAPI(url: url) { (result) in
            switch result {
            case .success(let data) :
                userprint(output: "getting image success...[\(data.count)개]")
                
                for image in data {
                    // 이미지 캐싱
                    let serialnumber = String(describing: image["serialnum"]!)
                    let imageurl = String(describing: image["originimgurl"]!)
                    
                    self.cachingImageList.append(serialnumber)
                    
                    // 캐싱된 이미지가 없을 때 이미지 캐싱 진행
                    if AFImageCache.image(withIdentifier: serialnumber) == nil {
                        AFImageCaching(cid: serialnumber, url: imageurl)
                    }
                }
                
                self.pagerView.reloadData()
                
                break
                
            case.fail(let error) :
                userprint(output: "error: \(error)")
                
                break
                
            case .zeroData:
                userprint(output: "there is no data")
                
                break
            }
        }
    }
    
    func dictionaryMerge(common: [String:AnyObject], intro: [String:AnyObject]) {
        
        self.mergeDic = common.merging(intro, uniquingKeysWith: { (first, _) in first})
        userprint(output: "Combined detail common/intro dictionaries")
        
        contents = listTypeFiltering(data: self.mergeDic)
        
        // 구글지도 표현
        googleMapDisplay()
        
        self.tableView.reloadData()
        self.view.layoutIfNeeded()
        
        removeActivityView()
        self.emptyView.removeFromSuperview()
    }
    
    func googleMapDisplay() {
        let latitude = (mergeDic["mapy"]?.doubleValue)!
        let longitude = (mergeDic["mapx"]?.doubleValue)!
        
        userprint(output: "target GPS is \(latitude), \(longitude)")
        
        mapView.delegate = self
        
        // 지도가 움직이는 것을 방지하기 위해서, 이렇게 설정하면 구글맵에서 제공하는 터치이벤트는 동작하지 않기 때문에 따로 터치이벤트를 만들어줌
        mapView.isUserInteractionEnabled = false
        
        // 터치제스쳐, 지도에서 제스쳐가 false로 설정되어있으므로 상위 뷰에서 실행
        let gesture = UITapGestureRecognizer(target: self, action: #selector(mapTappedAction(sender:)))
        mapTouchView.addGestureRecognizer(gesture)
        
        // Create map
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 16)
        mapView.camera = camera
        
        // Create marker
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        marker.title = mergeDic["title"]?.string
        marker.map = mapView
    }
    
    @objc func mapTappedAction(sender : UITapGestureRecognizer) {
        userprint(output: "Show detail map on googlemap")
        
        let googleMap = mapViewController()
        
        // 아래의 코드를 해주지 않으면 검정색 백그라운드가 무조건 적용됨
        googleMap.providesPresentationContextTransitionStyle = true
        googleMap.definesPresentationContext = true
        googleMap.modalPresentationStyle = .overCurrentContext
        
        // 데이터 전달
        googleMap.self.dic = mergeDic
        
        // 팝업
        self.navigationController?.present(googleMap, animated: true, completion: nil)
    }
    
    // MARK:- Googlemaps Delegate(구글지도 클릭 시 이벤트)
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        userprint(output: "Show detail map on googlemap")
        
        let googleMap = mapViewController()
        
        // 아래의 코드를 해주지 않으면 검정색 백그라운드가 무조건 적용됨
        googleMap.providesPresentationContextTransitionStyle = true
        googleMap.definesPresentationContext = true
        googleMap.modalPresentationStyle = .overCurrentContext
        
        // 데이터 전달
        googleMap.self.dic = mergeDic
        
        // 팝업
        self.navigationController?.present(googleMap, animated: true, completion: nil)
        
    }
}

extension EtcDetailViewController: FSPagerViewDelegate, FSPagerViewDataSource {
    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        self.pagecontrol.numberOfPages = self.cachingImageList.count
        
        return self.cachingImageList.count
    }
    
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        
        if let cachingImage = AFImageCache.image(withIdentifier: self.cachingImageList[index]) {
            cell.imageView?.image = cachingImage
        } else {
            cell.imageView?.image = UIImage(named: "img_no.png")
        }
        
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.clipsToBounds = true
        
        return cell
    }
    
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        self.pagecontrol.currentPage = targetIndex
    }
}
