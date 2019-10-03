import Foundation

/// Value types conforming to the `Action` protocol are used to perform changes
/// to the `Store`.
///
/// In order to make use of an `Action`, you need to either write a `Middleware`
/// or a `Reducer` and register them with the `Store` you send this `Action` to.
public protocol Action { }

/// Actions that need to be executed and perform changes in the store immediately
/// (in the same runloop as they are dispatched) must conform to this protocol.
///
/// This should *only* be used to change state in response to system events,
/// such as a `UIApplicationWillEnterForegroundNotification` or a
/// `UINavigationController` delegate callback
public protocol SystemResponseAction: Action { }
