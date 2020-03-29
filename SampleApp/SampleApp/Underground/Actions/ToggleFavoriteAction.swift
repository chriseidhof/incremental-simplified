import Foundation
import Incremental
import Resin

struct ToggleFavoriteAction: Action {
    var station: String

    public init(station: String) {
        self.station = station
    }
}

struct ToggleFavoriteReducer: Reducer {
    public func reduce(action: ToggleFavoriteAction, state: inout UndergroundState) {
        if state.favoriteStations.contains(action.station) {
            state.favoriteStations.remove(action.station)
        } else {
            state.favoriteStations.insert(action.station)
        }
    }
}
