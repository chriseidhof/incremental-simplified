import Foundation
import UIKit

public final class AppDelegate: NSObject {
    @objc public var window: UIWindow?

    let appCoordinator = AppCoordinator()

    public override init() {
        super.init()
    }
}

extension AppDelegate: UIApplicationDelegate {
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.rootViewController = appCoordinator.tabBarController
        window!.makeKeyAndVisible()

        return true
    }
}
