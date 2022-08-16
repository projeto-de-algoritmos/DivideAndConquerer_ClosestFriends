import Foundation

class Location: ObservableObject {
    @Published var friendsLocations: [User] = []
    
    func generateFriendsLocations() {
        var friends: [User] = []
        for _ in 0...30 {
            let randomX = Float.random(in: -20.896389...(-10.458611))
            let randomY = Float.random(in: -52.328611...(-40.793056))
            friends.append(.init(name: Randoms.randomFakeFirstName(), coordinate: .init(latitude: .init(randomX), longitude: .init(randomY))))
        }
        
        friendsLocations = friends
    }
}
