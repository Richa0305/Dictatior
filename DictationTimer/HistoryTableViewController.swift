//
//  HistoryTableViewController.swift
//  DictationTimer
//
//  Created by Srivastava, Richa on 24/05/18.
//  Copyright © 2018 Srivastava, Richa. All rights reserved.
//

import UIKit
import CoreData

class HistoryTableViewController: UITableViewController {

    let appDelegare = UIApplication.shared.delegate as! AppDelegate
    var historyArr = [HistoryModel]()
    var showAd = true
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let context = appDelegare.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "History")
        //request.predicate = NSPredicate(format: "age = %@", "12")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            var count = 0
                for data in result as! [NSManagedObject] {
                    let history = HistoryModel()
                    history.duration = data.value(forKey: "duration") as! String
                    history.dictation = data.value(forKey: "dictation") as! String
                    history.confidenceScore = data.value(forKey: "confidencescore") as! Float
                    historyArr.append(history)
                    count += 1
                }
            if count == result.count{
                historyArr.reverse()
            }
            
        } catch {
            
            print("Failed")
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if showAd {
            showAd = false
            let App = UIApplication.shared.delegate as! AppDelegate
            App.gViewController = self
            App.showAdmobInterstitial()
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return historyArr.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HistoryTableViewCell
        
        cell.dictationLabel.text = historyArr[indexPath.row].dictation
        cell.durationLabel.text =  "\(historyArr[indexPath.row].duration) seconds"
        cell.confidenceScoreLabel.text = "Confidence Score : \((historyArr[indexPath.row].confidenceScore) * 100)%"
        cell.progressBarView.progress = historyArr[indexPath.row].confidenceScore
        return cell
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func doneAction(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
}
