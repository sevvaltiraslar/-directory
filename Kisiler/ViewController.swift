//
//  ViewController.swift
//  Kisiler
//
//  Created by SEVVAL on 18.11.2021.
//

struct NameModel {
    let name: String
    let uuid: UUID
    let surname: String
    let birthday: String
    let number: String
    let email: String
    let note: String
}

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchText: UITextField!
    var realArray: [NameModel] = []
    var filteredArray: [NameModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchText.delegate = self
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        
        getData()
     
        
        searchText.leftViewMode = UITextField.ViewMode.always
        /*let imageView = UIImageView(frame: CGRect(x: 42, y:149.64, width: 15.4, height: 15.4))
        let image = UIImage(named: "search")
        imageView.image = image
        searchText.leftView = imageView*/
        searchText.layer.cornerRadius = 8.0
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "newPerson"), object: nil)
    }
    
    @objc func getData() {
        realArray.removeAll(keepingCapacity: false)
        filteredArray.removeAll(keepingCapacity: false)
        
        let appDelagate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelagate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Person")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(fetchRequest)
            if results.count > 0 {
                for result in results as! [NSManagedObject]{
                    var newName = ""
                    var newSurname = ""
                    var newBirthday = ""
                    var newEmail = ""
                    var newNumber = ""
                    var newNote = ""
                    var uuid: UUID!
                    if let name = result.value(forKey: "name") as? String {
                        newName = name
                    }
                    if let surname = result.value(forKey: "surname") as? String {
                        newSurname = surname
                    }
                    if let birthday = result.value(forKey: "birthdaydate") as? String {
                        newBirthday = birthday
                    }
                    if let email = result.value(forKey: "email") as? String {
                        newEmail = email
                    }
                    if let number = result.value(forKey: "numberdisplay") as? String {
                        newNumber = number
                    }
                    if let note = result.value(forKey: "note") as? String {
                        newNote = note
                    }
                    if let id = result.value(forKey: "id") as? UUID {
                        uuid = id
                    }
                    let total = NameModel(name: newName, uuid: uuid, surname: newSurname, birthday: newBirthday, number: newNumber, email: newEmail, note: newNote)
                    realArray.append(total)
                    
                }
            }
            
            alphabetical()
            self.tableView.reloadData()
        } catch {
            print("Hata")
        }
        
    }
    
    func alphabetical() {
        realArray = realArray.sorted(by: {$0.name.lowercased() < $1.name.lowercased()})
        filteredArray = realArray
    }
    
    @objc func addButtonClicked() {
        let destinationVC =  DetailsViewController.instantiate(storyboard: .main, bundle: nil, identifier: nil)
        destinationVC.chosenPerson = ""
        navigationController?.pushViewController(destinationVC, animated: true)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! Cell
        cell.nameLabel.text = realArray[indexPath.row].name + " " + realArray[indexPath.row].surname
        cell.birthdayLabel.text = realArray[indexPath.row].birthday
        cell.emailLabel.text = realArray[indexPath.row].email
        cell.numberLabel.text = realArray[indexPath.row].number
        cell.noteLabel.text = realArray[indexPath.row].note
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let destinationVC = DetailsViewController.instantiate(storyboard: .main, bundle: nil, identifier: nil)
        destinationVC.chosenId = filteredArray[indexPath.row].uuid
        destinationVC.chosenPerson = filteredArray[indexPath.row].name
        navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Person")
            let idString = filteredArray[indexPath.row].uuid.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let id = result.value(forKey: "id") as? UUID {
                            if id == filteredArray[indexPath.row].uuid {
                                context.delete(result)
                                filteredArray.remove(at: indexPath.row)
                                self.tableView.reloadData()
                                
                                do {
                                    try context.save()
                                } catch {
                                    print("Hata")
                                }
                                break
                            }
                        }
                    }
                }
            } catch {
                print("Hata")
            }
            
            
        }
    }

    
    
    @IBAction func searchChange(_ sender: Any) {
        var newArray: [NameModel] = []
        
        for member in realArray {
            if member.name.lowercased().contains(searchText.text ?? "") {
                newArray.append(member)
            }
        }
        
        if searchText.text ?? "" == "" {
            filteredArray = realArray
        } else {
            filteredArray = newArray
        }
        tableView.reloadData()
    }
    
}

