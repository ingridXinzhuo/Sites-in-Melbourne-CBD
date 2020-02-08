//
//  SiteDetailInfoViewController.swift
//  AssignmentVersionOne
//
//  Created by 于昕卓 on 6/9/19.
//  Copyright © 2019 XinzhuoYu. All rights reserved.
//

import UIKit

class SiteDetailInfoViewController: UIViewController, UIScrollViewDelegate {

   
    
    @IBOutlet weak var siteName: UILabel!
    @IBOutlet weak var siteDescription: UILabel!
    @IBOutlet weak var siteDetail: UIImageView!
    var annotation: LocationAnnotation?
    //var photo: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // accept the data accordingly
        if annotation != nil{
            siteName.text = annotation!.title
            siteDescription.text = annotation!.subtitle
            siteDescription.numberOfLines = 0
            siteDescription.lineBreakMode = NSLineBreakMode.byWordWrapping
            siteDetail.image = UIImage(named: annotation!.picture!)
            if (siteDetail.image == nil)
            {
                siteDetail.image = loadImageData(fileName: annotation!.picture!)
            }
            //siteDetail.image = UIImage(named: annotation!.picture!)
        }
        
    }
    
    func loadImageData(fileName: String) -> UIImage? {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) [0] as String
        let url = NSURL(fileURLWithPath: path)
        var image: UIImage?
        if let pathComponent = url.appendingPathComponent(fileName) {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            let fileData = fileManager.contents(atPath: filePath)
            image = UIImage(data: fileData!)
        }
        return image
    }
    

}
