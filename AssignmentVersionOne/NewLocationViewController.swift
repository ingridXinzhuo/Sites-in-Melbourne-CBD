//
//  NewLocationViewController.swift
//  AssignmentVersionOne
//
//  Created by 于昕卓 on 30/8/19.
//  Copyright © 2019 XinzhuoYu. All rights reserved.
//

import UIKit
import MapKit

//protocol NewLocationDelegate {
//    func locationAnnotationAdded(annotation: LocationAnnotation)
//    }


class NewLocationViewController: UIViewController,CLLocationManagerDelegate {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var latitudeTextField: UITextField!
    @IBOutlet weak var longitudeTextField: UITextField!
    
    @IBOutlet weak var siteType: UISegmentedControl!
    weak var databaseController: DatabaseProtocol?
//    var delegate: NewLocationDelegate?
    var locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Get the database controller once from the App Delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.startUpdatingLocation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations.last!
        currentLocation = location.coordinate
    }

    @IBAction func useCurrentLocation(_ sender: Any) {
        if let currentLocation = currentLocation {
            latitudeTextField.text = "\(currentLocation.latitude)"
            longitudeTextField.text = "\(currentLocation.longitude)"
        }
        else {
            let alertController = UIAlertController(title: "Location Not Found", message: "The location has not yet been determined.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                present(alertController, animated: true, completion: nil)
        }
    }
    
    //save current site
    func saveSite() -> String{
        
        var imageString: String?
        let iconString = siteType.titleForSegment(at: siteType.selectedSegmentIndex)
        switch iconString {
        case "church":
            imageString = "church"
        case "library":
            imageString = "library"
        case "heritage":
            imageString = "heritage"
        case "museum":
            imageString = "museum"
        case "public":
            imageString = "public"
        default:
            imageString = "public"
        }
        
        let _ = databaseController!.addSiteInfo(siteName:titleTextField.text!, siteDesc: descriptionTextField.text!, sitePicture: imageString!, latitude: latitudeTextField.text!, longitude: longitudeTextField.text!,iconPic: iconString!)
        //        let location = LocationAnnotation(newTitle: titleTextField.text!, newSubtitle:
        //            descriptionTextField.text!, lat: Double(latitudeTextField.text!)!, long: Double(longitudeTextField.text!)!)
        //        delegate?.locationAnnotationAdded(annotation: location)
        navigationController?.popViewController(animated: true)
        //tableView.reloadData()
        //    }
        //    @IBAction func saveLocation(_ sender: Any) {
        //    }
        return imageString!
    }
    
    //update photo button
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "updatePhoto" {
            let controller = segue.destination as! CameraViewController
            controller.siteName = titleTextField.text
            controller.siteDesc = descriptionTextField.text
            controller.iconPic = saveSite()
            controller.latitude = latitudeTextField.text
            controller.longitude = longitudeTextField.text
        }

    }
}
