//
//  HearthstoneRecorder.swift
//  VideoOsx
//
//  Copyright (c) 2014 Charles Gutjahr. See README.md for license details.
//

import Foundation
import Cocoa
import AppKit
import AVFoundation


public class HearthstoneRecorder : NSObject, AVCaptureFileOutputDelegate, AVCaptureFileOutputRecordingDelegate {
    
    var pid = 0;
    var windowId = 0;
    
    var windowX = 0;
    var windowY = 0;
    var windowInvertedY = 0;
    var windowHeight = 0;
    var windowWidth = 0;
    
    var captureSession: AVCaptureSession? = nil;
    var captureScreenInput: AVCaptureScreenInput? = nil;
    var captureMovieFileOutput: AVCaptureMovieFileOutput? = nil;
    
    var screenRecordingFileNameString: String? = nil;
    

    
    public func findPid() -> Int {
        var newPid = 0;
        
        let runningApps = NSRunningApplication.runningApplicationsWithBundleIdentifier("unity.Blizzard Entertainment.Hearthstone");
        if let runningApps = runningApps as? Array<NSRunningApplication>  {
            for runningApp in runningApps {
                if (runningApp.bundleIdentifier == "unity.Blizzard Entertainment.Hearthstone") {
                    newPid = Int(runningApp.processIdentifier);
                }
            }
        }
        
        println("findPid() old=\(pid) new=\(newPid)")
        NSLog("findPid() old=\(pid) new=\(newPid)")
        
        pid = newPid
        return pid;
    }
  
    
    public func getHSWindowBounds() -> String {
        let windowInfoRef = CGWindowListCopyWindowInfo(CGWindowListOption(kCGWindowListExcludeDesktopElements) | CGWindowListOption(kCGWindowListOptionOnScreenOnly), CGWindowID(0))
        
        let windowInfosCFArray = windowInfoRef.takeRetainedValue()
        let windowInfosNSArray = windowInfosCFArray as NSArray
        
        var newWindowId = 0;
        for windowInfo in windowInfosNSArray {
            let dictionaryRef = windowInfo as Dictionary<String, AnyObject>
            let thisPid = dictionaryRef[kCGWindowOwnerPID] as Int
            
            if (thisPid == pid) {
                // This window is a Hearthstone window
                
                // When running in full-screen mode, Hearthstone has two windows: one for the game and one that appears to be a temporary desktop or space for the game to run in.
                // The game window always has a kCGWindowLayer of zero, whereas the desktop has a non-zero kCGWindowLayer.
                let windowLayer = dictionaryRef[kCGWindowLayer] as Int
                
                if (windowLayer == 0) {
                    // This window has a zero kCGWindowLayer so it must be the main Hearthstone window
                    newWindowId = dictionaryRef[kCGWindowNumber] as Int
                    
                    let boundsDictionary = dictionaryRef[kCGWindowBounds] as Dictionary<String, AnyObject>

                    let scale = NSScreen.mainScreen()?.backingScaleFactor

//                    println("### Scale=\(scale!)")
//                    NSLog("### Scale=\(scale!)")
                    
                    let titleBar = 22;  // OS X titlebar is usually 22 pixels high
                    
                    if ((boundsDictionary["Height"] as Int) > 100) {
                    
                        windowWidth = boundsDictionary["Width"] as Int
                        windowHeight = (boundsDictionary["Height"] as Int) - titleBar
                        windowX = boundsDictionary["X"] as Int
                        windowY = (boundsDictionary["Y"] as Int) + titleBar
                        
                        // This should probably be replaced with a check of the display that Hearthstone is on
                        let screenSize: NSRect = NSScreen.mainScreen()!.frame
                        windowInvertedY = Int(screenSize.height) - windowY - windowHeight
                        
//                        println("### Window bounds x=\(windowX) y=\(windowY) (inverted \(windowInvertedY)) h=\(windowHeight) w=\(windowWidth)")
//                        NSLog("### Window bounds x=\(windowX) y=\(windowY) (inverted \(windowInvertedY)) h=\(windowHeight) w=\(windowWidth)")
                        
//                        println("### Screen bounds h=\(screenSize.height) w=\(screenSize.width)")
//                        NSLog("### Screen bounds h=\(screenSize.height) w=\(screenSize.width)")
                        
                        return "Found Window ID \(newWindowId) x=\(windowX) y=\(windowY) h=\(windowHeight) w=\(windowWidth) scale=\(scale)"
                        
                    } else {
                        let smallHeight = boundsDictionary["Height"] as Int
                        return "Window too small, height=\(smallHeight)"
                    }
                    
                }
            }
        }
        
        windowId = newWindowId
        return "Found Nothing"
    }
    
    
    
    private func getCaptureSessionPreset(width: Int, height: Int) -> String {
        if (width <= 640 || height <= 480) {
            return AVCaptureSessionPreset640x480
        } else if (width <= 960 || height <= 540) {
            return AVCaptureSessionPreset960x540
        } else if (width <= 1280 || height <= 720) {
            return AVCaptureSessionPreset1280x720
        } else {
            return AVCaptureSessionPresetMedium
        }
    }
    

    
    public func startRecording() {
        
        println("Starting recording of window \(windowId) (x=\(windowX),y=\(windowY),height=\(windowHeight),width=\(windowWidth))")
        NSLog("Starting recording of window \(windowId) (x=\(windowX),y=\(windowY),height=\(windowHeight),width=\(windowWidth))")

        captureSession = AVCaptureSession();
        let sessionPreset = getCaptureSessionPreset(windowWidth, height: windowHeight)
        if ((captureSession?.canSetSessionPreset(sessionPreset)) != nil) {
            captureSession?.sessionPreset = sessionPreset
        }

        let display = CGMainDisplayID()

        
        captureScreenInput = AVCaptureScreenInput(displayID: display)

        if ((captureSession?.canAddInput(captureScreenInput)) != nil) {
            captureSession?.addInput(captureScreenInput)
        }

        
        captureMovieFileOutput = AVCaptureMovieFileOutput()
        captureMovieFileOutput?.delegate = self
        if ((captureSession?.canAddOutput(captureMovieFileOutput)) != nil) {
            captureSession?.addOutput(captureMovieFileOutput)
        }

        
        // Set up screen size
        captureSession?.beginConfiguration()
        captureScreenInput?.cropRect = CGRect(x: windowX, y: windowInvertedY, width: windowWidth, height: windowHeight)
        captureScreenInput?.minFrameDuration = CMTimeMake(1, 25)
        captureScreenInput?.scaleFactor = 1.0
        captureSession?.commitConfiguration()
        
        captureSession?.startRunning()
        
        let suffix = arc4random()
        let screenRecordingFileName = "/private/tmp/hearthstats/HearthStatsRecording_\(suffix).mp4".stringByStandardizingPath.fileSystemRepresentation()
        screenRecordingFileNameString = NSString(bytes: screenRecordingFileName, length: Int(strlen(screenRecordingFileName)), encoding: NSASCIIStringEncoding)!
        
        println("screenRecordingFileName is \(screenRecordingFileNameString!)")
        NSLog("screenRecordingFileName is \(screenRecordingFileNameString!)")
        
        let fileUrl = NSURL.fileURLWithPath(screenRecordingFileNameString!)
        captureMovieFileOutput?.startRecordingToOutputFileURL(fileUrl, recordingDelegate: self)
    }
    
    
    public func stopRecording() -> String {
        println("Stopping recording of window \(windowId) (x=\(windowX),y=\(windowY),height=\(windowHeight),width=\(windowWidth))")
        NSLog("Stopping recording of window \(windowId) (x=\(windowX),y=\(windowY),height=\(windowHeight),width=\(windowWidth))")

        captureMovieFileOutput?.stopRecording()
        
        captureSession?.stopRunning()
        
        return screenRecordingFileNameString!
    }
    
    
    public func captureOutputShouldProvideSampleAccurateRecordingStart(captureOutput: AVCaptureOutput!) -> Bool {
        // We don't require frame accurate start when we start a recording. If we answer YES, the capture output
        // applies outputSettings immediately when the session starts previewing, resulting in higher CPU usage
        // and shorter battery life.
        return false
    }

    
    public func captureOutput(captureOutput: AVCaptureFileOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        // TODO
    }

    public func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        // TODO
    }
    
    public func captureOutput(captureOutput: AVCaptureFileOutput!, didPauseRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        // TODO
    }
    
    public func captureOutput(captureOutput: AVCaptureFileOutput!, didResumeRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        // TODO
    }
    
    public func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        // TODO
    }
    
    public func captureOutput(captureOutput: AVCaptureFileOutput!, willFinishRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        // TODO
    }
    
}