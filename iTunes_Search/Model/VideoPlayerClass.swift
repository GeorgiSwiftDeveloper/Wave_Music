//
//  VideoPlayerClass.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 5/3/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit
import YoutubePlayer_in_WKWebView

class VideoPlayerClass: NSObject, WKYTPlayerViewDelegate {
    
    static let callVideoPlayer = VideoPlayerClass()
    
    
    let cardHeight:CGFloat = 800
    let cardHandleAreaHeight:CGFloat = 160
    
    var webView = WKYTPlayerView()
    var cardViewController = CardViewController()
    var visualEffectView:UIVisualEffectView!
    var checkCardView = Bool()
    var checkIfPaused = Bool()
    var musicLabelText = UILabel()
    var playButton = UIButton()
    var cardVisible = false
    
    
    var rightButton = UIButton()
    var leftButton = UIButton()
    var volumeSlider = UISlider()
    var volMax = UIImageView()
    var volMin = UIImageView()
    var checkIfPause = true
    
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
    
    
    func videoPalyerClass(sellectedCell: UITableViewCell,genreVideoID:String,superView:UIViewController,ifCellIsSelected: Bool,selectedVideo: Video){
//        superViewController = superView
        if checkCardView{
            self.cardViewController.view.removeFromSuperview()
            checkCardView = false
        }
//        visualEffectView = UIVisualEffectView()
//        visualEffectView.frame = self.superViewController?.view.frame as! CGRect
//        self.superViewController!.view.addSubview(visualEffectView)
//        self.visualEffectView.effect = nil
        
        self.playButton.frame = CGRect(x: self.cardViewController.view.center.x + 130, y: 35, width: 35, height: 35)
        self.musicLabelText.frame = CGRect(x: 10, y: 30, width: Int(UIScreen.main.bounds.width - 100), height: 50)
        self.musicLabelText.numberOfLines = 0
        self.musicLabelText.textAlignment = .left
        self.musicLabelText.font = UIFont(name: "Verdana-Bold", size: 12)
        self.musicLabelText.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.musicLabelText.text = selectedVideo.videoTitle

        
        checkCardView = true
        cardViewController = CardViewController(nibName:"CardViewController", bundle:nil)
        cardViewController.view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.cardViewController.view.layer.cornerRadius = 12
        superView.addChild(cardViewController)
        superView.view.addSubview(cardViewController.view)
        
        cardViewController.view.frame = CGRect(x: 0, y: superView.view.frame.height - cardHandleAreaHeight, width: superView.view.bounds.width, height: cardHeight)
        cardViewController.view.clipsToBounds = true
        
        self.webView = WKYTPlayerView(frame: CGRect(x: 0, y: 45, width: UIScreen.main.bounds.width, height: 220))
        
        self.cardViewController.view.addSubview(self.webView)
        
        let playerVars: [AnyHashable: Any] = ["playsinline" : 1,
                                              "origin": "https://www.youtube.com"]
        self.webView.load(withVideoId: genreVideoID, playerVars: playerVars)
        
        self.webView.delegate = self
        self.webView.isHidden = true
        
        
        self.cardViewController.view.addSubview(self.musicLabelText)
        
        
        
        self.playButton.addTarget(self, action: #selector(self.playAndPauseButtonAction(sender:)), for: .touchUpInside)
        self.cardViewController.view.addSubview(self.playButton)
        
        checkIfPaused = true
        if checkIfPaused == false {
            webView.pauseVideo()
            self.playButton.setImage(UIImage(named: "btn-play"), for: .normal)
            checkIfPaused = true
        }else{
            webView.playVideo()
            self.playButton.setImage(UIImage(named: "btn-pause"), for: .normal)
            checkIfPaused = false
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleCardTap(recognzier:)))
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handleCardPan(recognizer:)))
        
        cardViewController.headerView.addGestureRecognizer(tapGestureRecognizer)
        sellectedCell.addGestureRecognizer(panGestureRecognizer)
        
        
    }
    
    @objc func playAndPauseButtonAction(sender: UIButton){
        if checkIfPaused == false {
            webView.pauseVideo()
            self.playButton.setImage(UIImage(named: "btn-play"), for: .normal)
            UserDefaults.standard.set(false, forKey:"pause")
            checkIfPaused = true
        }else{
            webView.playVideo()
            self.playButton.setImage(UIImage(named: "btn-pause"), for: .normal)
            UserDefaults.standard.set(true, forKey:"pause")
            checkIfPaused = false
            
        }
    }
    
    
    func playerViewDidBecomeReady(_ playerView: WKYTPlayerView) {
        webView.playVideo();
    }
    
    
    
    
    
    
    @objc func handleCardTap(recognzier:UITapGestureRecognizer) {
        switch recognzier.state {
        case .ended:
            animateTransitionIfNeeded(state: nextState, duration: 0.9)
        default:
            break
        }
    }
    
    
    @objc func handleCardPan (recognizer:UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            startInteractiveTransition(state: nextState, duration: 0.9)
        case .changed:
            let translation = recognizer.translation(in: self.cardViewController.headerView)
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
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                case .expanded:
                    self.cardViewController.view.frame.origin.y = (self.superViewController?.view.frame.height)! - self.cardHeight
                    self.cardViewController.headerView.setImage(UIImage(systemName: "arrow.down.circle.fill"), for: .normal)
                    self.cardViewController.view.layer.opacity = 1
                    self.playButton.frame = CGRect(x: self.cardViewController.view.center.x - 30, y: 400, width: 60, height: 60)
                    self.musicLabelText.frame = CGRect(x: 10, y: Int(self.cardViewController.view.center.y) - 180, width: Int(UIScreen.main.bounds.width) - 20, height: 50)
                    
                    
                    self.leftandRightButton()
                    self.musicLabelText.numberOfLines = 0
                    self.musicLabelText.textAlignment = .center
                    self.superViewController?.navigationController?.navigationBar.isHidden = true
                    self.superViewController?.tabBarController?.tabBar.isHidden = true
                    self.webView.isHidden = false
                    
                case .collapsed:
                    self.cardViewController.view.frame.origin.y = (self.superViewController?.view.frame.height)! - self.cardHandleAreaHeight
                    self.cardViewController.headerView.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
                    self.playButton.frame = CGRect(x: self.cardViewController.view.center.x + 130, y: 35, width: 35, height: 35)
                    self.musicLabelText.frame = CGRect(x: 10, y: 30, width: Int(UIScreen.main.bounds.width - 100), height: 50)
                    
                    self.musicLabelText.numberOfLines = 0
                    self.musicLabelText.textAlignment = .left
                    self.musicLabelText.font = UIFont(name: "Verdana-Bold", size: 12)
                    
                    self.webView.isHidden = true
//                    self.visualEffectView.removeFromSuperview()
                    self.superViewController?.navigationController?.navigationBar.isHidden = false
                    self.superViewController?.tabBarController?.tabBar.isHidden = false
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
        
        self.rightButton.frame = CGRect(x: self.cardViewController.view.center.x - 120, y: 400, width: 60, height: 60)
        self.rightButton.setImage(UIImage(named: "btn-previous"), for: .normal)
        //        self.rightButton.addTarget(self, action: #selector(playNextVideo(sender:)), for: .touchUpInside)
        self.cardViewController.view.addSubview(rightButton)
        
        self.leftButton.frame = CGRect(x: self.cardViewController.view.center.x + 60, y: 400, width: 60, height: 60)
        self.leftButton.setImage(UIImage(named: "btn-next"), for: .normal)
        //        self.leftButton.addTarget(self, action: #selector(playPrevVideo(sender:)), for: .touchUpInside)
        self.cardViewController.view.addSubview(leftButton)
        
        
        self.volumeSlider.frame = CGRect(x: self.cardViewController.view.center.x - 120, y: 500, width: 250, height: 25)
        volumeSlider.minimumValue = 0
        volumeSlider.maximumValue = 100
        volumeSlider.setValue(80, animated: true)
        volumeSlider.isContinuous = true
        volumeSlider.tintColor = UIColor.white
        
        self.cardViewController.view.addSubview(volumeSlider)
        
        self.volMin.frame = CGRect(x: self.cardViewController.view.center.x - 145, y: 505, width: 15, height: 15)
        self.volMin.image = UIImage(named: "vol-min")
        self.cardViewController.view.addSubview(volMin)
        
        
        self.volMax.frame = CGRect(x: self.cardViewController.view.center.x + 145, y: 505, width: 15, height: 15)
        self.volMax.image = UIImage(named: "vol-max")
        self.cardViewController.view.addSubview(volMax)
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



