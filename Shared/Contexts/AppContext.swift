import Foundation
import Logging

final class AppContext: NSObject, ObservableObject {

    override init() {

        LoggingSystem.bootstrap({
            var logHandler = StreamLogHandler.standardOutput(label: $0)
            logHandler.logLevel = .debug
            return logHandler
        })
    }
}
