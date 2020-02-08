//
//  CameraViewController.swift
//  AssignmentVersionOne
//
//  Created by 于昕卓 on 4/9/19.
//  Copyright © 2019 XinzhuoYu. All rights reserved.
//

import UIKit
import CoreData

class CameraViewController: UIViewController,UIImagePickerControllerDelegate,
UINavigationControllerDelegate {

    var siteName: String?
    var siteDesc: String?
    var iconPic: String?
    var latitude: String?
    var longitude: String?
 
    @IBOutlet weak var imageView: UIImageView!
    weak var databaseController: DatabaseProtocol?
    //var managedObjectContext: NSManagedObjectContext?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
       // managedObjectContext = appDelegate?.persistantContainer?.viewContext
        databaseController = appDelegate!.databaseController
    }
    
//    func imagePickerController(_ picker: UIImagePickerController,
//                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        if let pickedImage = info[.originalImage] as? UIImage {
//            imageView.image = pickedImage
//        }
//        dismiss(animated: true, completion: nil)
//    }
//
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        displayMessage("There was an error in getting the image", "Error")
//    }
//
//    func displayMessage(_ message: String,_ title: String) {
//        let alertController = UIAlertController(title: title, message: message,
//                                                preferredStyle: .alert)
//        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,
//                                                handler: nil))
//        self.present(alertController, animated: true, completion: nil)
//    }
    
//    @IBAction func takePhoto(_ sender: Any) {
//        let controller = UIImagePickerController()
//        if UIImagePickerController.isSourceTypeAvailable(.camera) {
//            controller.sourceType = .camera
//        } else {
//            controller.sourceType = .photoLibrary
//        }
//
//        controller.allowsEditing = false
//        controller.delegate = self
//        self.present(controller, animated: true, completion: nil)
//    }
    @IBAction func takePhoto(_ sender: Any) {
        let controller = UIImagePickerController()
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                controller.sourceType = .camera
            } else {
                controller.sourceType = .photoLibrary
            }
    
            controller.allowsEditing = false
    
            controller.delegate = self
            self.present(controller, animated: true, completion: nil)
    }
    func displayMessage(_ message: String,_ title: String) {
        let alertController = UIAlertController(title: title, message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,
                                                handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func savePhoto(_ sender: Any) {
        guard let image = imageView.image else {
            displayMessage("Cannot save until a photo has been taken!", "Error")
            return
        }
        let date = UInt(Date().timeIntervalSince1970)
        var data = Data()
        data = image.jpegData(compressionQuality: 0.8)!
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent("\(date)") {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            fileManager.createFile(atPath: filePath, contents: data,
                                   attributes: nil)
            
             databaseController!.addSiteInfo(siteName: siteName!, siteDesc: siteDesc!, sitePicture: "\(date)", latitude: latitude!, longitude: longitude!, iconPic: iconPic!)
            
            //(siteName: siteName!, siteDesc: siteDesc!,sitePicture: "\(date)", latitude:latitude!,longitude:longitude!,iconPic:iconPic!)
            navigationController?.popViewController(animated: true)
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            imageView.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        displayMessage("There was an error in getting the image", "Error")
    }

//        func takePhoto(_ sender: Any) {
//        let controller = UIImagePickerController()
//        if UIImagePickerController.isSourceTypeAvailable(.camera) {
//            controller.sourceType = .camera
//        } else {
//            controller.sourceType = .photoLibrary
//        }
//
//        controller.allowsEditing = false
//
//        controller.delegate = self
//        self.present(controller, animated: true, completion: nil)
//        }
    }

