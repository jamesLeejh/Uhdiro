//
//  ScrapViewController.swift
//  festival beaconyx
//
//  Created by Beaconyx Corp. on 12/11/2019.
//  Copyright © 2019 Beaconyx Corp. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class ScrapViewController: BaseViewController {

    @IBOutlet weak var topTitleLabel: UILabel!
    @IBOutlet weak var onView: UIView!
    
    var emptyView: UIView!
    var tableView: UITableView!
    var dic = [parseContent]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.dic = appDelegate.scrapArray
        self.topTitleLabel.text = appDelegate.languageDic["main_button_4"]
        
        self.tableView = nil
        
        emptyView = UIView.init(frame: self.onView.frame)
        emptyView.backgroundColor = .white
        emptyView.isHidden = false
        
        self.onView.addSubview(emptyView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // 여기서 테이블 뷰를 생성해주어야 화면크기에 정확히 맞게 설정됨
        self.makeTableView()
    }
    
    func makeTableView() {
        showActivityView(onView: self.view)
        
        self.tableView = UITableView()
        
        self.tableView = UITableView.init(frame: self.onView.frame)
        
        let nibName = UINib(nibName: "EventListViewCell", bundle: nil)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.register(nibName, forCellReuseIdentifier: "eventListCell")
        
        // estimateRowHeight가 설정되지 않으면 디폴트 값으로 이동하여 스크롤이 점프하는 현상이 발생
        tableView.estimatedRowHeight = 265
        
        self.tableView.frame = CGRect(x: 0, y: 0, width: self.onView.frame.width, height: self.onView.frame.height)

        self.onView.addSubview(tableView)
        
        removeActivityView()
        self.emptyView.isHidden = true
    }
    
    @objc func snsButtonTapped(_ sender: UIButton) {
        print("\(sender.currentTitle!) Button Tapped. title is \(dic[sender.tag].title!)")
        
        snsLink(snsType: sender.currentTitle!, title: dic[sender.tag].title!)
    }
    
    @objc func scrapButtonTapped(_ sender: UIButton) {
        let index = IndexPath(row: sender.tag, section: 0)
        print("tag : \(sender.tag)")
        let cell = tableView.cellForRow(at: index) as! EventListViewCell
        let cid = dic[sender.tag].contentid
        
        if findScrapedValue(cid: cid!) {
            // 스크랩되어 있으면 -> 스크랩 삭제/파스 Row 삭제
            cell.scrapImageView.image = UIImage(named: "ic_heart_grey.png")
            changeScrapesParsing(uid: appDelegate.keyChain!, cid: cid!, save: false) { (result) in
                if result {
                    getScrapesParsing(uid: self.appDelegate.keyChain!, coor: self.mCoordinate)
                }
            }
            
        } else {
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

extension ScrapViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.dic.count > 0 {
            self.tableView.isHidden = false
            return self.dic.count
        } else {
            self.tableView.isHidden = true
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventListCell") as! EventListViewCell
        let row = indexPath.row
        
        print("row: \(row)")
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
            } else {
                cell.proceedLabel.text = appDelegate.languageDic["list_item_end"]
                cell.proceedView.backgroundColor = .darkGray
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
        cell.labelView.backgroundColor = definePurpleColor // 설정 자체에 알파값 있음 (0.6)
        
        return cell
    }
}

extension ScrapViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nextView = self.storyboard?.instantiateViewController(withIdentifier: "EventDetailViewController") as! EventDetailViewController
        
        nextView.contentId = dic[indexPath.row].contentid!
        nextView.eventTitle = dic[indexPath.row].title!
        
        self.navigationController?.pushViewController(nextView, animated: true)
    }
}
