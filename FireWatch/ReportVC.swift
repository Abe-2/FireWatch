//
//  ReportVC.swift
//  FireWatch
//
//  Created by Abdalwahab on 10/19/18.
//  Copyright © 2018 Ali Kelkawi. All rights reserved.
//

//1- make the button store the image since we want to maybe change the image

import UIKit
import ImagePicker
import MapKit
import Firebase
import FirebaseStorage

class ReportVC: UIViewController {
    
    var cords : CLLocationCoordinate2D!
    
    //selected images
    var selectedImage = UIImage()
    
    @IBOutlet var cameraBtn: UIButton!
    @IBOutlet var submitBtn: UIButton!
    
    //database
    let ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraBtn.imageView?.contentMode = .scaleAspectFit
//        loadDataForMapRegionAndBikes()
    }
    
    //change location from one to a unique id
    @IBAction func submit() {
        MapVC.fireCount += 1
        let id = MapVC.fireCount
        
        ref.child("FireLocations").child("Location\(id)").child("Longitude").setValue(cords.longitude)
        ref.child("FireLocations").child("Location\(id)").child("Latitude").setValue(cords.latitude)
        
        //ADD THIS CODE. uploading selected image
        let storageRef = Storage.storage().reference()
        let data = UIImagePNGRepresentation(selectedImage)!

        //add id variable
        let imageRef = storageRef.child("images/Location\(id).png")
        _ = imageRef.putData(data, metadata: nil, completion: { (metadata,error ) in
            
            if (error != nil) {
                print(error as Any)
                return
            }
        })
    }
    
//    func submit2(long: CLLocationDegrees, lat: CLLocationDegrees, id: Int) {
//        ref.child("FireLocations").child("Location\(id)").child("Longitude").setValue(long)
//        ref.child("FireLocations").child("Location\(id)").child("Latitude").setValue(lat)
//    }
    
//    private func loadDataForMapRegionAndBikes() {
//        guard let plistURL = Bundle.main.url(forResource: "Data", withExtension: "plist") else {
//            fatalError("Failed to resolve URL for `Data.plist` in bundle.")
//        }
//
//        do {
//            let plistData = try Data(contentsOf: plistURL)
//            let decoder = PropertyListDecoder()
//            let decodedData = try decoder.decode(MapData.self, from: plistData)
////            map.region = decodedData.region
//            decodedData.region
//
//            var id = 1
//            for hello in decodedData.cycles {
//                submit2(long: hello.coordinate.longitude, lat: hello.coordinate.latitude, id: id)
//                id += 1
//            }
//        } catch {
//            fatalError("Failed to load provided data, error: \(error.localizedDescription)")
//        }
//    }
}

//MARK: - Photo selecting
extension ReportVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate, ImagePickerDelegate {
    
    @IBAction func selectPhotos() {
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 1
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        selectedImage = images[0]
        
        cameraBtn.setImage(selectedImage, for: .normal)
        cameraBtn.imageView?.clipsToBounds = true
        cameraBtn.imageView?.contentMode = .scaleAspectFill
        cameraBtn.isEnabled = true
        
        submitBtn.alpha = 1
        submitBtn.isEnabled = true
        
        dismiss(animated: true, completion: nil)
    }
}

extension ReportVC {
    
}
