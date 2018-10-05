//
//  DownloadManager.swift
//  GamerMatch
//
//  Created by Eric Rado on 10/4/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import Foundation

class DownloadManager: NSObject {
    
    static var shared = DownloadManager()
    //var delegate = DownloadManagerSessionDelegate()
    private var session: URLSession!
    
    
    private override init() {
        super.init()
        let config = URLSessionConfiguration.background(withIdentifier: "BackgroundDownloads")
        session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }
}

extension DownloadManager: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
    }
    
    
}
