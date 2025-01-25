//
//  OnboardingViewController.swift
//  MoneyPlant App
//
//  Created by admin86 on 19/11/24.
//

import UIKit

class OnboardingViewController: UIViewController {

    
    var cells: [OnboardingCell] = [
        OnboardingCell(title: "Welcome", description: "Your First interaction as a tenant with the application", image: UIImage(systemName: "square.and.pencil.circle.fill")!),
        OnboardingCell(title: "Detailed Description", description: "Tenant policy with approval", image: UIImage(systemName: "rectangle.grid.2x2.fill")!),
//        OnboardingCell(title: "Track Your Growth", description: "Watch your interactive plant flourish as you manage your finances effectively.", image: UIImage(systemName: "leaf.circle.fill")!),
        OnboardingCell(title: "Meaningful Insights", description: "Visual summaries help you understand your spending.", image: UIImage(systemName: "chart.pie.fill")!)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func continueButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
extension OnboardingViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cells.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OnboardingCollectionViewCell", for: indexPath) as! OnboardingCollectionViewCell
        
        cell.setup(cells[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 361, height: 120)
    }
    
}
