// An HTTP/1.1 server on 127.0.0.1, for the tests that need a real `URLSession`: a request cancelled in flight, a body
// cut short. POSIX sockets only, on Apple platforms (Linux's `FoundationNetworking` session is not exercised).

#if canImport(Darwin)
    import Darwin
    import Foundation

    /// Answers each connection with the next `Reply` (the last one repeats), and records the requests it read and the
    /// connections the client closed while the server was waiting on them.
    final class LoopbackHTTPServer: @unchecked Sendable {
        enum Reply: Sendable {
            /// Reads the request and sends nothing, until the client closes the connection.
            case stallBeforeHeaders
            /// A `200` chunked `text/event-stream` response: each of `events` in a chunk of its own, then `ending`.
            case sse([String], then: Ending)
        }

        enum Ending: Sendable, CustomStringConvertible {
            /// Keeps the connection open, sending nothing more, until the client closes it.
            case stall
            /// Closes the connection without the last chunk, so the body is cut short.
            case closeConnection
            /// Sends the last chunk, so the body is whole, and closes the connection.
            case endBody

            var description: String {
                switch self {
                case .stall: return "stall"
                case .closeConnection: return "closeConnection"
                case .endBody: return "endBody"
                }
            }
        }

        let port: UInt16
        private let listener: Int32
        private let lock = NSLock()
        private var replies: [Reply]
        private var _requests: [String] = []
        private var _closedByClient = 0
        private var stopped = false

        init(_ replies: [Reply]) throws {
            precondition(!replies.isEmpty)
            self.replies = replies
            let fd = socket(AF_INET, SOCK_STREAM, 0)
            guard fd >= 0 else { throw POSIXError(.init(rawValue: errno) ?? .EIO) }
            var yes: Int32 = 1
            setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &yes, socklen_t(MemoryLayout<Int32>.size))
            var addr = sockaddr_in()
            addr.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
            addr.sin_family = sa_family_t(AF_INET)
            addr.sin_port = 0
            addr.sin_addr.s_addr = inet_addr("127.0.0.1")
            let bound = withUnsafePointer(to: &addr) {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { bind(fd, $0, socklen_t(MemoryLayout<sockaddr_in>.size)) }
            }
            guard bound == 0, listen(fd, 16) == 0 else {
                close(fd)
                throw POSIXError(.init(rawValue: errno) ?? .EIO)
            }
            var length = socklen_t(MemoryLayout<sockaddr_in>.size)
            _ = withUnsafeMutablePointer(to: &addr) {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { getsockname(fd, $0, &length) }
            }
            listener = fd
            port = UInt16(bigEndian: addr.sin_port)
            let thread = Thread { [self] in acceptLoop() }
            thread.start()
        }

        var baseURL: String { "http://127.0.0.1:\(port)" }
        /// The request line of each request read, in order.
        var requests: [String] { lock.withLock { _requests } }
        /// How many connections the client closed while the server waited on them.
        var closedByClient: Int { lock.withLock { _closedByClient } }

        /// Stops accepting and ends every connection's thread within a poll interval.
        func stop() {
            lock.withLock { stopped = true }
        }

        private var isStopped: Bool { lock.withLock { stopped } }

        /// Waits up to 50 ms for `fd` to be readable; nil once the server is stopped.
        private func readable(_ fd: Int32) -> Bool? {
            var p = pollfd(fd: fd, events: Int16(POLLIN), revents: 0)
            while !isStopped {
                let n = poll(&p, 1, 50)
                if n > 0 { return true }
                if n < 0 && errno != EINTR { return true }
            }
            return nil
        }

        private func acceptLoop() {
            defer { close(listener) }
            while readable(listener) != nil {
                let connection = accept(listener, nil, nil)
                if connection < 0 { continue }
                var yes: Int32 = 1
                setsockopt(connection, SOL_SOCKET, SO_NOSIGPIPE, &yes, socklen_t(MemoryLayout<Int32>.size))
                let thread = Thread { [self] in serve(connection) }
                thread.start()
            }
        }

        private func serve(_ fd: Int32) {
            defer { close(fd) }
            guard let requestLine = readRequest(fd) else { return }
            let reply: Reply = lock.withLock {
                _requests.append(requestLine)
                return replies.count > 1 ? replies.removeFirst() : replies[0]
            }
            switch reply {
            case .stallBeforeHeaders:
                waitForClose(fd)
            case .sse(let events, let ending):
                var head = "HTTP/1.1 200 OK\r\ncontent-type: text/event-stream\r\ntransfer-encoding: chunked\r\nrequest-id: req_loopback\r\n"
                if case .endBody = ending { head += "connection: close\r\n" }
                write(fd, head + "\r\n")
                for event in events {
                    let bytes = Data(event.utf8)
                    write(fd, String(bytes.count, radix: 16) + "\r\n" + event + "\r\n")
                }
                switch ending {
                case .stall: waitForClose(fd)
                case .closeConnection: break
                case .endBody: write(fd, "0\r\n\r\n")
                }
            }
        }

        /// Reads one request (its head and a `content-length` body) and returns its request line.
        private func readRequest(_ fd: Int32) -> String? {
            var buffer = [UInt8]()
            var chunk = [UInt8](repeating: 0, count: 4096)
            let separator: [UInt8] = [13, 10, 13, 10]
            var headEnd: Int?
            var bodyLength = 0
            while true {
                if headEnd == nil, let end = buffer.firstRange(of: separator)?.upperBound {
                    headEnd = end
                    let head = String(decoding: buffer[..<end], as: UTF8.self)
                    for line in head.components(separatedBy: "\r\n") {
                        let parts = line.split(separator: ":", maxSplits: 1)
                        if parts.count == 2, parts[0].lowercased() == "content-length" {
                            bodyLength = Int(parts[1].trimmingCharacters(in: .whitespaces)) ?? 0
                        }
                    }
                }
                if let headEnd, buffer.count >= headEnd + bodyLength {
                    let head = String(decoding: buffer[..<headEnd], as: UTF8.self)
                    return head.components(separatedBy: "\r\n").first
                }
                guard readable(fd) != nil else { return nil }
                let n = recv(fd, &chunk, chunk.count, 0)
                if n <= 0 { return nil }
                buffer.append(contentsOf: chunk[..<n])
            }
        }

        /// Waits until the client closes the connection (or the server stops), discarding anything it sends.
        private func waitForClose(_ fd: Int32) {
            var chunk = [UInt8](repeating: 0, count: 1024)
            while readable(fd) != nil {
                if recv(fd, &chunk, chunk.count, 0) <= 0 {
                    lock.withLock { _closedByClient += 1 }
                    return
                }
            }
        }

        private func write(_ fd: Int32, _ text: String) {
            let bytes = Array(text.utf8)
            var sent = 0
            while sent < bytes.count {
                let n = bytes[sent...].withUnsafeBytes { send(fd, $0.baseAddress, $0.count, 0) }
                if n <= 0 { return }
                sent += n
            }
        }
    }
#endif
