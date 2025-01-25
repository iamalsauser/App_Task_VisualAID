//
//  UserDashboardViewController.swift
//  MoneyPlant App
//
//  Created by admin17 on 25/01/25.
//

import UIKit

class UserDashboardViewController: UIViewController {
    
    @IBOutlet weak var userNameLbl: UILabel!
    
    @IBOutlet weak var tenantSelectedLbl: UILabel!
    
    @IBOutlet weak var profileImage: UIImageView!

    var user: Account?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("User: ", user?.name as Any)
        // Do any additional setup after loading the view.
    }
    
    func setUpUI(){
        
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
