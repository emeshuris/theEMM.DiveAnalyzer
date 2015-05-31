import UIKit
import Foundation // for NSJSONSerialization
import JBChart

class Dive {
    var DiveIdentifier: String!
    var DiveStartDate: NSDate!
    var DivePoints = [DivePoint]()
    
    init(diveIdentifier: String, diveStartDate: String) {
        DiveIdentifier = diveIdentifier
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        DiveStartDate = dateFormatter.dateFromString(diveStartDate)
    }
}

class DivePoint {
    var Time: Int32!
    var Depth: Int32!
    var Pressure: Float!
    var Temperature: Float!
    
    
    init(time: Int32, depth: Int32, pressure: Float, temperature: Float)
    {
        Time = time
        Depth = 150 - depth
        Pressure = pressure
        Temperature = temperature
    }
    
    init(time: NSNumber, depth: NSString, pressure: NSString, temperature: NSString)
    {
        Time = time.intValue
        Depth = 150 - depth.intValue
        Pressure = pressure.floatValue
        Temperature = temperature.floatValue
    }
}

class ViewController: UIViewController, JBLineChartViewDelegate, JBLineChartViewDataSource {
    @IBOutlet weak var lineChart: JBLineChartView!
    var newDive: Dive?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        hideChart()
    }
    
    func setUpUI()
    {
        view.backgroundColor = UIColor.darkGrayColor()
        
        lineChart.backgroundColor = UIColor.darkGrayColor()
        lineChart.delegate = self
        lineChart.dataSource = self
        lineChart.minimumValue = 0
        lineChart.maximumValue = 150
    }
    
    func getData(){
        var diveEndpoint: String = "http://localhost:3000/api/dives/"
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
                        
                        self.newDive = Dive(diveIdentifier: dive[0]["Identifier"] as! String, diveStartDate: dive[0]["DiveStart"] as! String)
                        
                        for divePoint in dive[0]["DivePoints"] as! NSArray! {
                            println(divePoint)
                            
                            let newDivePoint = DivePoint(time: divePoint["Time"] as! NSNumber, depth: divePoint["Depth"] as! NSString, pressure: divePoint["Pressure"] as! NSString, temperature: divePoint["Temperature"] as! NSString)
                            
                            self.newDive!.DivePoints.append(newDivePoint)
                        }
                        
                        self.drawChart()
                    })
                }
            }
        })
        
        lineChart.setState(.Collapsed, animated: false)
    }
    
    func drawChart(){
        setUpUI()
        lineChart.reloadData()
        var timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("showChart"), userInfo: nil, repeats: false)
    }
    
    func hideChart(){
        lineChart.setState(.Collapsed, animated: true)
    }
    
    func showChart(){
        lineChart.setState(.Expanded, animated: true)
    }
    
    //MARK: JBBChartView
    func numberOfLinesInLineChartView(lineChartView: JBLineChartView!) -> UInt {
        return 1
    }
    
    func lineChartView(lineChartView: JBLineChartView!, numberOfVerticalValuesAtLineIndex lineIndex: UInt) -> UInt {
        if (lineIndex == 0) {
            return UInt(newDive!.DivePoints.count)
        }
        
        return 0
    }
    
    func lineChartView(lineChartView: JBLineChartView!, verticalValueForHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> CGFloat {
        if (lineIndex == 0) {
            return CGFloat(newDive!.DivePoints[Int(horizontalIndex)].Depth)
        }
        
        return 0
    }
    
    func lineChartView(lineChartView: JBLineChartView!, colorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        if (lineIndex == 0) {
            return UIColor.lightGrayColor()
        }
        
        return UIColor.lightGrayColor()
    }
    
    func lineChartView(lineChartView: JBLineChartView!, showsDotsForLineAtLineIndex lineIndex: UInt) -> Bool {
        return false
    }
    
    func lineChartView(lineChartView: JBLineChartView!, colorForDotAtHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> UIColor! {
        return UIColor.lightGrayColor()
    }
    
    func lineChartView(lineChartView: JBLineChartView!, smoothLineAtLineIndex lineIndex: UInt) -> Bool {
        if (lineIndex == 0) {
            return true
        }
        
        return true
    }
    
    func lineChartView(lineChartView: JBLineChartView!, didSelectLineAtIndex lineIndex: UInt, horizontalIndex: UInt) {
        if (lineIndex == 0) {
            let data = newDive!.DivePoints[Int(horizontalIndex)].Depth
            let key = newDive!.DivePoints[Int(horizontalIndex)].Time
        }
    }
    
    func lineChartView(lineChartView: JBLineChartView!, fillColorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        if (lineIndex == 1) {
            return UIColor.whiteColor()
        }
        
        return UIColor.clearColor()
    }
}