// LoginController.swift
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

struct LoginController: HTTPRequestController {

    func get(request: HTTPRequest) -> HTTPResponse {

        if let body = DataBody(resourceAtPath: "login.html") {

            return HTTPResponse(status: .OK, body: body)

        } else {

            return HTTPResponse(status: .NotFound)

        }

    }

    func post(request: HTTPRequest) -> HTTPResponse {

        guard let body = request.body as? FormURLEncodedBody
        else { return HTTPResponse(status: .BadRequest) }

        guard let email = body.parameters["email"],
               password = body.parameters["password"] else {

            return HTTPResponse(status: .BadRequest)

        }

        if email == "regis@regis.com" && password == "123" {

            return HTTPResponse(status: .OK, body: HTMLBody(body: "logou"))

        } else {

            return HTTPResponse(status: .Unauthorized)

        }
        
    }

}