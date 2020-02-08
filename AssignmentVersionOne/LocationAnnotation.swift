//
//  LocationAnnotation.swift
//  AssignmentVersionOne
//
//  Created by 于昕卓 on 30/8/19.
//  Copyright © 2019 XinzhuoYu. All rights reserved.
//

import UIKit
import MapKit

class LocationAnnotation: NSObject,MKAnnotation{

    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var picture: String?
    var iconPic:String?
    var siteinfo:SiteInfo?
    
    init(newTitle: String, newSubtitle: String, newPicture:String, lat: Double, long: Double, newIconPic:String) {
        self.title = newTitle
        self.subtitle = newSubtitle
        self.picture = newPicture
        self.iconPic = newIconPic
        coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
    init(siteinfo : SiteInfo) {
        self.title = siteinfo.siteName
        self.subtitle = siteinfo.siteDesc
        coordinate = CLLocationCoordinate2D(latitude: Double(siteinfo.latitude!) as! CLLocationDegrees, longitude: Double(siteinfo.longitude!) as! CLLocationDegrees)
        self.picture = siteinfo.sitePicture
        self.iconPic = siteinfo.iconPic
        self.siteinfo = siteinfo
        
    }
}
