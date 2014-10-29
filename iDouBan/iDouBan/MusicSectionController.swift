//
//  sectionsController.swift
//  iDouBan
//
//  Created by Cunqi.X on 10/13/14.
//  Copyright (c) 2014 cunqi xiao. All rights reserved.
//

import UIKit
import CoreData

class MusicSectionController: UITableViewController,HttpProtocol {
	
	/*
	=================================================================================
	Constant
	=================================================================================
	*/
	let ENTITY_NAME = "Section"
    let sectionsURL = "http://www.douban.com/j/app/radio/channels"
	let httpController = HttpController()
	let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
	
	/*
	=================================================================================
	Common Class Inner Variable
	=================================================================================
	*/
	
    var musicsInSection = "http://www.douban.com/j/app/radio/people?app_name=radio_desktop_win&version=100&user_id=&expire=&token=&sid=&h=&channel="
    
    var sections: NSArray = [NSManagedObject]()
    var delegate : SongLoadDelegate?

	/*
	=================================================================================
	The Override Implementation of Super Class
	=================================================================================
	*/
    override func viewDidLoad() {
        super.viewDidLoad()
		self.httpController.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	override func viewWillAppear(animated: Bool) {
		let managedContext = self.appDelegate.managedObjectContext!
		let fetchRequest = NSFetchRequest(entityName: ENTITY_NAME)
		
		let fetchResult: NSArray = managedContext.executeFetchRequest(fetchRequest, error: nil)!
		
		if fetchResult.count > 0 {
			self.sections = fetchResult
		}else {
			//load data from Internet.
			self.httpController.onSearch(sectionsURL)
		}
	}
	
	/*
	=================================================================================
	The Override Implementation of UITableViewController
	=================================================================================
	*/
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: ENTITY_NAME)
        
        let section: AnyObject = sections[indexPath.row]
        cell.textLabel.text = section.valueForKey("name") as String?
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		let section: AnyObject = sections[indexPath.row]
        //load selected data
		let row = section.valueForKey("channel_id") as String
		var resultURL = musicsInSection + "\(row)&type=n"
		
		//update playList
		delegate?.didLoad(resultURL)
        
        self.navigationController?.popViewControllerAnimated(true)
    }
	
	/*
	=================================================================================
	The Implementation of Protocol
	=================================================================================
	*/
    func didReceiveResults(result: NSDictionary) {
        if (result["channels"] != nil) {
            let data = result["channels"]! as NSArray
			
			sections = saveData(data)
			
            self.tableView.reloadData()
            
        }

    }
	
	/*
	=================================================================================
	The Implementation of Private Method
	=================================================================================
	*/
	
	private func saveData(data: NSArray) -> NSArray{
		let managedContext = self.appDelegate.managedObjectContext!
		
		return batchSaveData(data, managedContext: managedContext)
	
	}
	
	private func batchSaveData(data: NSArray, managedContext: NSManagedObjectContext) -> NSArray {
		
		let formatter: NSNumberFormatter = NSNumberFormatter()
		var result:[NSManagedObject] = []
		
		var channel_id: NSNumber = 0
		for map in data {
			
			let section = NSEntityDescription.insertNewObjectForEntityForName(ENTITY_NAME, inManagedObjectContext: managedContext) as NSManagedObject
			
			if(map.objectForKey("channel_id")!.isKindOfClass(NSNumber)) {
				channel_id = map["channel_id"] as NSNumber
			}else if(map.objectForKey("channel_id")!.isKindOfClass(NSString)){
				channel_id = formatter.numberFromString(map["channel_id"] as NSString)!
			}
			
			let name = map["name"]
			
			section.setValue(name, forKey: "name")
			section.setValue(channel_id, forKey: "channel_id")
			
			managedContext.save(nil)
			
			result.append(section)
		}
		
		return result
	}
}