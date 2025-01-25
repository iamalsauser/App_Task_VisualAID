//
//  TransactionsViewController.swift
//  MoneyPlant App
//
//  Created by admin86 on 06/11/24.
//

import UIKit

class TransactionsViewController: UIViewController, UISearchBarDelegate{
    
    @IBOutlet weak var noTransactionView: UIView!
    @IBOutlet weak var transactionsView: UIView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var leftChevronButton: UIButton!
    @IBOutlet weak var rightChevronButton: UIButton!
    
    @IBOutlet weak var accountBalanceLabel: UILabel!
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var expensesLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var numberofTransactions: Int = 0
    var currentMonth: Date = Date()
    var allTransactions: [Transaction] = []
    var filteredTransactions: [Transaction] = []
    var isSearching: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Document Directory: ", URL.documentsDirectory)
        searchBar.delegate = self
        loadTransactions()
        updateForCurrentMonth()
    }

    func loadTransactions() {
        allTransactions = PersistenceController.shared.fetchTransactions()
    }
    
    func updateForCurrentMonth() {
        if !isSearching {
            filteredTransactions = allTransactions.filter { transaction in
                Calendar.current.isDate(transaction.date, equalTo: currentMonth, toGranularity: .month)
            }
        }
        updateTableView()
        updateMonthLabel()
        updateChevronStates()
        updateFinancialSummary()
    }
    
    func updateTableView() {
        print("Entered Update Table View function....")
            
        numberofTransactions = filteredTransactions.count
        print("Number of transactions for current month: \(numberofTransactions)")

        noTransactionView.isHidden = numberofTransactions != 0
        transactionsView.isHidden = numberofTransactions == 0
            
        if let containerVC = children.last as? TransactionsTableViewController {
            print("Updating TransactionList in the TransactionView...")
            containerVC.transactionsList = filteredTransactions
            containerVC.transactionsTableView.reloadData()
        }
    }
    
    func updateMonthLabel() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM yyyy"
        monthLabel.text = dateFormatter.string(from: currentMonth)
    }
        
    func updateChevronStates() {
        let isCurrentMonth = Calendar.current.isDate(currentMonth, equalTo: Date(), toGranularity: .month)
        rightChevronButton.isEnabled = !isCurrentMonth
    }
    
    @IBAction func didTapLeftChevron(_ sender: UIButton) {
        guard let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) else { return }
        currentMonth = previousMonth
        updateForCurrentMonth()
    }
        
    @IBAction func didTapRightChevron(_ sender: UIButton) {
        guard let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) else { return }
        
        currentMonth = nextMonth
        updateForCurrentMonth()
        
        updateChevronStates()
    }
    
    func updateFinancialSummary() {
        let totalIncome = filteredTransactions.filter { $0.type == "Income" }
                                              .reduce(0.0) { $0 + $1.amount }
        
        let totalExpenses = filteredTransactions.filter { $0.type == "Expense" }
                                                .reduce(0.0) { $0 + $1.amount }
        
        guard let account = PersistenceController.shared.fetchAccount() else {
            print("No account found. Cannot calculate financial summary.")
            return
        }
        let initialBalance = 0.0
        
        let accountBalance = initialBalance + totalIncome - totalExpenses
        
        accountBalanceLabel.text = String(format: "₹ %.2f", accountBalance)
        incomeLabel.text = String(format: "₹ %.2f", totalIncome)
        expensesLabel.text = String(format: "₹ %.2f", totalExpenses)
    }
    
    // MARK: - UISearchBarDelegate Methods
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            updateForCurrentMonth()
        } else {
            isSearching = true
            filteredTransactions = allTransactions.filter { transaction in
                transaction.description.lowercased().contains(searchText.lowercased())
            }
            updateTableView()
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        updateForCurrentMonth()
    }

    @IBAction func didTapFilterButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "Filter Transactions", message: "Select a category to filter", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "All", style: .default, handler: { _ in
            self.filterTransactions(by: nil)
        }))
        alert.addAction(UIAlertAction(title: "Income", style: .default, handler: { _ in
            self.filterTransactions(by: "Income")
        }))
        alert.addAction(UIAlertAction(title: "Expense", style: .default, handler: { _ in
            self.filterTransactions(by: "Expense")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }

    func filterTransactions(by type: String?) {
        if let type = type {
            filteredTransactions = allTransactions.filter { $0.type == type && Calendar.current.isDate($0.date, equalTo: currentMonth, toGranularity: .month) }
        } else {
            // No filter applied
            filteredTransactions = allTransactions.filter { Calendar.current.isDate($0.date, equalTo: currentMonth, toGranularity: .month) }
        }
        
        // Update search results if searching
        if isSearching, let searchBarText = searchBar.text, !searchBarText.isEmpty {
            filteredTransactions = filteredTransactions.filter { $0.description.localizedCaseInsensitiveContains(searchBarText) }
        }
        updateTableView()
    }
    
    @IBAction func unwindToTransactionsTableView(segue: UIStoryboardSegue){
        guard segue.identifier == "saveUnwind",
              let sourceVC = segue.source as? AddNewRecordTableViewController, let transaction = sourceVC.transaction else { return }
        
        if let transactionsVC = children.last as? TransactionsTableViewController{
            if let indexPath = transactionsVC.transactionsTableView.indexPathForSelectedRow{
                print("Old transaction: \(transactionsVC.transactionsList[indexPath.row])")
                let updateTransaction = transactionsVC.transactionsList[indexPath.row]
                PersistenceController.shared.updateTransaction(transaction: updateTransaction, paidTo: transaction.paidTo, amount: transaction.amount, date: transaction.date, note: transaction.note)
                print("Updated to: \(transactionsVC.transactionsList[indexPath.row])")
                print("Transactions list updated...")
                
            }else{
                print("Adding new transaction...")
                print("Transaction data in TransactionsVC: \(String(describing: transaction))")
                PersistenceController.shared.addTransaction(transaction)
                let newIndexPath = IndexPath(row: transactionsVC.transactionsList.count, section: 0)
                transactionsVC.transactionsList.insert(transaction, at: 0)
            }
            transactionsVC.transactionsTableView.reloadData()
        }
        print("unWindToTransactionsTableView called...")
        loadTransactions()
        updateForCurrentMonth()
        print("Update for current month called.....")
    }
}
