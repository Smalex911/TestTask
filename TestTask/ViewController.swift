//
//  ViewController.swift
//  TestTask
//
//  Created by Александр Смородов on 19.08.17.
//  Copyright © 2017 Александр. All rights reserved.
//

import UIKit

extension UIViewController {
    func popupErrorAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .cancel))
        self.present(alert, animated: true)
    }
    
    func showDisconnectAlert() {
        self.popupErrorAlert(
            title: "Ошибка загрузки данных",
            message: "Пожалуйста проверьте соединение с интернетом и попробуйте снова")
    }
    
    func showErrorCallAlert() {
        self.popupErrorAlert(
            title: "Ошибка выполнения звонка",
            message: "Пожалуйста проверьте настройки телефона и попробуйте снова")
    }
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var persons : [Person] = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        loadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITextFieldDelegate Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return persons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PersonTableViewCell
        
        cell.name.text = persons[indexPath.row].name
        cell.surname.text = persons[indexPath.row].surname
        cell.icon.image = persons[indexPath.row].icon
        
        //Загрузка выполняется быстрее, однако при разрывах соединения с интернетом пропадают изображения у некоторых людей
        //        let searchURL = URL(string: persons[indexPath.row].iconM)
        //        URLSession.shared.dataTask(with: searchURL!) { data, response, error in
        //            guard let data = data, error == nil else { return }
        //
        //            DispatchQueue.main.sync() {
        //
        //                cell.icon.image = UIImage(data: data)!
        //            }
        //        }.resume()
        
        return cell
    }
    
    // MARK: - UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset
        
        if deltaOffset <= 44 {
            loadData()
        }
    }
    
    var loadMoreStatus = false
    func loadData() {
        if ( !loadMoreStatus ) {
            self.loadMoreStatus = true
            self.activityIndicator.startAnimating()
            self.loadingView.isHidden = false
            loadDataBegin()
        }
    }
    
    func loadDataBegin() {
        DispatchQueue.global(qos: .default).async() {
            print("loading")
            Person.persons() { persons in
                DispatchQueue.main.async() {
                    self.persons += persons
                    self.tableView.reloadData()
                    self.loadMoreStatus = false
                    self.activityIndicator.stopAnimating()
                    self.loadingView.isHidden = true
                }
                
                if persons.count == 0 {
                    print("Ошибка загрузки данных")
                    self.showDisconnectAlert()
                }
            }
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPersonDetails" {
            
            let detailViewController = segue.destination
                as! DetailViewController
            
            let myIndexPath = self.tableView.indexPathForSelectedRow!
            detailViewController.person = persons[myIndexPath.row]
        }
    }
}
