//
//  MapViewController.swift
//  AssignmentVersionOne
//
//  Created by 于昕卓 on 31/8/19.
//  Copyright © 2019 XinzhuoYu. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import UserNotifications

class MapViewController: UIViewController,DatabaseListener, MKMapViewDelegate,CLLocationManagerDelegate, UNUserNotificationCenterDelegate {
    

    @IBOutlet weak var mapView: MKMapView!
    var allAnnotations : [LocationAnnotation] = []
    weak var databaseController: DatabaseProtocol?
    var mapPin : LocationAnnotation?
    var listenerType = ListenerType.siteInfo
    var geoLocation: CLCircularRegion?
    var geoLocationList: [CLCircularRegion] = []
    var locationManager: CLLocationManager = CLLocationManager()
    
    //loading
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        requestPermissionNotifications()
        //mapView.reloadInputViews()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        //center
        //latitude: "-37.8182711", longitude: "144.9670618" flinders
        let initialLocation = CLLocation(latitude: -37.8182711, longitude: 144.9670618)
        let regionRadius: CLLocationDistance = 1000
        func centerMapOnLocation(location: CLLocation) {
            let coordinateRegion = MKCoordinateRegion(center: location.coordinate,latitudinalMeters: regionRadius,longitudinalMeters: regionRadius)
            mapView.setRegion(coordinateRegion, animated: true)
            
        }
        centerMapOnLocation(location: initialLocation)

        // Do any additional setup after loading the view.
    }
    //default area on the map
    func focusOn(annotation: MKAnnotation) {
        mapView.selectAnnotation(annotation, animated: true)//recenter
        
        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000,longitudinalMeters: 1000)
        mapView.setRegion(mapView.regionThatFits(zoomRegion), animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.mapPin = mapView.selectedAnnotations[0] as? LocationAnnotation
    }


    func postLocalNotifications(eventTitle:String){
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = eventTitle
        content.body = "You've entered a new region"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let notificationRequest:UNNotificationRequest = UNNotificationRequest(identifier: "Region", content: content, trigger: trigger)
        
        center.add(notificationRequest, withCompletionHandler: { (error) in
            if let error = error {
                // Something went wrong
                print(error)
            }
            else{
                print("added")
            }
        })
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let alert = UIAlertController(title: "Movement Detected!", message: "You have left \(region.identifier)", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        postLocalNotifications(eventTitle: "You have left: \(region.identifier)")
    }
    //set pin on the map
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard let annotation = annotation as? LocationAnnotation else { return nil }
        
        let identifyString = "AnnotationView"
        
        var pointView = mapView.dequeueReusableAnnotationView(withIdentifier: identifyString)
        //
        if pointView == nil {
            pointView = MKAnnotationView(annotation: annotation, reuseIdentifier: restorationIdentifier)
            pointView!.canShowCallout = true
        }
        else {
            pointView!.annotation = annotation
        }
        
        let pinImage = UIImage(named: annotation.iconPic!)
        pointView!.image = pinImage
        pointView!.calloutOffset = CGPoint(x: -6, y: 6)
        let pinBtn = UIButton(frame: CGRect(origin: CGPoint.zero,size: CGSize(width: 40, height: 40)))
        pinBtn.setBackgroundImage(UIImage(named: annotation.iconPic!), for: UIControl.State())
        pointView!.rightCalloutAccessoryView = pinBtn
        return pointView
    }
    
    //reference from:https://stackoverflow.com/questions/10865088/how-do-i-remove-all-annotations-from-mkmapview-except-the-user-location-annotati/14949650
    func onSiteListChange(change: DatabaseChange, sites: [SiteInfo]) {
        
        let removedAnnotation = mapView.annotations.filter { $0 !== mapView.userLocation }
        mapView.removeAnnotations(removedAnnotation)
        var newLocationList = [LocationAnnotation]()
        for s in sites{
            let annotation = LocationAnnotation(siteinfo: s)
            newLocationList.append(annotation)
        }
        allAnnotations = newLocationList
        addSiteGeofecing()
        mapView.addAnnotations(allAnnotations)
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showInfo" {
            let controller = segue.destination as! SiteDetailInfoViewController
            controller.annotation = self.mapPin!
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        performSegue(withIdentifier: "showInfo", sender: nil)
        
    }
    
    func addSiteGeofecing(){
        for annotation in allAnnotations {
            geoLocation = CLCircularRegion(center: annotation.coordinate, radius: 30, identifier: (annotation.title!))
            geoLocation!.notifyOnExit = true
            locationManager.startMonitoring(for: geoLocation!)
            geoLocationList.append(geoLocation!)
        }
    }
    
    
    func removeSiteGeofecing(siteLocation: LocationAnnotation) {
        for geofencing in geoLocationList{
            if geofencing.identifier == siteLocation.title{
                locationManager.stopMonitoring(for: geofencing)
            }
        }
    }
    
    //Reference: https://github.com/ElectronicArmory/tutorial-ios-locations/blob/master/Location/ViewController.swift
    func requestPermissionNotifications(){
        let application =  UIApplication.shared
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (isAuthorized, error) in
                if( error != nil ){
                    print(error!)
                }
                else{
                    if( isAuthorized ){
                        print("authorized")
                        NotificationCenter.default.post(Notification(name: Notification.Name("AUTHORIZED")))
                    }
                    else{
                        let pushPreference = UserDefaults.standard.bool(forKey: "PREF_PUSH_NOTIFICATIONS")
                        if pushPreference == false {
                            let alert = UIAlertController(title: "Turn on Notifications", message: "Push notifications are turned off.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Turn on notifications", style: .default, handler: { (alertAction) in
                                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                                    return
                                }
                                
                                if UIApplication.shared.canOpenURL(settingsUrl) {
                                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                        // Checking for setting is opened or not
                                        print("Setting is opened: \(success)")
                                    })
                                }
                                UserDefaults.standard.set(true, forKey: "PREF_PUSH_NOTIFICATIONS")
                            }))
                            alert.addAction(UIAlertAction(title: "No thanks.", style: .default, handler: { (actionAlert) in
                                print("user denied")
                                UserDefaults.standard.set(true, forKey: "PREF_PUSH_NOTIFICATIONS")
                            }))
                            let viewController = UIApplication.shared.keyWindow!.rootViewController
                            DispatchQueue.main.async {
                                viewController?.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
        else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    func removeSiteGeofecing(siteinfomation: LocationAnnotation) {
        for geofencing in geoLocationList{
            if geofencing.identifier == siteinfomation.title{
                locationManager.stopMonitoring(for: geofencing)
            }
        }
    }
    
}

