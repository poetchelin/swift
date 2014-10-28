//
//  StrUtil.swift
//  iDouBan
//
//  Created by Cunqi.X on 14/10/28.
//  Copyright (c) 2014年 cunqi xiao. All rights reserved.
//

import Foundation

class StrUtil: NSObject {
	
	/*
	Convert time to String (i.e. 19:00)
	@param time: NSTimeInterval; time be converted
	@return the string format of time
	*/
	internal class func timeFormatter(#time: NSTimeInterval) -> String {
		let total = Int(time)
		
		let second = total % 60
		let minute = total / 60
		
		var result: String = ""
		
		if minute < 10 {
			result = "0\(minute):"
		}else{
			result = "\(minute):"
		}
		
		if second < 10 {
			result += "0\(second)"
		}else{
			result += "\(second)"
		}

		return result
	}
}