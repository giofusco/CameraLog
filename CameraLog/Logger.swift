//
//  Logger.swift
//  CameraLog
//
//  Created by Giovanni Fusco on 2/28/20.
//  Copyright © 2020 Smith-Kettlewell Eye Research Institute. All rights reserved.
//

import Foundation
import ARKit.ARFrame
import CoreMotion

class Logger{
    
    var lastTimeUpdated: TimeInterval
    var sessionDirectoryURL: URL
    var arkitDataFileURL: URL
    var arkitDataFileHandle: FileHandle
    var samplingTime: Double
    var altimeterPressure: Double
    var attitudeMatrix : CMRotationMatrix
    
    init(){
        lastTimeUpdated = 0
        sessionDirectoryURL = URL(fileURLWithPath: "foo")
        arkitDataFileURL = URL(fileURLWithPath: "foo")
        arkitDataFileHandle = FileHandle()
        samplingTime = 0
        altimeterPressure = 0
        attitudeMatrix = CMRotationMatrix()
    }
    
    deinit{
        arkitDataFileHandle.closeFile()
    }
    
    func startSession(sessionID: String){
        lastTimeUpdated = 0;
        sessionDirectoryURL = try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        sessionDirectoryURL = sessionDirectoryURL.appendingPathComponent(sessionID)
        let timestamp = NSDate().timeIntervalSince1970
        arkitDataFileURL = sessionDirectoryURL.appendingPathComponent("VIO_"+"\(timestamp).txt")
        
        
        
        if !FileManager().fileExists(atPath: sessionDirectoryURL.path) {
            do {
                try FileManager().createDirectory(atPath: sessionDirectoryURL.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                NSLog("Couldn't create document directory")
            }
        }
        NSLog("Document directory is \(sessionDirectoryURL)")
        
        // initialize transform data file
        let fileHeader = String("ARKit Data\n")
        arkitDataFileHandle = FileHandle()
        do{
            try fileHeader.write(to: arkitDataFileURL, atomically: true, encoding: .utf8)
            try arkitDataFileHandle = FileHandle(forWritingTo: arkitDataFileURL)
        }
        catch{
            print("error writing to file")
        }
    }
    
    func logData(currentARFrame: ARFrame, cnt: UInt64){
        //print("SAMPLING: \(samplingTime)" )
                
        lastTimeUpdated = currentARFrame.timestamp
        let imageFilename = "\(cnt)"+".jpg"
        let altPressString:String = String(format:"%.8f", self.altimeterPressure)
        let fileURL = sessionDirectoryURL.appendingPathComponent(imageFilename)
        let currTransform = "\n"+"\(cnt)"+"\n"+"\(lastTimeUpdated)"+"\n" + "\(currentARFrame.camera.trackingState)" + "\n" +
            "\(currentARFrame.camera.transform)" + "\n" +
            "\(currentARFrame.camera.transform.columns.3.x)" + ", " +
            "\(currentARFrame.camera.transform.columns.3.y)" + ", " +
            "\(currentARFrame.camera.transform.columns.3.z)" + "\n" +
            "\(currentARFrame.camera.eulerAngles)" + "\n" +
            "\(altPressString)" + "\n" +
            "\(attitudeMatrix)" + "\n"
        
        self.appendToFile(stringToAppend: currTransform, fileHandle: arkitDataFileHandle)
        //self.saveUIImage(imageToSave: scaledFrame, saveTo: fileURL)
        self.saveCurrentFrameToImage(imageToSave: currentARFrame.capturedImage, saveTo: fileURL)
    }
    
    func saveUIImage(imageToSave: UIImage, saveTo: URL){
        let data = imageToSave.jpegData(compressionQuality: 1.0)
//        JPEGRepresentation(imageToSave, 1.0)
        do{
            try data!.write(to: saveTo)
        }
        catch{
            print ("Error Saving Data")
        }
    }
    
    func saveCurrentFrameToImage(imageToSave: CVPixelBuffer, saveTo: URL){
        let image = self.pixelBufferToUIImage(pixelBuffer: imageToSave)
        let data = image.jpegData(compressionQuality: 1.0)
        do{
            try data!.write(to: saveTo)
        }
        catch{
            print ("Error Saving Data")
        }
    }
    
    func pixelBufferToUIImage(pixelBuffer: CVPixelBuffer) -> UIImage {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(ciImage, from: ciImage.extent)
        let uiImage = UIImage(cgImage: cgImage!)
        return uiImage
    }
    
    func appendToFile(stringToAppend: String, fileHandle: FileHandle){
        fileHandle.seekToEndOfFile()
        fileHandle.write(stringToAppend.data(using: .utf8)!)
    }
    
    func saveImage(imageToSave: UIImage, counter: UInt64){
        let imageFilename = "\(counter)"+".jpg"
        let fileURL = sessionDirectoryURL.appendingPathComponent(imageFilename)
        let data = imageToSave.jpegData(compressionQuality: 1.0)
        do{
            try data!.write(to: fileURL)
        }
        catch{
            print ("Error Saving Data")
        }
    }
    
    func saveImage(imageToSave: CVPixelBuffer, counter: UInt64){
        let image =  pixelBufferToUIImage(pixelBuffer: imageToSave)
        saveImage(imageToSave: image, counter: counter)
    }
    
    func getImageFilename(counter: UInt64) -> NSString {
        let imageFilename = "\(counter)"+".jpg"
        let fileURL = sessionDirectoryURL.appendingPathComponent(imageFilename)
        return fileURL.absoluteString as NSString
    }
    
}

