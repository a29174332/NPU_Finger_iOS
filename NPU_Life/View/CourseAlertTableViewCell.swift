//
//  CourseAlertTableViewCell.swift
//  NPU_Finger
//
//  Created by BigAnna on 2021/9/24.
//

import UIKit
import Foundation

class CourseAlertTableViewCell: UITableViewCell {

    @IBOutlet weak var alertSwitch: UISwitch!
    @IBOutlet weak var courseName: UILabel!
    @IBOutlet weak var alertTIme: UITextField!
    var defaultTime = 5
    var superTableView:CourseAlertTableViewController?
    override func awakeFromNib() {
        super.awakeFromNib()
        if UserDefaults.standard.object(forKey: "setAlertTime") == nil{
            UserDefaults.standard.setValue(5, forKey: "setAlertTime")
        }else{
            defaultTime = UserDefaults.standard.object(forKey: "setAlertTime") as! Int
        }
    }
    
    @IBAction func changeTime(_ sender: UIStepper) {
        self.alertTIme.text = String(Int(sender.value))
        defaultTime = Int(sender.value)
    }
    
    
    @IBAction func switchAlert(_ sender: UISwitch) {
        for findName in (superTableView?.alertList)!{
            if findName.courseName == self.courseName.text{
                findName.alertIsOn = sender.isOn
                findName.updateSetting(ALERT: sender.isOn)
                if sender.isOn == false{
                    self.removeAlertCourse(indentifier: self.courseName.text!)
                    return
                }
                
                let mySplitTime = findName.courseTime!.split(separator: "%")
                print(mySplitTime)
                var count = 0
                for myTime in mySplitTime{
                    let alertDay = String(myTime[0])
                    let alertTime = String(myTime[1...])
                    setAlertCourse(courseName: findName.courseName!, courseRoom: findName.courseRoom!, courseDay: alertDay, courseTime: alertTime,count: String(count))
                    count += 1
                }
                                
            }
        }
    }
    
    
    @IBAction func setTime(_ sender: UIButton) {
        UserDefaults.standard.setValue(defaultTime, forKey: "setAlertTime")
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "???????????????", message: "????????????????????????????????????????????????" , preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.superTableView?.present(alert, animated: true, completion: nil)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setAlertCourse(courseName:String, courseRoom:String, courseDay:String?,courseTime:String?,count:String){
        let content = UNMutableNotificationContent()
        content.title = "????????????????????????"
        content.subtitle = "???????????????????\(courseName)"
        content.body = "?????????????????????\(courseRoom)"
        content.badge = 0
        content.sound = .default
        

        var date = DateComponents()
        switch courseDay{
        case "???" : date.weekday = 2
        case "???" : date.weekday = 3
        case "???" : date.weekday = 4
        case "???" : date.weekday = 5
        case "???" : date.weekday = 6
        case "???" : date.weekday = 7
        default:
            date.weekday = 1
        }
        
        switch courseTime{
        case "1" :
            date.hour = 08
            date.minute = 10
        case "2":
            date.hour = 09
            date.minute = 10
        case "3":
            date.hour = 10
            date.minute = 10
        case "4":
            date.hour = 11
            date.minute = 10
        case "5":
            date.hour = 13
            date.minute = 30
        case "6":
            date.hour = 14
            date.minute = 30
        case "7":
            date.hour = 15
            date.minute = 30
        case "8":
            date.hour = 16
            date.minute = 25
        case "9":
            date.hour = 17
            date.minute = 20
        case "10":
            date.hour = 18
            date.minute = 25
        case "11":
            date.hour = 19
            date.minute = 15
        case "12":
            date.hour = 20
            date.minute = 05
        case "13":
            date.hour = 20
            date.minute = 55
        default:
            date.hour = 21
            date.minute = 45
        }
        
        let newDate = Calendar.current.date(from: date)
        let addTime = Calendar.current.date(byAdding: .minute, value: -defaultTime, to: newDate!)
        date.hour = Calendar.current.component(.hour, from: addTime!)
        date.minute = Calendar.current.component(.minute, from: addTime!)
        print(date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let request = UNNotificationRequest(identifier: courseName+count, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler:{ _ in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "??????????????????", message: "?????????\(courseName)????????????????????????\n???????????????\(self.defaultTime)?????????????????????", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.superTableView?.present(alert, animated: true, completion: nil)
            }
        })
        
    }
    func removeAlertCourse(indentifier:String){
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [indentifier])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [indentifier])
        for i in Range(0...5){
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [indentifier+String(i)])
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [indentifier+String(i)])
        }
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "??????????????????", message: "?????????\(indentifier)??????????????????" , preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.superTableView?.present(alert, animated: true, completion: nil)
        }
    }
    
    
}

extension String {

    var length: Int {
        return self.string.count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)), upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
}

}
