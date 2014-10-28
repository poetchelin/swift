//
//  MusicSectionController.swift
//  iDouBan
//
//  Created by Cunqi.X on 10/13/14.
//  Copyright (c) 2014 cunqi xiao. All rights reserved.
//

import UIKit

class MusicSectionController: UITableViewController,HttpProtocol {
	
	/*
	=================================================================================
	Constant
	=================================================================================
	*/
    let musicSectionURL = "http://www.douban.com/j/app/radio/channels"
	let httpController = HttpController()
	
	/*
	=================================================================================
	Common Class Inner Variable
	=================================================================================
	*/
	
    var musicInSection = "http://www.douban.com/j/app/radio/people?app_name=radio_desktop_win&version=100&user_id=&expire=&token=&sid=&h=&channel="
    
    var musicSection: NSArray = NSArray()
    var delegate : SongLoadDelegate?

	/*
	=================================================================================
	The Override Implementation of Super Class
	=================================================================================
	*/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //load data from Internet.
        httpController.delegate = self
        httpController.onSearch(musicSectionURL)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	/*
	=================================================================================
	The Override Implementation of UITableViewController
	=================================================================================
	*/
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
        
        //load selected data
		let row: Character = Character(UnicodeScalar(indexPath.row))
		var resultURL = musicInSection + "\(indexPath.row)&type=n"
		
		//update playList
		delegate?.didLoad(resultURL)
        
        self.navigationController?.popViewControllerAnimated(true)
    }
	
	/*
	=================================================================================
	The Implementation of Private Method.
	=================================================================================
	*/
    func didReceiveResults(result: NSDictionary) {
        if (result["channels"] != nil) {
            self.musicSection = result["channels"]! as NSArray

            self.tableView.reloadData()
            
        }

    }
    
}