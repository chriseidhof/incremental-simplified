import Foundation
import Incremental
import Resin

enum SyncFavoritesAction: Action {
    case fromUserDefaults(Set<String>)
    case toUserDefaults(Set<String>)
}

class SyncFavoritesMiddleware: Middleware<SyncFavoritesAction, UndergroundState> {
    private let userDefaults: UserDefaults

    private var observer: NSKeyValueObservation?

    private var disposable: Disposable?

    required public init(favoritesStations: I<Set<String>>, userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
        
        super.init()

        observer = userDefaults.observe(\.favorites) { [unowned self] _, changes in
            if changes.newValue != changes.oldValue {
                self.dispatch(SyncFavoritesAction.fromUserDefaults(changes.newValue ?? Set()))
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [unowned self] in
            self.dispatch(SyncFavoritesAction.fromUserDefaults(self.userDefaults.favorites))

            self.disposable = favoritesStations.observe { [unowned self] favorites in
                self.dispatch(SyncFavoritesAction.toUserDefaults(favorites))
            }
        }
    }

    override func transform(action: SyncFavoritesAction, context: ActionContext, state: UndergroundState) -> Resin.Action? {
        guard case let .toUserDefaults(favorites) = action else {
            return action
        }

        userDefaults.favorites = favorites
        return nil
    }
}

struct SyncFavoritesReducer: Reducer {
    public func reduce(action: SyncFavoritesAction, state: inout UndergroundState) {
        guard case let .fromUserDefaults(favorites) = action else {
            return
        }

        state.favoriteStations = favorites
    }
}


extension UserDefaults {
    @objc var favorites: Set<String> {
        get {
            let array = object(forKey: "favorites") as? [String] ?? []

            return Set(array)
        }
        set {
            set(Array(newValue), forKey: "favorites")
        }
    }
}
