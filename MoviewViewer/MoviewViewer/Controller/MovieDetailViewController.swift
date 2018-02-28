//
//  MovieDetailViewController.swift
//  MoviewViewer
//
//  Created by Amiel Reyes on 2/28/18.
//  Copyright © 2018 Amiel Reyes. All rights reserved.
//

import UIKit
import SDWebImage
import SVProgressHUD

class MovieDetailViewController: UIViewController {
    @IBOutlet weak var landScapeImageView: UIImageView!
    @IBOutlet weak var portraitImageview: UIImageView!
    @IBOutlet weak var movieNameLBL: UILabel!
    @IBOutlet weak var movieGenreLBL: UILabel!
    @IBOutlet weak var movieAdvisoryLBL: UILabel!
    @IBOutlet weak var movieDurationLBL: UILabel!
    @IBOutlet weak var movieReleaseDateLBL: UILabel!
    @IBOutlet weak var movieSynopsisLBL: UILabel!
    
    var movieData : [String:String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.getData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        
    }
    
    
    func minutesToHoursMinutes (minutes : String) -> String {
        let d : Float = Float(minutes)!
        return "\(Int(d) / 60) hr \(Int(d) % 60)mins"
    }
    
    func getData(){
        SVProgressHUD.show()
        WebServiceAPI.shared.getMovieDetail { (data, error) in
            SVProgressHUD.dismiss()

            if let response = data {
                self.movieData["poster"] = response["poster"] as? String
                self.movieData["poster_landscape"] = response["poster_landscape"] as? String
                self.movieData["canonical_title"] = response["canonical_title"] as? String
                self.movieData["genre"] = response["genre"] as? String
                self.movieData["advisory_rating"] = response["advisory_rating"] as? String

                self.movieData["runtime_mins"] = self.minutesToHoursMinutes(minutes: (response["runtime_mins"] as? String)!)
                self.movieData["release_date"] = response["release_date"] as? String
                self.movieData["synopsis"] = response["synopsis"] as? String
                self.movieData["theater"] = response["theater"] as? String
                self.displayRetriveData()
            }else{
                let v  = UIAlertController.init(title: "Error", message: "There is a problem connecting to the server", preferredStyle: UIAlertControllerStyle.alert)
                
                let okButton = UIAlertAction.init(title: "Re-Try", style: UIAlertActionStyle.default, handler: { (action) in
                    self.getData()
                })
                v.addAction(okButton)
                
                self.present(v, animated: true, completion:nil)

            }
        }
    }

    
    
    func displayRetriveData() {


        self.landScapeImageView.sd_setImage(with: URL(string:self.movieData["poster_landscape"]!), placeholderImage: UIImage(named: "place_holder"))
        self.portraitImageview.sd_setImage(with: URL(string:self.movieData["poster"]!), placeholderImage: UIImage(named: "place_holder"))
        
        self.movieNameLBL.text = self.movieData["canonical_title"]
        self.movieGenreLBL.text = self.movieData["genre"]
        self.movieAdvisoryLBL.text = self.movieData["advisory_rating"]
        self.movieDurationLBL.text = self.movieData["runtime_mins"]
        self.movieReleaseDateLBL.text = self.movieData["release_date"]?.formatDate()
        self.movieSynopsisLBL.text = self.movieData["synopsis"]

    }
    

    @IBAction func viewSeatMap(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: "toSeatMapViewController", sender: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "toSeatMapViewController" {
            let vc : SeatMapViewController = segue.destination as! SeatMapViewController
            
            if let name = self.movieData["theater"]  {
                vc.theaterString = name

            }
        }
    
    }
 

}


extension String {
    func formatDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let date = dateFormatter.date(from: self)
        dateFormatter.dateFormat = "MMMM dd, YYYY "
        
        return dateFormatter.string(from: date!)
    }
}
