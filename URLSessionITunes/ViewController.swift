//
//  ViewController.swift
//  URLSessionITunes
//
//  Created by Jack Allen on 5/22/17.
//  Copyright © 2017 Jack Allen. All rights reserved.
//

import UIKit
import Alamofire
import FirebaseCore
import FirebaseDatabase

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var table: UITableView? = UITableView()
    var albumTitles = [String]()
    var albumPrices = [String]()
    var teams = [String]()
    var countrySongs = [String]()
    var ref : DatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseApp.configure()
        ref = Database.database().reference(withPath: "teams")
        table?.dataSource = self
        table?.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
        downloadData() //downloads the top ten albums info using the traditional method
        alamoFireExample() //downloads the top 50 country song info using the Alamofire Library
        
        for index in 0...319{
            let strPath = String(index)
            ref?.child(strPath).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let region = value?["region"] as? String
                let name = value?["name"] as? String
                print(String(index) + region! + " " + name!)
                self.teams.append(region! + " " + name!)
                self.sortArray()
            })
        }
        
        
    }

    func sortArray(){
        teams = teams.sorted { (s1: String, s2: String) -> Bool in
            return s1 < s2
        }
        self.table?.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //edit this to change table content
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teams.count
    }
    
    //edit this to change table contnet
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = UITableViewCell()
        cell.textLabel?.text = teams[indexPath.row]
        return cell
    }
    
    //method to download data using the URL libraries that apple already has (sucky :[)
    func downloadData(){
        //put url here and set up request settings and tsk
        let requestURL: URL = URL(string: "https://itunes.apple.com/us/rss/topalbums/limit=10/json")!
        let urlRequest: URLRequest = URLRequest(url: requestURL as URL)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest as URLRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            //if it's all good in the hood, start parsing the json
            if(statusCode == 200){
                do{
                    var json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String : AnyObject]
                    
                    if let feed = json["feed"] as? [String: Any]{
                        if let entry = feed["entry"] as? [Any] {
                            for index in entry{
                                if let currentEntry = index as? [String: Any] {
                                    if let imName = currentEntry["im:name"] as? [String: Any]{
                                        if let label = imName["label"] as? String {
                                            self.albumTitles.append(label)
                                        }
                                    }
                                    if let albumPrice = currentEntry["im:price"] as? [String: Any]{
                                        if let label = albumPrice["label"] as? String {
                                            self.albumPrices.append(label)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    self.table?.reloadData()
                    
                }catch{
                    print("error with json: \(error)")
                }
            }
        }
        task.resume()
    }
    
    //method to download data using the alamofire library (hopefully making it a fuckton easier)
    func alamoFireExample(){

        Alamofire.request("https://itunes.apple.com/us/rss/topsongs/limit=50/genre=6/json").responseJSON { (response)->Void in
            //go crazy with alamofire

            
            if let json = response.result.value as? [String: AnyObject]{
                if let feed = json["feed"] as? [String: Any]{
                    if let entry = feed["entry"] as? [Any]{
                        for element in entry{
                            if let currentElement = element as? [String: Any]{
                                if let imName = currentElement["im:name"] as? [String: Any]{
                                    if let label = imName["label"] as? String{
                                        self.countrySongs.append(label)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            self.table?.reloadData()
        }
    }
    
}

