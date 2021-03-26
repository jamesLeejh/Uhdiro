//
//  AreaViewController.swift
//  festival beaconyx
//
//  Created by Beaconyx Corp. on 05/11/2019.
//  Copyright © 2019 Beaconyx Corp. All rights reserved.
//

import UIKit
import Parse

class AreaViewController: BaseViewController {
    
    @IBOutlet weak var onView: UIView!
    
    @IBOutlet weak var topTitle: UILabel!
    @IBOutlet weak var sort1Label: UILabel!
    @IBOutlet weak var sort2Label: UILabel!
    @IBOutlet weak var sort3Label: UILabel!
    
    var tableView: UITableView!
    
    var areaCode: String!
    
    var areaDic = [String:AnyObject]()
    var dic = [parseContent]()
    var selectedSortIndex = 1
    
    var skipIndex = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mCoordinate = appDelegate.getLocation()
        UIDataConfig()
        
        areaCode = String(describing: areaDic["code"]!)
        getLocationData(areaCode: areaCode, sort: selectedSortIndex)
    }
    
    func UIDataConfig() {
        let title = (appDelegate.languageDic["list_title"])!.replacingOccurrences(of: "%1$s", with: String(describing: self.areaDic["name"]!))
        self.topTitle.text = title
        self.sort1Label.text = appDelegate.languageDic["list_order_date"]
        self.sort2Label.text = appDelegate.languageDic["list_order_favor"]
        self.sort3Label.text = appDelegate.languageDic["list_order_title"]
    }
    
    @IBAction func sortButtonTapped(_ sender: UIButton) {
        // Internet checking
        if Reachability.isConnectedToNetwork() {
            userprint(output: "Internet connection available")
        } else {
            userprint(output: "Internet connection not available")
            notAvailableAlert()
        }
        
        /** 언어별로 글자 길이가 모두 다르기 때문에 AutoAdjustmentFontSize를 적용하기 위하여
         ** Label과 Button을 따로 사용하였음
         * tag 1 : 날짜순
         * tag 2 : 인기순
         * tag 3 : 제목순
         */
        
        // 버튼중복처리 방지
        if selectedSortIndex == sender.tag {
            return
        } else {
            selectedSortIndex = sender.tag
            
            self.skipIndex = 1 // skipIndex 초기화
            
            getLocationData(areaCode: areaCode, sort: selectedSortIndex)
            labelColorChange(index: selectedSortIndex)
        }
    }
    
    // MARK:- Location Parsing
    func getLocationData(areaCode: String, sort: Int) {
        showActivityView(onView: self.view)
        
        locationParsing(coor: mCoordinate, qLimit: queryLimit, qSkip: ((self.skipIndex - 1) * self.queryLimit), area: areaCode, sort: sort) { (result) in
            switch result {
            case .success(let data):
                self.dic = data
                
                userprint(output: "Location Parsing Success. reload tableview")
                
                self.tableView = nil
                self.makeTableView()
                
                self.skipIndex += 1
                
            case .zeroData:
                let view = NoDataView(frame: self.onView.bounds)
                self.onView.addSubview(view)
                
            case .fail(let error):
                userprint(output: "LocationParseError: \(error)")
            }
            
            self.removeActivityView()
        }
    }
    
    func makeTableView() {
        self.tableView = UITableView()
        
        let nibName = UINib(nibName: "EventListViewCell", bundle: nil)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(nibName, forCellReuseIdentifier: "eventListCell")
        
        // estimateRowHeight가 설정되지 않으면 디폴트 값으로 이동하여 스크롤이 점프하는 현상이 발생
        tableView.estimatedRowHeight = 265
        
        self.tableView.frame = CGRect(x: 0, y: 0, width: self.onView.frame.width, height: self.onView.frame.height)
        
        self.onView.addSubview(tableView)
    }

    // MARK:- Label Color Change
    func labelColorChange(index: Int) {
        switch index {
        case 1:
            sort1Label.textColor = definePinkColor
            sort2Label.textColor = .darkGray
            sort3Label.textColor = .darkGray
            break
            
        case 2:
            sort1Label.textColor = .darkGray
            sort2Label.textColor = definePinkColor
            sort3Label.textColor = .darkGray
            break
            
        case 3:
            sort1Label.textColor = .darkGray
            sort2Label.textColor = .darkGray
            sort3Label.textColor = definePinkColor
            break
            
        default:
            break
        }
    }
}

extension AreaViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dic.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventListCell") as! EventListViewCell
        let row = indexPath.row
        
        // 선택시 틴트효과 끄기
        cell.selectionStyle = .none
        
        // 타이틀 설정
        cell.titleLabel.text = dic[row].title!
        
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
        
        if findScrapedValue(cid: dic[row].contentid) {
            // true
            cell.scrapImageView.image = UIImage(named: "ic_heart_red.png")
        } else {
            cell.scrapImageView.image = UIImage(named: "ic_heart_grey.png")
        }
        
        // 기간 설정
        let start = datestringJoinDot(dateTime: dic[row].eventstartdate)
        let end = datestringJoinDot(dateTime: dic[row].eventenddate)
        cell.dateLabel.text = (start + " ~ " + end)
        
        // 이벤트 진행, 예정 등 표시
        if let proceed = dic[row].pastNowFuture {
            if proceed == "now" {
                cell.proceedLabel.text = appDelegate.languageDic["list_item_proceed"]
                cell.proceedView.backgroundColor = definePinkColor
            } else if proceed == "future" {
                cell.proceedLabel.text = appDelegate.languageDic["list_item_expected"]
                cell.proceedView.backgroundColor = .lightGray
            }
        }
        
        // 이미지 설정 -> 캐싱이 아직 안되었을 때는 url로 가져오고 캐싱된 후 리로드 부터 캐싱된 이미지로 로드
        if AFImageCache.image(withIdentifier: self.dic[row].contentid) == nil {
            cell.cellImageView.af_setImage(withURL: URL(string: dic[row].firstimage)!)
        } else {
            cell.cellImageView.image = AFImageCache.image(withIdentifier: self.dic[row].contentid)
        }

        // 조회수 (ReadCount) 설정
        cell.readcountLabel.text = String(dic[row].readcount)

        // 거리계산
        cell.distanceLabel.text = String(format: "%.1f km", dic[row].distance)
        
        // 랜더링 .. 특정 모서리만 깎는 roundCorners를 사용하게되면 렌더링이 마구잡이 형식으로 변함
        // 해당 함수내부 설정 문제인듯. --> 모든 코너를 고정으로 깎는 cornerRadius로 변경
        cell.labelView.cornerRadius = 30
        cell.proceedView.cornerRadius = 10
        cell.labelView.backgroundColor = definePurpleColor
        
        return cell
    }
}

extension AreaViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nextView = self.storyboard?.instantiateViewController(withIdentifier: "EventDetailViewController") as! EventDetailViewController
        
        nextView.contentId = dic[indexPath.row].contentid!
        nextView.eventTitle = dic[indexPath.row].title!
        
        self.navigationController?.pushViewController(nextView, animated: true)
    }

    // while scrolling to load table data
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // loadMore를 실행할 indexPath.row 위치
        let lastElement = dic.count - 5
        
        let count = self.dic.count // 현재 데이터 개수
        let totalCount = queryLimit * (self.skipIndex - 1) // 10개 씩 가져올 경우 있어야 할 개수
        
        if indexPath.row > lastElement {
            // 현재 데이터 개수 >= 전체 카운터 개수 (10개 씩 정상적으로 가져오는 경우)
            if count >= totalCount {
                if loadMoreFinish {
                    loadmore()
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
                locationParsing(coor: self.mCoordinate, qLimit: self.queryLimit, qSkip: (self.queryLimit * self.skipIndex), area: self.areaCode, sort: self.selectedSortIndex) { (result) in
                    
                    switch result {
                        
                    case .success(let data):
                        self.dic.append(contentsOf: data)
                        userprint(output: "[loadmore] parsing success. insert tableView")
                        
                        self.skipIndex += 1
                        
                        self.tableView.reloadData()
                        
                    case .fail(let error): userprint(output: "LocationParsingError: \(error)")
                    case .zeroData:
                        userprint(output: "there is zero data")
                    }
                }

                self.loadMoreFinish = true
            }

        }
    }
}

extension AreaViewController {
    @objc func snsButtonTapped(_ sender: UIButton) {
        print("\(sender.currentTitle!) Button Tapped. title is \(dic[sender.tag].title!)")
        
        snsLink(snsType: sender.currentTitle!, title: dic[sender.tag].title!)
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
        let cid = dic[sender.tag].contentid

        if findScrapedValue(cid: cid!) {
            print(findScrapedValue(cid: cid!))
            // 스크랩되어 있으면 -> 스크랩 삭제/파스 Row 삭제
            cell.scrapImageView.image = UIImage(named: "ic_heart_grey.png")
            changeScrapesParsing(uid: appDelegate.keyChain!, cid: cid!, save: false) { (result) in
                if result {
                    getScrapesParsing(uid: self.appDelegate.keyChain!, coor: self.mCoordinate)
                }
            }
            
            
        } else {
            print(findScrapedValue(cid: cid!))
            // 스크랩되어 있지 않으면 -> 스크랩 등록/파스 Row 추가
            cell.scrapImageView.image = UIImage(named: "ic_heart_red.png")
            changeScrapesParsing(uid: appDelegate.keyChain!, cid: cid!, save: true) { (result) in
                if result {
                    getScrapesParsing(uid: self.appDelegate.keyChain!, coor: self.mCoordinate)
                }
            }
        }
    }
    
    @objc override func viewWillAppear(_ animated: Bool) {
        if self.tableView != nil {
            self.tableView.reloadData()
        }
    }
}
