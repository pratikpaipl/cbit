import UIKit
import UserNotifications
import M13Checkbox


class PopUpCell: UITableViewCell {
    
    @IBOutlet var chkvw: M13Checkbox?
    @IBOutlet var lbltitle: UILabel!
    @IBOutlet weak var lblsubtitle: UILabel!
    
}


class PassBookVC: UIViewController {
    //MARK: - Properties
  
    
    @IBOutlet var popupvw: UIView!
    @IBOutlet var tblpopup: UITableView!
    
    @IBOutlet weak var tablePassBook: UITableView!
    @IBOutlet weak var labelbalance: LabelComman!
    @IBOutlet weak var labelWinning: LabelComman!
    @IBOutlet weak var viewNoData: UIView!
    
    private var arrPassbook = [[String: Any]]()
    
 //   var filterarr = [String]()
    var DisplayValue = [[String: Any]]()
    var SavedIndex = [String]()
    
    var isfliparr = [Bool]()
    
    lazy  var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.handleRefresh(_:)), for: .valueChanged)
        refreshControl.tintColor = Define.APPCOLOR
        return refreshControl
    }()
    
    private var isRefresh = Bool()
    private var isShowLoading = Bool()
    
    var Start = 0
    var Limit = 20
    var ismoredata = false
    
    //MARK: - Default Method
    override func viewDidLoad() {
        super.viewDidLoad()
        tablePassBook.rowHeight = UITableView.automaticDimension
        tablePassBook.tableFooterView = UIView()
        tablePassBook.addSubview(refreshControl)
        
      //  UNUserNotificationCenter.current().delegate = self
        if !MyModel().isConnectedToInternet() {
            Alert().showTost(message: Define.ERROR_INTERNET,
                             viewController: self)
        } else {
            isShowLoading = true
            Start = 0
            arrPassbook = [[String:Any]]()
            getPassbookData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setWalletDetail()
    }
    
    func setWalletDetail() {
        
        let pbAmount = "\(Define.USERDEFAULT.value(forKey: "PBAmount")!)"
        guard let amountPB = Double(pbAmount) else {
            return
        }
        labelbalance.text = MyModel().getCurrncy(value: amountPB)
        
        let sbAmount = "\(Define.USERDEFAULT.value(forKey: "SBAmount")!)"
        guard let amountSB = Double(sbAmount) else {
            return
        }
        labelWinning.text = MyModel().getCurrncy(value: amountSB)
    }
    
    @objc func handleRefresh(_ refresh: UIRefreshControl) {
        setWalletDetail()
        if !MyModel().isLogedIn() {
            Alert().showTost(message: Define.ERROR_INTERNET, viewController: self)
        } else {
            isRefresh = true
            isShowLoading = false
            refreshControl.beginRefreshing()
            Start = 0
            arrPassbook = [[String:Any]]()
            tablePassBook.reloadData()
            self.getPassbookData()
        }
    }
    
    //MARK: - Button Method
    @IBAction func buttonBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func filter_click(_ sender: UIButton) {
        popupvw.isHidden = false
    }
    @IBAction func closepopup_click(_ sender: UIButton) {
        popupvw.isHidden = true
    }
    @IBAction func applyfilter_click(_ sender: UIButton) {
        popupvw.isHidden = true
        Start = 0
        arrPassbook = [[String:Any]]()
        getPassbookData()
    }
    @IBAction func clearfilter_click(_ sender: UIButton) {
        popupvw.isHidden = true
        SavedIndex = [String]()
        arrPassbook = [[String:Any]]()
        Start = 0
        getPassbookData()
    }
    
}
//MARK: - TableView Delegate
extension PassBookVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        
        if tableView == tablePassBook {
            return arrPassbook.count
        }
        else if tableView == tblpopup {
            return DisplayValue.count
        }
        
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tablePassBook {
            
        
        let passBookCell = tableView.dequeueReusableCell(withIdentifier: "PassBookTVC") as! PassBookTVC
        
        passBookCell.labelTransactionName.text = arrPassbook[indexPath.row]["title"] as? String ?? "No Name"
        passBookCell.labelData.text = "\(arrPassbook[indexPath.row]["date"] as? String ?? "00-00-0000")"
        passBookCell.labelTime.text = "\(arrPassbook[indexPath.row]["time"] as? String ?? "00:00")"
            
            let amount = arrPassbook[indexPath.row]["amount"] as? String ?? "0"
            let beforebalance = arrPassbook[indexPath.row]["beforebalance"] as? String ?? "0"
            
            var myMutableString = NSMutableAttributedString()
            myMutableString = NSMutableAttributedString(string: amount)
            myMutableString.setAttributes([NSAttributedString.Key.foregroundColor : UIColor.darkGray], range: NSRange(location:myMutableString.length-2,length:2)) // What ever range you want to give
            passBookCell.labelAmount.attributedText = myMutableString
            
            var myMutableString1 = NSMutableAttributedString()
            myMutableString1 = NSMutableAttributedString(string: beforebalance)
            myMutableString1.setAttributes([NSAttributedString.Key.foregroundColor : UIColor.darkGray], range: NSRange(location:myMutableString1.length-2,length:2)) // What ever range you want to give
            passBookCell.beforebalance.attributedText =  myMutableString1
        
        let strType = arrPassbook[indexPath.row]["type"] as? String ?? "subtract"
        if strType == "subtract" {
            passBookCell.imageTransaction.image = #imageLiteral(resourceName: "ic_recive")
            passBookCell.viewbefore.backgroundColor  = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        } else {
            passBookCell.imageTransaction.image = #imageLiteral(resourceName: "ic_send")
            passBookCell.viewbefore.backgroundColor  = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
        }
        
        let strTDS = "\(arrPassbook[indexPath.row]["tds"]!)"
        if strTDS == "0" {
            passBookCell.labelTDS.isHidden = true
            passBookCell.labelTDS.text = nil
        } else {
            passBookCell.labelTDS.isHidden = false
            MyModel().setGradient(view: passBookCell.labelTDS, startColor: #colorLiteral(red: 1, green: 0.3215686275, blue: 0.3215686275, alpha: 1), endColor: #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1))
            
//            if let amountTDS = Double(strTDS)  {
//               passBookCell.labelTDS.text = "TDS " + MyModel().getCurrncy(value: amountTDS)
//            } else {
                passBookCell.labelTDS.text = "TDS " + strTDS
            //}
            
        }
            passBookCell.lbldepositedt.text = "\(arrPassbook[indexPath.row]["dep_date"]!)"
            passBookCell.lbldepositetime.text = "\(arrPassbook[indexPath.row]["dep_time"]!)"
            passBookCell.lbltransactionid.text = "\(arrPassbook[indexPath.row]["transId"]!)"
            
            let RedeemFlag = "\(arrPassbook[indexPath.row]["RedeemFlag"]!)"
            
            if RedeemFlag == "1" {
                passBookCell.imgapprovedstamp.isHidden = false
                passBookCell.imggreentick.isHidden = false
            }
            else
            {
                passBookCell.imgapprovedstamp.isHidden = true
                passBookCell.imggreentick.isHidden = true
            }
            
            if isfliparr[indexPath.row]  {
                passBookCell.vwflip.isHidden = false
                passBookCell.vwnormal.isHidden = true
            }
            else
            {
                passBookCell.vwflip.isHidden = true
                passBookCell.vwnormal.isHidden = false
            }
            
            if arrPassbook.count > 1 {
                let lastElement = arrPassbook.count - 1
                if indexPath.row == lastElement && ismoredata{
                    //call get api for next page
                    getPassbookData()
                }

            }
        
        return passBookCell
        }
        else if tableView == tblpopup {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PopUpCell", for: indexPath) as! PopUpCell
//                    cell.chkvw?.markType = .checkmark
                    cell.chkvw?.boxType = .square
                    cell.chkvw?.tintColor = #colorLiteral(red: 0, green: 0.2535815537, blue: 0, alpha: 1)
                    cell.chkvw?.secondaryTintColor = #colorLiteral(red: 0.2176683843, green: 0.8194433451, blue: 0.2584097683, alpha: 1)
                    cell.chkvw?.tag = indexPath.row + 1
                    cell.chkvw?.addTarget(self, action: #selector(PassBookVC.checkboxValueChangedPopUp(_:)), for: .valueChanged)
            
            cell.lbltitle.text = "\(DisplayValue[indexPath.row]["display"] ?? "")"
     
                if SavedIndex.contains(String(indexPath.row+1)) {
                    cell.chkvw?.checkState = .checked
                }
                else
                {
                    cell.chkvw?.checkState = .unchecked
                }
            
            
             cell.selectionStyle = .none
            return cell
                      }
        return UITableViewCell()
    }
    
    @IBAction func checkboxValueChangedPopUp(_ sender: M13Checkbox) {
        print("TAG:",sender.tag)
        switch sender.checkState {
                 case .unchecked:
                    print("UnChecked")
                        if SavedIndex.contains((String(sender.tag))) {
                            let index = SavedIndex.firstIndex(of: (String(sender.tag)))!
                            SavedIndex.remove(at: index)
                        }
                     break
                 case .checked:
                     print("Checked")
                    SavedIndex.append(String(sender.tag))
                     break
                 case .mixed:
                     print("Mixed")
                     
                     break
                 }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView == tablePassBook {
            let cell = tableView.cellForRow(at: indexPath) as! PassBookTVC
            let RedeemFlag = "\(arrPassbook[indexPath.row]["RedeemFlag"]!)"
            if RedeemFlag != "1" {
                return
            }
            if isfliparr[indexPath.row]   {
                isfliparr[indexPath.row] = false
                cell.vwflip.isHidden = true
                cell.vwnormal.isHidden = false
                UIView.transition(with: cell.contentView, duration: 0.6, options: .transitionFlipFromLeft, animations: {() -> Void in
                    cell.contentView.insertSubview(cell.vwnormal, aboveSubview: cell.vwflip)
                    }, completion: {(_ finished: Bool) -> Void in
                    })
            }
            else
            {
        
                
                cell.vwflip.isHidden = false
                cell.vwnormal.isHidden = true
                isfliparr[indexPath.row] = true
                UIView.transition(with: cell.contentView, duration: 0.6, options: .transitionFlipFromRight, animations: {() -> Void in
                    cell.contentView.insertSubview(cell.vwflip, aboveSubview: cell.vwnormal)
                   }, completion: {(_ finished: Bool) -> Void in
                   })
            }
        }
        
    }
}

//MARK: - API
extension PassBookVC {
    func getPassbookData() {
        if isShowLoading {
            Loading().showLoading(viewController: self)
        }
        let strURL = Define.APP_URL + Define.API_PASSBOOK
        
        print("URL: \(strURL)")
        var descr = String()
        if SavedIndex.count > 0 {
            
            for i in SavedIndex {
                let WeekID = DisplayValue[Int(i)!-1]["value"]
                
                descr.append("\(WeekID ?? ""),")
            }
          
            descr.removeLast(1)
        }
      
        let parameter: [String: Any] = [
            "filter":descr,"start": Start,"limit":Limit
        ]
        
        print("parameter: \(parameter)")
        
        
        SwiftAPI().postMethodSecure(stringURL: strURL,
                                    parameters: parameter,
                                    header: Define.USERDEFAULT.value(forKey: "AccessToken") as? String,
                                    auther: Define.USERDEFAULT.value(forKey: "UserID") as? String)
        { (result, error) in
            if error != nil {
                if self.isRefresh {
                    self.isRefresh = false
                    self.refreshControl.endRefreshing()
                }
                
                Loading().hideLoading(viewController: self)
                print("Error: \(error!)")
                //self.retry()
                self.getPassbookData()
            } else {
                if self.isRefresh {
                    self.isRefresh = false
                    self.refreshControl.endRefreshing()
                }
                
                Loading().hideLoading(viewController: self)
                print("Result: \(result!)")
                let status = result!["statusCode"] as? Int ?? 0
                if status == 200 {
                  //  self.arrPassbook = result!["content"] as! [[String: Any]]
                 //   self.filterarr = result!["DropDown"] as? [String] ?? []
                    self.DisplayValue = result!["DisplayValuess"] as! [[String: Any]]
                    let arr =  result!["content"] as! [[String : Any]]
                      if arr.count > 0 {
                          self.arrPassbook.append(contentsOf: arr)
                          self.ismoredata = true
                          self.Start = self.Start + 10
                        for _ in self.arrPassbook {
                            self.isfliparr.append(false)
                        }
                      }
                      else
                      {
                          self.ismoredata = false
                      }
                    if self.arrPassbook.count == 0 {
                        self.viewNoData.isHidden = false
                    } else {
                        self.viewNoData.isHidden = true
                    }
                    self.tablePassBook.reloadData()
                    self.tblpopup.reloadData()
                    
                } else if status == 401 {
                    Define.APPDELEGATE.handleLogout()
                } else {
                    Alert().showAlert(title: "Error",
                                      message: result!["message"] as! String,
                                      viewController: self)
                }
            }
        }
    }
}

//MARK: - Notifcation Delegate Method
//extension PassBookVC: UNUserNotificationCenterDelegate {
//    func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                willPresent notification: UNNotification,
//                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        completionHandler([.alert, .sound])
//    }
//    func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                didReceive response: UNNotificationResponse,
//                                withCompletionHandler completionHandler: @escaping () -> Void) {
//        switch response.actionIdentifier {
//        case Define.PLAYGAME:
//            print("Play Game")
//            let dictData = response.notification.request.content.userInfo as! [String: Any]
//            print(dictData)
//            let gamePlayVC = self.storyboard?.instantiateViewController(withIdentifier: "GamePlayVC") as! GamePlayVC
//            gamePlayVC.isFromNotification = true
//            gamePlayVC.dictContest = dictData
//            self.navigationController?.pushViewController(gamePlayVC, animated: true)
//        default:
//            break
//        }
//        
//    }
//}

//MARK: - Alert Contollert
extension PassBookVC {
    func retry() {
        let alertController = UIAlertController(title: Define.ERROR_TITLE,
                                                message: Define.ERROR_SERVER,
                                                preferredStyle: .alert)
        let buttonRetry = UIAlertAction(title: "Retry",
                                        style: .default)
        { _ in
            self.getPassbookData()
        }
        let cancel = UIAlertAction(title: "Cancel",
                                   style: .cancel,
                                   handler: nil)
        alertController.addAction(cancel)
        alertController.addAction(buttonRetry)
        self.present(alertController,
                     animated: true,
                     completion: nil)
    }
}
