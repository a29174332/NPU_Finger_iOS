//
//  DashBoardViewController.swift
//  NPU_Life
//
//  Created by BigAnna on 2021/7/22.
//

import UIKit
import LocalAuthentication
import SafariServices
import SwiftyJSON
import Photos
import PhotosUI

class DashBoardViewController: UIViewController {
    var user = User()
    var loadSettings = newSettings()
    var dataView : ShowDataViewController?
    var newsView : newNewsTableViewController?
    var dataType:DataType?
    var nowWeather:Weather = Weather()
    var timer = Timer()
    let formatter = DateFormatter()

    var todayDate:String = ""
    var nowTime:Int = 0
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var downView: UIView!
    @IBOutlet weak var stdidLabel: UILabel!
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var settingButton: UIButton!
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.newsView?.dashVC = self
        self.getWeather()
        let pressGesture = UILongPressGestureRecognizer(target: self, action: #selector(changePhoto))
        self.imageButton.addGestureRecognizer(pressGesture)
        formatter.dateFormat = "yyyy-MM-dd"
        todayDate = formatter.string(from: Date())
        formatter.dateFormat = "HH"
        nowTime = Int(formatter.string(from: Date()))!
        let settingImage = UIImage(named: "SETTINGIMG")!.withRenderingMode(.alwaysTemplate)
        settingButton.setImage(settingImage, for: .normal)
        settingButton.tintColor = .white
        
        
        downView.layer.masksToBounds = true
        downView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        nameLabel.text = "??????"+user.name
        stdidLabel.text = user.stdid
        classLabel.text = user.Class
        
        if user.name != "????????????"{
            if UserDefaults.standard.object(forKey: "LOCAL_AUTH_ON") == nil {
                let localAuthAlert = UIAlertController(title: "????????????????????????????????????", message: "???????????????????????????", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "?????????", style: .default, handler: {
                    _ in
                    self.localAuth()
                })
                localAuthAlert.addAction(UIAlertAction(title: "?????????", style: .destructive, handler: {
                    _ in
                    self.loadSettings.updateSetting(LOCALAUTH: false, AUTOUPDATE: self.loadSettings.AUTO_UPDATE,DASHBOARD_WEATHER: self.loadSettings.DASHBOARD_WEATHER)
                }))
                localAuthAlert.addAction(okAction)
                DispatchQueue.main.async {
                    self.present(localAuthAlert, animated: true, completion: nil)
                }
            }else if UserDefaults.standard.object(forKey: "UPDATE1.3") == nil{
                self.showMessage(title: "?????????????????????", message: "???????????????????????????\n??????iPhone13??????\n???iOS15????????????\n????????????????????????")
                UserDefaults.standard.set("updated", forKey: "UPDATE1.3")
            }
            if UserDefaults.standard.object(forKey: "profile\(self.user.stdid)") != nil{
                let profilePhoto = (UserDefaults.standard.object(forKey: "profile\(self.user.stdid)") as? Data)!
                let mySaveImage = UIImage(data: profilePhoto)!
                self.imageButton.setImage(mySaveImage, for: .normal)
            }
        }
        if loadSettings.DASHBOARD_WEATHER {
            imageButton.isHidden = true
            weatherIcon.isHidden = false
            weatherLabel.isHidden = false
        }else{
            weatherIcon.isHidden = true
            weatherLabel.isHidden = true
            imageButton.isHidden = false
        }
        
        if let AUTOUPDATE = UserDefaults.standard.object(forKey: "AUTO_UPDATE") as? Bool{
            if AUTOUPDATE == true {
                checkUpdate()
            }
        }
    }
    
    @objc
    func changeWeatherSts(){
        switch self.nowWeather.times{
        case 1:
            self.nowWeather.times = 2
            self.weatherLabel.text = "\(self.nowWeather.nowDescri)"
            break
        case 2:
            self.nowWeather.times = 3
            self.weatherLabel.text = "????????????\(self.nowWeather.avgTemp)???"
            break
        case 3:
            self.nowWeather.times = 1
            self.weatherLabel.text = "????????????\(self.nowWeather.rainPer)%"
        default:
            return
        }
    }
    
    @objc func changePhoto(){
        let myChangeAlert = UIAlertController(title: "???????????????", message:nil, preferredStyle: .actionSheet)
        myChangeAlert.addAction(UIAlertAction(title: "??????????????????", style: .default, handler: {
            _ in
            self.selectPhoto()
        }))
        myChangeAlert.addAction(UIAlertAction(title: "???????????????", style: .cancel, handler: nil))
        self.present(myChangeAlert, animated: true, completion: nil)
    }
    
    func checkUpdate(){
        let url = URL(string:"https://app.npu.edu.tw/api/ckeckVersion")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let newURL = URLSession(configuration: .default)
        let myTask = newURL.dataTask(with: request, completionHandler: {
            (data,respond,error) in
            if error != nil {
                let myErrorCode = (error! as NSError).code
                var errorMsg = ""
                switch myErrorCode {
                case -1009:
                    errorMsg = "?????????????????????????????????\n???????????????????????????"
                case -1004:
                    errorMsg = "?????????????????????????????????\n??????????????????\n????????????????????????????????????"
                default:
                    errorMsg = "?????????????????????????????????????????????????????????!"
                }
                DispatchQueue.main.async {
                    self.showMessage(title: "?????????", message: errorMsg)
                }
                return
            }else if let response = respond as? HTTPURLResponse{
                if response.statusCode == 500{
                    DispatchQueue.main.async {
                        self.showMessage(title: "????????????", message: "????????????????????????\n????????????????????????\n??????????????????????????????????????????\n????????????")
                        return
                    }
                }
            }
            let myData = JSON(data!)
            if myData["iOS"].string! != "1.3.1" && myData["iOS"].string! != "1.4.0"{
                DispatchQueue.main.async {
                    let updateAlert = UIAlertController(title: "??????????????????", message: "????????????????????????????????????????????????", preferredStyle: .alert)
                    updateAlert.addAction(UIAlertAction(title: "?????????", style: .default, handler: {
                        _ in
                        let updateURL = URL(string: myData["URL"].string!)!
                        UIApplication.shared.open(updateURL)
                    }))
                    updateAlert.addAction(UIAlertAction(title: "?????????", style: .cancel, handler: nil))
                    self.present(updateAlert, animated: true, completion: nil)
                }
            }
            
        })
        myTask.resume()
        
    }
    
    @IBAction func settingButton(_ sender: UIButton) {
        if user.name == "????????????"{
            self.showMessage(title: "??????", message: "???????????????????????????????????????")
            return
        }
        if let settingsView = self.storyboard?.instantiateViewController(identifier: "settings") as? SettingsTableViewController{
            settingsView.modalPresentationStyle = .pageSheet
            settingsView.settings = loadSettings
            self.present(settingsView, animated: true, completion: nil)
        }
    }
    
    @IBAction func calendarVC(_ sender: UIButton) {
        performSegue(withIdentifier: "goCalendat", sender: nil)
    }
    

    
    @IBAction func showData(_ sender: UIButton) {
        if user.name == "????????????"{
            self.showMessage(title: "??????", message: "??????????????????????????????")
            return
        }
        
        switch sender.tag {
        case 0:
            dataType = .Score
        case 1:
            dataType = .NoShow
        case 2:
            dataType = .Reward
        default:
            return
        }
        performSegue(withIdentifier: "showData", sender: nil)
    }
    

    
    @IBAction func showGread(_ sender: FancyButton) {
        if user.name == "????????????"{
            self.showMessage(title: "??????", message: "??????????????????????????????")
            return
        }
        performSegue(withIdentifier: "showGread", sender: nil)
    }
    @IBAction func goCourseTable(_ sender: UIButton) {
        if user.name == "????????????"{
            self.showMessage(title: "??????", message: "???????????????????????????????????????")
            return
        }
        performSegue(withIdentifier: "courseTable", sender: nil)
    }
    
    @IBAction func callEmergency(_ sender: Any) {
        let callController = UIAlertController(title: "??????", message: "????????????????????????????????????", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "??????", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "?????????", style: .destructive, handler: {
            _ in
            let phoneURL = URL(string: "tel://0928483123")!
            if UIApplication.shared.canOpenURL(phoneURL) {
                UIApplication.shared.open(phoneURL)
            }
        })
        callController.addAction(cancelAction)
        callController.addAction(okAction)
        present(callController, animated: true, completion: nil)
    }
    
    
    @IBAction func logout(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func showMessage(title: String?, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func localAuth(){
        let context = LAContext()
        context.localizedCancelTitle = "??????"
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            if error != nil{
                return
            }
            let reason = "??????????????????????????????"
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { (success, error) in
                if success {
                    DispatchQueue.main.async { [unowned self] in
                        showMessage(title: "???????????????", message: "??????????????????????????????")
                        loadSettings.updateSetting(LOCALAUTH: true, AUTOUPDATE: self.loadSettings.AUTO_UPDATE,DASHBOARD_WEATHER:  self.loadSettings.DASHBOARD_WEATHER)
                    }
                } else {
                    self.showMessage(title: "??????", message: "???????????????????????????????????????")
                }
            }
        } else {
            showMessage(title: "??????", message: "???????????????????????????????????????")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "courseTable"{
            let courseTableView = segue.destination as? CourseTableViewController
            courseTableView?.user = self.user
        }else if segue.identifier == "showData"{
            dataView = segue.destination as? ShowDataViewController
            dataView?.myUser = self.user
            dataView?.dataType = self.dataType
        }else if segue.identifier == "showGread"
        {
            let greadView = segue.destination as? GreaduateViewController
            greadView?.myUser = self.user
        }
        let backItem = UIBarButtonItem()
        backItem.title = "??????"
        backItem.tintColor = .white
        navigationItem.backBarButtonItem = backItem
    }
    
    func getWeather(){
        let url = URL(string:"https://opendata.cwb.gov.tw/api/v1/rest/datastore/F-D0047-047?Authorization=CWB-F65EF798-C1B9-4E6A-9192-59B1D77691CC&limit=1&offset=0&format=JSON&locationName=%E9%A6%AC%E5%85%AC%E5%B8%82&elementName=PoP12h&elementName=T,Wx&timeFrom=\(todayDate)T00%3A00%3A00&timeTo=\(todayDate)T24%3A00%3A00")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let newURL = URLSession(configuration: .default)
        let myTask = newURL.dataTask(with: request, completionHandler: {
            (data,respond,error) in
            if error != nil {
                let myErrorCode = (error! as NSError).code
                var errorMsg = ""
                switch myErrorCode {
                case -1009:
                    errorMsg = "?????????????????????????????????\n???????????????????????????"
                case -1004:
                    errorMsg = "?????????????????????????????????\n??????????????????\n????????????????????????????????????"
                default:
                    errorMsg = "?????????????????????????????????????????????????????????!"
                }
                DispatchQueue.main.async {
                    self.showMessage(title: "?????????", message: errorMsg)
                }
                return
            }else if let response = respond as? HTTPURLResponse{
                if response.statusCode == 500{
                    DispatchQueue.main.async {
                        self.showMessage(title: "????????????", message: "????????????????????????\n??????????????????????????????\n??????????????????????????????????????????\n????????????")
                        return
                    }
                }
            }
            let myData = JSON(data!)
            if myData["success"].string! == "true"{
                var dayNight = 0
                var dayString = "D"
                if self.nowTime >= 18{
                    dayString = "N"
                    dayNight = 1
                }
                self.nowWeather.avgTemp = myData["records"]["locations"][0]["location"][0]["weatherElement"][1]["time"][dayNight]["elementValue"][0]["value"].string!
                self.nowWeather.nowDescri = myData["records"]["locations"][0]["location"][0]["weatherElement"][2]["time"][dayNight]["elementValue"][0]["value"].string!
                self.nowWeather.wxNum = myData["records"]["locations"][0]["location"][0]["weatherElement"][2]["time"][dayNight]["elementValue"][1]["value"].string!
                self.nowWeather.rainPer = myData["records"]["locations"][0]["location"][0]["weatherElement"][0]["time"][dayNight]["elementValue"][0]["value"].string!
                DispatchQueue.main.async {
                    self.changeImage(dayNight:dayString)
                    self.changeWeatherSts()
                    self.timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.changeWeatherSts), userInfo: nil, repeats: true)
                }
            }else{
                DispatchQueue.main.async {
                    self.showMessage(title: "??????", message: "?????????????????????????????????????????????????????????")
                }
            }
            
        })
        myTask.resume()
    }
    
    func changeImage(dayNight:String){
        self.weatherIcon.image = UIImage(named: "\(dayNight)\(self.nowWeather.wxNum)")
    }
}

extension DashBoardViewController : UIImagePickerControllerDelegate , UINavigationControllerDelegate {

    func selectPhoto(){
        checkAuth()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let myImage = info[.editedImage] as? UIImage
        let imageData = myImage?.jpegData(compressionQuality: 1.0)
        if imageData != nil {
            UserDefaults.standard.setValue(imageData, forKey: "profile\(self.user.stdid)")
        }
        self.dismiss(animated: true, completion: nil)
        DispatchQueue.main.async {
            self.imageButton.setImage(myImage, for: .normal)
        }
        
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func checkAuth(){
        let photoLibraryStatus = PHPhotoLibrary.authorizationStatus()
        switch photoLibraryStatus {
        case .denied:
            let alertController = UIAlertController(title: "?????????", message: "????????????????????????????????????\n????????????????????????", preferredStyle: .alert)
            let settingAction = UIAlertAction(title: "??????", style: .default, handler: { (action) in
                let url = URL(string: UIApplication.openSettingsURLString)
                    if let url = url, UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
            })
            alertController.addAction(UIAlertAction(title: "?????????", style: .cancel, handler: nil))
            alertController.addAction(settingAction)
            self.present(alertController, animated: true, completion: nil)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (statusFirst) in
                switch statusFirst {
                case .denied:
                    let alertController = UIAlertController(title: "?????????", message: "????????????????????????????????????\n????????????????????????", preferredStyle: .alert)
                    let settingAction = UIAlertAction(title: "??????", style: .default, handler: { (action) in
                        let url = URL(string: UIApplication.openSettingsURLString)
                            if let url = url, UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url)
                            }
                    })
                    alertController.addAction(UIAlertAction(title: "?????????", style: .cancel, handler: nil))
                    alertController.addAction(settingAction)
                    DispatchQueue.main.async {
                        self.present(alertController, animated: true, completion: nil)
                    }
                default:
                    return
                }
            })
        case .authorized:
            let controller = UIImagePickerController()
            controller.delegate = self
            controller.sourceType = .photoLibrary
            controller.allowsEditing = true
            self.present(controller, animated: true, completion: nil)
        default:
            let alertController = UIAlertController(title: "?????????", message: "????????????????????????????????????\n????????????????????????", preferredStyle: .alert)
            let settingAction = UIAlertAction(title: "??????", style: .default, handler: { (action) in
                let url = URL(string: UIApplication.openSettingsURLString)
                    if let url = url, UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
            })
            alertController.addAction(UIAlertAction(title: "?????????", style: .cancel, handler: nil))
            alertController.addAction(settingAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

