//
//  tourAPI.swift
//  festival beaconyx
//
//  Created by Beaconyx Corp. on 01/11/2019.
//  Copyright © 2019 Beaconyx Corp. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class apiparams {
    static let baseUrl = "http://api.visitkorea.or.kr/openapi/service/rest/"
    static let detailCommon = "/detailCommon"
    static let detailIntro  = "/detailIntro"
    static let detailImage  = "/detailImage"
    static let search       = "/searchKeyword"
    static let locationBase = "/locationBasedList"
    
    // request parameter
    static let numOfRows            = "&numOfRows="         // 한 페이지 결과 수
    static let pageNo               = "&pageNo="            // 현재 페이지 번호
    static let MobileOS             = "&MobileOS="          // iOS, AND, WIN, ETC
    static let MobileApp            = "&MobileApp="         // 서비스명 = 어플명
    static let ServiceKey           = "?ServiceKey="        // 공공데이터포털에서 발급받은 인증키
    static let areaCode             = "&areaCode="          // 지역코드
    static let contentTypeId        = "&contentTypeId="     // 관광타입 ID
    static let contentId            = "&contentId="         // 컨텐츠 타입
    static let cat1                 = "&cat1="              // 대분류 코드
    static let cat2                 = "&cat2="              // 중분류 코드
    static let cat3                 = "&cat3="              // 소분류 코드
    static let arrange              = "&arrange="           // 정렬 (A=제목순, B=조회순, C=수정일순, D=생성일순, E=거리순) | 대표이미지가 반드시 있는 정렬(O=제목순, P=조회순, Q=수정일순, R=생성일순)
    static let sigunguCode          = "&sigunguCode="       // 시군구코드(areaCode 필수)
    static let mapX                 = "&mapX="              // GPS X좌표(경도)
    static let mapY                 = "&mapY="              // GPS Y좌표(위도)
    static let radius               = "&radius="            // 거리반경 (단위 m) -- Max : 20000m
    static let keyword              = "&keyword="           // 검색 요청할 키워드 (국문 = 인코딩 필요)
    static let eventStartDate       = "&eventStartDate="    // 행사 시작일 (형식: YYYYMMDD)
    static let eventEndDate         = "&eventEndDate="      // 행사 종료일 (형식: YYYYMMDD)
    static let hanOK                = "&hanOK="             // 한옥 여부
    static let benikia              = "&benikia="           // 베니키아 여부
    static let goodstay             = "&goodstay="          // 굿스테이 여부
    static let defaultYN            = "&defaultYN="         // 기본정보 조회 여부
    static let firstImageYN         = "&firstImageYN="      // 원본, 썸네일 대표이미지 조회 여부
    static let areacodeYN           = "&areacodeYN="        // 지역코드, 시군구코드 조회 여부
    static let catcodeYN            = "&catcodeYN="         // 대,중,소 분류코드 조회 여부
    static let addrinfoYN           = "&addrinfoYN="        // 주소, 상세주소 조회 여부
    static let mapinfoYN            = "&mapinfoYN="         // 좌표 X,Y 조회 여부
    static let overviewYN           = "&overviewYN="        // 콘텐츠 개요 조회 여부
    static let imageYN              = "&imageYN="           // Y = 콘텐츠 이미지 조회, N = 음식점 타입의 음식메뉴 이미지
    static let subImageYN           = "&subImageYN="        // Y = 원본,썸네일 이미지 조회 | N = Null
    static let listYN               = "&listYN="            // 목록 구분 (Y = 목록, N = 개수)
    static let introYN              = "&introYN="           // 설명서에 없음
    
    static let json                 = "&_type=json"         // json으로 response
    
    // 앱 호출을 위한 파라미터 정의 - ContentTypeId 코드표 (Korean)
    struct contentsTypeID {
        static let attractions          = 12
        static let culturalFacility     = 14
        static let event_festival       = 15
        static let course               = 25
        static let reports              = 28
        static let stay                 = 32
        static let shopping             = 38
        static let restaurant           = 39
        static let transport            = 0 // 다국어만 서비스
    }
    // 앱 호출을 위한 파라미터 정의 - ContentTypeId 코드표 (Multi-Language)
    struct contentsTypeID_ML {
        static let attractions          = 76
        static let culturalFacility     = 78
        static let event_festival       = 85
        static let course               = 0 // 국문만 서비스
        static let reports              = 75
        static let stay                 = 80
        static let shopping             = 79
        static let restaurant           = 82
        static let transport            = 77 // 다국어만 서비스
    }
}


// 조회가능한 지역정보 (서울, 경기, 인천 등등)을 조회하기 위한 URL 작성
func requestAreaNameUrl(language: String) -> String {
    let getArea = "/areaCode"
    let srv = language + "Service" // KorService, EngService 등
    let url: String = apiparams.baseUrl     + srv       + getArea
                    + apiparams.ServiceKey  + appInfo.tourAPIKey
                    + apiparams.numOfRows   + "100"
                    + apiparams.pageNo      + "1"
                    + apiparams.MobileOS    + "IOS"
                    + apiparams.MobileApp   + "festivalApp"    + apiparams.json
    
    return url
}

func requestEventDetailIntroUrl(language: String, contentId: String, contentTypeId: String) -> String {
    let srv = language + "Service" // KorService, EngService 등
    let url: String = apiparams.baseUrl         + srv           + apiparams.detailIntro
                    + apiparams.ServiceKey      + appInfo.tourAPIKey
                    + apiparams.contentTypeId   + contentTypeId
                    + apiparams.contentId       + contentId
                    + apiparams.defaultYN       + "Y"
                    + apiparams.listYN          + "Y"
                    + apiparams.MobileApp       + "festivalApp"
                    + apiparams.MobileOS        + "IOS"         + apiparams.json
    
    return url
}

func requestEventDetailCommonUrl(language: String, contentId: String, contentTypeId: String) -> String {
    let srv = language + "Service" // KorService, EngService 등
    let url: String = apiparams.baseUrl         + srv           + apiparams.detailCommon
                    + apiparams.ServiceKey      + appInfo.tourAPIKey
                    + apiparams.contentTypeId   + contentTypeId
                    + apiparams.contentId       + contentId
                    + apiparams.introYN         + "Y"
                    + apiparams.listYN          + "Y"
                    + apiparams.firstImageYN    + "Y"
                    + apiparams.areacodeYN      + "Y"
                    + apiparams.catcodeYN       + "Y"
                    + apiparams.addrinfoYN      + "Y"
                    + apiparams.mapinfoYN       + "Y"
                    + apiparams.overviewYN      + "Y"
                    + apiparams.mapinfoYN       + "Y"
                    + apiparams.defaultYN       + "Y"
                    + apiparams.MobileApp       + "festivalApp"
                    + apiparams.MobileOS        + "IOS"         + apiparams.json
    
    return url
}

func requestEventDetailImageUrl(language: String, contentId: String, contentTypeId: String) -> String {
    let srv = language + "Service" // KorService, EngService 등
    let url: String = apiparams.baseUrl         + srv           + apiparams.detailImage
                    + apiparams.ServiceKey      + appInfo.tourAPIKey
                    + apiparams.contentTypeId   + contentTypeId
                    + apiparams.contentId       + contentId
                    + apiparams.imageYN         + "Y"
                    + apiparams.MobileApp       + "festivalApp"
                    + apiparams.MobileOS        + "IOS"         + apiparams.json
    
    return url
}

func requestEventSearchUrl(language: String, keyword: String, numOfRows: Int, pageNo: Int, arrange: String) -> String {
    let srv = language + "Service"
    let url: String = apiparams.baseUrl         + srv           + apiparams.search
                    + apiparams.ServiceKey      + appInfo.tourAPIKey
                    + apiparams.keyword         + keyword
                    + apiparams.numOfRows       + String(numOfRows)
                    + apiparams.pageNo          + String(pageNo)
                    + apiparams.arrange         + arrange
                    + apiparams.listYN          + "Y"
                    + apiparams.MobileOS        + "IOS"
                    + apiparams.MobileApp       + "festivalApp" + apiparams.json
    
    return url
}

func requestEventNearbyUrl(language: String, numOfRows: Int, pageNo: Int, arrange: String, mapx: String, mapy: String, contenttypeid: Int, radius: Int) -> String {
    let srv = language + "Service"
    let url: String = apiparams.baseUrl        + srv           + apiparams.locationBase
                    + apiparams.ServiceKey      + appInfo.tourAPIKey
                    + apiparams.contentTypeId   + String(contenttypeid)
                    + apiparams.mapX            + mapx
                    + apiparams.mapY            + mapy
                    + apiparams.radius          + String(radius)
                    + apiparams.numOfRows       + String(numOfRows)
                    + apiparams.pageNo          + String(pageNo)
                    + apiparams.listYN          + "Y"
                    + apiparams.MobileOS        + "IOS"
                    + apiparams.MobileApp       + "festivalApp" + apiparams.json
    
    return url
}

enum tourAPIResult {
    case success([[String:AnyObject]])
    case fail(Error)
    case zeroData
}

func requestTourAPI(url: String, completion: @escaping (tourAPIResult) -> ()) {
    
    var array = [[String:AnyObject]]()
    
    // Encoding을 nil로 주게되면 특수문자 변환이 들어가게되어서 반드시 queryString으로 해주어야한다.
    // url 자체를 Encoding하고 request를 하면 이중 Encoding 처리가 됨으로 request에서 설정해준다.
//    Alamofire.request(url, method: .get, encoding: URLEncoding.queryString).responseJSON { response in
    AF.request(url, method: .get, encoding: URLEncoding.queryString).responseJSON { response in
        print("request: \(response.request!)")  // original URL request
        print("reuslt: \(response.result)")   // result of response serialization
        
        switch response.result {
        case .success:
//            if let value = response.result.value {
            if let value = response.value {
                let json = JSON(value)
                
                if json["response"]["header"]["resultCode"].rawString() == "0000" {
                    // 지역조회, 일반적인 데이터
                    if let arrayData = json["response"]["body"]["items"]["item"].arrayObject {
                        array = arrayData as! [[String:AnyObject]]
                    }
                    
                    // 상세보기 데이터
                    if let dicData = json["response"]["body"]["items"]["item"].dictionaryObject {
                        array.append(dicData as [String : AnyObject])
                    }
                    
                    for dic in array {
                        if let url = dic["firstimage"] {
                            let id = String(describing: dic["contentid"]!)
                            // 이미지 캐싱
                            if AFImageCache.image(withIdentifier: id) == nil {
                                print("[\(id)] image caching")
                                AFImageCaching(cid: id, url: String(describing: url))
                            }
                        }
                    }
                    if array.count == 0 {
                        completion(.zeroData)
                    } else {
                        userprint(output: "** value : \(array)")
                        completion(.success(array))
                    }
                }
            }
            
        case .failure:
            print(response.error!)
            completion(.fail(response.error!))
        }
    }
}

class apiContent {
    var title       : String!
    var subTitle    : String!
    var iconName    : String!
}

// TourAPI를 호출하여 받은 Dictionary 데이터를 배열 형식으로 변환 -> 테이블 뷰에서 보여주기 위함
// 필요한 데이터만 필터링하는 함수
func listTypeFiltering(data: [String:AnyObject]) -> [apiContent] {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var dicArray = [apiContent]()
    
    // Tuple Type Array 생성
    var array: [(image: String, text: String, key: String)] = []
    
    // Array 형식으로 Append
    array.append((image: "ic_det_1.png",        text: "tour_label_07",      key: "opendate"))
    array.append((image: "ic_det_1.png",        text: "shopping_label_06",  key: "opendateshopping"))
    array.append((image: "ic_det_1.png",        text: "food_label_06",      key: "opendatefood"))
    array.append((image: "ic_det_1.png",        text: "fest_label_1",       key: "eventstartdate"))
    array.append((image: "ic_closed_date.png",  text: "tour_label_09",      key: "restdate"))
    array.append((image: "ic_closed_date.png",  text: "tour_label_09",      key: "restdateculture"))
    array.append((image: "ic_closed_date.png",  text: "tour_label_09",      key: "restdateshopping"))
    array.append((image: "ic_closed_date.png",  text: "tour_label_09",      key: "restdatefood"))
    array.append((image: "ic_det_2.png",        text: "fest_label_2",       key: "playtime"))
    array.append((image: "ic_det_2.png",        text: "tour_label_11",      key: "usetime"))
    
    array.append((image: "ic_det_2.png",        text: "tour_label_11",      key: "usetimeculture"))
    array.append((image: "ic_det_2.png",        text: "shopping_label_07",  key: "opentime"))
    array.append((image: "ic_det_1.png",        text: "shopping_label_04",  key: "fairday"))
    array.append((image: "ic_check_in.png",     text: "lodging_label_1",    key: "checkintime"))
    array.append((image: "ic_check_out.png",    text: "lodging_label_2",    key: "checkouttime"))
    array.append((image: "ic_det_2.png",        text: "shopping_label_07",  key: "opentimefood"))
    array.append((image: "ic_det_5.png",        text: "lodging_label_5",    key: "pickup"))
    array.append((image: "ic_det_3.png",        text: "fest_label_3",       key: "agelimit"))
    array.append((image: "ic_det_4.png",        text: "fest_label_4",       key: "usetimefestival"))
    array.append((image: "ic_det_4.png",        text: "fest_label_4",       key: "usefee"))
    
    array.append((image: "ic_det_5.png",        text: "lodging_label_7",    key: "roomcount"))
    array.append((image: "ic_overview.png",     text: "fest_label_5",       key: "overview"))
    array.append((image: "ic_shopping.png",     text: "shopping_label_10",  key: "saleitem"))
    array.append((image: "ic_food_menu.png",    text: "food_label_03",      key: "firstmenu"))
    array.append((image: "ic_food_menu.png",    text: "food_label_15",      key: "treatmenu"))
    array.append((image: "ic_det_5.png",        text: "tour_label_06",      key: "infocenter"))
    array.append((image: "ic_det_5.png",        text: "tour_label_06",      key: "infocenterculture"))
    array.append((image: "ic_reserved.png",     text: "lodging_label_6",    key: "reservationlodging"))
    array.append((image: "ic_reserved.png",     text: "lodging_label_6",    key: "reservationfood"))
    array.append((image: "ic_det_5.png",        text: "lodging_label_9",    key: "refundregulation"))
    
    array.append((image: "ic_det_5.png",        text: "tour_label_06",      key: "infocentershopping"))
    array.append((image: "ic_baby_car.png",     text: "tour_label_03",      key: "chkbabycarriage"))
    array.append((image: "ic_baby_car.png",     text: "tour_label_03",      key: "chkbabycarriageculture"))
    array.append((image: "ic_baby_car.png",     text: "tour_label_03",      key: "chkbabycarriageshopping"))
    array.append((image: "ic_det_3.png",        text: "food_label_14",      key: "smoking"))
    array.append((image: "ic_credit_card.png",  text: "culture_label_02",   key: "chkcreditcard"))
    array.append((image: "ic_credit_card.png",  text: "culture_label_02",   key: "chkcreditcardculture"))
    array.append((image: "ic_credit_card.png",  text: "culture_label_02",   key: "chkrcreditcardshopping"))
    array.append((image: "ic_credit_card.png",  text: "culture_label_02",   key: "chkcreditcardfood"))
    array.append((image: "ic_pet.png",          text: "tour_label_04",      key: "chkpet"))
    
    array.append((image: "ic_pet.png",          text: "tour_label_04",      key: "chkpetculture"))
    array.append((image: "ic_pet.png",          text: "tour_label_04",      key: "chkpetshopping"))
    array.append((image: "ic_parking.png",      text: "tour_label_08",      key: "parking"))
    array.append((image: "ic_parking.png",      text: "tour_label_08",      key: "parkingculture"))
    array.append((image: "ic_parking.png",      text: "tour_label_08",      key: "parkinglodging"))
    array.append((image: "ic_parking.png",      text: "tour_label_08",      key: "parkingshopping"))
    array.append((image: "ic_parking.png",      text: "tour_label_08",      key: "parkingfood"))
    array.append((image: "ic_det_4.png",        text: "culture_label_07",   key: "parkingfee"))
    array.append((image: "ic_det_5.png",        text: "food_label_08",      key: "packing"))
    array.append((image: "ic_det_6.png",        text: "fest_label_6",       key: "addr1"))
    
    array.append((image: "ic_det_7.png",        text: "fest_label_7",       key: "homepage"))
    array.append((image: "ic_det_8.png",        text: "fest_label_8",       key: "tel"))
    
    for tuple in array {
        
        if let value = data[tuple.key] { // 해당 키값이 nil이 아닌 경우
            var stringValue = String(describing: value) // Convert AnyObject to String
            
            if stringValue != "" { // string null ("")이 아닌경우
                
/****************************  날짜 구하기 ****************************/
                if tuple.key == "eventstartdate", let end = data["eventenddate"] {
                    let startDate = datestringJoinDot(dateTime: stringValue)
                    let endDate = datestringJoinDot(dateTime: String(describing: end))
                    
                    stringValue = "\(startDate) ~ \(endDate)"
                }
                
/****************************  데이터 저장 ****************************/
                let dic = apiContent()
                
                dic.title = appDelegate.languageDic[tuple.text]
                dic.subTitle = HTMLtoString_info(htmlString: stringValue, replace: "")
                dic.iconName = tuple.image
                
                dicArray.append(dic)
            }
        }
    }
    
    userprint(output: "final api data : \(dicArray)")
    
    return dicArray
}
