//
//  mapViewController.swift
//  festival beaconyx
//
//  Created by Beaconyx Corp. on 11/11/2019.
//  Copyright © 2019 Beaconyx Corp. All rights reserved.
//

import UIKit
import GoogleMaps

class mapViewController: BaseViewController, GMSMapViewDelegate {

    @IBOutlet weak var topTitleLabel: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    
    var dic: [String:AnyObject]!
    var myLocation: CLLocationCoordinate2D!
    
    var latitude: Double!
    var longitude: Double!
    
    var mLocationTapFlag = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        myLocation = appDelegate.getLocation()
        
        topTitleLabel.text = appDelegate.languageDic["fest_label_9"] // "지도"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // ViewDidLoad에 있으면 기준점이 지도 좌측 상단으로 표시됨
        // ViewWillAppear에서 실행하라는 내용 확인
        mapView.delegate = self
        
        // Create map
        latitude = (dic["mapy"]?.doubleValue)!
        longitude = (dic["mapx"]?.doubleValue)!
        
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 16)
        mapView.camera = camera
        
        // Create marker
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        marker.title = String(describing: dic["title"])
        marker.map = mapView
        
        // mapview Configuration
        mapView.isUserInteractionEnabled    = true
        mapView.isMyLocationEnabled         = true      //현재 위치 마커 제공
        mapView.settings.myLocationButton   = true      //현재 위치 버튼 제공
        mapView.settings.rotateGestures     = true      //회전 제스처 사용 안함
        mapView.settings.tiltGestures       = true      //기울기 제스처 사용 안함
    }
    
    // 내 위치 버튼 클릭 이벤트
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {

        let markerPosition = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

        // '내 위치' 버튼 클릭시 액션
        switch mLocationTapFlag {

        case 0: // 내 위치로 이동
            let camera = GMSCameraPosition.camera(withTarget: myLocation, zoom: 16)
            mapView.animate(to: camera)

            break

        case 1: // 마커 위치로 이동
            let camera = GMSCameraPosition.camera(withTarget: markerPosition, zoom: 16)
            mapView.animate(to: camera)
            break

        case 2: // 내 위치, 마커 위치 동시 표현
            let camera = mapView.camera(for: .init(coordinate: myLocation, coordinate: markerPosition), insets: .init(top: 50, left: 50, bottom: 50, right: 50))!

            mapView.animate(to: camera)
            break

        default:
            break
        }

        if mLocationTapFlag == 2 {
            mLocationTapFlag = 0
        } else {
            mLocationTapFlag += 1
        }

        return true
    }

    @IBAction func dismissButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
