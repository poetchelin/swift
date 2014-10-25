//
//  ViewController.swift
//  iDouBan
//
//  Created by Cunqi.X on 10/13/14.
//  Copyright (c) 2014 cunqi xiao. All rights reserved.
//

import UIKit
import MediaPlayer

protocol SongLoadDelegate{
    func didLoad(newSongsURL: String)
}

class PlayListController: UIViewController,UITableViewDataSource, UITableViewDelegate, HttpProtocol, SongLoadDelegate{

	@IBOutlet var ranTime: UILabel!
    @IBOutlet var restTime: UILabel!
    @IBOutlet var progress: UIProgressView!
    @IBOutlet var cover: UIImageView!
    @IBOutlet var playingListTable: UITableView!
	
	@IBOutlet var controlButton: UIButton!
	
	//store the background and image of control button
	var controlBackground: UIColor?
	var controlImage: UIImage?
	
    let playlistSectionURL = "http://www.douban.com/j/app/radio/people?app_name=radio_desktop_win&version=100&user_id=&expire=&token=&sid=&h=&channel=0&type=n"
    
    var httpController: HttpController = HttpController()
    
    var playList: NSArray = NSArray()
    
    var imageCache = Dictionary<String, UIImage>()
	
	var playingStop: Bool = true	//using to judge the state of play
	
	var audioPlayer: MPMoviePlayerController = MPMoviePlayerController()
	
	var timer: NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        loadHttpData()
    }
	
	@IBAction func controlClicked(sender: AnyObject) {
		let control = sender as UIButton
		
		if playingStop {
			control.backgroundColor = nil
			control.setImage(nil, forState: UIControlState.Normal)
			
			resumeMusic()
			
			playingStop = false
		}else{
			control.backgroundColor = controlBackground
			control.setImage(controlImage, forState: UIControlState.Normal)
			
			pauseMusic()
			
			playingStop = true
		}
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
	
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return playList.count
	}
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return "song"
	}
	
	
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "songs")
        
        let song: NSDictionary = playList[indexPath.section] as NSDictionary
        
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
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 176
	}
	
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let song: NSDictionary = playList[indexPath.section] as NSDictionary
		
		updateCoverAndTitle(picURL: song["picture"] as String, titleURL: song["title"] as String)
        
        //play the selected music
		playMusic(contentURL: song["url"] as String)
		
		if controlBackground == nil && controlImage == nil{
			controlBackground = controlButton.backgroundColor
			controlImage	  = controlButton.imageView?.image
		}
		
		controlButton.backgroundColor = nil
		controlButton.imageView?.image = nil
		
    }
	
	private func updateCoverAndTitle(#picURL: String, titleURL: String) {
		//update the cover
		let image = self.imageCache[picURL]
		
		if image == nil {
			//do something
		}
		cover.image = image
		
		//update the title
		self.navigationItem.title = title

	}
	
	private func updateProgressAndTimeLabel(#ran: String, rest: String, progressCount: CFloat) {
		ranTime.text = ran
		restTime.text  = rest
		progress.setProgress(progressCount, animated: false)
		
	}
	
	private func playMusic(#contentURL: String) {
		timer?.invalidate()
		
		self.audioPlayer.stop()
		self.audioPlayer.contentURL = NSURL(string: contentURL)
		self.audioPlayer.play()
		
		timer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "onTimerUpdate", userInfo: nil, repeats: true)
	}
	
	func onTimerUpdate() {
		let current = self.audioPlayer.currentPlaybackTime
		let length = self.audioPlayer.duration
		let rest = length - current
		
		var percent: CFloat = 0.0
		
		if current > 0.0 {
			percent = CFloat(current / length)
			
			updateProgressAndTimeLabel(ran: timeFormater(current), rest: timeFormater(rest), progressCount: percent)
		}
	}
	
	//format the time to string
	private func timeFormater(time: NSTimeInterval) -> String {
		let total = Int(time)
		let second = total % 60
		let minute = total / 60
		
		var time: String = ""
		
		if minute < 10 {
			time = "0\(minute):"
		}else{
			time = "\(minute):"
		}
		
		if second < 10 {
			time += "0\(second)"
		}else{
			time += "\(second)"
		}
		
		return time
		
	}
	
	private func pauseMusic() {
		self.audioPlayer.pause()
		
		timer?.fireDate = NSDate.distantFuture() as NSDate
	}
	
	private func resumeMusic() {
		self.audioPlayer.play()
		timer?.fireDate = NSDate()
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

