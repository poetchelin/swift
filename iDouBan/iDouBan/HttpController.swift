//
//  HttpController.swift
//  iDouBan
//
//  Created by Cunqi.X on 10/13/14.
//  Copyright (c) 2014 cunqi xiao. All rights reserved.
//

import UIKit

protocol HttpProtocol {
    func didReceiveResults(result: NSDictionary)
}

class HttpController: NSObject {
    var delegate: HttpProtocol?
    
    func onSearch(url: String) {
        var nsUrl: NSURL = NSURL(string: url)!
        
        var request: NSURLRequest = NSURLRequest(URL: nsUrl)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
            
            self.delegate?.didReceiveResults(jsonResult)
        })
        
    }
}