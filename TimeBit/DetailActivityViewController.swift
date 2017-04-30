//
//  DetailActivityViewController.swift
//  TimeBit
//
//  Created by Namrata Mehta on 4/29/17.
//  Copyright © 2017 BiteOfTime. All rights reserved.
//

import UIKit

class DetailActivityViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var detailActivity1Cell: DetailActivity1Cell!
    var detailActivity4Cell: DetailActivity4Cell!
    // Expecting this value from the calling screen.
    //var activity_name: String!
    var activity_name: String = "Dance"
    var activityToday: [ActivityLog]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "DetailActivity1Cell", bundle: nil), forCellReuseIdentifier: "DetailActivity1Cell")
        tableView.register(UINib(nibName: "DetailActivity2Cell", bundle: nil), forCellReuseIdentifier: "DetailActivity2Cell")
        tableView.register(UINib(nibName: "DetailActivity3Cell", bundle: nil), forCellReuseIdentifier: "DetailActivity3Cell")
        tableView.register(UINib(nibName: "DetailActivity4Cell", bundle: nil), forCellReuseIdentifier: "DetailActivity4Cell")
        
        // Today's activity update
        todayCount()
        
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func todayCount() {
        let params = ["activity_name": activity_name] as [String : Any]
        ParseClient.sharedInstance.getTodayCountForActivity(params: params as NSDictionary?) { (activities: [ActivityLog]?, error: Error?) -> Void in
            if error != nil {
                NSLog("Error getting activities from Parse")
            } else {
                self.activityToday = activities!
                NSLog("Items from Parse \(self.activityToday)")
            }
        }
    }

}

extension DetailActivityViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("section \(indexPath.section)")
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailActivity1Cell", for: indexPath) as! DetailActivity1Cell
            return cell
        }
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailActivity2Cell", for: indexPath) as! DetailActivity2Cell
            return cell
        }
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailActivity3Cell", for: indexPath) as! DetailActivity3Cell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailActivity4Cell", for: indexPath) as! DetailActivity4Cell
            cell.activity_name = activity_name
            return cell
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            print("Set a goal")
            /*
            let gvc = GoalSettingViewController(nibName: "GoalSettingViewController", bundle: nil)
            gvc.activityName = activity_name
            gvc.goalSetting = "Set"
            navigationController?.pushViewController(gvc, animated: true);
            */
        } else if indexPath.section == 2 {
            print("Update a goal")
            /*
            let gvc = GoalSettingViewController(nibName: "GoalSettingViewController", bundle: nil)
            gvc.activityName = activity_name
            gvc.goalSetting = "Update"
            navigationController?.pushViewController(gvc, animated: true);
             */
        }
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        if indexPath.section == 0 {
            return 120
        }
        else if indexPath.section == 1 {
            return 60
        }
        else if indexPath.section == 2 {
            return 60
        }
        else if indexPath.section == 3 {
            return 300
        }
        return 10
    }
    
    
}
