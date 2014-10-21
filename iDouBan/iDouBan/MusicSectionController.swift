//
//  MusicSectionController.swift
//  iDouBan
//
//  Created by Cunqi.X on 10/13/14.
//  Copyright (c) 2014 cunqi xiao. All rights reserved.
//

import UIKit

class MusicSectionController: UITableViewController,HttpProtocol {
    
    let musicSectionURL = "http://www.douban.com/j/app/radio/channels"
    
    var musicInSection = "http://douban.fm/j/mine/playlist?channel="
    
    var musicSection: NSArray = NSArray()
    
    let httpController = HttpController()
    
    var musicLoader : SongLoadDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //load data from Internet.
        httpController.delegate = self
        httpController.onSearch(musicSectionURL)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.musicSection.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "section")
        
        let section: NSDictionary = musicSection[indexPath.row] as NSDictionary
        
        cell.textLabel.text = (section["name"] as String)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		let row: Character = Character(UnicodeScalar(indexPath.row))
        
        //load selected data
		var resultURL = musicInSection + "\(indexPath.row)"
		
		//println(resultURL)
		
		//update playList
		musicLoader?.didLoad(resultURL)
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func didReceiveResults(result: NSDictionary) {
        if (result["channels"] != nil) {
            self.musicSection = result["channels"]! as NSArray
            println(self.musicSection.count)
            self.tableView.reloadData()
            
        }

    }
    
}