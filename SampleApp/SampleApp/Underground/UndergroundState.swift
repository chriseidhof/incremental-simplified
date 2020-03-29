import Foundation
import Resin

public struct UndergroundState: Equatable {
    var navigationStack: [AnyPresentationIdentifier] = []

    var favoriteStations: Set<String> = []
    
    var stationsState = StationsState()
    var stationStateRequest: RequestState = .none
}

enum RequestState: Equatable {
    case none
    case loading
    case failure
    case success
}
