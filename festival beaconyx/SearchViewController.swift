//
//  SearchViewController.swift
//  festival beaconyx
//
//  Created by Beaconyx Corp. on 12/11/2019.
//  Copyright © 2019 Beaconyx Corp. All rights reserved.
//

import UIKit
import Parse

class SearchViewController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var topTitleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sort1Label: UILabel!
    @IBOutlet weak var sort2Label: UILabel!
    @IBOutlet weak var onView: UIView!
    @IBOutlet weak var alphaView: UIView!
    
    var selectedSortIndex: String = "B" // default 인기순
    var dic = [[String:AnyObject]]()
    var skipIndex: Int = 1 // default 1
    
    var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        textField.delegate = self
        
        mCoordinate = appDelegate.getLocation()
        
        UIDataConfig()
    }
    
    func UIDataConfig() {
        self.topTitleLabel.text = appDelegate.languageDic["search"]
        self.sort1Label.text = appDelegate.languageDic["list_order_favor"]
        self.sort2Label.text = appDelegate.languageDic["list_order_title"]
        
        // 스토리보드에서 알파를 설정하게되면 하위 모든 뷰가 알파적용이 들어감
        self.alphaView.backgroundColor = UIColor(white: 1, alpha: 0.3)
    }
    
    // 인기순/제목순 정렬
    @IBAction func sortButtonTapped(_ sender: UIButton) {
        
        // Internet checking
        if Reachability.isConnectedToNetwork() {
            userprint(output: "Internet connection available")
        } else {
            userprint(output: "Internet connection not available")
            notAvailableAlert()
        }
        
        /* tag 1 : 인기순
         * tag 2 : 제목순
         */
        let tag = sender.tag
        var tagValue = ""
        
        switch tag {
        case 1:
            tagValue = "B" // 인기순
            break
            
        case 2:
            tagValue = "A" // 제목순
            break
            
        default: break
        }
        
        // 버튼 중복처리 방지
        if selectedSortIndex == tagValue {
            return
        } else {
            selectedSortIndex = tagValue
            
            self.skipIndex = 1 // 초기화
            
            labelColorChange(index: tag)
            if (textField.text?.count)! >= 2 {
                getSearchData(sort: self.selectedSortIndex)
            }
            
        }
    }
    
    // MARK:- Label Color Change
    func labelColorChange(index: Int) {
        switch index {
        case 1:
            sort1Label.textColor = definePinkColor
            sort2Label.textColor = .darkGray
            break
            
        case 2:
            sort1Label.textColor = .darkGray
            sort2Label.textColor = definePinkColor
            break
            
        default:
            break
        }
    }
    
    func getSearchData(sort: String) {
        showActivityView(onView: self.view)
        
        // 한글의 경우 url 호출 때 인코딩을 해주지 않으면 쿼리를 작성하는 부분에서 이중 인코딩이 들어가게 되어 에러가 발생한다.
        let encodedKeyword = (self.textField.text)?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = requestEventSearchUrl(language: appDelegate.selectedLanguage,
        keyword: encodedKeyword!, numOfRows: queryLimit, pageNo: skipIndex, arrange: sort)
        
        // request
        requestTourAPI(url: url) { (result) in
            // response
            switch result {
                
            case .success(let data):
                self.dic = data
                userprint(output: "RequestEventSearch Success. make tableView")
                self.skipIndex += 1
                
                self.makeTableView()
                
            case .zeroData:
                let view = NoDataView(frame: self.onView.bounds)
                self.onView.addSubview(view)
                
            case .fail(let error):
                userprint(output: "Request Event Search Error : \(error)")
            }
            self.removeActivityView()
        }
    }
    
    func makeTableView() {
        self.tableView = UITableView()
        
        let nibName = UINib(nibName: "EventListViewCell", bundle: nil)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(nibName, forCellReuseIdentifier: "eventListCell")
        // estimateRowHeight가 설정되지 않으면 디폴트 값으로 이동하여 스크롤이 점프하는 현상이 발생
        tableView.estimatedRowHeight = 265
        
        self.tableView.frame = CGRect(x: 0, y: 0, width: self.onView.frame.width, height: self.onView.frame.height)
        
        self.onView.addSubview(tableView)
    }
    
    @IBAction func searchButtonTapped(_ sender: AnyObject?) {
        // Internet checking
        if Reachability.isConnectedToNetwork() {
            userprint(output: "Internet connection available")
        } else {
            userprint(output: "Internet connection not available")
            notAvailableAlert()
        }
        
        textField.resignFirstResponder()
        self.skipIndex = 1 // 초기화
        // Check Textfield's length. minimum size is 2 Characters
        if (self.textField.text?.count)! >= 2 {
            
            getSearchData(sort: self.selectedSortIndex)
            
        } else {
            // have to edit more 2 characters
            let message = appDelegate.languageDic["search_invalid"]
            self.view.makeToast(message, duration: 2.0, position: CSToastPositionCenter)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // 텍스트필드에서 리턴키를 눌렀을 때 키보드를 초기화 시키는 함수
        textField.resignFirstResponder()
        // 버튼액션 이벤트 호출
        self.searchButtonTapped(nil)
        
        return true
    }

}

// MARK:- TABLEVIEW DELEGATE
extension SearchViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dic.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventListCell") as! EventListViewCell
        let row = indexPath.row

        // 선택시 틴트효과 끄기
        cell.selectionStyle = .none
        
        // 날짜가 나오지 않는 관계로 날짜행 제거
        cell.subTitleViewHeight.constant = 0
        
        cell.dateLabel.text = ""
        
        // 타이틀 설정
        if let title = dic[row]["title"] {
            cell.titleLabel.text = String(describing: title)
        }
        
        // SNS 활성화
        if let ctid = dic[row]["contenttypeid"] {
            switch String(describing: ctid) {
            case "15", "85":
                cell.snsView.isHidden = false
                print("** false \(String(describing: ctid))")
            default:
                cell.snsView.isHidden = true
                print("** true \(String(describing: ctid))")
            }
        }
        
        // 버튼 태그 설정
        cell.youtubeButton.tag = row
        cell.youtubeButton.addTarget(self, action: #selector(snsButtonTapped(_:)), for: .touchUpInside)
        cell.instaButton.tag = row
        cell.instaButton.addTarget(self, action: #selector(snsButtonTapped(_:)), for: .touchUpInside)
        cell.naverButton.tag = row
        cell.naverButton.addTarget(self, action: #selector(snsButtonTapped(_:)), for: .touchUpInside)
        
        // 스크랩 버튼 설정
        cell.scrapButton.tag = row
        cell.scrapButton.addTarget(self, action: #selector(scrapButtonTapped(_:)), for: .touchUpInside)
        
        if findScrapedValue(cid: String(describing: dic[row]["contentid"])) {
            // true
            cell.scrapImageView.image = UIImage(named: "ic_heart_red.png")
        } else {
            cell.scrapImageView.image = UIImage(named: "ic_heart_grey.png")
        }

        // 이미지 설정 -> 캐싱이 아직 안되었을 때는 url로 가져오고 캐싱된 후 리로드 부터 캐싱된 이미지로 로드
        let cid = String(describing: dic[row]["contentid"]!)
        
        if AFImageCache.image(withIdentifier: cid) == nil {
            if let url = dic[row]["firstimage"] {
                cell.cellImageView.af_setImage(withURL: URL(string: String(describing:url))!)
            } else {
                cell.cellImageView.image = UIImage(named: "img_no.png")
            }
            
        } else {
            cell.cellImageView.image = AFImageCache.image(withIdentifier: cid)
        }

        // 조회수 (ReadCount) 설정
        if let readcount = dic[row]["readcount"] {
            cell.readcountLabel.text = String(describing: readcount)
        }
        
        // 거리계산
        if let mapx = dic[row]["mapx"], let mapy = dic[row]["mapy"] {
            let distance = getDistance(startX: (mapx.doubleValue)!,
                                       startY: (mapy.doubleValue)!,
                                       endX: mCoordinate.latitude,
                                       endY: mCoordinate.longitude)
            
            cell.distanceLabel.text = distance
        }

        // 랜더링 .. 특정 모서리만 깎는 roundCorners를 사용하게되면 렌더링이 마구잡이 형식으로 변함
        // 해당 함수내부 설정 문제인듯. --> 모든 코너를 고정으로 깎는 cornerRadius로 변경
        cell.labelView.cornerRadius = 15
        cell.proceedView.cornerRadius = 10
        cell.labelView.backgroundColor = definePurpleColor // 설정 자체에 알파값 있음 (0.6)
        
        return cell
    }
}

extension SearchViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ctid = String(describing: self.dic[indexPath.row]["contenttypeid"]!)
        
        switch ctid {
        case "15", "85": // 행사, 축제
            let nextView = self.storyboard?.instantiateViewController(withIdentifier: "EventDetailViewController") as! EventDetailViewController
            
            nextView.contentId = String(describing: dic[indexPath.row]["contentid"]!)
            nextView.eventTitle = String(describing: dic[indexPath.row]["title"]!)
            nextView.contentTypeId = String(describing: dic[indexPath.row]["contenttypeid"]!)
            
            self.navigationController?.pushViewController(nextView, animated: true)
            
            break
            
        default: // 그 외
            let nextView = self.storyboard?.instantiateViewController(withIdentifier: "EtcDetailViewController") as! EtcDetailViewController
            
            nextView.contentId = String(describing: dic[indexPath.row]["contentid"]!)
            nextView.eventTitle = String(describing: dic[indexPath.row]["title"]!)
            nextView.contentTypeId = String(describing: dic[indexPath.row]["contenttypeid"]!)
            
            self.navigationController?.pushViewController(nextView, animated: true)
            
            break
        }
        
//        let nextView = self.storyboard?.instantiateViewController(withIdentifier: "EventDetailViewController") as! EventDetailViewController
//
//        nextView.contentId = String(describing: dic[indexPath.row]["contentid"]!)
//        nextView.eventTitle = String(describing: dic[indexPath.row]["title"]!)
//        nextView.contentTypeId = String(describing: dic[indexPath.row]["contenttypeid"]!)
//
//        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    // while scrolling to load table data
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // loadMore를 실행할 indexPath.row 위치
        let lastElement = dic.count - 5
        
        let count = self.dic.count // 현재 데이터 개수
        let totalCount = queryLimit * (self.skipIndex - 1) // 10개 씩 가져올 경우 있어야 할 개수
        
        print("index: \(indexPath.row), count : \(count), total: \(totalCount)")
        
        if indexPath.row > lastElement {
            // 현재 데이터 개수 >= 전체 카운터 개수 (10개 씩 정상적으로 가져오는 경우)
            if count >= totalCount {
                if loadMoreFinish {
                    loadmore()
                    
                    return
                }
                
            } else {
                /* 전체 데이터 개수 33개 가정
                 * 3회차 loadMore 시 변수 값 : count(30), totalCount(30)
                 * 4회차 loadMore 시 변수 값 : count(33), totalCount(40)
                 * --> 즉 더 이상 로드 할 내용이 없음. loadMore Done.
                 */
                userprint(output: "더 이상 가져올 데이터가 없습니다.")
            }
        }
    }
    
    func loadmore() {
        loadMoreFinish = false
        // 백그라운드 스레드 안에 메인 스레드가 있어야 앱이 멈추지 않고 연속적으로 동작함
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.main.async {
                // 한글의 경우 url 호출 때 인코딩을 해주지 않으면 쿼리를 작성하는 부분에서 이중 인코딩이 들어가게 되어 에러가 발생한다.
                let encodedKeyword = (self.textField.text)?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                print("limit: \(self.queryLimit), skip : \(self.skipIndex)")
                let url = requestEventSearchUrl(language: self.appDelegate.selectedLanguage,
                                                keyword: encodedKeyword!,
                                                numOfRows: self.queryLimit,
                                                pageNo: self.skipIndex,
                                                arrange: "B")
                requestTourAPI(url: url) { (result) in
                    
                    switch result {
                        
                    case .success(let data):
                        self.dic.append(contentsOf: data)
                        userprint(output: "RequestEventSearch Success. insert tableView")
                        
                        self.skipIndex += 1
                        
                        self.tableView.reloadData()
                        self.loadMoreFinish = true
                        
                    case .zeroData:
                        break
                        
                    case .fail(let error):
                        userprint(output: "Request Event Search Error : \(error)")
                    }
                }
            }
        }
    }
}


extension SearchViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        if tableView != nil {
            self.tableView.reloadData()
        }
    }
    
    @objc func snsButtonTapped(_ sender: UIButton) {
        print("\(sender.currentTitle!) Button Tapped. title is \(String(describing: dic[sender.tag]["title"]!))")
        
        snsLink(snsType: sender.currentTitle!, title: String(describing: dic[sender.tag]["title"]!))
    }
    @objc func scrapButtonTapped(_ sender: UIButton) {
        
        // Internet checking
        if Reachability.isConnectedToNetwork() {
            userprint(output: "Internet connection available")
        } else {
            userprint(output: "Internet connection not available")
            notAvailableAlert()
        }
        
        let index = IndexPath(row: sender.tag, section: 0)
        let cell = tableView.cellForRow(at: index) as! EventListViewCell
        let cid = String(describing: dic[sender.tag]["contentid"])
        
        if findScrapedValue(cid: cid) {
            print(findScrapedValue(cid: cid))
            // 스크랩되어 있으면 -> 스크랩 삭제/파스 Row 삭제
            cell.scrapImageView.image = UIImage(named: "ic_heart_grey.png")
            changeScrapesParsing(uid: appDelegate.keyChain!, cid: cid, save: false) { (result) in
                if result {
                    getScrapesParsing(uid: self.appDelegate.keyChain!, coor: self.mCoordinate)
                }
            }
            
            
        } else {
            print(findScrapedValue(cid: cid))
            // 스크랩되어 있지 않으면 -> 스크랩 등록/파스 Row 추가
            cell.scrapImageView.image = UIImage(named: "ic_heart_red.png")
            changeScrapesParsing(uid: appDelegate.keyChain!, cid: cid, save: true) { (result) in
                if result {
                    getScrapesParsing(uid: self.appDelegate.keyChain!, coor: self.mCoordinate)
                }
            }
        }
    }
}
