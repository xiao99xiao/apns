import AsyncKit
import Logging

internal final class APNSConnectionSource: ConnectionPoolSource {
    private let configuration: APNSwiftConfiguration

    public init(configuration: APNSwiftConfiguration) {
        self.configuration = configuration
    }
    public func makeConnection(
        logger: Logger,
        on eventLoop: EventLoop
    ) -> EventLoopFuture<APNSwiftConnection> {
        APNSwiftConnection.connect(configuration: self.configuration, on: eventLoop)
            .flatMapError { (error) -> EventLoopFuture<APNSwiftConnection> in
                logger.notice("APNSConnection failed with error: \(error.localizedDescription), reconnecting...")
                return self.makeConnection(logger: logger, on: eventLoop)
            }
    }
}

extension APNSwiftConnection: ConnectionPoolItem {
    public var eventLoop: EventLoop {
        self.channel.eventLoop
    }

    public var isClosed: Bool {
        !self.channel.isActive
    }
    
    public func close() -> EventLoopFuture<Void> {
        return self.channel.close()
    }
}
