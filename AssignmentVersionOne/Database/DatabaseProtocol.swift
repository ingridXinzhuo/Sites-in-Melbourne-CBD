//
//  DatabaseProtocol.swift
//  AssignmentVersionOne
//
//  Created by 于昕卓 on 2/9/19.
//  Copyright © 2019 XinzhuoYu. All rights reserved.
//

import Foundation
enum DatabaseChange {
    case add
    case remove
    case update
}
enum ListenerType {
    case siteInfo
    case all
}
protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onSiteListChange(change: DatabaseChange, sites: [SiteInfo])
}
protocol DatabaseProtocol: AnyObject {
    var defaultSite: SiteInfo {get}
    
    func addSiteInfo(siteName: String, siteDesc: String,sitePicture: String, latitude:String,longitude:String,iconPic:String) -> SiteInfo
    func deleteSiteInfo(site: SiteInfo)
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
}
