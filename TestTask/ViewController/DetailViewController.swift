//
//  DetailViewController.swift
//  TestTask
//
//  Created by Александр Смородов on 20.08.17.
//  Copyright © 2017 Александр. All rights reserved.
//

import UIKit
import MessageUI

class DetailViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    var person: Person? = nil
    
    @IBOutlet weak var ScrollView: UIScrollView!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var surnameLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var streetLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var postcodeLabel: UILabel!
    @IBOutlet weak var emailLabel: UIButton!
    @IBOutlet weak var phoneLabel: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        activityIndicator.startAnimating()
        
        let searchURL = URL(string: person!.iconL)
        URLSession.shared.dataTask(with: searchURL!) { data, response, error in
            if error != nil {
                print(error!)
                DispatchQueue.main.sync() {
                    self.activityIndicator.stopAnimating()
                    self.showDisconnectAlert()
                }
            } else {
                guard let data = data, error == nil else { return }
                DispatchQueue.main.sync() {
                    self.iconView.image = UIImage(data: data)!
                    self.activityIndicator.stopAnimating()
                }
            }
            }.resume()
        
        let dateString = person!.birthday
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateObj = dateFormatter.date(from: dateString)
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        nameLabel.text = person!.name
        surnameLabel.text = person!.surname
        birthdayLabel.text = dateFormatter.string(from: dateObj!)
        streetLabel.text = person!.location.street
        cityLabel.text = person!.location.city
        stateLabel.text = person!.location.state
        postcodeLabel.text = String(person!.location.postcode)
        emailLabel.setTitle(person!.email, for: .normal)
        phoneLabel.setTitle(person!.phone, for: .normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendEmail(_ sender: Any) {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients([person!.email])
        mailComposerVC.setSubject("Hello, " + person!.name)
        
        return mailComposerVC
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func callNumber(_ sender: Any) {
        let clearNumberPhone = person!.phone.components(separatedBy:
            CharacterSet
                .decimalDigits
                .inverted)
            .joined(separator: "")
        
        if let phoneCallURL:NSURL = NSURL(string:"tel://"+"\(clearNumberPhone)") {
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL as URL)) {
                application.openURL(phoneCallURL as URL);
            } else {
                self.showErrorCallAlert()
            }
        }
    }
}
