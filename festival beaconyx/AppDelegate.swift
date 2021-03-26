//
//  AppDelegate.swift
//  festival beaconyx
//
//  Created by Beaconyx Corp. on 12/08/2019.
//  Copyright © 2019 Beaconyx Corp. All rights reserved.
//

import UIKit
import Parse
//import AudioToolbox
//import CoreLocation
import GoogleMaps
import Firebase
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var locationManager: CLLocationManager!
    var keyChain: String!
    var languageDic = [String: String]()
    var selectedLanguage: String!
    var selectedLanguageText: String = "한국어"
    var osLanguageLocale: String!
    var scrapArray = [parseContent]()
    var mCoor = CLLocationCoordinate2DMake(37.566293, 126.977943)
    
    let gcmMessageIDKey = "gcm.message_id"
   
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // darkmode 금지
        if #available(iOS 13.0, *) {
            self.window?.overrideUserInterfaceStyle = .light
        }
                
        // Location Manager
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization() // 포그라운드에서만 동작 권한 요청
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
                
        // make and load Keychain
        self.keyChain = KeychainItemWrapper().getBDA()
        
        // connect to parse server
        parseConnect(launchOptions: launchOptions)
        getAPIKey()
        
        //구글지도 사용을 위한 API KEY 등록
        GMSServices.provideAPIKey(appInfo.googleMapAPIKey)
        
        // firebase 초기화
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        // notification 등록
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler:  {_, _ in})
        
        application.registerForRemoteNotifications()
        checkPushToken() // FCM Push Token Check
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // deviceToken 등록
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
      // If you are receiving a notification message while your app is in the background,
      // this callback will not be fired till the user taps on the notification launching the application.
      // TODO: Handle data of notification

      // With swizzling disabled you must let Messaging know about the message, for Analytics
      // Messaging.messaging().appDidReceiveMessage(userInfo)

      // Print message ID.
      if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID: \(messageID)")
      }

      // Print full message.
      print(userInfo)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
      // If you are receiving a notification message while your app is in the background,
      // this callback will not be fired till the user taps on the notification launching the application.
      // TODO: Handle data of notification

      // With swizzling disabled you must let Messaging know about the message, for Analytics
      // Messaging.messaging().appDidReceiveMessage(userInfo)

      // Print message ID.
      if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID: \(messageID)")
      }

      // Print full message.
      print(userInfo)

      completionHandler(UIBackgroundFetchResult.newData)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                    didReceive response: UNNotificationResponse,
                                    withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
 
        // Print full message.
        print("userInfo : \(userInfo)")
 
        // userInfo는 [AnyHashable:Any] 형태를 갖는다.
        // 관련 로직을 추가한다.
 
        completionHandler()
    }

    // MARK:- FUNCTION about Parse server
    // connect to parse server
    func parseConnect(launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        let configuration = ParseClientConfiguration {
            $0.applicationId = appInfo.parseApplicationID
            $0.clientKey = appInfo.parseClientKey
            $0.server = appInfo.parseServer
        }
        
        Parse.initialize(with: configuration)
        PFAnalytics.trackAppOpened(launchOptions: launchOptions)
        
        userprint(output: "Successfully connected Parse server.")
    }
    
    // MARK:- get TourAPIKEY from Parse server
    func getAPIKey() {
        let table = parseTable.APIKeyTableKey.self
        let query = PFQuery(className: table.tableName)
        
        query.findObjectsInBackground(block: {(objects: [PFObject]?, error: Error?) in
            
            if error == nil {
                for object in objects! {
                    appInfo.tourAPIKey = object.object(forKey: table.apiKey) as? String
                    print(object)
                }
                userprint(output: "Successfully received TourAPIKey")
            }
            else {
                userprint(output: "ERROR : \(error!)")
            }
        })
    }
    
    // MARK:- FUNCTION about getting coordinate
    func getLocation() -> CLLocationCoordinate2D {
        if let mCoordinate = locationManager.location?.coordinate {
            userprint(output: "현재 GPS 위치 정보 : \(mCoordinate)")
            self.mCoor = mCoordinate
        
            return mCoordinate
        } else {
            return self.mCoor
        }
    }
    
    // MARK:- function for checking FCM push token
    func checkPushToken() {
        // TODO: check
//        InstanceID.instanceID().instanceID { (result, error) in
        Installations.installations().installationID { (result, error) in
            if let error = error {
                userprint(output: "Error fetching remote instance ID: \(error)")
            } else if let result = result {
                userprint(output: "Remote instance ID token: \(result)")
                UserDefaults.standard.setValue(result, forKey: "FCMtoken")
            }
        }
    }
}
