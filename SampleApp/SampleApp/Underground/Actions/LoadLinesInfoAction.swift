import Combine
import Foundation
import Resin

public struct LoadStationsAction: Action {
}

final class LoadStationsMiddleware: Middleware<LoadStationsAction, UndergroundState> {
    var loadStations: (@escaping (Result<StationsState, Error>) -> Void) -> Void
    
    init(loadStations: @escaping (@escaping (Result<StationsState, Error>) -> Void) -> Void) {
        self.loadStations = loadStations
    }
    
    override func transform(action: LoadStationsAction, context: ActionContext, state: UndergroundState) -> Resin.Action? {
        self.loadStations { [weak self] result in
            self?.dispatch(SetStationsAction.done(result))
        }
        
        return SetStationsAction.loading
    }
}

enum SetStationsAction: Action {
    case none
    case loading
    case done(Result<StationsState, Error>)
}

struct SetStationsReducer: Reducer {
    func reduce(action: SetStationsAction, state: inout UndergroundState) {
        switch action {
        case .none:
            state.stationStateRequest = .none
            
        case .loading:
            state.stationStateRequest = .loading
            
        case let .done(result):
            switch result {
            case let .success(stations):
                state.stationStateRequest = .success
                state.stationsState = stations
                
            case .failure:
                state.stationStateRequest = .failure
                // leave the loast sucessfully loaded stations visible
            }
        }
    }
}


func dummyLoadStations(completionHandler: @escaping (Result<StationsState, Error>) -> Void) {
    DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + 2) {
        completionHandler(.success(StationsState.dummyData))
    }
}


