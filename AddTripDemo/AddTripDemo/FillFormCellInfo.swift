//
//  FillFromCellInfo.swift
//  AddTripDemo
//
//  Created by Cunqi.X on 11/16/14.
//  Copyright (c) 2014 cx363. All rights reserved.
//

import UIKit

class FillFormCellInfo: NSObject {
	/*
	=================================================================================
	Constant
	=================================================================================
	*/
	let nibName = "FillFormCell"
	
	/*
	=================================================================================
	UI-binded Variable.
	=================================================================================
	*/
	
	@IBOutlet var tripName: UITableViewCell!
	@IBOutlet var tripNameInput: UITextField!
	
	@IBOutlet var tripLocation: UITableViewCell!

	/*
	=================================================================================
	class method
	=================================================================================
	*/
	//return the height of specific row
	class func heightOfRow(indexpath: NSIndexPath) -> Int {
		return 44
	}
	
	func loadCells() {
		NSBundle.mainBundle().loadNibNamed(nibName, owner: self, options: nil)
	}
}