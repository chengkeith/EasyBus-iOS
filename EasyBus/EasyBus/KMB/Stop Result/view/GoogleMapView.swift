//
//  GoogleMapView.swift
//  EasyBus
//
//  Created by KL on 23/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit
import GoogleMaps

class GoogleMapView: GMSMapView {
    
    var markers: [GMSMarker] = []
    var selectedIndex: Int?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if UserSettingManager.shared.isAllowLocation {
            isMyLocationEnabled = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initPoint(stopViewModels: [StopViewModel], targetIndex: Int?) {
        let cameraFocusIndex = targetIndex ?? 0
        let path = GMSMutablePath()
        
        for (i, stopViewModel) in stopViewModels.enumerated() {
            let stop = stopViewModel.stopData
            
            let coordinate = CLLocationCoordinate2D(latitude: stop.lat, longitude: stop.long)
            path.add(coordinate)
            createMarker(position: coordinate, name: stop.cName)
            
            if cameraFocusIndex == i {
                setCamera(coordinate: coordinate)
                setSelectMarker(index: i)
            }
            
            drawPolyline(path: path)
        }
    }
    
    func initPoint(stopViewModels: [CNBusStopViewModel], targetIndex: Int?) {
        let cameraFocusIndex = targetIndex ?? 0
        let path = GMSMutablePath()
        
        for (i, stopViewModel) in stopViewModels.enumerated() {
            let stop = stopViewModel.stop
            
            let coordinate = CLLocationCoordinate2D(latitude: stop.lat, longitude: stop.long)
            path.add(coordinate)
            createMarker(position: coordinate, name: stop.name)
            
            if cameraFocusIndex == i {
                setCamera(coordinate: coordinate)
                setSelectMarker(index: i)
            }
            
            drawPolyline(path: path)
        }
    }
    
    private func createMarker(position: CLLocationCoordinate2D, name: String) {
        let marker = GMSMarker()
        marker.position = position
        
        marker.title = name
        marker.map = self
        markers.append(marker)
    }
    
    private func drawPolyline(path: GMSMutablePath) {
        let polyline = GMSPolyline(path: path)
        polyline.map = self
        polyline.strokeColor = EasyBusColor.appColor
        polyline.strokeWidth = 5
    }
    
    func setSelectMarker(index: Int) {
        if let oldSelectedIndex = selectedIndex {
            markers[oldSelectedIndex].icon = GMSMarker.markerImage(with: nil)
        }
        
        guard index < markers.count else { return }
        selectedIndex = index
        let marker = markers[index]
        marker.icon = GMSMarker.markerImage(with: EasyBusColor.appColor)
        animate(toLocation: marker.position)
        animate(toZoom: 15)
    }
    
    func scrollToUserLocation() {
        guard let postion = UserLocationManager.shared.userLocation?.coordinate else { return }
        animate(toLocation: postion)
        animate(toZoom: 15)
    }
}

fileprivate extension GoogleMapView {
    
    func setCamera(lat: Double, long: Double) {
        camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: 15)
    }
    
    func setCamera(coordinate: CLLocationCoordinate2D) {
        camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: 15)
    }
}
