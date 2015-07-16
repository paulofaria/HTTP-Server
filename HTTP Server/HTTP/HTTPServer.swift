// HTTPServer.swift
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Zewo
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

final class HTTPServer {

    private var router = HTTPRouter()
    private var socket: Socket?

    var routes: [String] {

        return router.routes.map { $0.path }

    }

    init(inMiddlewares: RequestMiddleware? = nil, routes: [String: RequestResponder], outMiddlewares: ResponseMiddleware? = nil) {

        for (path, responder) in routes {

            let responderChain: RequestResponder

            if let inMiddlewares = inMiddlewares,
                  outMiddlewares = outMiddlewares {

                responderChain = inMiddlewares >>> responder >>> outMiddlewares

            } else if let inMiddlewares = inMiddlewares {

                responderChain = inMiddlewares >>> responder

            } else if let outMiddlewares = outMiddlewares {

                responderChain = responder >>> outMiddlewares

            } else {

                responderChain = responder
                
            }

            router.addRoute(path, responder: responderChain)
            
        }
        
    }

    convenience init(_ serverConfiguration: HTTPServerConfiguration) {

        self.init(
            inMiddlewares: serverConfiguration.inMiddlewares,
            routes: serverConfiguration.routes,
            outMiddlewares: serverConfiguration.outMiddlewares
        )

    }

    convenience init(_ routes: [String: RequestResponder]) {

        self.init(routes: routes)
        
    }

}

// MARK: - Start / Stop

extension HTTPServer {

    func start(port port: TCPPort = 8080, failure: ErrorType -> Void = HTTPServer.defaultFailure)   {

        do {

            socket?.release()
            socket = try Socket(port: port, maxConnections: 1000)

            Log.info("HTTP Server listening at port \(port).")

            Dispatch.async {

                self.waitForClients(failure)

            }

        } catch {

            failure(error)

        }

    }

    func stop() {

        socket?.release()

    }

}

// MARK: - Private

extension HTTPServer {

    private static func defaultFailure(error: ErrorType) {

        Log.error("Server error: \(error)")
        
    }

    private func waitForClients(failure: ErrorType -> Void) {

        do {

            while true {

                let clientSocket = try socket!.acceptClient()

                Dispatch.async {

                    self.processClientSocket(clientSocket, failure: failure)

                }

            }

        } catch {

            socket?.release()
            failure(error)
            
        }

    }

    private func processClientSocket(clientSocket: Socket, failure: ErrorType -> Void) {

        do {

            while true {

                let request =  try HTTPServerParser.receiveHTTPRequest(clientSocket)
                let response = responseForRequest(request, failure: failure)
                try HTTPServerSerializer.sendHTTPResponse(clientSocket, response: response)

                if !request.keepAlive { break }

            }

            clientSocket.release()

        } catch {

            failure(error)

        }

    }

    private func responseForRequest(request: HTTPRequest, failure: ErrorType -> Void) -> HTTPResponse {

        if let routeMatch = router.match(request.path) {

            return responseForRouteMatch(routeMatch, request: request, failure: failure)

        } else {

            return responseForAssetAtPath(request.path)
            
        }

    }

    private func responseForRouteMatch(routeMatch: HTTPRouter.RouteMatch, request: HTTPRequest, failure: ErrorType -> Void) -> HTTPResponse {

        do {

            let keepAliveMiddleware = HTTPKeepAliveMiddleware(keepAlive: request.keepAlive).mediate
            let responder = routeMatch.responder >>> keepAliveMiddleware
            return try responder(request)

        } catch {

            failure(error)
            return HTTPResponse(status: .InternalServerError, body: TextBody(text: "\(error)"))

        }
        
    }

    private func responseForAssetAtPath(path: String) -> HTTPResponse {

        let assetPath = path.dropFirstCharacter()

        if let asset = Asset(path: assetPath) {

            return HTTPResponse(status: .OK, body: DataBody(asset: asset))

        } else {

            return HTTPResponse(status: .NotFound)
            
        }

    }

}

