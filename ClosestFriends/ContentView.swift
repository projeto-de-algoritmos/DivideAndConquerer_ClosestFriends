import MapKit
import SwiftUI

struct ContentView: View {
    @State private var region: MKCoordinateRegion = MKCoordinateRegion(center: .init(latitude: MapDefaults.latitude, longitude: MapDefaults.longitude), span: MKCoordinateSpan(latitudeDelta: MapDefaults.zoom, longitudeDelta: MapDefaults.zoom))
    
    @State private var shouldDraw: Bool = false
    @State private var shouldChange: Bool = false
    @State private var shouldShowSteps: Bool = false
    @State private var steps: [String] = []
    @State private var distance: Double = 0.0
    @State private var travelTime: TimeInterval = 0.0
    @State private var showSteps: Bool = false
    
    private enum MapDefaults {
        static let latitude = -15.915010
        static let longitude = -48.058010
        static let zoom = 10.0
    }
    
    @ObservedObject var location: Location = .init()
    let algorithm: Algorithm = .init()
    
    var body: some View {
        NavigationView {
            ZStack {
                Divider()
                    .background(.ultraThinMaterial)
                MapView(region: region, location: location, shouldChange: $shouldChange, shouldDraw: $shouldDraw, shouldShowSteps: $shouldShowSteps, steps: $steps, distance: $distance, travelTime: $travelTime)
                    .ignoresSafeArea(.all, edges: .bottom)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        if shouldShowSteps {
                            Spacer()
                            Button {
                                showSteps.toggle()
                            } label: {
                                Image(systemName: "map")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(.purple)
                                    .clipShape(Circle())
                            }
                            .sheet(isPresented: $showSteps) {
                                NavigationView {
                                    VStack {
                                        if !steps.isEmpty {
                                            List(steps, id: \.self) { step in
                                                Text(step)
                                            }
                                        } else {
                                            Text("Sem direções disponíveis 😕")
                                        }
                                    }
                                    .navigationTitle(
                                        Text("Direções ") +
                                        Text(travelTime != 0 ? "(\(Int(travelTime/60))min)" : "")
                                    )
                                }
                            }
                            Spacer()
                        }
                        Button {
                            shouldChange = true
                        } label: {
                            Image(systemName: "arrow.clockwise")
                                .font(.title3)
                                .padding()
                                .background(.purple)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                        .padding(.trailing)
                    }
                }
            }
            .onAppear {
                location.generateFriendsLocations()
                let currentLocation = LocationHelper.currentLocation
                region = .init(center: .init(latitude: currentLocation.latitude, longitude: currentLocation.longitude), span: MKCoordinateSpan(latitudeDelta: MapDefaults.zoom, longitudeDelta: MapDefaults.zoom))
            }
            .navigationTitle("Closest Friends")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        shouldDraw = true
                    } label: {
                        Image(systemName: "map")
                            .foregroundColor(.purple)
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
