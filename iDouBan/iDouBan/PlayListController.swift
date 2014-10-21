//
//  ViewController.swift
//  iDouBan
//
//  Created by Cunqi.X on 10/13/14.
//  Copyright (c) 2014 cunqi xiao. All rights reserved.
//

import UIKit

protocol SongLoadDelegate{
    func didLoad(newSongsURL: String)
}

class PlayListController: UIViewController,UITableViewDataSource, UITableViewDelegate, HttpProtocol, SongLoadDelegate{

    @IBOutlet var runedTime: UILabel!
    @IBOutlet var restTime: UILabel!
    @IBOutlet var progress: UIProgressView!
    @IBOutlet var cover: UIImageView!
    @IBOutlet var playingListTable: UITableView!
    
    let playlistSectionURL = "http://douban.fm/j/mine/playlist?channel=0"
    
    var httpController: HttpController = HttpController()
    
    var playList: NSArray = NSArray()
    
    var imageCache = Dictionary<String, UIImage>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        loadHttpData()
        
        
    }
    
    @IBAction func BtnClicked(sender: AnyObject) {
        var musicSectionController = MusicSectionController()
        musicSectionController.musicLoader = self
        self.navigationController?.pushViewController(musicSectionController, animated: true)
    }
    
    //load Http data with URL
    private func loadHttpData() {
        httpController.delegate = self
        
        httpController.onSearch(playlistSectionURL)
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
        
        cell.textLabel.text = (song["title"] as String)
        cell.detailTextLabel?.text = (song["artist"] as String)
        cell.imageView.image = UIImage(named: "detail.jpg")
        
        let picURL = song["picture"] as String
        
        let image  = self.imageCache[picURL]
        
        if image == nil {
            checkAndUpdateImage(picURL, cell: cell)
        }else {
            cell.imageView.image = image
        }
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let song: NSDictionary = playList[indexPath.row] as NSDictionary
        
        //update the cover
        let picURL = song["picture"] as String
        
        let image = self.imageCache[picURL]
        
        if image == nil {
            //do something
        }
        cover.image = image
        
        //update the title
        let title = song["title"] as String
        self.navigationItem.title = title
        
        //update the processView
        
        //play the selected music
        
    }
    
    private func checkAndUpdateImage(picURL: String, cell: UITableViewCell) {
        let realURL: NSURL = NSURL(string: picURL)!
        let request: NSURLRequest = NSURLRequest(URL: realURL)
        
        //send async request
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            let img = UIImage(data: data)
            
            cell.imageView.image = img
            
            self.imageCache[picURL] = img
        })

    }
    
    func didReceiveResults(result: NSDictionary) {
        
        if (result["song"] != nil) {
            self.playList = result["song"] as NSArray
            self.playingListTable.reloadData()
        }
    }
    
    func didLoad(newSongsURL: String) {
        httpController.onSearch(newSongsURL)
    }


}

