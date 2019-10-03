import Foundation

extension RootStore {
    public func integrate(parcel: Parcel<State, Environment>) {
        for middleware in parcel.legacyMiddleware {
            add(middleware: middleware)
        }

        for factory in parcel.middleware {
            add(middleware: factory)
        }

        for reducer in parcel.reducers {
            add(reducer: reducer)
        }
    }
}
