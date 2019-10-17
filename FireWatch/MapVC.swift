//
//  ReportFire.swift
//  FireWatch
//
//  Created by Abdalwahab on 10/18/18.
//  Copyright © 2018 Ali Kelkawi. All rights reserved.
//

//1- check checkLocation method. I am currently comparing between every fire and user location. Should I change it to the pinned location?
//--change it to pinned location
//2- uploading images and download them requires firebase storage, which should be enabled from the panel

import UIKit
import MapKit
import Firebase
import FirebaseStorage

class MapVC: UIViewController {
    
    static var fireCount = 0
    
    //map objects
    @IBOutlet var map: MKMapView!
    var reportLocation : MKPointAnnotation = MKPointAnnotation()
    var reportPinAdded = false
    
    //buttons
    @IBOutlet var reportBtn: UIButton!
    @IBOutlet var checkBtn: UIButton!
    @IBOutlet var cancelBtn: UIButton!
    private var userTrackingBtn: MKUserTrackingButton!
    
    //pin card
    @IBOutlet var cardTopConstraint: NSLayoutConstraint!
    @IBOutlet var pinImage: UIImageView!
    
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        userTrackingBtn = MKUserTrackingButton(mapView: map)
        userTrackingBtn.frame.origin = CGPoint(x: view.frame.width - 50, y: view.frame.height - 50)
        userTrackingBtn.layer.backgroundColor = UIColor.white.cgColor
        userTrackingBtn.layer.cornerRadius = 5
        userTrackingBtn.isHidden = true // Unhides when location authorization is given.
        view.addSubview(userTrackingBtn)
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
//        loadDataForMapRegionAndBikes()
        extract()
        
        let addPinGesture = UILongPressGestureRecognizer.init(target: self, action: #selector(addPin))
        map.addGestureRecognizer(addPinGesture)
        map.visibleMapRect = MKMapRectWorld
        
        fireTimer() //start checking for nearby fires
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let report = segue.destination as? ReportVC {
            report.cords = reportLocation.coordinate
        }
    }
    
    
        //remove when done from data
//    private func loadDataForMapRegionAndBikes() {
//        guard let plistURL = Bundle.main.url(forResource: "Data", withExtension: "plist") else {
//            fatalError("Failed to resolve URL for `Data.plist` in bundle.")
//        }
//
//        do {
//            let plistData = try Data(contentsOf: plistURL)
//            let decoder = PropertyListDecoder()
//            let decodedData = try decoder.decode(MapData.self, from: plistData)
//            map.region = decodedData.region
//            map.addAnnotations(decodedData.cycles)
//
////            map.visibleMapRect = MKMapRectWorld
//
//        } catch {
//            fatalError("Failed to load provided data, error: \(error.localizedDescription)")
//        }
//    }
    ////////////////
    
    private func extract() {
        let ref = Database.database().reference()
        let query = ref.queryOrdered(byChild: "FireLocations")
        query.observeSingleEvent(of: .value, with: { (fireSnapshot) in
            
            for child in fireSnapshot.children.allObjects as! [DataSnapshot]{
                MapVC.fireCount = child.children.allObjects.count
                
                for i in 1...child.children.allObjects.count {
                    let long = child.childSnapshot(forPath: "Location\(i)/Longitude").value as! Double
                    let lat = child.childSnapshot(forPath: "Location\(i)/Latitude").value as! Double
                    
                    let cycle = Cycle()
                    cycle.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    cycle.id = "Location\(i)"
                    
                    self.map.addAnnotation(cycle)
                }
            }
        })
    }
    
    @IBAction func closeCard() {
        UIView.animate(withDuration: 0.4) {
            self.cardTopConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
}

//MARK: - Checking locations
extension MapVC {
    @IBAction func checkLocation() {
        let radius = 1000.0 // meters
        
        for annotation in map.annotations {
            //calculate from the current location of the user and every fire location
            let fireLocation = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
            let pinnedLocation = CLLocation(latitude: reportLocation.coordinate.latitude, longitude: reportLocation.coordinate.longitude)
            
            //the distance is measured in meters
            if (fireLocation.distance(from: pinnedLocation) <= radius) {
                showAlert(title: "Warning", message: "The location specified is close to a fire", parent: self)
                return
            }
        }
        
        showAlert(title: "Safe", message: "The specifiec location is safe", parent: self)
    }
    
    func fireTimer() {
        //it will check every 60 seconds
        Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(checkUserLocation), userInfo: nil, repeats: true)
    }
    
    @objc func checkUserLocation() {
        let radius = 100000.0 // meters
        var mini = Double.greatestFiniteMagnitude
        var found = false
        
        for annotation in map.annotations {
            //calculate from the current location of the user and every fire location
            let fireLocation = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
            
            //the distance is measured in meters
            let distance = fireLocation.distance(from: locationManager.location!)
            if (distance <= radius && !(annotation is MKUserLocation)) {
                mini = min(mini, distance) // only send the closest fire
                found = true
            }
        }
        
        if found {
            let delegate = UIApplication.shared.delegate as? AppDelegate
            delegate?.scheduleNotification(body: "Warning! you are in the vicinity of a forest fire. Distance: \(mini)", triggerDate: Date(), identifier: "hi")
        }
    }
}

//MARK: - Map functions
extension MapVC: MKMapViewDelegate {
    @objc func addPin(_ gesture: UILongPressGestureRecognizer) {
        var pointCord = CLLocationCoordinate2D()
        let touchLocation = gesture.location(in: map)
        pointCord = map.convert(touchLocation, toCoordinateFrom: map)
        
        reportLocation.coordinate = pointCord
        
        if (!reportPinAdded) {
            map.addAnnotation(reportLocation)
            reportPinAdded = true
            
            UIView.animate(withDuration: 0.1) {
                self.reportBtn.alpha = 1
                self.checkBtn.alpha = 1
                self.cancelBtn.alpha = 1
            }
        }
    }
    
    @IBAction func cancel() {
        map.removeAnnotation(reportLocation)
        reportPinAdded = false
        
        UIView.animate(withDuration: 0.1) {
            self.reportBtn.alpha = 0
            self.checkBtn.alpha = 0
            self.cancelBtn.alpha = 0
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKClusterAnnotation) {
            return ClusterAnnotationView(annotation: annotation, reuseIdentifier: "intensity")
        }else if annotation is MKPointAnnotation {
            return MKMarkerAnnotationView()
        }else if annotation is MKUserLocation {
            return nil
        }
        return intensityAnnotation(annotation: annotation, reuseIdentifier: intensityAnnotation.ReuseID)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        UIView.animate(withDuration: 0.4) {
            self.cardTopConstraint.constant = -mapView.frame.height + 10
            self.view.layoutIfNeeded()
        }
        
        let casted = view.annotation as! Cycle
        
        let pathReference = Storage.storage().reference(withPath: "images/\(casted.id).png")
        
        // Download in memory with a maximum allowed size of 10MB (10 * 1024 * 1024 bytes)
        pathReference.getData(maxSize: 10 * 1024 * 1024) { data, error in
            if let error = error {
                print(error)
            } else {
                // Data for downloaded image is returned
                let image = UIImage(data: data!)
                self.pinImage.image = image
            }
        }
    }
}

extension MapVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        let locationAuthorized = status == .authorizedWhenInUse
        userTrackingBtn.isHidden = !locationAuthorized
    }
}
