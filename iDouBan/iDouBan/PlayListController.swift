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
	
	/*
	=================================================================================
	Constant
	=================================================================================
	*/
	
	let defaultPlayingListURL = "http://www.douban.com/j/app/radio/people?app_name=radio_desktop_win&version=100&user_id=&expire=&token=&sid=&h=&channel=0&type=n"
	let httpController: HttpController = HttpController()	//used to download information from Internet
	
	/*
	=================================================================================
	UI-binded Variable.
	=================================================================================
	*/
	@IBOutlet var ranTime: UILabel!
    @IBOutlet var restTime: UILabel!
    @IBOutlet var progress: UIProgressView!
    @IBOutlet var cover: UIImageView!
    @IBOutlet var playingListTable: UITableView!
	@IBOutlet var controlButton: UIButton!
	
	/*
	=================================================================================
	Common Class Inner Variable
	=================================================================================
	*/
	
	//store the background and image of control button
	var controlBackground: UIColor?
	var controlImage: UIImage?
	
    var playList: NSArray = NSArray()	//store the playlist of current channel
    var imageCache = Dictionary<String, UIImage>()	//store the cover image of songs
	var isPlayStop: Bool = true	//using to judge the state of play
	
	var audioPlayer: MPMoviePlayerController = MPMoviePlayerController()	//used to play music
	
	var timer: NSTimer?	//used to run a schedule time task
	
	/*
	=================================================================================
	The Override Implementation of Super Class
	=================================================================================
	*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.httpController.delegate = self;
		self.controlBackground = self.controlButton.backgroundColor
		self.controlImage	   = self.controlButton.imageView?.image
		
		self.downloadData(URL: defaultPlayingListURL)
    }
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		var destination: AnyObject = segue.destinationViewController
		
		if destination is MusicSectionController  {
			var musicSectionController = destination as MusicSectionController
			musicSectionController.delegate = self
		}
	}
	
	
	/*
	=================================================================================
	The Implementation of Event Handler
	=================================================================================
	*/
	@IBAction func controlClicked(sender: AnyObject) {
		let control = sender as UIButton
		
		if isPlayStop {
			control.backgroundColor = nil
			control.setImage(nil, forState: UIControlState.Normal)
			
			resumeMusic()
		}else{
			control.backgroundColor = controlBackground
			control.setImage(controlImage, forState: UIControlState.Normal)
			
			pauseMusic()
		}
		
		isPlayStop = !isPlayStop
	}
	
	/*
	=================================================================================
	The Implementation of UITableViewDataSource, UITableViewDelegate
	=================================================================================
	*/
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.playList.count
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 144
	}
	
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let identifier: String = "song"
		let song: NSDictionary = playList[indexPath.row] as NSDictionary
		let pictureURL = song["picture"] as String
		
		var nib: UINib = UINib(nibName: "CustomerTableViewCell", bundle: nil)
		self.playingListTable.registerNib(nib, forCellReuseIdentifier: identifier)
		
		var cell: CustomerTableViewCell? = self.playingListTable.dequeueReusableCellWithIdentifier(identifier) as? CustomerTableViewCell
        
        cell!.title.text = (song["title"] as String)
        cell!.singer.text = (song["artist"] as String)
        cell!.cover.image = UIImage(named: "detail.jpg")
		
		//load picture
        let image  = self.imageCache[pictureURL]
        if image == nil {
            downloadAndSetImage(pictureURL, cell: cell!)
        }else {
            cell!.cover.image = image
        }
		
        return cell!
    }
	
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let song: NSDictionary = playList[indexPath.row] as NSDictionary
        
        //play the selected music
		playMusic(contentURL: song["url"] as String)
	
		updateCoverAndTitle(pictureURL: song["picture"] as String, title: song["title"] as String)
    }
	
	/*
	=================================================================================
	The Implementation of Private Method.
	=================================================================================
	*/
	
	/*
	Update cover and title of current playing song
	@param pictureURL: String; the URL address of picture which will display
	@param titleURL: String; the title of music
	*/
	private func updateCoverAndTitle(#pictureURL: String, title: String) {
		//clean current cover and title
		controlButton.imageView?.image = nil
		controlButton.backgroundColor  = nil
		
		//update cover
		let image = self.imageCache[pictureURL]
		if image == nil {
			//do something
		}
		cover.image = image
		
		//update title
		self.navigationItem.title = title
	}
	
	/*
	Update progressView, ran time label, rest time label
	@param ran: String; ran time label
	@param rest: String; rest time label
	@param progressCount: CFloat; the progress of progressView
	*/
	private func updateProgressAndTime(#ran: String, rest: String, progressCount: CFloat) {
		ranTime.text = ran
		restTime.text  = rest
		progress.setProgress(progressCount, animated: false)
		
	}
	
	/*
	Play a music
	@contentURL: String; the URL of the music will be play
	*/
	private func playMusic(#contentURL: String) {
		//stop current playing music
		timer?.invalidate()
		self.audioPlayer.stop()
		
		//download the next music
		self.audioPlayer.contentURL = NSURL(string: contentURL)
		
		//play the music
		self.audioPlayer.play()
		timer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "onTimerUpdate", userInfo: nil, repeats: true)
	}
	
	func onTimerUpdate() {
		let current = self.audioPlayer.currentPlaybackTime
		let length = self.audioPlayer.duration
		let rest = length - current
		
		//music is playing
		if current > 0.0 {
			let percent = CFloat(current / length)
			let tRan  = StrUtil.timeFormatter(time: current)
			let tRest = StrUtil.timeFormatter(time: rest)
			
			updateProgressAndTime(ran: tRan, rest: tRest, progressCount: percent)
		}
	}
	
	/*
	Pause current playing music.
	*/
	private func pauseMusic() {
		self.audioPlayer.pause()
		timer?.fireDate = NSDate.distantFuture() as NSDate
	}
	
	/*
	Resume the paused music
	*/
	private func resumeMusic() {
		self.audioPlayer.play()
		timer?.fireDate = NSDate()
	}
	
	/*
	Download and cache music covers
	@param pictureURL: String; the URL of picture
	@param cell: CustomerTableViewCell the cell to display cover
	*/
    private func downloadAndSetImage(pictureURL: String, cell: CustomerTableViewCell) {
        let realURL: NSURL = NSURL(string: pictureURL)!
        let request: NSURLRequest = NSURLRequest(URL: realURL)
		
		func completionHandler(response: NSURLResponse!, data: NSData!, error: NSError!) {
			let image = UIImage(data: data)
			
			cell.cover.image = image
			
			self.imageCache[pictureURL] = image
		}
        
        //send async request
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: completionHandler)

    }

	/*
	download data from Internet
	@param url: String; the URL address to asscess the data online
	*/
	private func downloadData(#URL: String) {
		self.httpController.onSearch(URL)
	}
	
	/*
	=================================================================================
	The Implementation of Protocol
	=================================================================================
	*/
	
	
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

