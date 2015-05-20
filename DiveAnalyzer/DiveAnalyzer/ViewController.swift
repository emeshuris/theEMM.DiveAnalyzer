import UIKit
import Foundation // for NSJSONSerialization
import JBChart

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

class ViewController: UIViewController, JBBarChartViewDelegate, JBBarChartViewDataSource {
    @IBOutlet weak var barChart: JBBarChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.darkGrayColor()
        barChart.backgroundColor = UIColor.darkGrayColor()
        
        barChart.delegate = self
        barChart.dataSource = self
        barChart.minimumValue = 0
        barChart.maximumValue = 4000
        
        
        
        
        
        
        var diveEndpoint: String = "http://edwardmeshuf842/DiveAnalyzer.API/api/dive"
        var diveIdentifierOut: String?
        
        var urlRequest = NSURLRequest(URL: NSURL(string: diveEndpoint)!)
        
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue(), completionHandler:{
            (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if let anError = error {}
            else
            {
                var jsonError: NSError?
                if let dive = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &jsonError) as! NSArray!{
                    dispatch_async(dispatch_get_main_queue(),{
                        
                        let newDive = Dive(diveIdentifier: dive[0]["Identifier"] as! String, diveStartDate: dive[0]["DiveStart"] as! String)
                        
                        for divePoint in dive[0]["DivePoints"] as! NSArray! {
                            println(divePoint)
                            
                            let newDivePoint = DivePoint(time: divePoint["Time"] as! NSNumber, depth: divePoint["Depth"] as! NSNumber, pressure: divePoint["Pressure"] as! NSNumber, temperature: divePoint["Temperature"] as! NSNumber)
                            
                            newDive.DivePoints.append(newDivePoint)
                        }
                        
                        //                        var legend
                    })
                }
            }
        })
        
        barChart.reloadData()
        barChart.setState(.Collapsed, animated: false)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        barChart.reloadData()
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("showChart"), userInfo: nil, repeats: false)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        hideChart()
    }
    
    func hideChart(){
        barChart.setState(.Collapsed, animated: true)
    }
    
    func showChart(){
        barChart.setState(.Expanded, animated: true)
    }
    
    //MARK: JBBChartView
    func numberOfBarsInBarChartView(barChartView: JBBarChartView!) -> UInt {
        //return UInt(chart
        //https://youtu.be/2J-_YBXEhNU?t=17m13s
    }
    
}