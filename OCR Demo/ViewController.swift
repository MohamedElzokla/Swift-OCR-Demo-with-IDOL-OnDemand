//
//  ViewController.swift
//  OCR Demo
//
//  Created by polat on 05/11/14.
//  Copyright (c) 2014 polat. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var imageToRead: UIImageView!
    @IBOutlet weak var textFromOcr: UITextView!
    
    //OCR settings
    let apiKey = "7785fb90-db1f-454b-9b19-37f389dd50ec"
    //Sample Images - Use yours if you want.
    let ocrImageUrl1 = "http://www.joyintheaftermath.com/wp-content/uploads/2014/08/meaningoflife.png"
    let ocrImageUrl2 = "http://i.imgur.com/8UcN9ly.jpg"
    let ocrImageUrl3 = "http://www.chupamobile.com/blog/wp-content/uploads/2014/10/sebastian_6.jpg"
    let ocrImageUrl4 = "http://i.imgur.com/iG4ZCw7.jpg"
    var ocrImageUrl = ""
    //API call address of IDOL ON DEMAND
    let endpoint: NSURL = NSURL(string: "https://api.idolondemand.com/1/api/sync/ocrdocument/v1")!
    //Reading modes
    let mode1 = "&mode=document_photo"   //This is best for photos
    let mode2 = "&mode=document_scan"  //Best for scanned documents
    let mode3 = "&mode=scene_photo"  //Best for scenes
    
    var imageID = 1
    
    
    //IDOL on Demand Call
    func postAndGetResult(){
        let request = NSMutableURLRequest(URL: endpoint)
        request.HTTPMethod = "POST"
        
        //change mode here according to type of the image
        let payload = "apikey=\(apiKey)&url=\(ocrImageUrl)\(mode3)".dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = NSURLSession.sharedSession().uploadTaskWithRequest(request, fromData: payload, completionHandler: {data, response, error -> Void in
            
            if let value = data {
                var error:NSError? = nil
                if let jsonObject : AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error) {
                    let json = JSON(jsonObject)
                    if let ocr_results = json["text_block"][0]["text"].string {
                        println(ocr_results)
                        
                        dispatch_async(dispatch_get_main_queue(),{
                            self.textFromOcr.text = ocr_results
                            self.textFromOcr.hidden = false
                            self.imageToRead.hidden = true
                        })
                    }
                }else{
                    println(error)
                }
            }
        })
        task.resume()
    }
    
    
    //Download images from the image location to display
    func downloadImage(fromURL:String){
        let url:NSURL = NSURL(string:fromURL)!
        let request:NSURLRequest = NSURLRequest(URL:url)
        let queue:NSOperationQueue = NSOperationQueue()
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            dispatch_async(dispatch_get_main_queue(),{
                self.textFromOcr.hidden = true
                self.imageToRead.hidden = false
                self.imageToRead.image = UIImage(data: data)
            })
        })
    }
    
    
    //Skip to next image
    @IBAction func nextImage(sender: AnyObject) {
        self.textFromOcr.hidden = true
        self.imageToRead.hidden = false
        imageID++
        if imageID == 1{
            ocrImageUrl = ocrImageUrl1
        }else if imageID == 2 {
            ocrImageUrl = ocrImageUrl2
            
        }else if imageID == 3 {
            ocrImageUrl = ocrImageUrl3
            
        }else if imageID == 4 {
            ocrImageUrl = ocrImageUrl4
            imageID = 0
        }
        downloadImage(ocrImageUrl)
        
    }
    
    
    //Comvert to Text action
    @IBAction func convertToText(sender: AnyObject) {
        postAndGetResult()
        
    }
    
    
    
    func addDropShadow(){
        imageToRead.layer.shadowColor = UIColor.blackColor().CGColor
        imageToRead.layer.shadowOffset = CGSizeMake(0, 1);
        imageToRead.layer.shadowOpacity = 1
        imageToRead.layer.shadowRadius = 4.0
        imageToRead.clipsToBounds = false

    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //default startup values
        textFromOcr.hidden = true
        ocrImageUrl = ocrImageUrl1
        downloadImage(ocrImageUrl)
        addDropShadow()

        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

