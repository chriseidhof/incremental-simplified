import Incremental
import Resin
import SafariServices
import UIKit

public typealias Environment = (
    userDefaults: UserDefaults,
    loadStations: (@escaping (Result<StationsState, Error>) -> Void) -> Void
)

public func makeUndergroundParcel(environment: Environment) -> Parcel<UndergroundState> {
    return Parcel<UndergroundState> { store in
        var result = Parcel<UndergroundState>.Delivery()

        result.presentationRoutes = [
            LineListViewController.presentationRoute.unfocused(by: \.stationsState).typeErased,
            StationDetailViewController.presentationRoute.typeErased,
            StationListViewController.presentationRoute.typeErased,
            StationListViewController.navigationPresentationRoute.typeErased,
        ]

        result.middlewares = [
            LoadStationsMiddleware(loadStations: environment.loadStations),
            SyncFavoritesMiddleware(favoritesStations: store.state[\.favoriteStations], userDefaults: environment.userDefaults),
        ]

        result.reducers = [
            SetStationsReducer().typeErased,
            ToggleFavoriteReducer().typeErased,
            SyncFavoritesReducer().typeErased,
        ]

        return result
    }
}
