import Foundation
import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    typealias UIViewType = MKMapView
    let region: MKCoordinateRegion
    @ObservedObject var location: Location
    let algorithm = Algorithm()
    @Binding var shouldChange: Bool
    @Binding var shouldDraw: Bool
    @Binding var shouldShowSteps: Bool
    @Binding var steps: [String]
    @Binding var distance: Double
    @Binding var travelTime: Double
    
    func makeCoordinator() -> MapViewCoordinator {
        return MapViewCoordinator()
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()

        mapView.delegate = context.coordinator
        
        loadMap(mapView)

        mapView.showsUserLocation = true
        
        addAnnotations(mapView)
        
        return mapView
    }
    
    func loadMap(_ mapView: MKMapView) {
        location.generateFriendsLocations()
                
        let closestFriends = algorithm.closestPairOf(points: location.friendsLocations)

        mapView.setRegion(.init(center: .init(latitude: closestFriends.firstPoint.coordinate.latitude, longitude: closestFriends.firstPoint.coordinate.longitude), span: .init(latitudeDelta: 10.0, longitudeDelta: 10.0)), animated: true)
    }
    
    func addAnnotations(_ mapView: MKMapView) {
        for pin in location.friendsLocations {
            let marker = MKPointAnnotation()
            marker.coordinate = .init(latitude: pin.coordinate.latitude, longitude: pin.coordinate.longitude)
            marker.title = pin.name
            mapView.addAnnotation(marker)
        }
    }
    
    func shouldChangeLocations(_ mapView: MKMapView) {
        let allAnnotations = mapView.annotations
        
        shouldShowSteps = false
        
        mapView.removeAnnotations(allAnnotations)
        
        location.generateFriendsLocations()
        
        let overlays = mapView.overlays
        
        mapView.removeOverlays(overlays)
        
        addAnnotations(mapView)
    }
    
    func shouldDrawPath(_ mapView: MKMapView) {
        let closestFriends = algorithm.closestPairOf(points: location.friendsLocations)

        let origin = MKPlacemark(coordinate: .init(latitude: closestFriends.firstPoint.coordinate.latitude, longitude: closestFriends.firstPoint.coordinate.longitude))
        
        let destiny = MKPlacemark(coordinate: .init(latitude: closestFriends.secondPoint.coordinate.latitude, longitude: closestFriends.secondPoint.coordinate.longitude))
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: origin)
        request.destination = MKMapItem(placemark: destiny)
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let route = response?.routes.first else { return }
            let originPointmark = MKPointAnnotation()
            originPointmark.coordinate = origin.coordinate
            originPointmark.title = closestFriends.firstPoint.name
            let destinyPointmark = MKPointAnnotation()
            destinyPointmark.coordinate = destiny.coordinate
            destinyPointmark.title = closestFriends.secondPoint.name
            mapView.addAnnotations([originPointmark, destinyPointmark])
            mapView.addOverlay(route.polyline)
            mapView.setVisibleMapRect(
                route.polyline.boundingMapRect,
                edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20),
                animated: true
            )
            steps = route.steps.map { $0.instructions }.filter { !$0.isEmpty }
            distance = route.distance
            travelTime = route.expectedTravelTime
        }
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        if shouldChange {
            shouldChangeLocations(uiView)
            loadMap(uiView)
            shouldChange = false
        }
        
        if shouldDraw {
            shouldDrawPath(uiView)
            shouldDraw = false
            shouldShowSteps = true
        }
    }
        
    class MapViewCoordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .systemPurple
            renderer.lineWidth = 7
            
            return renderer
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "myAnnotation") as? MKMarkerAnnotationView
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "myAnnotation")
            } else {
                annotationView?.annotation = annotation
            }
            
            annotationView?.glyphTintColor = .white
            annotationView?.markerTintColor = .purple
            annotationView?.glyphImage = UIImage(systemName: "person")
            annotationView?.selectedGlyphImage = UIImage(systemName: "person.fill")
            
            return annotationView
        }
    }
}
