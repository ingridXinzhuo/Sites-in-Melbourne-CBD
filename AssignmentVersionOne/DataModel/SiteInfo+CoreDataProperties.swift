//
//  SiteInfo+CoreDataProperties.swift
//  AssignmentVersionOne
//
//  Created by 于昕卓 on 5/9/19.
//  Copyright © 2019 XinzhuoYu. All rights reserved.
//
//

import Foundation
import CoreData


extension SiteInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SiteInfo> {
        return NSFetchRequest<SiteInfo>(entityName: "SiteInfo")
    }

    @NSManaged public var latitude: String?
    @NSManaged public var longitude: String?
    @NSManaged public var siteDesc: String?
    @NSManaged public var siteName: String?
    @NSManaged public var sitePicture: String?
    @NSManaged public var iconPic: String?

}
