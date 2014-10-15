//
//  ViewController.swift
//  iDouBan
//
//  Created by Cunqi.X on 10/13/14.
//  Copyright (c) 2014 cunqi xiao. All rights reserved.
//

import UIKit

class PlayListController: UIViewController,UITableViewDataSource, UITableViewDelegate, HttpProtocol {

    @IBOutlet var runedTime: UILabel!
    @IBOutlet var restTime: UILabel!
    @IBOutlet var progress: UIProgressView!
    @IBOutlet var cover: UIImageView!
    @IBOutlet var playingListTable: UITableView!
    
    let playlistSectionURL = "http://douban.fm/j/mine/playlist?channel=0"
    let musicSectionURL = "http://www.douban.com/j/app/radio/channels"
    
    var httpController: HttpController = HttpController()
    
    var playList: NSArray = NSArray()
    var musicSection: NSArray = NSArray()
    var imageCache = Dictionary<String, UIImage>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        httpController.delegate = self
        
        httpController.onSearch(playlistSectionURL)
        //httpController.onSearch(musicSectionURL)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "playingList")
        
        let song: NSDictionary = playList[indexPath.row] as NSDictionary
        
        cell.textLabel?.text = (song["title"] as String)
        cell.detailTextLabel?.text = (song["artist"] as String)
        cell.imageView?.image = UIImage(named: "detail.jpg")
        
        let picURL = song["picture"] as String
        
        let image  = self.imageCache[picURL]
        
        if (image == nil) {
            let realURL: NSURL = NSURL(string: picURL)
            let request: NSURLRequest = NSURLRequest(URL: realURL)
            
            //send async request
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                let img = UIImage(data: data)
                
                cell.imageView?.image = img
                
                self.imageCache[picURL] = img
            })
        }else {
            cell.imageView?.image = image
        }
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func didReceiveResults(result: NSDictionary) {
        
        if (result["song"] != nil) {
            self.playList = result["song"] as NSArray
            self.playingListTable.reloadData()
        }else if (result["channels"] != nil) {
            self.musicSection = result["channels"] as NSArray
        }
    }


}

