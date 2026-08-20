# Monitoring

Open job tabs are the monitored set. The first snapshot is a silent baseline. Later build-number transitions may emit one started, succeeded, failed, or unstable event. Poll failures never fabricate build events. Notification identifiers and grouping threads are deterministic hashes of non-secret job/build identity.

The application bundle prohibits multiple simultaneous instances. Selecting a notification routes its job into the existing process, restores minimized application windows, and activates the application so notification handling cannot fall through to another registered build copy with a different sandbox context.
