//
//  InformationController.swift
//  Youbike
//
//  Created by 曾柏瑒 on 2022/1/11.
//

import UIKit
import MapKit
import CoreLocation

class InformationController: UIViewController {
    
    // MARK: - Properties
    
    var userLocation: CLLocation?
    
    var youbikeModel: YoubikeModel?
    
    private let manager = CLLocationManager()
    
    private let informationLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.backgroundColor = .white
        label.textAlignment = .left
        
        return label
    }()
    
    private let mapView = MKMapView()
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    // MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .white
        navigationItem.title = "詳細頁"
        
        view.addSubview(informationLabel)
        
        informationLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 16, paddingLeft: 32, paddingRight: 32)
        informationLabel.setHeight((view.frame.height / 5))
        
        view.addSubview(mapView)
        mapView.anchor(top: informationLabel.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor)
        
        configureInformationText()
        
        configureMapUI()
    }
    
    func configureInformationText() {
        guard let youbikeModel = youbikeModel else { return }
        let chineseName = youbikeModel.chineseName
        let chineseArea = youbikeModel.chineseArea
        let chineseAddress = youbikeModel.chineseAddress
        
        DispatchQueue.main.async {
            let text = "場站中文名稱: \(chineseName)\n場站區域: \(chineseArea)\n地點: \(chineseAddress)"
            self.informationLabel.text = text
        }
    }
    
    func configureMapUI() {
        
        if let youbikeLocation = youbikeModel?.location,
           let userLocation = userLocation {
            let sourceLocation = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
            let detinationLocation = CLLocationCoordinate2D(latitude: youbikeLocation.coordinate.latitude, longitude: youbikeLocation.coordinate.longitude)
            
            createPath(sourceLocation: sourceLocation, destinationLocation: detinationLocation)
            
            self.mapView.delegate = self

        } else if let youbikeLocation = youbikeModel?.location {
            let coordinate = CLLocationCoordinate2D(latitude: youbikeLocation.coordinate.latitude, longitude: youbikeLocation.coordinate.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            let region = MKCoordinateRegion(center: coordinate, span: span)
            mapView.setRegion(region, animated: true)
            let pin = MKPointAnnotation()
            pin.coordinate = coordinate
            mapView.addAnnotation(pin)
            
        }
        
    }
    
    func createPath(sourceLocation: CLLocationCoordinate2D, destinationLocation: CLLocationCoordinate2D) {
        let sourcePlaceMark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let detinationPlaceMark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlaceMark)
        let destinationItem = MKMapItem(placemark: detinationPlaceMark)
        
        let sourceAnotation = MKPointAnnotation()
        if let location = sourcePlaceMark.location {
            sourceAnotation.coordinate = location.coordinate
        }
        
        let destinationAnotation = MKPointAnnotation()
        if let location = detinationPlaceMark.location {
            destinationAnotation.coordinate = location.coordinate
        }
        
        print(sourceAnotation, destinationAnotation)
        
        mapView.showAnnotations([sourceAnotation, destinationAnotation], animated: true)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationItem
        directionRequest.transportType = .walking
        
        let direction = MKDirections(request: directionRequest)
        direction.calculate { response, error in
            guard let response = response else {
                if let error = error {
                    print("ERROR: \(error.localizedDescription)")
                }
                return
            }
            
            let route = response.routes[0]
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            
            let rec = route.polyline.boundingMapRect
        
            let insets = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
            let rect = self.mapView.mapRectThatFits(rec, edgePadding: insets)
            
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
    
    
}



// MARK: - MKMapViewDelegate

extension InformationController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.lineWidth = 7
        renderer.strokeColor = .systemBlue

        return renderer
    }

}
