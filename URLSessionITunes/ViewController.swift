//
//  ViewController.swift
//  URLSessionITunes
//
//  Created by Jack Allen on 5/22/17.
//  Copyright © 2017 Jack Allen. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var table: UITableView? = UITableView()
    var albumTitles = [String]()
    var albumPrices = [String]()
    
    //todo: figue out how to access specific json stuff
    override func viewDidLoad() {
        super.viewDidLoad()
        table?.dataSource = self
        table?.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
        downloadData()
        print(albumPrices)
        print(albumTitles)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = UITableViewCell()
        cell.textLabel?.text = albumPrices[indexPath.row] + " " + albumTitles[indexPath.row]
        return cell
    }
    
    func downloadData(){
        //put url here and set up request settings and task
        let requestURL: NSURL = NSURL(string: "https://itunes.apple.com/us/rss/topalbums/limit=10/json")!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(url: requestURL as URL)
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
                                            self.addTitle(title: label)
                                            print(label)
                                        }
                                    }
                                    if let albumPrice = currentEntry["im:price"] as? [String: Any]{
                                        if let label = albumPrice["label"] as? String {
                                            self.addPrice(price: label)
                                            print(label)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    self.meMethod()
                    
                }catch{
                    print("error with json: \(error)")
                }
            }
        }
        task.resume()
        print("test")
    }
    
    func meMethod(){
        print("count: " + String(albumTitles.count))
        print(albumTitles)
        print(albumPrices)
        self.table?.reloadData()
    }
    func addTitle(title: String){
        let meString = String(title)
        albumTitles.append(meString!)
    }
    
    func addPrice(price: String){
        albumPrices.append(price)
    }
}

