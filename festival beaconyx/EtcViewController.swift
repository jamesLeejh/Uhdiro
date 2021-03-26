//
//  EtcViewController.swift
//  festival beaconyx
//
//  Created by Beaconyx Corp. on 21/11/2019.
//  Copyright © 2019 Beaconyx Corp. All rights reserved.
//

import UIKit

class EtcViewController: BaseViewController {

    @IBOutlet weak var topTitleLabel: UILabel!
    @IBOutlet weak var onView: UIView!
    
    var tableView: UITableView!
    var ctid: Int! // contentsTypeId
    var mapx: String!
    var mapy: String!
    var skipIndex = 1
    
    var dic = [[String:AnyObject]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 위치 정보 갱신
        mCoordinate = appDelegate.getLocation()
        
        switch ctid {
        case apiparams.contentsTypeID.culturalFacility, apiparams.contentsTypeID_ML.culturalFacility:
            self.topTitleLabel.text = appDelegate.languageDic["fest_btn_1"]
            break
            
        case apiparams.contentsTypeID.attractions, apiparams.contentsTypeID_ML.attractions:
            self.topTitleLabel.text = appDelegate.languageDic["fest_btn_2"]
            break
            
        case apiparams.contentsTypeID.stay, apiparams.contentsTypeID_ML.stay:
            self.topTitleLabel.text = appDelegate.languageDic["fest_btn_3"]
            break
            
        case apiparams.contentsTypeID.shopping, apiparams.contentsTypeID_ML.shopping:
            self.topTitleLabel.text = appDelegate.languageDic["fest_btn_4"]
            break
            
        case apiparams.contentsTypeID.restaurant, apiparams.contentsTypeID_ML.restaurant:
            self.topTitleLabel.text = appDelegate.languageDic["fest_btn_5"]
            break
            
        default:
            break
        }
        
        getNearbyData()
    }
    
    func getNearbyData() {
        showActivityView(onView: self.view)
        
        let url = requestEventNearbyUrl(language: self.appDelegate.selectedLanguage, numOfRows: self.queryLimit, pageNo: self.skipIndex, arrange: "E", mapx: self.mapx, mapy: self.mapy, contenttypeid: ctid, radius: 10000)
        
        // request
        requestTourAPI(url: url) { (result) in
            
            switch result {
                
            case .success(let data):
                self.dic = data
                userprint(output: "RequestEventNearby Success. make tableView")
                self.skipIndex += 1
                
                self.makeTableView()
                
            case .zeroData:
                let view = NoDataView(frame: self.onView.bounds)
                self.onView.addSubview(view)
                
            case .fail(let error):
                userprint(output: "Request Event Nearby Error: \(error)")
            }
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
        
        removeActivityView()
    }
}

// MARK:- TABLEVIEW DELEGATE
extension EtcViewController: UITableViewDataSource {
    
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
        cell.snsView.isHidden = true
        cell.labelView.backgroundColor = definePurpleColor // 설정 자체에 알파값 있음 (0.6)
        
        return cell
    }
}

extension EtcViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nextView = self.storyboard?.instantiateViewController(withIdentifier: "EtcDetailViewController") as! EtcDetailViewController
        
        nextView.contentId = String(describing: dic[indexPath.row]["contentid"]!)
        nextView.eventTitle = String(describing: dic[indexPath.row]["title"]!)
        nextView.contentTypeId = String(describing: dic[indexPath.row]["contenttypeid"]!)
        
        self.navigationController?.pushViewController(nextView, animated: true)
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
                let url = requestEventNearbyUrl(language: self.appDelegate.selectedLanguage,
                                                numOfRows: self.queryLimit, pageNo: self.skipIndex, arrange: "E",
                                                mapx: self.mapx, mapy: self.mapy,
                                                contenttypeid: self.ctid, radius: 10000)
                
                requestTourAPI(url: url) { (result) in
                    
                    switch result {
                        
                    case .success(let data):
                        self.dic.append(contentsOf: data)
                        userprint(output: "RequestEventSearch Success. insert tableView")
                        
                        self.skipIndex += 1
                        
                        self.tableView.reloadData()
                        self.loadMoreFinish = true
                        
                    case .zeroData:
                        userprint(output: "더 이상 가져올 데이터가 없습니다.")
                        break
                        
                    case .fail(let error):
                        userprint(output: "Request Event Search Error : \(error)")
                    }
                }
            }
        }
    }
}
