//
//  AFImageCache.swift
//  festival beaconyx
//
//  Created by Beaconyx Corp. on 19/11/2019.
//  Copyright © 2019 Beaconyx Corp. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

let AFImageCache = AutoPurgingImageCache()

func AFImageCaching(cid: String, url: String) {
    // jpg 확장자 허용
//    DataRequest.addAcceptableImageContentTypes(["image/jpg"])
    ImageResponseSerializer.addAcceptableImageContentTypes(["image/jpg"])
    
//    Alamofire.request(url).responseImage { (response) in
    AF.request(url).responseImage { (response) in
        print(response.result)
        
//        if let image = response.result.value {
        if let image = response.value {
            AFImageCache.add(image, withIdentifier: cid)
        }
    }
}
