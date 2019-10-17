//
//  intensityAnnotation.swift
//  FireWatch
//
//  Created by Abdalwahab on 10/19/18.
//  Copyright © 2018 Ali Kelkawi. All rights reserved.
//

import UIKit
import MapKit

class intensityAnnotation: MKMarkerAnnotationView {

    static let ReuseID = "intensityAnnotation"
    
    /// - Tag: ClusterIdentifier
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        clusteringIdentifier = "intensity"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        displayPriority = .defaultHigh
        markerTintColor = #colorLiteral(red: 0.9333333333, green: 0.7333333333, blue: 0.1058823529, alpha: 1)
        glyphImage = #imageLiteral(resourceName: "flame")
    }
}

/*
 Abstract:
 The annotation view representing multiple fires annotations in a clustered annotation.
 */

/// - Tag: ClusterAnnotationView
class ClusterAnnotationView: MKMarkerAnnotationView {

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        collisionMode = .circle
        centerOffset = CGPoint(x: 0, y: -10) // Offset center point to animate better with marker annotations
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// - Tag: CustomCluster
    override func prepareForDisplay() {
        super.prepareForDisplay()
        
        subtitleVisibility = MKFeatureVisibility.hidden

        let casted = annotation as! MKClusterAnnotation

        if casted.memberAnnotations.count < 2 {
            markerTintColor = #colorLiteral(red: 0.9333333333, green: 0.7333333333, blue: 0.1058823529, alpha: 1)
        } else if casted.memberAnnotations.count < 6 {
            markerTintColor = #colorLiteral(red: 0.9450980392, green: 0.4039215686, blue: 0.1411764706, alpha: 1)
        } else if casted.memberAnnotations.count < 10 {
            markerTintColor = #colorLiteral(red: 0.7490196078, green: 0.1254901961, blue: 0.1843137255, alpha: 1)
        } else {
            markerTintColor = #colorLiteral(red: 0.4431372549, green: 0.05882352941, blue: 0.06666666667, alpha: 1)
        }
    }
}

//class ClusterAnnotationView: MKAnnotationView {
//
//    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
//        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
//        collisionMode = .circle
//        centerOffset = CGPoint(x: 0, y: -10) // Offset center point to animate better with marker annotations
//
//        let casted = annotation as! MKClusterAnnotation
//
//        if casted.memberAnnotations.count < 2 {
//            image = #imageLiteral(resourceName: "Extreme copy")
//        } else if casted.memberAnnotations.count < 6 {
//            image = #imageLiteral(resourceName: "Extreme copy")
//        } else if casted.memberAnnotations.count < 10 {
//            image = #imageLiteral(resourceName: "Extreme copy")
//        } else {
//            image = #imageLiteral(resourceName: "Extreme copy")
//        }
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
