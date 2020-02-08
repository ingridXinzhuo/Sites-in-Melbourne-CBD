//
//  CoreDataControllerController.swift
//  AssignmentVersionOne
//
//  Created by 于昕卓 on 2/9/19.
//  Copyright © 2019 XinzhuoYu. All rights reserved.
//

import UIKit
import CoreData

class CoreDataControllerController: NSObject,DatabaseProtocol,NSFetchedResultsControllerDelegate {

    let DEFAULT_SITE_NAME = "Default site"
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistantContainer: NSPersistentContainer
    
    // Results
    var allSitesFetchedResultsController: NSFetchedResultsController<SiteInfo>?
    var SitesFetchedResultsController: NSFetchedResultsController<SiteInfo>?
    override init() {
        persistantContainer = NSPersistentContainer(name: "SitesInfo")
        persistantContainer.loadPersistentStores() { (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
        
        super.init()
        
        // If there are no heroes in the database assume that the app is running
        // for the first time. Create the default team and initial superheroes.
        if fetchAllSites().count == 0 {
            createDefaultEntries()
        }
    }
    
    func saveContext() {
        if persistantContainer.viewContext.hasChanges {
            do {
                try persistantContainer.viewContext.save()
            } catch {
                fatalError("Failed to save data to Core Data: \(error)")
            }
        }
    }
    
    /*
     add site
    */
    func addSiteInfo(siteName: String, siteDesc: String, sitePicture: String, latitude: String, longitude: String,iconPic:String) -> SiteInfo {
        let site = NSEntityDescription.insertNewObject(forEntityName: "SiteInfo", into:
            persistantContainer.viewContext) as! SiteInfo
        site.siteName = siteName
        site.siteDesc = siteDesc
        site.latitude = latitude
        site.longitude = longitude
        site.sitePicture = sitePicture
        site.iconPic = iconPic
        // This less efficient than batching changes and saving once at end.
        saveContext()
        return site
    }
    
    func addSite(siteName: String) -> SiteInfo {
        let site = NSEntityDescription.insertNewObject(forEntityName: "SiteInfo", into:
            persistantContainer.viewContext) as! SiteInfo
        site.siteName = siteName

        // This less efficient than batching changes and saving once at end.
        saveContext()
        return site
    }
    
//    func addHeroToTeam(hero: SuperHero, team: Team) -> Bool {
//        guard let heroes = team.heroes, heroes.contains(hero) == false, heroes.count < 6 else {
//            return false
//        }
//
//        team.addToHeroes(hero)
//        // This less efficient than batching changes and saving once at end.
//        saveContext()
//        return true
//    }
    
    func deleteSiteInfo(site: SiteInfo) {
        persistantContainer.viewContext.delete(site)
        // This less efficient than batching changes and saving once at end.
        saveContext()
    }
    
//    func deleteTeam(team: Team) {
//        persistantContainer.viewContext.delete(team)
//        // This less efficient than batching changes and saving once at end.
//        saveContext()
//    }
//
//    func removeHeroFromTeam(hero: SuperHero, team: Team) {
//        team.removeFromHeroes(hero)
//        // This less efficient than batching changes and saving once at end.
//        saveContext()
//    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == ListenerType.siteInfo || listener.listenerType == ListenerType.all {
            listener.onSiteListChange(change: .update, sites: fetchAllSites())
        }
        
//        if listener.listenerType == ListenerType.heroes || listener.listenerType == ListenerType.all {
//            listener.onHeroListChange(change: .update, heroes: fetchAllHeroes())
//        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    func fetchAllSites() -> [SiteInfo] {
        if allSitesFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<SiteInfo> = SiteInfo.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "siteName", ascending: true)
            fetchRequest.sortDescriptors = [nameSortDescriptor]
            allSitesFetchedResultsController = NSFetchedResultsController<SiteInfo>(fetchRequest:
                fetchRequest, managedObjectContext: persistantContainer.viewContext, sectionNameKeyPath: nil,
                              cacheName: nil)
            allSitesFetchedResultsController?.delegate = self
            do {
                try allSitesFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request failed: \(error)")
            }
        }
        
        var sites = [SiteInfo]()
        if allSitesFetchedResultsController?.fetchedObjects != nil {
            sites = (allSitesFetchedResultsController?.fetchedObjects)!
        }
        
        return sites
    }
//    func fetchTeamHeroes() -> [SuperHero] {
//        if teamHeroesFetchedResultsController == nil {
//            let fetchRequest: NSFetchRequest<SuperHero> = SuperHero.fetchRequest()
//            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
//            fetchRequest.sortDescriptors = [nameSortDescriptor]
//            let predicate = NSPredicate(format: "ANY teams.name == %@", DEFAULT_TEAM_NAME)
//            fetchRequest.predicate = predicate
//            teamHeroesFetchedResultsController =
//                NSFetchedResultsController<SuperHero>(fetchRequest: fetchRequest, managedObjectContext:
//                    persistantContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
//            teamHeroesFetchedResultsController?.delegate = self
//
//            do {
//                try teamHeroesFetchedResultsController?.performFetch()
//            } catch {
//                print("Fetch Request failed: \(error)")
//            }
//        }
//
//        var heroes = [SuperHero]()
//        if teamHeroesFetchedResultsController?.fetchedObjects != nil {
//            heroes = (teamHeroesFetchedResultsController?.fetchedObjects)!
//        }
//
//        return heroes
//    }
    // MARK: - Fetched Results Conttroller Delegate
    func controllerDidChangeContent(_ controller:
        NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == allSitesFetchedResultsController {
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.siteInfo || listener.listenerType == ListenerType.all {
                    listener.onSiteListChange(change:.update, sites:fetchAllSites())
                }
            }
        }
//        else if controller == teamHeroesFetchedResultsController {
//            listeners.invoke { (listener) in
//                if listener.listenerType == ListenerType.team || listener.listenerType == ListenerType.all {
//                    listener.onTeamChange(change: .update, teamHeroes: fetchTeamHeroes())
//                }
//            }
//        }
    }
    // MARK: - Default entries
    lazy var defaultSite: SiteInfo = {
        var sites = [SiteInfo]()
        
        let request: NSFetchRequest<SiteInfo> = SiteInfo.fetchRequest()
        let predicate = NSPredicate(format: "siteName = %@", DEFAULT_SITE_NAME)
        request.predicate = predicate
        do {
            try sites = persistantContainer.viewContext.fetch(SiteInfo.fetchRequest()) as! [SiteInfo]
        } catch {
            print("Fetch Request failed: \(error)")
        }
        
        if sites.count == 0 {
            return addSite(siteName: DEFAULT_SITE_NAME)
        }
        else {
            return sites.first!
        }
    }()
    
    func createDefaultEntries() {
        //1
        let _ = addSiteInfo(siteName: "Old Melbourne Gaol", siteDesc: "Shrouded in secrets, wander the same cells and halls as some of history’s most notorious criminals, from Ned Kelly to Squizzy Taylor, and discover the stories that never left. Hosting day and night tours, exclusive events and kids activities throughout school holidays and an immersive lock-up experience in the infamous City Watch House, the Gaol remains Melbourne’s most spell-binding journey into its past.", sitePicture: "OldMelbourneGaol", latitude: "-37.8076583", longitude: "144.9632857",iconPic: "heritage")
        //2
        let _ = addSiteInfo(siteName: "Melbourne Museum", siteDesc: "A visit to Melbourne Museum is a rich, surprising insight into life in Victoria. It shows you Victoria's intriguing permanent collections and bring you brilliant temporary exhibitions from near and far. You'll see Victoria's natural environment, cultures and history through different perspectives.", sitePicture: "MelbourneMuseum", latitude: "-37.803273", longitude: "144.9717408",iconPic: "museum")
        //3
        let _ = addSiteInfo(siteName: "Immigration Museum", siteDesc: "Explore Melbourne's history through stories of people from across the world who have migrated to Victoria at the Immigration Museum. Take a fresh look at what it means to belong and not belong in Australia. Explore who Australians are and who others think Australians are.", sitePicture: "ImmigrationMuseum", latitude: "-37.8192442", longitude: "144.9604547",iconPic: "museum")
        //4
        let _ = addSiteInfo(siteName: "Chinese Museum", siteDesc: "Located in the heart of Melbourne’s Chinatown, the Chinese Museum (Museum of Chinese Australian History)’s five floors showcase the heritage and culture of Australia’s Chinese community. Marvel at the world’s biggest processional Dai Loong Dragon, experience Finding Gold and discover the new One Million Stories Exhibition, showcasing the contribution Chinese Australians have made to Australian Society over 200 years.", sitePicture: "ChineseMuseum", latitude: "-37.810802", longitude: "144.9691688",iconPic: "museum")
        //5
        let _ = addSiteInfo(siteName: "Flinders Street Station", siteDesc: "Stand beneath the clocks of Melbourne's iconic railway station, as tourists and Melburnians have done for generations. Take a train for outer-Melbourne explorations, join a tour to learn more about the history of the grand building, or go underneath the station to see the changing exhibitions that line Campbell Arcade.", sitePicture: "FlindersStreetStation", latitude: "-37.8182711", longitude: "144.9670618",iconPic: "heritage")
        //6
        let _ = addSiteInfo(siteName: "St Paul's Cathedral", siteDesc: "Leave the bustling Flinders Street Station intersection behind and enter the peaceful place of worship that's been at the heart of city life since the mid 1800s. Join a tour and admire the magnificent organ, the Persian Tile and the Five Pointed Star of the historic St Paul's Cathedral.", sitePicture: "StPaul'sCathedral", latitude: "-37.817029", longitude: "144.967687",iconPic: "church")
        //7
        let _ = addSiteInfo(siteName: "NGV International", siteDesc: "The National Gallery of Victoria has two magnificent galleries located a short walk apart, both with free entry to the permanent collection. The NGV offers an extraordinary visual arts experience with diverse temporary exhibitions, Collection displays, talks, tours, programs for kids, films, late-night openings and performances.", sitePicture: "NGVInternational", latitude: "-37.8225942", longitude: "144.9689278",iconPic: "museum")
        //8
        let _ = addSiteInfo(siteName: "The Scots' Church", siteDesc: "Look up to admire the 120-foot spire of the historic Scots' Church, once the highest point of the city skyline. Nestled between modern buildings on Russell and Collins streets, the decorated Gothic architecture and stonework is an impressive sight, as is the interior's timber panelling and stained glass.", sitePicture: "TheScots'Church", latitude: "-37.8146055", longitude: "144.9663239",iconPic: "church")
        //9
        let _ = addSiteInfo(siteName: "Parliament Gardens", siteDesc: "The Parliament House Gardens Tour provides an opportunity for the public to see Parliament's historic gardens. The tour takes about 90 minutes. As the tour is outdoors, please ensure you wear appropriate footwear and bring umbrellas or hats depending on the weather on the day.", sitePicture: "ParliamentGardens", latitude: "-37.8095276", longitude: "144.9735753",iconPic: "public")
        //10
        let _ = addSiteInfo(siteName: "Flagstaff Gardens", siteDesc: "For more than 168 years, the story of Collins Street Baptist Church has been entwined with the story of Melbourne. Located part way between the historic Town Hall and State Parliament, CSBC sits at Melbourne’s cultural, commercial, political and spiritual heart.", sitePicture: "FlagstaffGardens", latitude: "-37.8083866", longitude: "144.9539962",iconPic: "public")
        //11
        let _ = addSiteInfo(siteName: "City Library", siteDesc: "Escape to the serene Flagstaff Gardens with a picnic from the nearby Queen Victoria Market and lounge by the rose gardens. Come with a group for a barbecue and a game of tennis. View the informative memorials and monuments and enjoy the green space.", sitePicture: "CityLibrary", latitude: "-37.857119", longitude: "145.028221",iconPic: "library")
        //12
        let _ = addSiteInfo(siteName: "State Library", siteDesc: "The State Library is the keeper of Victoria's history – and home to millions of stories. Get to know the treasures and curiosities from our incredible collection, and hear tales from our community and from inside the Library.", sitePicture: "StateLibrary", latitude: "-37.8098087", longitude: "144.9651897",iconPic: "library")
        //13
        let _ = addSiteInfo(siteName: "Law Library of Victoria", siteDesc: "The Supreme Court of Victoria is the superior court for the Victorian jurisdiction. The Library runs independently of the Court, under a governing Committee. The Library provides services to all Victorian judicial officers and members of the legal profession.", sitePicture: "LawLibraryofVictoria", latitude: "-37.814076", longitude: "144.9581581",iconPic: "library")
        //14
        let _ = addSiteInfo(siteName: "Federation Square", siteDesc: "It is increasingly hard to imagine Melbourne without Federation Square. As a home to major cultural attractions, world-class events, tourism experiences and an exceptional array of restaurants, bars and specialty stores, this modern piazza has become the city's meeting place. ", sitePicture: "FederationSquare", latitude: "-37.8179789", longitude: "144.9690576",iconPic: "public")
        //15
        let _ = addSiteInfo(siteName: "Queen Victoria Market", siteDesc: "Queen Victoria Market is an authentic, bustling, inner-city market that has been the heart and soul of Melbourne for 140 years. Home to over 600 small businesses, it is a great place to discover fresh and specialty produce, hand-made and unique products, great coffee and food, souvenirs and clothing. ", sitePicture: "QueenVictoriaMarket", latitude: "-37.8073584", longitude: "144.954483",iconPic: "public")
    }
}
