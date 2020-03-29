import Foundation

extension RootStore {
    public func integrate(delivery: Parcel<State>.Delivery) {
        for middleware in delivery.middlewares {
            add(middleware: middleware)
        }

        for reducer in delivery.reducers {
            add(reducer: reducer)
        }
    }
}
