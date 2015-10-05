//
//  LocationViewController.swift
//  Permissions
//
//  Created by Daniel Thorpe on 28/07/2015.
//  Copyright (c) 2015 Daniel Thorpe. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit
import Operations

class LocationViewController: PermissionViewController {

    var mapView: MKMapView!

    var location: CLLocation? = .None {
        didSet {
            if let location = location {
                dispatch_async(Queue.Main.queue) {
                    self.mapView.setRegion(location.region, animated: true)
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Location", comment: "Location")

        permissionNotDetermined.informationLabel.text = "We haven't yet asked permission to access your Location."
        permissionGranted.instructionLabel.text = "Perform an operation to get your current Location."
        permissionGranted.button.setTitle("Where am I?", forState: .Normal)
        operationResults.informationLabel.hidden = true

        mapView = MKMapView.newAutoLayoutView()
        operationResults.addSubview(mapView)
        mapView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero)

    }

    override func viewWillAppear(animated: Bool) {
        determineAuthorizationStatus()
    }

    func locationServicesEnabled(enabled: Bool, withAuthorization status: CLAuthorizationStatus) {
        switch (enabled, status) {
        case (false, _):
            print("Location Services are not enabled")

        case (true, .AuthorizedWhenInUse), (true, .AuthorizedAlways):
            self.state = .Authorized
            self.mapView.showsUserLocation = true

        case (true, .Restricted), (true, .Denied):
            self.state = .Denied

        default:
            self.state = .Unknown
        }
    }

    func determineAuthorizationStatus() {
        let status = GetAuthorizationStatus(Capability.Location(), completion: locationServicesEnabled)
        queue.addOperation(status)
    }

    override func requestPermission() {
        let authorize = Authorize(Capability.Location(), completion: locationServicesEnabled)
        queue.addOperation(authorize)
    }

    override func performOperation() {
        let location = UserLocationOperation { location in
            self.state = .Completed
            self.location = location
        }
        queue.addOperation(location)
    }
}

extension CLLocation {

    var region: MKCoordinateRegion {
        get {
            let miles: CLLocationDistance = 12
            let scalingFactor = abs(cos(2.0 * M_PI * coordinate.latitude / 360.0))
            let span = MKCoordinateSpan(latitudeDelta: miles/69.0, longitudeDelta: miles/(scalingFactor*69.0))
            return MKCoordinateRegion(center: coordinate, span: span)
        }
    }
}




