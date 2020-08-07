//
//  VideoPlayerClass.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 5/3/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit
import MediaPlayer
import YoutubePlayer_in_WKWebView

class VideoPlayer: NSObject, WKYTPlayerViewDelegate, UIGestureRecognizerDelegate {
    
    static let callVideoPlayer = VideoPlayer()
    
    
    let cardHeight:CGFloat = 750
    let cardHandleAreaHeight:CGFloat = 130
    var playerView = UIView()
    var webView = WKYTPlayerView()
    var cardViewController = CardViewController()
    var visualEffectView:UIVisualEffectView!
    var checkCardView = Bool()
    var checkIfPaused = true
    var cardVisible = false
    var checkifAnimationHappend = Bool()
    
    var leftButton = UIButton()
    var rightButton = UIButton()
    var volumeSlider = UISlider()
    var systemSlider = UISlider()
    var volMax = UIImageView()
    var volMin = UIImageView()
    var addToFavorite = UIButton()
    var sharePlayedMusic = UIButton()
    var checkIfPause = true
    var videoID = String()
    var videoIndex = Int()
    var videoTitle = String()
    var checkIfCollapsed = Bool()
    
    enum CardState {
        case expanded
        case collapsed
    }
    
    var nextState:CardState {
        return cardVisible ? .collapsed : .expanded
    }
    
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted:CGFloat = 0
    var superViewController: UIViewController?
    
    var topMusicTextLabel = MusicTextLabel()
    var middleMusicTextLabel = MusicTextLabel()
    
    var playerButton = MusicPlayerButton()
    
    func videoPalyerClass(sellectedCell: UITableViewCell,genreVideoID:String,index: Int,superView:UIViewController,ifCellIsSelected: Bool,selectedVideoTitle: String){
        
        videoID = genreVideoID
        videoIndex = index
        videoTitle = selectedVideoTitle
        
        if checkCardView{
            self.cardViewController.view.removeFromSuperview()
            checkCardView = false
        }
        //        setupCardVisualEffect()
        
        
        
        
        checkCardView = true
        
        cardViewController = CardViewController(nibName:String(cardController), bundle:nil)
        cardViewController.view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.cardViewController.view.layer.cornerRadius = 12
        
        superView.addChild(cardViewController)
        superView.view.addSubview(cardViewController.view)
        
        cardViewController.view.frame = CGRect(x: 0, y: superView.view.frame.height - cardHandleAreaHeight, width: superView.view.bounds.width, height: cardHeight)
        cardViewController.view.clipsToBounds = true
        
        self.webView = WKYTPlayerView(frame: CGRect(x: 0, y: 55, width: UIScreen.main.bounds.width, height: 220))
        
        self.cardViewController.view.addSubview(self.webView)
        let playerVars: [AnyHashable: Any] = ["playsinline" : 1,
                                              "origin": "https://www.youtube.com"]
        
        self.webView.delegate = self
        self.webView.isHidden = true
        
        DispatchQueue.main.async {
            self.webView.load(withVideoId: genreVideoID, playerVars: playerVars)
        }
        
        self.topMusicLabelConfiguration()
        self.musicPlayerButtonConfiguration()
        
        UserDefaults.standard.set(true, forKey:"pause")
        
        
        let tapGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handleCardTap(recognzier:)))
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handleCardPan(recognizer:)))
        
        cardViewController.view.addGestureRecognizer(tapGestureRecognizer)
        cardViewController.view.addGestureRecognizer(panGestureRecognizer)
        
    }
    @objc func rightButtonAction(sender: UIButton){
        
        if self.videoIndex == self.videoID.count - 1{
            self.videoIndex = -1
        }else{
            self.videoIndex += 1
            let playerVars: [AnyHashable: Any] = ["playsinline" : 1,
                                                  "origin": "https://www.youtube.com"]
            //            self.webView.load(withVideoId: self.videoID[self.videoIndex], playerVars: playerVars)
            
        }
    }
    
    @objc func leftButtonAction(sender: UIButton){
        if self.videoIndex == 0{
            self.videoIndex = self.videoID.count
        }else{
            self.videoIndex -= 1
            
            let playerVars: [AnyHashable: Any] = ["playsinline" : 1,
                                                  "origin": "https://www.youtube.com"]
            //            self.webView.load(withVideoId: self.videoID[self.videoIndex], playerVars: playerVars)
        }
    }
    
    
    @objc func playAndPauseButtonAction(sender: UIButton){
        VideoPlayer.callVideoPlayer.webView.getPlayerState({ [weak self] (playerState, error) in
            if let error = error {
                print("Error getting player state:" + error.localizedDescription)
            } else if let playerState = playerState as? WKYTPlayerState {
                
                self?.updatePlayerState(playerState)
                if self?.checkIfPaused == false {
                    self?.webView.playVideo()
                    sender.setImage(UIImage(named: "btn-pause"), for: .normal)
                    UserDefaults.standard.set(true, forKey:"pause")
                }else{
                    self?.webView.pauseVideo()
                    sender.setImage(UIImage(named: "btn-play"), for: .normal)
                    UserDefaults.standard.set(false, forKey:"pause")
                }
            }
        })
    }
    
    
    
    func updatePlayerState(_ playerState: WKYTPlayerState){
        switch playerState {
        case .ended:
            checkIfPaused = false
        case .paused:
            checkIfPaused = false
        case .playing:
            checkIfPaused = true
        default:
            break
        }
    }
    
    
    
    //    func setupCardVisualEffect() {
    //        visualEffectView = UIVisualEffectView()
    //        visualEffectView.frame = CGRect(x: 0, y: 0, width: (self.superViewController?.view.frame.width)!, height: 170)
    //        self.superViewController!.view.addSubview(visualEffectView)
    //
    //    }
    //
    
    func playerViewDidBecomeReady(_ playerView: WKYTPlayerView) {
        webView.playVideo();
    }
    
    
    
    
    
    
    @objc func handleCardTap(recognzier:UIPanGestureRecognizer) {
        switch recognzier.state {
        case .ended:
            animateTransitionIfNeeded(state: nextState, duration: 0.6)
        default:
            break
        }
    }
    
    
    @objc func handleCardPan (recognizer:UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            startInteractiveTransition(state: nextState, duration: 0.6)
        case .changed:
            let translation = recognizer.translation(in: self.cardViewController.view)
            var fractionComplete = translation.y / cardHeight
            fractionComplete = cardVisible ? fractionComplete : -fractionComplete
            updateInteractiveTransition(fractionCompleted: fractionComplete)
        case .ended:
            continueInteractiveTransition()
        default:
            break
        }
    }
    
    
    
    
    func animateTransitionIfNeeded (state:CardState, duration:TimeInterval) {
        if runningAnimations.isEmpty {
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 0.7) {
                switch state {
                case .expanded:
                    //                    self.setupCardVisualEffect()
                    
                    self.cardViewController.view.frame.origin.y = (self.superViewController?.view.frame.height)! - self.cardHeight
                    self.cardViewController.view.layer.opacity = 1
                    
                    self.playerButton.frame = CGRect(x: self.cardViewController.view.center.x - 30, y: 400, width: 60, height: 60)
                    
                    self.cardViewController.view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                    self.leftandRightButton()
                    self.superViewController?.navigationController?.navigationBar.isHidden = true
                    self.superViewController?.tabBarController?.tabBar.isHidden = true
                    
                    self.middleMusicLabelConfiguration()
                    
                    self.volumeSlider.frame = CGRect(x: self.cardViewController.view.center.x - 120, y: 500, width: 250, height: 25)
                    self.volumeSlider.minimumValue = 0
                    self.volumeSlider.maximumValue = 100
                    self.volumeSlider.setValue(80, animated: true)
                    self.volumeSlider.isContinuous = true
                    self.volumeSlider.tintColor = UIColor.white
                    self.cardViewController.view.addSubview(self.volumeSlider)
                    self.volumeSlider.addTarget(self, action: #selector(self.sliderVolume(sender:)), for: .touchUpInside)
                    
                    self.topMusicTextLabel.isHidden = true
                    self.webView.isHidden = false
                    self.volumeSlider.isHidden = false
                    self.playerView.isHidden = false
                    self.checkIfCollapsed = false
                case .collapsed:
                    self.cardViewController.view.frame.origin.y = (self.superViewController?.view.frame.height)! - self.cardHandleAreaHeight
                    self.cardViewController.view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                    self.playerButton.frame = CGRect(x: self.cardViewController.view.center.x + 160, y: 10, width: 30, height: 30)
                    
                    self.topMusicLabelConfiguration()
                    
                    self.superViewController?.navigationController?.navigationBar.isHidden = false
                    self.superViewController?.tabBarController?.tabBar.isHidden = false
                    self.checkIfCollapsed = true
                    if ((self.superViewController as? GenresViewController) != nil) {
                        self.superViewController?.navigationController?.navigationBar.isHidden = true
                    }
                    
                    //                    self.visualEffectView.removeFromSuperview()
                }
            }
            
            frameAnimator.addCompletion { _ in
                self.cardVisible = !self.cardVisible
                self.runningAnimations.removeAll()
            }
            
            frameAnimator.startAnimation()
            runningAnimations.append(frameAnimator)
            
            
            let cornerRadiusAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
                switch state {
                case .expanded:
                    self.cardViewController.view.layer.cornerRadius = 16
                case .collapsed:
                    self.cardViewController.view.layer.cornerRadius = 12
                }
            }
            
            cornerRadiusAnimator.startAnimation()
            runningAnimations.append(cornerRadiusAnimator)
            
            let blurAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                case .expanded:
                    break
                    //                    self.visualEffectView.effect = UIBlurEffect(style: .systemThickMaterialDark)
                    
                case .collapsed:
                    break
                    //                    self.visualEffectView.effect = nil
                }
            }
            
            blurAnimator.startAnimation()
            runningAnimations.append(blurAnimator)
            
        }
    }
    
    
    func leftandRightButton(){
        
        self.leftButton.frame = CGRect(x: self.cardViewController.view.center.x - 120, y: 400, width: 60, height: 60)
        self.leftButton.setImage(UIImage(named: "btn-previous"), for: .normal)
        self.cardViewController.view.addSubview(leftButton)
        
        self.rightButton.frame = CGRect(x: self.cardViewController.view.center.x + 60, y: 400, width: 60, height: 60)
        self.rightButton.setImage(UIImage(named: "btn-next"), for: .normal)
        self.cardViewController.view.addSubview(rightButton)
        
        self.volMin.frame = CGRect(x: self.cardViewController.view.center.x - 145, y: 505, width: 15, height: 15)
        self.volMin.image = UIImage(named: "vol-min")
        self.cardViewController.view.addSubview(volMin)
        
        
        self.volMax.frame = CGRect(x: self.cardViewController.view.center.x + 145, y: 505, width: 15, height: 15)
        self.volMax.image = UIImage(named: "vol-max")
        self.cardViewController.view.addSubview(volMax)
        
        
        let textFont = UIFont(name: "Helvetica Bold", size: 11)
        
        self.addToFavorite.frame = CGRect(x: self.cardViewController.view.frame.origin.x, y: 600, width: 100, height: 30)
        self.addToFavorite.setImage(UIImage(systemName: "star.fill"), for: .normal)
        self.addToFavorite.imageView?.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.addToFavorite.imageView?.clipsToBounds = true
        self.addToFavorite.setTitle("  My Library", for: .normal)
        self.addToFavorite.titleLabel?.font = textFont
        
        self.cardViewController.view.addSubview(addToFavorite)
        
        
        self.sharePlayedMusic.frame = CGRect(x: self.cardViewController.view.center.x + 40, y: 600, width: 230, height: 30)
        self.sharePlayedMusic.setImage(UIImage(systemName: "arrowshape.turn.up.right.fill"), for: .normal)
        self.sharePlayedMusic.imageView?.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.sharePlayedMusic.imageView?.clipsToBounds = true
        self.sharePlayedMusic.setTitle(" Share", for: .normal)
        self.sharePlayedMusic.titleLabel?.font = textFont
        self.cardViewController.view.addSubview(sharePlayedMusic)
        
        
    }
    
    
    func  topMusicLabelConfiguration() {
        topMusicTextLabel = MusicTextLabel(textTitle: videoTitle, textAlignment: .left)
        self.cardViewController.view.addSubview(topMusicTextLabel)
        topMusicTextLabel.frame = CGRect(x: 10, y: 5, width: Int(UIScreen.main.bounds.width - 100), height: 40)
    }
    
    
    func  middleMusicLabelConfiguration() {
        middleMusicTextLabel = MusicTextLabel(textTitle: videoTitle, textAlignment: .center)
        self.cardViewController.view.addSubview(middleMusicTextLabel)
        self.middleMusicTextLabel.frame = CGRect(x: 10, y: Int(self.cardViewController.view.center.y) - 180, width: Int(UIScreen.main.bounds.width) - 20, height: 50)
    }
    
    func  musicPlayerButtonConfiguration() {
        playerButton = MusicPlayerButton(image: "btn-pause")
        self.cardViewController.view.addSubview(playerButton)
        self.playerButton.frame = CGRect(x: self.cardViewController.view.center.x + 160, y: 10, width: 30, height: 30)
        
        self.playerButton.addTarget(self, action: #selector(self.playAndPauseButtonAction(sender:)), for: .touchUpInside)
        
        self.leftButton.addTarget(self, action: #selector(self.leftButtonAction(sender:)), for: .touchUpInside)
        self.rightButton.addTarget(self, action: #selector(self.rightButtonAction(sender:)), for: .touchUpInside)
    }
    
    @objc  func sliderVolume(sender: UISlider) {
        switch Int(sender.value) {
        case 0:
            MPVolumeView.setVolume(0.0)
        case 5...15:
            MPVolumeView.setVolume(0.2)
        case 15...20:
            MPVolumeView.setVolume(0.3)
        case 20...40:
            MPVolumeView.setVolume(0.4)
        case 40...60:
            MPVolumeView.setVolume(0.5)
        case 60...80:
            MPVolumeView.setVolume(0.7)
        case 80...100:
            MPVolumeView.setVolume(1)
        default:
            break
        }
    }
    
    
    
    
    
    func startInteractiveTransition(state:CardState, duration:TimeInterval) {
        if runningAnimations.isEmpty {
            animateTransitionIfNeeded(state: state, duration: duration)
        }
        for animator in runningAnimations {
            animator.pauseAnimation()
            animationProgressWhenInterrupted = animator.fractionComplete
        }
    }
    
    func updateInteractiveTransition(fractionCompleted:CGFloat) {
        for animator in runningAnimations {
            animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
        }
    }
    
    func continueInteractiveTransition (){
        for animator in runningAnimations {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
    
    
    
}


extension MPVolumeView {
    static func setVolume(_ volume: Float) {
        let volumeView = MPVolumeView()
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            slider?.value = volume
        }
    }
}
