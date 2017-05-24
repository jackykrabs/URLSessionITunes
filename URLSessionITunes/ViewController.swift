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
        //addCollege(abbrev: "DUKE", cid: 1, city: "Durham", did: 1, name: "Blue Devils", pop: 66, region: "Duke", state: "NC", rank: 1)
        //deleteCollege(identifier: "1")
        updateCollege(identifier: "0")
        downloadData()
    }


    //fix before using
    func firebaseSDKExample(){
        for index in 0...320{
            let strPath = String(index)
            ref?.child(strPath).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let region = value?["region"] as? String
                let name = value?["name"] as? String
                self.teams.append(region! + " " + name!)
                self.sortArray()
            })
        }
    }
    
    //method to update information about one of the colleges in the database (unlike editCollege, it doesn't delete the elements it's not touching)
    //given the identifier (jumble of characters or string number) (PATCH Method)
    func updateCollege(identifier: String){
        let requestURL: URL = URL(string: "https://my-awesome-project-8b957.firebaseio.com/teams/" + identifier + ".json")!
        var urlRequest: URLRequest = URLRequest(url: requestURL as URL)
        urlRequest.httpMethod = "PATCH"
        
        let testObj = [
            "region" : "Duke"
        ] as [String: Any]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: testObj)
        
        urlRequest.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: urlRequest as URLRequest) {
            (data, response, error) -> Void in
            
            self.table?.reloadData()
        }
        task.resume()
    }
    
    //method to delete a college in the database, given the identifier (usually either a number in a string or a random jumble of characters) (DELETE Method)
    func deleteCollege(identifier: String){
        let requestURL: URL = URL(string: "https://my-awesome-project-8b957.firebaseio.com/teams/" + identifier + ".json")!
        var urlRequest: URLRequest = URLRequest(url: requestURL as URL)
        urlRequest.httpMethod = "DELETE"
        
        let task = URLSession.shared.dataTask(with: urlRequest as URLRequest) {
            (data, response, error) -> Void in
            
            self.table?.reloadData()
        }
        task.resume()
    }
    
    //method to edit a college in the database, given the identifier (usually either a number in a string or a random jumble of characters) (PUT Method)
    //unlike the updateCollege() method, this use of the PUT method deletes all of the elements that aren't touched
    func editCollege(identifier: String){
        let requestURL: URL = URL(string: "https://my-awesome-project-8b957.firebaseio.com/teams/" + identifier + ".json")!
        var urlRequest: URLRequest = URLRequest(url: requestURL as URL)
        urlRequest.httpMethod = "PUT"
        
        let validTeam = [
            "abbrev" : "oi",
            "cid" : 1,
            "city" : "San Antonio",
            "did" : 54,
            "latitude" : 12.3,
            "longitude" : 38.4,
            "name" : "Spurs",
            "pop" : 987,
            "region" : "San Antonio",
            "state" : "TX",
            "tid" : 32
            ] as [String : Any]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: validTeam)
        
        //move the data into the body of the http request (prepare to send off to the webserver aka Firebase project)
        urlRequest.httpBody = jsonData
        
        
        //create the task to send the data and execute it
        let task = URLSession.shared.dataTask(with: urlRequest as URLRequest) {
            (data, response, error) -> Void in
            
            self.table?.reloadData()
        }
        task.resume()

    }
 
    //method to add college (not using the firebase SDK because we're baller) (POST Method)
    func addCollege(abbrev: String, cid: Int, city: String, did: Int, name: String, pop: Int, region: String, state: String, rank: Int){
        
        //create the json object to place into the database
        let validTeam = [
            "abbrev" : abbrev,
            "cid" : cid,
            "city" : city,
            "did" : did,
            "latitude" : 12.3,
            "longitude" : 38.4,
            "name" : name,
            "pop" : pop,
            "region" : region,
            "state" : state,
            "tid" : rank
            ] as [String : Any]
        
        //put the 'team' we created and put it into the form of json data
        let jsonData = try? JSONSerialization.data(withJSONObject: validTeam)
        
        //set up the URL request and set the request to 'POST' (let the program know we're writing data)
        let requestURL: URL = URL(string: "https://my-awesome-project-8b957.firebaseio.com/teams/0.json")!
        var urlRequest: URLRequest = URLRequest(url: requestURL as URL)
        urlRequest.httpMethod = "POST"
        
        //move the data into the body of the http request (prepare to send off to the webserver aka Firebase project)
        urlRequest.httpBody = jsonData
        
        
        //create the task to send the data and execute it
        let task = URLSession.shared.dataTask(with: urlRequest as URLRequest) {
            (data, response, error) -> Void in

            self.table?.reloadData()
        }
        task.resume()
    }
 
    //sorts the array in alphabetical order (data isn't pulled in order since it's treated as a dictionary of json objects)
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
    
    //method to download data using the URL libraries that apple already has (GET Method)
    func downloadData(){
        
        //put url here, set up request settings, and set the HTTP method to 'GET' (let the program know we're reading data)
        let requestURL: URL = URL(string: "https://my-awesome-project-8b957.firebaseio.com/teams.json")!
        var urlRequest: URLRequest = URLRequest(url: requestURL as URL)
        urlRequest.httpMethod = "GET"
        
        //create the task to read the data, and then execute it (.resume())
        let task = URLSession.shared.dataTask(with: urlRequest as URLRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            //if it's all good in the hood, start parsing the json
            if(statusCode == 200){
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [AnyObject]
                   
                    //iterate through the dictionary of json objects, and add each one's school name and mascot to the (same) cell in the teams array
                    for value in json {
                        if let team = value as? [String: AnyObject]{
                            if let name = team["region"] as? String {
                                self.teams.append(name)
                            }
                            if let school = team["name"] as? String {
                                self.teams[self.teams.count - 1] = self.teams[self.teams.count - 1] + " " + school
                            }
                        }
                    }
                    //if this isn't called, the teams are in a random order
                   // self.sortArray()
                    
                    //update the table with the new data
                    self.table?.reloadData()
                    
                }catch{
                    print("error with json: \(error)")
                }
            }
        }
        task.resume()
    }
    
    //method to download data using the alamofire library
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

