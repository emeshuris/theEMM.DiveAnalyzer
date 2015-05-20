import UIKit
import Foundation // for NSJSONSerialization

class Dive {
    var DiveIdentifier: String!
    var DiveStartDate: NSDate!
    var DivePoints = Array<DivePoint>()
    
    init(diveIdentifier: String, diveStartDate: String) {
        DiveIdentifier = diveIdentifier
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        DiveStartDate = dateFormatter.dateFromString(diveStartDate)
    }
}

class DivePoint {
    var Time: Int32!
    var Depth: Float!
    var Pressure: Float!
    var Temperature: Float!
    
    init(time: NSNumber, depth: NSNumber, pressure: NSNumber, temperature: NSNumber)
    {
        Time = time.intValue
        Depth = depth.floatValue
        Pressure = pressure.floatValue
        Temperature = temperature.floatValue
    }
}

class ViewController: UIViewController {
    @IBOutlet var diveLabel: UILabel!
    @IBOutlet var startDateLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var pressureLabel: UILabel!
    @IBOutlet var depthLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var diveEndpoint: String = "http://edwardmeshuf842/DiveAnalyzer.API/api/dive"
        var diveIdentifierOut: String?
        
        var urlRequest = NSURLRequest(URL: NSURL(string: diveEndpoint)!)
        
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue(), completionHandler:{
            (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if let anError = error
            {
                self.diveLabel.text = "error calling GET on /dives/1"
            }
            else
            {
                var jsonError: NSError?
                if let dive = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &jsonError) as! NSArray!{
                    dispatch_async(dispatch_get_main_queue(),{
                        var diveIdentifier = dive[0]["Identifier"] as! String
                        var stringStartDate = dive[0]["DiveStart"] as! String
                        
                        let newDive = Dive(diveIdentifier:diveIdentifier, diveStartDate: stringStartDate)
                        
                        self.diveLabel.text = "Identifier: \(newDive.DiveIdentifier)"
                        self.startDateLabel.text = "DiveStart: \(newDive.DiveStartDate)"
                        
                        var divePoints = dive[0]["DivePoints"] as! NSArray!
                        
                        for divePoint in divePoints {
                            println(divePoint)
                            
                            let newDivePoint = DivePoint(time: divePoint["Time"] as! NSNumber, depth: divePoint["Depth"] as! NSNumber, pressure: divePoint["Pressure"] as! NSNumber, temperature: divePoint["Temperature"] as! NSNumber)
                            
                            newDive.DivePoints.append(newDivePoint)
                        }
                        
                        self.timeLabel.text = "   Time: \(newDive.DivePoints[1].Time)"
                        self.depthLabel.text = "   Depth: \(newDive.DivePoints[1].Depth)"
                        self.pressureLabel.text = "   Pressure: \(newDive.DivePoints[1].Pressure)"
                        
                        /*
                        var divePoint = divePoints[0] as! NSDictionary
                        var time: AnyObject! = divePoint["Time"]
                        var depth: AnyObject! = divePoint["Depth"]
                        var pressure: AnyObject! = divePoint["Pressure"]
                        
                        self.timeLabel.text = "   Time: \(time)"
                        self.depthLabel.text = "   Depth: \(depth)"
                        self.pressureLabel.text = "   Pressure: \(pressure)"*/
                    })
                }
            }
        })
    }
}