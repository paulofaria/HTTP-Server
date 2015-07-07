// Resource.swift
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

#if os(iOS)
 
import Foundation
    
#endif

struct Resource {

    let path: String
    let data: Data

    init?(path: String) {

        let resourcePath = Resource.pathForResource(path)

        guard let resourceData = Resource.getDataForResourceAtPath(resourcePath)
        else { return nil }

        self.path = resourcePath
        self.data = resourceData

    }

}

// MARK: - Private

extension Resource {

    private static func pathForResource(path: String) -> String {

        return "Assets/" + path

    }

    private static func getDataForResourceAtPath(path: String) -> Data? {
        
        #if os(iOS)
            
            let resourcePath = NSBundle.mainBundle().resourcePath!
            let filePath = resourcePath.stringByExpandingTildeInPath.stringByAppendingPathComponent(path)
            
            if let data = NSData(contentsOfFile: filePath) {
                
                let rawArray = Array<UInt8>(start: data.bytes, length: data.length)
                return Data(bytes: data.bytes)
                
            }
            
            return nil
            
    
        #elseif os(OSX)
            
            return File(path: path)?.data
            
        #endif
        
    }

}