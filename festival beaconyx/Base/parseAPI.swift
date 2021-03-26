//
//  parseAPI.swift
//  festival beaconyx
//
//  Created by Beaconyx Corp. on 31/10/2019.
//  Copyright © 2019 Beaconyx Corp. All rights reserved.
//

import Foundation
import Parse

class parseContent {
    var firstimage: String!
    var eventstartdate: String!
    var eventenddate: String!
    var modifiedtime: String!
    var areacode: String!
    var title: String!
    var readcount: Int!
    var likecount: Int!
    var mapx: Double!
    var mapy: Double!
    var contentid: String!
    var mappoint: PFGeoPoint!
    var distance: Double!
    var pastNowFuture: String!
}

enum parseFinalResult {
    case success([parseContent])
    case fail(Error)
    case zeroData
}

func relationParsing(coor: CLLocationCoordinate2D, qLimit: NSInteger, kmLimit: Double, qSkip: Int, sort: Int, completion: @escaping (parseFinalResult) -> ()) {
    
    print("\n\n")
    userprint(output: "** \(coor.latitude)/\(coor.longitude) 기준 \(kmLimit)Km 이내의 행사중 \(qLimit)개를 \(qSkip)부터 가져옵니다. [\(sort) 정렬] **")
    let today = getToday()
    let myGeoPoint = PFGeoPoint(latitude: coor.latitude, longitude: coor.longitude)
    
    var dic = [parseContent]()
    
    let table = parseTable.originDataTableKey.self
    let className = getClassName(tableName: table.tableName)
    let query = PFQuery(className: className)
    
    // withinKilometers 이내의 데이터만 추출
    query.whereKey(table.mappoint, nearGeoPoint: myGeoPoint, withinKilometers: kmLimit)
    // 진행중 또는 진행예정 데이터만 추출
    query.whereKey(table.eventenddate, greaterThanOrEqualTo: today)
   
    // 정렬
    switch sort {
    case 1: // 거리순
        query.whereKey(table.mappoint, nearGeoPoint: myGeoPoint)
        break
    case 2: // 날짜순
        query.order(byAscending: table.eventstartdate)
        break
    case 3: // 인기순
        query.order(byDescending: table.readcount)
        break
    case 4: // 제목순
        query.order(byAscending: table.title)
        break
        
    case 5: // 내주변 축제 - 이번주 종료
//        let nextmonday = getThisWeekend()
        let dateboundary = getThisWeekend()
        
        /* <--------------------- (<) 시작일
         * 월--화--수--목--금--토--일--월(nextMonday)
         * (<=)-----------------> 종료일
         * enddate - startdate < 30
         */
        
        query.whereKey(table.eventstartdate, lessThan: dateboundary.nextMonday)
        query.whereKey(table.eventenddate, greaterThan: dateboundary.previousSunday)

        // 거리순정렬
        query.whereKey(table.mappoint, nearGeoPoint: myGeoPoint)
            
        default:
            break
    }
    
    // 쿼리 갯수 제한
    query.limit = qLimit
    
    // 어디서 부터 보여줄 지 (skip)
    query.skip = qSkip
    
    query.findObjectsInBackground(block: {(objects: [PFObject]?, error: Error?) in
        
        if let error = error {
            // The request failed
            userprint(output: "ERROR: \(error.localizedDescription)")
            completion(.fail(error))
                        
        } else if let objects = objects {
            // Success
            userprint(output: "** 가져온 데이터 \(objects.count)개 **")
            
            if objects.count == 0 {
                completion(.zeroData)
            } else {
                for object in objects {
                    
                    // 각 열에 맞게 데이터를 생성하고 최종적으로 딕셔너리 파일로 저장
                    let content = parseContent()
                    
                    content.contentid       = object.object(forKey: table.contentid) as? String
                    content.areacode        = object.object(forKey: table.areacode) as? String
                    content.eventenddate    = object.object(forKey: table.eventenddate) as? String
                    content.eventstartdate  = object.object(forKey: table.eventstartdate) as? String
                    content.firstimage      = object.object(forKey: table.firstimage) as? String
                    content.modifiedtime    = object.object(forKey: table.modifiedtime) as? String
                    content.title           = object.object(forKey: table.title) as? String
                    content.readcount       = object.object(forKey: table.readcount) as? Int
                    content.likecount       = object.object(forKey: table.likecount) as? Int
                    content.mapx            = object.object(forKey: table.mapx) as? Double
                    content.mapy            = object.object(forKey: table.mapy) as? Double
                    content.mappoint        = object.object(forKey: table.mappoint) as? PFGeoPoint
                    content.distance        = content.mappoint.distanceInKilometers(to: myGeoPoint)
                    
                    // 이미지 캐싱
                    if AFImageCache.image(withIdentifier: content.contentid) == nil {
                        print("[\(content.contentid!)] image caching")
                        AFImageCaching(cid: content.contentid!, url: content.firstimage)
                    }
                    
                    // 종료, 진행중, 예정
                    if (content.eventenddate < today) { // 종료일자 < 현재 --> 과거
                        content.pastNowFuture = "past"
                    } else if (content.eventstartdate > today) { // 시작일자 > 현재 --> 미래
                        content.pastNowFuture = "future"
                    } else {
                        content.pastNowFuture = "now"
                    }
                
                    dic.append(content)
                }
                completion(.success(dic))
                print("\n\n")
            }
        }
    })
}

// 메인화면에 들어가는 <금주진행중 내주변행사>용 쿼리
func relationParsingOnGoing(coor: CLLocationCoordinate2D, qLimit: NSInteger, kmLimit: Double, qSkip: Int, completion: @escaping (parseFinalResult) -> ()) {
    
    print("\n\n")
    userprint(output: "** \(coor.latitude)/\(coor.longitude) 기준 \(kmLimit)Km 이내의 행사중 \(qLimit)개를 \(qSkip)부터 가져옵니다. **")
    let today = getToday()
    let myGeoPoint = PFGeoPoint(latitude: coor.latitude, longitude: coor.longitude)
    
    var dic = [parseContent]()
    
    let table = parseTable.originDataTableKey.self
    let className = getClassName(tableName: table.tableName)
    let query = PFQuery(className: className)
    
    // withinKilometers 이내의 데이터만 추출
    query.whereKey(table.mappoint, nearGeoPoint: myGeoPoint, withinKilometers: kmLimit)
    // 진행중 또는 진행예정 데이터만 추출
    query.whereKey(table.eventenddate, greaterThanOrEqualTo: today)
    
    let dateboundary = getThisWeekend()
    
    /* <--------------------- (<) 시작일
     * 월--화--수--목--금--토--일--월(nextMonday)
     * (<=)-----------------> 종료일
     * enddate - startdate < 30
     */
    
    query.whereKey(table.eventstartdate, lessThan: dateboundary.nextMonday)
    query.whereKey(table.eventenddate, greaterThan: dateboundary.previousSunday)

    // 거리순정렬
    query.whereKey(table.mappoint, nearGeoPoint: myGeoPoint)
    
    // 쿼리 갯수 제한
    query.limit = qLimit
    
    // 어디서 부터 보여줄 지 (skip)
    query.skip = qSkip
    
    query.findObjectsInBackground(block: {(objects: [PFObject]?, error: Error?) in
        
        if let error = error {
            // The request failed
            userprint(output: "ERROR: \(error.localizedDescription)")
            completion(.fail(error))
                        
        } else if let objects = objects {
            // Success
            userprint(output: "** 가져온 데이터 \(objects.count)개 **")
            
            if objects.count == 0 {
                completion(.zeroData)
            } else {
                for object in objects {
                    let start = object.object(forKey: table.eventstartdate) as! String
                    let end = object.object(forKey: table.eventenddate) as! String
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyyMMdd"
                    
                    let startDate = formatter.date(from: start)!
                    let endDate = formatter.date(from: end)!
                    
                    let gap = endDate.timeIntervalSince(startDate) / 86400 // sec로 계산되어 있으므로 day로 변경해준다.
                    let title = object.object(forKey: table.title) as? String
                    
                    // 차이가 한달보다 작은경우
                    if gap <= 30 {
                        // 각 열에 맞게 데이터를 생성하고 최종적으로 딕셔너리 파일로 저장
                        let content = parseContent()
                        
                        content.contentid       = object.object(forKey: table.contentid) as? String
                        content.areacode        = object.object(forKey: table.areacode) as? String
                        content.eventenddate    = object.object(forKey: table.eventenddate) as? String
                        content.eventstartdate  = object.object(forKey: table.eventstartdate) as? String
                        content.firstimage      = object.object(forKey: table.firstimage) as? String
                        content.modifiedtime    = object.object(forKey: table.modifiedtime) as? String
                        content.title           = object.object(forKey: table.title) as? String
                        content.readcount       = object.object(forKey: table.readcount) as? Int
                        content.likecount       = object.object(forKey: table.likecount) as? Int
                        content.mapx            = object.object(forKey: table.mapx) as? Double
                        content.mapy            = object.object(forKey: table.mapy) as? Double
                        content.mappoint        = object.object(forKey: table.mappoint) as? PFGeoPoint
                        content.distance        = content.mappoint.distanceInKilometers(to: myGeoPoint)
                        
                        // 이미지 캐싱
                        if AFImageCache.image(withIdentifier: content.contentid) == nil {
                            print("[\(content.contentid!)] image caching")
                            AFImageCaching(cid: content.contentid!, url: content.firstimage)
                        }
                        
                        // 종료, 진행중, 예정
                        if (content.eventenddate < today) { // 종료일자 < 현재 --> 과거
                            content.pastNowFuture = "past"
                        } else if (content.eventstartdate > today) { // 시작일자 > 현재 --> 미래
                            content.pastNowFuture = "future"
                        } else {
                            content.pastNowFuture = "now"
                        }
                    
                        dic.append(content)
                    }
                }
                completion(.success(dic))
                print("\n\n")
            }
        }
    })
}

func locationParsing(coor: CLLocationCoordinate2D, qLimit: NSInteger, qSkip: Int, area: String, sort: Int, completion: @escaping (parseFinalResult) -> ()) {
    
    let today = getToday()
    let myGeoPoint = PFGeoPoint(latitude: coor.latitude, longitude: coor.longitude)
    
    var dic = [parseContent]()
    var imageDic = [String : String]()
    
    let table = parseTable.originDataTableKey.self
    let className = getClassName(tableName: table.tableName)
    let query = PFQuery(className: className)
    
    if area != "0" {
        // '전국' 행사가 아닐때 지역 필터를 걸어준다.
        // areaCode가 같은 데이터만 추출
        query.whereKey(table.areacode, equalTo: area)
    }
    
    // 진행중 또는 진행예정 데이터만 추출
    query.whereKey(table.eventenddate, greaterThan: today)
    
    query.skip = qSkip
    
    // 정렬
    switch sort {
        case 1: // 날짜순
            query.order(byAscending: table.eventstartdate)
            break
        case 2: // 인기순
            query.order(byDescending: table.readcount)
            break
        case 3: // 제목순
            query.order(byAscending: table.title)
            break

        default:
            break
    }
    
    // 쿼리 갯수 제한
    query.limit = qLimit
    
    query.findObjectsInBackground(block: {(objects: [PFObject]?, error: Error?) in
        
        if let error = error {
            // The request failed
            userprint(output: "ERROR: \(error.localizedDescription)")
            completion(.fail(error))
                        
        } else if let objects = objects {
            // Success
            userprint(output: "data Count : \(objects.count)")
            
            if objects.count == 0 {
                completion(.zeroData)
                
            } else {
                for object in objects {
                    // 각 열에 맞게 데이터를 생성하고 최종적으로 딕셔너리 파일로 저장
                    let content = parseContent()
                    
                    content.contentid = object.object(forKey: table.contentid) as? String
                    content.areacode = object.object(forKey: table.areacode) as? String
                    content.eventenddate = object.object(forKey: table.eventenddate) as? String
                    content.eventstartdate = object.object(forKey: table.eventstartdate) as? String
                    content.firstimage = object.object(forKey: table.firstimage) as? String
                    content.modifiedtime = object.object(forKey: table.modifiedtime) as? String
                    content.title = object.object(forKey: table.title) as? String
                    content.readcount = object.object(forKey: table.readcount) as? Int
                    content.likecount = object.object(forKey: table.likecount) as? Int
                    content.mapx = object.object(forKey: table.mapx) as? Double
                    content.mapy = object.object(forKey: table.mapy) as? Double
                    content.mappoint = object.object(forKey: table.mappoint) as? PFGeoPoint
                    content.distance = content.mappoint.distanceInKilometers(to: myGeoPoint)
                    
                    imageDic.updateValue(content.contentid!, forKey: "contentid")
                    
                    // 이미지 캐싱
                    if AFImageCache.image(withIdentifier: content.contentid) == nil {
                        print("[\(content.contentid!)] image caching")
                        AFImageCaching(cid: content.contentid!, url: content.firstimage)
                    }
                    
                    // 종료, 진행중, 예정
                    if (content.eventenddate < today) { // 종료일자 < 현재 --> 과거
                        content.pastNowFuture = "past"
                    } else if (content.eventstartdate > today) { // 시작일자 > 현재 --> 미래
                        content.pastNowFuture = "future"
                    } else {
                        content.pastNowFuture = "now"
                    }
                    
                    dic.append(content)
                }
                completion(.success(dic))
            }
        }
    })
}

func getScrapesParsing(uid: String, coor: CLLocationCoordinate2D) {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let myGeoPoint = PFGeoPoint(latitude: coor.latitude, longitude: coor.longitude)
    let today = getToday()
    let table = parseTable.AccountTablekey.self
    let query = PFQuery(className: table.tableName)
    
    var dic = [parseContent]()
    
    // 유저아이디가 있을 때
    query.whereKey(table.userId, equalTo: uid)
    query.getFirstObjectInBackground { (object: PFObject?, error: Error?) in
        if let error = error {
            // The query failed
            userprint(output: error.localizedDescription)
                        
        } else if let object = object {
            // The query succeeded with a matching result
            let relation = object.relation(forKey: "scrapes")
            let subQuery = relation.query()
            let subTable = parseTable.originDataTableKey.self
            
            subQuery.findObjectsInBackground(block: {(objects: [PFObject]?, error: Error?) in
                if error == nil {
                    if objects?.count == 0 {
                        // 스크랩 된 데이터 없음
                        appDelegate.scrapArray = []
                    } else {
                        // 스크랩 된 데이터 저장
                        for object in objects! {
                            let content = parseContent()
                            
                            content.contentid = object.object(forKey: subTable.contentid) as? String
                            content.areacode = object.object(forKey: subTable.areacode) as? String
                            content.eventenddate = object.object(forKey: subTable.eventenddate) as? String
                            content.eventstartdate = object.object(forKey: subTable.eventstartdate) as? String
                            content.firstimage = object.object(forKey: subTable.firstimage) as? String
                            content.modifiedtime = object.object(forKey: subTable.modifiedtime) as? String
                            content.title = object.object(forKey: subTable.title) as? String
                            content.readcount = object.object(forKey: subTable.readcount) as? Int
                            content.likecount = object.object(forKey: subTable.likecount) as? Int
                            content.mapx = object.object(forKey: subTable.mapx) as? Double
                            content.mapy = object.object(forKey: subTable.mapy) as? Double
                            content.mappoint = object.object(forKey: subTable.mappoint) as? PFGeoPoint
                            content.distance = content.mappoint.distanceInKilometers(to: myGeoPoint)
                            
                            // 이미지 캐싱
                            if AFImageCache.image(withIdentifier: content.contentid) == nil {
                                print("[\(content.contentid!)] image caching")
                                AFImageCaching(cid: content.contentid!, url: content.firstimage)
                            }
                                                                                    
                            // 종료, 진행중, 예정
                            if (content.eventenddate < today) { // 종료일자 < 현재 --> 과거
                                content.pastNowFuture = "past"
                            } else if (content.eventstartdate > today) { // 시작일자 > 현재 --> 미래
                                content.pastNowFuture = "future"
                            } else {
                                content.pastNowFuture = "now"
                            }
                            
                            dic.append(content)
                        }
                        appDelegate.scrapArray = dic
                        userprint(output: "get scrapes array success : \(appDelegate.scrapArray)")
                    }
                } else { userprint(output: error!) }
            })
            
        } else {
            // The query succeeded but no matching result was found
            userprint(output: "no matching result")
        }
    }
}

func changeScrapesParsing(uid: String, cid: String, save: Bool, completion: @escaping (Bool) -> ()) {
    let dataTable = parseTable.originDataTableKey.self
    let dataQuery = PFQuery(className: dataTable.tableName)
    
    let userTable = parseTable.AccountTablekey.self
    let userQuery = PFQuery(className: userTable.tableName)
    
    dataQuery.whereKey(dataTable.contentid, equalTo: cid)
    dataQuery.getFirstObjectInBackground (block: {(object: PFObject?, error: Error?) in
        if error == nil {
            // cid 존재 -> Account에 UID가 존재하는지 확인
            userQuery.whereKey(userTable.userId, equalTo: uid)
            
            if let user = try? userQuery.getFirstObject() {
                // 해당 계정이 존재
                let relation = user.relation(forKey: "scrapes")
                
                if save { // 저장
                    relation.add(object!)
                } else { // 삭제
                    relation.remove(object!)
                }
                
                user.saveInBackground { (success, error) in
                    if error != nil {
                        userprint(output: error!)
                    }
                    completion(success)
                }
            }
            
        } else {
            userprint(output: "There is no result matching CID. error : \(error!.localizedDescription)")
        }
    })
}

func getClassName(tableName: String) -> String{
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let lang = appDelegate.selectedLanguage
    var lang2: String!
    
    switch lang {
        
    case "Kor":
        lang2 = ""
        break
    case "Eng":
        lang2 = "_en"
        break
    case "Spn":
        lang2 = "_es"
        break
    case "Jpn":
        lang2 = "_ja"
        break
    case "Fre":
        lang2 = "_fr"
        break
    case "Ger":
        lang2 = "_de"
        break
    case "Rus":
        lang2 = "_ru"
        break
    case "Chs":
        lang2 = "_CN"
        break
    case "Cht":
        lang2 = "_TW"
        break
        
    default:
        break
    }
    return tableName + lang2
}
