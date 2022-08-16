import Foundation
import MapKit

struct User: Identifiable {
    let id = UUID()
    let name: String
    var coordinate: CLLocationCoordinate2D
}
