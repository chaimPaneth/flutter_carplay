//
// FCPMapViewController.swift
// flutter_carplay
//
// Created by Oğuzhan Atalay on on 19/01/24.
// Copyright © 2024. All rights reserved.
//

import UIKit
import MapKit
import CarPlay

/// A custom CarPlay map view controller.
class FCPMapViewController: UIViewController {
    
    /// The map view associated with the map view controller.
    @IBOutlet weak var mapView: MKMapView!
    
    /// The banner view associated with the map view controller.
    @IBOutlet weak var bannerView: FCPBannerView!{
        didSet {
            guard let view = bannerView else { return }
            view.isHidden = true
        }
    }
    
    /// The toast view associated with the map view controller.
    @IBOutlet weak var toastView: FCPToastView! {
        didSet {
            guard let view = toastView else { return }
            view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            view.layer.cornerRadius = 10
            view.isHidden = true
        }
    }
    
    /// The maximum width of the toast view.
    @IBOutlet weak var toastViewMaxWidth: NSLayoutConstraint!
    
    /// The maximum width of the overlay view.
    @IBOutlet weak var overlayViewMaxWidth: NSLayoutConstraint!
    
    /// The overlay view associated with the map view controller.
    @IBOutlet weak var overlayView: FCPOverlayView! {
        didSet {
            guard let view = overlayView else { return }
            view.backgroundColor = .clear
            view.clipsToBounds = true
            view.layer.cornerRadius = 8
            view.isHidden = true
        }
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        configureMapView()
    
        
    }
    
    /// This method is called when the view's bounds change.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        /// Set the maximum width of the toast view.
        toastViewMaxWidth.constant = view.bounds.size.width - 80.0
        overlayViewMaxWidth.constant = view.bounds.size.width - 80.0
        
    }
    
    
    // MARK: - configureMapView
    
    func configureMapView() {
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 23.0225, longitude: 72.5714),
            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        )
        
        mapView?.setRegion(region, animated: true)
        mapView?.showsUserLocation = true
        mapView?.delegate = self // Add this line
        mapView?.setUserTrackingMode(.follow, animated: true)
        mapView?.overrideUserInterfaceStyle = .light
    }
    
    /// Calculates and displays a route on the map.
    func calculateAndDisplayRoute() {
        // Replace these coordinates with the actual destination coordinates
        let sourceLocation = CLLocationCoordinate2D(latitude: 22.9978, longitude: 72.6660)
        let destinationLocation = CLLocationCoordinate2D(latitude: 23.0120, longitude: 72.5108)
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { response, _ in
            guard let route = response?.routes.first else {
                MemoryLogger.shared.appendEvent("Route calculation failed.")
                return
            }
            
            self.mapView.removeOverlays(self.mapView?.overlays ?? [])
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            
            let routeRect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(routeRect), animated: true)
        }
    }
    
}

// Extension for UIViewController utility methods
// MARK: - Banner & Toast View
extension FCPMapViewController {
    /// Displays a banner message at the top of the screen
    func showBanner(message: String, color: Int) {
        bannerView.setMessage(message)
        bannerView.backgroundColor = UIColor(argb: color)
        bannerView.isHidden = false
    }
    
    /// Hides the banner message at the top of the screen.
    func hideBanner() {
        bannerView.isHidden = true
    }
    
    /// Displays a toast message on the screen for a specified duration.
    func showToast(message: String, duration: TimeInterval = 2.0) {
        toastView.setMessage(message)
        toastView.alpha = 1.0
        toastView.isHidden = false

        UIView.animate(withDuration: 0.5, delay: duration, options: .curveEaseOut, animations: {
            self.toastView.alpha = 0.0
        }, completion: { _ in
            self.toastView.alpha = 1.0
            self.toastView.isHidden = true
        })
        
    }
    
    /// Displays an overlay view on the screen.
    func showOverlay(primaryTitle: String, secondaryTitle: String, subTitle: String) {
        overlayView.setPrimaryTitle(primaryTitle)
        overlayView.setSecondaryTitle(secondaryTitle)
        overlayView.setSubTitle(subTitle)
        overlayView.isHidden = false
    }
    
    /// Hides the overlay view on the screen.
    func hideOverlay() {
        overlayView.isHidden = true
    }
}

// MARK: - CPMapTemplateDelegate
extension FCPMapViewController: CPMapTemplateDelegate {
    // Implement CPMapTemplateDelegate methods here
    // ...
    
    /// Called when a pan gesture begins on the map.
    func mapTemplateDidBeginPanGesture(_: CPMapTemplate) {
        MemoryLogger.shared.appendEvent("🚙🚙🚙🚙🚙 Panning")
    }
    
    /// Called when the map is panned in a specific direction.
    func mapTemplate(_: CPMapTemplate, panWith direction: CPMapTemplate.PanDirection) {
        MemoryLogger.shared.appendEvent("🚙🚙🚙🚙🚙 Panning: \(direction)")
    }
    
    /// Called when a button is pressed on the map template.
    func mapTemplate(_: CPMapTemplate, buttonPressed button: CPBarButton) {
        if button.title == "Location" { // Replace with the actual button title
            calculateAndDisplayRoute()
        }
    }
    
}

// Extension for MKMapViewDelegate methods
// MARK: - MKMapViewDelegate
extension FCPMapViewController: MKMapViewDelegate {
    func mapView(_: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 5
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}
