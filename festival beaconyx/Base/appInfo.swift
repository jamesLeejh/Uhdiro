//
//  appInfo.swift
//  festival beaconyx
//
//  Created by Beaconyx Corp. on 23/10/2019.
//  Copyright © 2019 Beaconyx Corp. All rights reserved.
//

import Foundation

class appInfo {
    // MARK:- Information connect to Parse server
    static let parseApplicationID = "FestivalbeconyxjAZx4r86akomIweGfdfOLbT2CnQKFcQ5"
    static let parseClientKey = "FestivalbeaconyxSpvy38GBFH6i1MZ2JGxfYkt0jgbRoKxy"
    static let parseRESTAPIKey = "mFxXWGAXodYefwxYYHV3SDJO7hd34ddXEho3V5de"
    static let parseMasterKey = "Festival4867847ft7aFzC5SxZgs7csDYhT4PsK7"
    static let parseServer = "http://www.beaconyx.co.kr:1337/parse"
    
    // MARK:- Information connect to tourAPI
    static var tourAPIKey: String!
    
    // MARK:- Information connect to Firebase
    static let firAPIKey = "AIzaSyCgk4tw8PWcNbUIfWcZM4ZrCqVxftDxDy0"
    
    // MARK:- Information connect to GoogleMaps
    static let googleMapAPIKey = "AIzaSyAITAT8qKfmuKt2w8itcZ5MRFL6CkI7CQQ"
}

// MARK:- Parse Table Key Settings
class parseTable {
    static let undefined = "undefined"

    struct AccountTablekey {
        static let tableName: String = "TB_Account"
        static let device: String = "deviceModel"
        static let osVer: String = "osVersion"
        static let osType: String = "osType"
        static let userId: String = "userId"
        static let pushToken: String = "pushToken"
    }
    
    struct APIKeyTableKey {
        static let tableName: String = "TB_API_KEY"
        static let apiKey: String = "apiKey"
    }
    
    struct languageTableKey {
        static let tableName: String = "TB_Language"
    }
    
    struct viewContentsTableKey {
        static let tableName: String = "TB_ViewContents"
        static let viewName: String = "viewName"
        static let url: String = "imageUrl"
    }
    
    struct originDataTableKey {
        static let tableName: String = "TB_Original_Data"
        static let firstimage: String = "firstimage"
        static let eventstartdate: String = "eventstartdate"
        static let eventenddate: String = "eventenddate"
        static let modifiedtime: String = "modifiedtime"
        static let areacode: String = "areacode"
        static let title: String = "title"
        static let readcount: String = "readcount"
        static let likecount: String = "likecount"
        static let mapx: String = "mapx"
        static let mapy: String = "mapy"
        static let contentid: String = "contentid"
        static let mappoint: String = "mappoint"
    }
}


