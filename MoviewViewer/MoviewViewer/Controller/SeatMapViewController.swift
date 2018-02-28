//
//  SeatMapViewController.swift
//  MoviewViewer
//
//  Created by Amiel Reyes on 2/28/18.
//  Copyright © 2018 Amiel Reyes. All rights reserved.
//

import UIKit
import DropDown
import SVProgressHUD

class SeatMapViewController: UIViewController {
    @IBOutlet weak var seatMapScrollView: UIScrollView!
    @IBOutlet weak var selectedSeatScrollView: UIScrollView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cinemaLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var theaterNameLabel: UILabel!
    
    
    let dropDown = DropDown()
    
    var selectedSeatArray : [String] = []

    var cinemaPrice : Float = 0.0
    var theaterString : String = ""
    
    var seatMapMainView : UIView = UIView()

    ///Schedule
    var scheduleDataArray : [String] = []
    var scheduleCinemaArray : [String] = []
    var scheduleTimes : [[String:Any]] = []
    var scheduleTimesStringArray : [String] = []

    
    ///mapSeat
    var dataSeatMap : [Any] = []
    var dataAvailableSeat : [String] = []
    var seatInfoArray : [[String:String]] = [[:]]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.theaterNameLabel.text = self.theaterString
        self.getSeatMap()
        self.getschedule()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    
    func dropdownSetup(sender:UIButton , dataSource : [String]) {
        dropDown.anchorView = sender
        dropDown.direction = .bottom
        dropDown.bottomOffset = CGPoint(x: 0, y:sender.frame.height)
        
        dropDown.dataSource = dataSource
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            if sender.tag == 1 {
                self.cinemaLabel.text = item
            }else if sender.tag == 2 {
                self.timeLabel.text = item
                
                if let n = NumberFormatter().number(from: self.scheduleTimes[index]["price"] as! String) {
                    self.cinemaPrice = Float(truncating: n)
                }
                self.computeSelectedSeat()
                
            }else{
                self.dateLabel.text = item
            }
            self.dropDown.hide()

        }
        
        dropDown.show()
    }
    
    @IBAction func selectDate(_ sender: UIButton) {
        self.dropdownSetup(sender: sender, dataSource: self.scheduleDataArray)

    }
    @IBAction func selectCinema(_ sender: UIButton) {

        self.dropdownSetup(sender: sender, dataSource: self.scheduleCinemaArray)

    }
    @IBAction func selectTime(_ sender: UIButton) {
        self.dropdownSetup(sender: sender, dataSource: self.scheduleTimesStringArray)

    }
    
    func  getschedule() {
        SVProgressHUD.show()
        
        WebServiceAPI.shared.getSchedule { (data, error) in
            SVProgressHUD.dismiss()
            if let response = data {
                
                if let date = response["dates"] as? [[String:Any]] {
                    
                    for data in date {
                        self.scheduleDataArray.append(data["label"] as! String)
                    }
                }
                
                if let time = response["times"] as? [[String:Any]] {
                    let timeObject : [String:Any] = time.first!
                    let timeArray : [[String : Any]] = timeObject["times"] as! [[String : Any]]
                    for data in timeArray {
                        self.scheduleTimes.append(data)
                        self.scheduleTimesStringArray.append(data["label"] as! String)
                    }
                    self.timeLabel.text = self.scheduleTimes.first!["label"] as? String
                    if let n = NumberFormatter().number(from: self.scheduleTimes.first!["price"] as! String) {
                        self.cinemaPrice = Float(truncating: n)
                    }
                    
                }
                
                if let cinemas = response["cinemas"] as? [[String:Any]] {
                    let cinemasObject : [String:Any]  = cinemas.first!
                    if let cinema = cinemasObject["cinemas"] as? [[String:Any]]{
                        
                        for data in cinema {
                            self.scheduleCinemaArray.append(data["label"] as! String)
                        }
                    }
                }
            }else{
                let v  = UIAlertController.init(title: "Error", message: "There is a problem connecting to the server", preferredStyle: UIAlertControllerStyle.alert)
                
                let okButton = UIAlertAction.init(title: "Re-Try", style: UIAlertActionStyle.default, handler: { (action) in
                    self.getschedule()
                })
                v.addAction(okButton)
                
                self.present(v, animated: true, completion:nil)
            }
        }
    }

    func getSeatMap() {
     SVProgressHUD.show()
        WebServiceAPI.shared.getSeatMap { (data, error) in
            SVProgressHUD.dismiss()
            if let response = data {
                self.dataSeatMap = response["seatmap"] as! [Any]
                self.dataSeatMap = response["seatmap"] as! [Any]
                
                if let availableSeat = response["available"] as? [String : Any] {
                    self.dataAvailableSeat = availableSeat["seats"] as! [String]
                }
                self.displayAvailableSeats()
            }else{
                let v  = UIAlertController.init(title: "Error", message: "There is a problem connecting to the server", preferredStyle: UIAlertControllerStyle.alert)
                
                let okButton = UIAlertAction.init(title: "Re-Try", style: UIAlertActionStyle.default, handler: { (action) in
                    self.getSeatMap()
                })
                v.addAction(okButton)
                
                self.present(v, animated: true, completion:nil)
            }
        }
    }
    
    func displayAvailableSeats() {
        
        var layoutX : CGFloat = 0
        var layouty : CGFloat = 45
        var buttonTag : Int = 0
        
        
        self.seatMapMainView = UIView.init(frame: CGRect(x: 0,y: 0,width: self.seatMapScrollView.frame.size.width,height: self.seatMapScrollView.frame.size.height))
        self.seatMapScrollView.addSubview(self.seatMapMainView)
        self.createMovieScreen()

        
        for seatDataArray in self.dataSeatMap {
            let seatArray : [String] = seatDataArray as! [String]
            let objectTitle : String = seatArray.first!
            let result = objectTitle.trimmingCharacters(in: .decimalDigits)
            let frameSize : CGFloat = (UIScreen.main.bounds.width / CGFloat(seatArray.count + 4)) // width size
            
            self.checkLetter(result: result, layoutX: layoutX + 2, layouty: layouty, frameSize: frameSize)

            layoutX =  frameSize + frameSize

            for seatID in seatArray {

                if seatID == "b(20)" || seatID == "a(30)" {
                    layoutX = frameSize + layoutX
                }else{
                    
                    self.creaButton( name: seatID, xFloat: layoutX, yFloat: layouty,size: frameSize, tag: buttonTag)
                    buttonTag = buttonTag + 1
                    layoutX = frameSize + layoutX
                }
            }
            
            layoutX =  layoutX + frameSize
            
            self.checkLetter(result: result, layoutX: layoutX - 2, layouty: layouty, frameSize: frameSize)


            
            layouty = layouty + frameSize + 5
            layoutX = 0
        }
    }
    
    
    func checkLetter(result : String,layoutX : CGFloat, layouty : CGFloat ,frameSize :CGFloat) {
        if result == "b(20)" {
            self.createLabel(name:"A", xFloat: layoutX, yFloat: layouty,size: frameSize)
        }else{
            self.createLabel(name: result, xFloat: layoutX, yFloat: layouty,size: frameSize)
        }
    }
    
    
    @objc func seatTapped(sender: UIButton) {
        if sender.isSelected == true {
            sender.isSelected = false
            sender.setBackgroundImage(UIImage.init(named: "boxGray"), for: .normal)
            if let index = self.selectedSeatArray.index(of:sender.titleLabel!.text!) {
                self.selectedSeatArray.remove(at: index)
                self.removeSelectedSeat()
                self.computeSelectedSeat()
            }
        }else {
            if self.selectedSeatArray.count < 10 {
                sender.isSelected = true
                sender.setBackgroundImage(UIImage.init(named: "checkRed2"), for: .normal)
                self.selectedSeatArray.append(sender.titleLabel!.text!)
                self.removeSelectedSeat()
                self.computeSelectedSeat()
            }

        }
    }
    
    
    func computeSelectedSeat(){
        
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ","
        formatter.numberStyle = .currencyISOCode
        formatter.locale = Locale(identifier: "fil_PH")
        if let s = formatter.string(from: (self.cinemaPrice * Float(self.selectedSeatArray.count)) as NSNumber) {
            self.totalPriceLabel.text = "\(s)".replacingOccurrences(of: "PHP", with: "Php ")
            
        }
        
    }
    
    func removeSelectedSeat(){
        for view in self.selectedSeatScrollView.subviews{
            
            if view.tag  == 1{
                view.removeFromSuperview()
            }
        }
        
        self.createSelectedSeatItem()
    }
    
    func createSelectedSeatItem() {
        
        if self.selectedSeatArray.count > 0 {
            let height : CGFloat =  35
            var  x : CGFloat =  0
            
            
            let vc : UIView = UIView.init(frame: CGRect(x: 0,y: 0,width: 50 * CGFloat(self.selectedSeatArray.count),height: height))
            vc.center = self.view.center
            vc.tag = 1
            var newFrame : CGRect  = vc.frame
            newFrame.origin.y = 0
            vc.frame = newFrame
            vc.backgroundColor = UIColor.clear
            
            for seat in self.selectedSeatArray {
                
                let seatLb : UILabel = UILabel.init(frame: CGRect(x: x,y: 0,width: 45,height: height))
                seatLb.text = seat;
                seatLb.font = seatLb.font.withSize(12)
                seatLb.textAlignment = .center
                seatLb.backgroundColor = UIColor.red
                vc.addSubview(seatLb)
                x = x + 50
            }
            
            self.selectedSeatScrollView.addSubview(vc)
            self.selectedSeatScrollView.contentSize = CGSize.init(width: 50 * CGFloat(self.selectedSeatArray.count), height: 0)
        }
        
       
    }
    
    
    
    
    /// Create
    
    func createLabel(name:String,xFloat:CGFloat,yFloat : CGFloat,size : CGFloat) {
        let seatLb : UILabel = UILabel.init(frame: CGRect(x: xFloat,y: yFloat,width: size - 2,height: size - 2))
        seatLb.text = name;
        seatLb.font = seatLb.font.withSize(size)
        self.seatMapMainView.addSubview(seatLb)
    }
    
    func creaButton(name:String,xFloat:CGFloat,yFloat : CGFloat,size : CGFloat, tag : Int) {
        let btn : UIButton = UIButton.init(frame: CGRect(x: xFloat,y: yFloat,width: size - 2,height: size - 2))
        btn.backgroundColor = UIColor.clear;
        btn.setTitle(name, for: .normal)
        btn.setTitleColor(UIColor.clear, for: .normal)
        
        let isAvailable = self.dataAvailableSeat.contains { $0 == name }
        
        if isAvailable {
            btn.setBackgroundImage(UIImage.init(named: "boxGray"), for: .normal)

        }else{
            btn.setBackgroundImage(UIImage.init(named: "blue"), for: .normal)
            btn.isEnabled = false
        }

        
        
        btn.tag = tag
        btn.addTarget(self, action: #selector(self.seatTapped(sender:)), for: .touchUpInside)
        self.seatInfoArray.append(["name_seat" : name])
        self.seatMapMainView.addSubview(btn)
        
    }
    
    func createMovieScreen () {
        let seatLb : UILabel = UILabel.init(frame: CGRect(x: 0,y: 0,width: self.view.frame.size.width - 50,height: 30.0))
        seatLb.text = "Movie Screen";
        seatLb.textAlignment = .center
        seatLb.textColor = UIColor.lightGray

        let vScreen : UIView = UIView.init(frame: CGRect(x: 0,y: 0,width: self.view.frame.size.width - 50,height: 30.0))
        vScreen.center = self.view.center
        var newFrame : CGRect  = vScreen.frame
        newFrame.origin.y = 5
        vScreen.frame = newFrame
        
        vScreen.layer.borderColor = UIColor.lightGray.cgColor
        vScreen.layer.borderWidth = 1
        vScreen.layer.cornerRadius = 5
        vScreen.layer.masksToBounds = true
        vScreen.addSubview(seatLb)
        
        self.seatMapMainView.addSubview(vScreen)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SeatMapViewController : UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.seatMapMainView
    }
    
    
}



