//
//  LocationTableViewController.swift
//  AssignmentVersionOne
//
//  Created by 于昕卓 on 30/8/19.
//  Copyright © 2019 XinzhuoYu. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import UserNotifications

class LocationTableViewController: UITableViewController,DatabaseListener,UISearchResultsUpdating {
   
    
    
    
    @IBAction func ascFilter(_ sender: Any) {
        filterList = filterList.sorted(by: {$0.title! < $1.title!})
        self.tableView.reloadData()
    }
    
    @IBAction func descFilter(_ sender: Any) {
        filterList = filterList.sorted(by: {$0.title! > $1.title!})
        self.tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchContent = searchController.searchBar.text?.lowercased(), searchContent.count > 0 {
            filterList = locationList.filter({(site: LocationAnnotation) -> Bool in
                return site.title!.lowercased().contains(searchContent)
            })
        }
        else {
            filterList = locationList;
        }
        tableView.reloadData();
    }

    var mapViewController: MapViewController?
    var locationList = [LocationAnnotation]()
    var filterList : [LocationAnnotation] = []
    weak var databaseController: DatabaseProtocol?
    var listenerType = ListenerType.siteInfo
    //weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Get the database controller once from the App Delegate
        //changes!
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        filterList = locationList
        let searchBar = UISearchController(searchResultsController: nil);
        searchBar.searchResultsUpdater = self
        searchBar.obscuresBackgroundDuringPresentation = false
        searchBar.searchBar.placeholder = "Search your site"
        navigationItem.searchController = searchBar
        definesPresentationContext = true
        
    }
    
//    func filteredSearchList(for searchController: UISearchController) {
//
//    }
    
//    func locationAnnotationAdded(annotation: LocationAnnotation) {
//        locationList.append(annotation)
//        mapViewController?.mapView.addAnnotation(annotation)
//        tableView.insertRows(at: [IndexPath(row: locationList.count - 1, section: 0)], with: .automatic)
//    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return locationList.count
//    }
    
    func onSiteListChange(change: DatabaseChange, sites: [SiteInfo]) {
        var locationListNewAdd = [LocationAnnotation]()
        for location in sites{
            let mapAnnotation = LocationAnnotation(siteinfo: location)
            locationListNewAdd.append(mapAnnotation)
            //mapViewController?.mapView.add
            mapViewController?.mapView.addAnnotation(mapAnnotation)
        }
        locationList = locationListNewAdd
        //tableView.reloadData()
        updateSearchResults(for: navigationItem.searchController!)
    }

//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->
//        UITableViewCell {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath)
//            let annotation = self.locationList[indexPath.row]
//            cell.textLabel?.text = annotation.title
//            cell.detailTextLabel?.text = "Lat: \(annotation.coordinate.latitude) Long:\(annotation.coordinate.longitude)"
//            cell.imageView?.image =  UIImage(named: annotation.iconPic!)
//            return cell
//    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !UIDevice.current.orientation.isLandscape {
            self.navigationController?.pushViewController(self.mapViewController!, animated: true)
        }
        mapViewController?.focusOn(annotation: self.locationList[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle:
        UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //locationList.remove(at: indexPath.row)
            //tableView.deleteRows(at: [indexPath], with: .fade)
            let targetAnnotation = filterList[indexPath.row]
            let siteinfoAnnotation = targetAnnotation.siteinfo
            databaseController?.deleteSiteInfo(site: siteinfoAnnotation!)
            mapViewController?.mapView.removeAnnotation(targetAnnotation)
            mapViewController?.removeSiteGeofecing(siteinfomation: targetAnnotation)
        }
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "addLocationSegue" {
//            let controller = segue.destination as! NewLocationViewController
//            //controller.delegate = self
//        }
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filterList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath)
        let annotation = self.filterList[indexPath.row]
        cell.textLabel?.text = annotation.title
        cell.detailTextLabel?.text = annotation.subtitle
        cell.imageView?.image = UIImage(named: annotation.iconPic!)
        return cell
    }
    
    
//    @IBAction func ascFilter(_ sender: Any) {
//        filterList = filterList.sorted(by: {$0.title! < $1.title!})
//        self.tableView.reloadData()
//        
//    }
//    
//    @IBAction func descFilter(_ sender: Any) {
//        filterList = filterList.sorted(by: {$0.title! > $1.title!})
//        self.tableView.reloadData()
//    }
//    func onHeroListChange(change: DatabaseChange, heroes: [SuperHero]) {
//        allHeroes = heroes
//        updateSearchResults(for: navigationItem.searchController!)
//    }
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "addLocationSegue" {
//            let controller = segue.destination as! NewLocationViewController
//            controller.delegate = self
//        }
//    }
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
