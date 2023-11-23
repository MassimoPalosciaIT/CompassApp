//
//  ContentView.swift
//  compass
//
//  Created by Massimo Paloscia on 15/11/23.
//

import SwiftUI
import CoreLocation
import CoreMotion

struct Marker: Hashable {
    let degrees: Double
    let label: String

    init(degrees: Double, label: String = "") {
        self.degrees = degrees
        self.label = label
    }

    func degreeText() -> String {
        return String(format: "%.0f", self.degrees)
    }

    static func markers() -> [Marker] {
        return [
            Marker(degrees: 0, label: "N"),
            Marker(degrees: 30),
            Marker(degrees: 60),
            Marker(degrees: 90, label: "E"),
            Marker(degrees: 120),
            Marker(degrees: 150),
            Marker(degrees: 180, label: "S"),
            Marker(degrees: 210),
            Marker(degrees: 240),
            Marker(degrees: 270, label: "W"),
            Marker(degrees: 300),
            Marker(degrees: 330)
        ]
    }
}

struct CompassMarkerView: View {
    let marker: Marker
    let compassDegress: Double

    var body: some View {
        VStack {
            Text(marker.degreeText())
                .fontWeight(.light)
                .rotationEffect(self.textAngle())
            
            Capsule()
                .frame(width: self.capsuleWidth(),
                       height: self.capsuleHeight())
                .foregroundColor(self.capsuleColor())
            
            Text(marker.label)
                .fontWeight(.bold)
                .rotationEffect(self.textAngle())
                .padding(.bottom, 180)
        }.rotationEffect(Angle(degrees: marker.degrees))
    }
    
    private func capsuleWidth() -> CGFloat {
        return self.marker.degrees == 0 ? 7 : 3
    }

    private func capsuleHeight() -> CGFloat {
        return self.marker.degrees == 0 ? 45 : 30
    }

    private func capsuleColor() -> Color {
        return self.marker.degrees == 0 ? .red : .gray
    }

    private func textAngle() -> Angle {
        return Angle(degrees: self.compassDegress - self.marker.degrees)
    }
}

struct ContentView: View {
    
    @StateObject var locationViewModel = LocationViewModel()
    

    
    
    
    
    var body: some View {
        
        switch locationViewModel.authorizationStatus {
        case .notDetermined:
            AnyView(RequestLocationView())
                .environmentObject(locationViewModel)
        case .restricted:
            ErrorView(errorText: "Location use is restricted.")
        case .denied:
            ErrorView(errorText: "The app does not have location permissions. Please enable them in settings.")
        case .authorizedAlways, .authorizedWhenInUse:
            TrackingView()
                .environmentObject(locationViewModel)
        default:
            Text("Unexpected status")
        }
        
    }
}

struct RequestLocationView: View {
    @EnvironmentObject var locationViewModel: LocationViewModel
    
    var body: some View {
        VStack {
            Image(systemName: "location.circle")
                .resizable()
                .frame(width: 100, height: 100, alignment: .center)
                .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
            Button(action: {
                locationViewModel.requestPermission()
            }, label: {
                Label("Allow tracking", systemImage: "location")
            })
            .padding(10)
            .foregroundColor(.white)
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            Text("We need your permission to track you.")
                .foregroundColor(.gray)
                .font(.caption)
        }
    }
}

struct ErrorView: View {
    var errorText: String
    
    var body: some View {
        VStack {
            Image(systemName: "xmark.octagon")
                .resizable()
                .frame(width: 100, height: 100, alignment: .center)
            Text(errorText)
        }
        .padding()
        .foregroundColor(.white)
        .background(Color.red)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct TrackingView: View {
    @EnvironmentObject var locationViewModel: LocationViewModel
    @ObservedObject var gyroscopeManager = GyroscopeModel()
    
    private var cardinalDirections: [String] = ["N", "NE", "E", "SE", "S", "SO", "O", "NO", "N"]

        private var currentDirection: String {
            let index = Int((gyroscopeManager.degrees / 45.0).rounded()) % 8
            return cardinalDirections[index]
        }
    
    var body: some View {
        
        VStack {
            Capsule()
                .frame(width: 5,
                       height: 50)
            
            ZStack {
                ForEach(Marker.markers(), id: \.self) { marker in
                    CompassMarkerView(marker: marker,
                                      compassDegress: gyroscopeManager.degrees)
                }
            }
            .frame(width: 300,
                   height: 300)
            .rotationEffect(Angle(degrees: -gyroscopeManager.degrees))
            .statusBar(hidden: true)
            
            
            

            
            Text("\(Int(gyroscopeManager.degrees))\u{00B0} \(currentDirection)").font(.system(size: 70))
            
            
            
            
            Text(String(locationViewModel.getFormattedCoordinates()))
            HStack{
                //Text(String(locationViewModel.currentPlacemark?.locality ?? "NAPPOLI"))
                //Text(",")
                //Text(String(locationViewModel.currentPlacemark?.administrativeArea ?? "NAPPOLI"))
                Text(String(locationViewModel.getLocatiionAndOthers()))
                
            }
            //Text(String(locationViewModel.lastSeenLocation?.altitude.rounded(.up) ?? 0))
            Text(locationViewModel.getAltitude())
            
            
        }
        
        var coordinate: CLLocationCoordinate2D? {
            locationViewModel.lastSeenLocation?.coordinate
        }
    }
    
    struct PairView: View {
        let leftText: String
        let rightText: String
        
        var body: some View {
            HStack {
                Text(leftText)
                
                Text(rightText)
            }
        }
    }
    
    
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
