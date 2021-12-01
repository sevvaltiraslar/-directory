//
//  DetailsViewController.swift
//  Kisiler
//
//  Created by SEVVAL on 18.11.2021.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController {

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var nameParentView: UIView!
    @IBOutlet weak var surnameParentView: UIView!
    @IBOutlet weak var birthdayParentView: UIView!
    @IBOutlet weak var emailParentView: UIView!
    @IBOutlet weak var numberParentView: UIView!
    @IBOutlet weak var noteParentView: UIView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var surnameText: UITextField!
    @IBOutlet weak var birthdayText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var numberText: UITextField!
    @IBOutlet weak var noteText: UITextView!
    
    var pickerView : UIDatePicker!
    var chosenPerson = ""
    var chosenId : UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupField()
        coreDataSetup()
        
        
    }
    
    
    func showAlert(message: String) {
        
        let alertView = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alertView.view.backgroundColor = .green
        alertView.view.layer.cornerRadius = 8
        self.present(alertView, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            alertView.dismiss(animated: true, completion: nil)
        })
    }
    
    func setupField() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let barItem = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(fieldAct))
        toolBar.setItems([barItem], animated: false)
        
        pickerView = UIDatePicker()
        pickerView.datePickerMode = .date
        
        birthdayText.inputAccessoryView = toolBar
        birthdayText.inputView = pickerView
    }
    
    @objc func fieldAct() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM.d.Y"
        dateFormatter.locale = Locale.current
        
        birthdayText.text = dateFormatter.string(from: pickerView.date)
        self.view.endEditing(true)
    }
    
    func fieldsAreOk() -> Bool {

        
        ///MARK: Field Kontrolleri
        
        let nameTextIsOk = nameText.text != ""
        let surnameTextIsOk = surnameText.text != ""
        let birthdayTextIsOk = birthdayText.text != ""
        let emailTextIsOk = emailText.text != ""
        let numberTextIsOk = numberText.text != ""
        let noteTextIsOk = noteText.text != ""
    
        nameParentView.layer.borderWidth = nameTextIsOk ? 0 : 2
        nameParentView.layer.borderColor = nameTextIsOk ? UIColor.white.cgColor : UIColor.red.cgColor
        
        surnameParentView.layer.borderWidth = surnameTextIsOk ? 0 : 2
        surnameParentView.layer.borderColor = surnameTextIsOk ? UIColor.white.cgColor : UIColor.red.cgColor
        
        birthdayParentView.layer.borderWidth = birthdayTextIsOk ? 0 : 2
        birthdayParentView.layer.borderColor = birthdayTextIsOk ? UIColor.white.cgColor : UIColor.red.cgColor
        
        emailParentView.layer.borderWidth = emailTextIsOk ? 0 : 2
        emailParentView.layer.borderColor = emailTextIsOk ? UIColor.white.cgColor : UIColor.red.cgColor
        
        numberParentView.layer.borderWidth = numberTextIsOk ? 0 : 2
        numberParentView.layer.borderColor = numberTextIsOk ? UIColor.white.cgColor : UIColor.red.cgColor
        
        noteParentView.layer.borderWidth = noteTextIsOk ? 0 : 2
        noteParentView.layer.borderColor = noteTextIsOk ? UIColor.white.cgColor : UIColor.red.cgColor
        
        /// MARK: Return değerleri
        return nameTextIsOk && surnameTextIsOk && emailTextIsOk && birthdayTextIsOk && numberTextIsOk && noteTextIsOk

    }
    
    @IBAction func saveUpdateClickedButton(_ sender: Any) {
        
        if chosenPerson == "" {
            // MARK: Ekleme Adımı
            if !fieldsAreOk() {
                showAlert(message: "Tüm Alanları Doldurun")
                return
            }
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let newPerson = NSEntityDescription.insertNewObject(forEntityName: "Person", into: context)
            newPerson.setValue(nameText.text ?? "", forKey: "name")
            newPerson.setValue(surnameText.text ?? "", forKey: "surname")
            
            newPerson.setValue(birthdayText.text ?? "", forKey: "birthdaydate")
            
            newPerson.setValue(emailText.text ?? "", forKey: "email")
            
            newPerson.setValue(numberText.text ?? "", forKey: "numberdisplay")
            
            newPerson.setValue(noteText.text ?? "", forKey: "note")
            newPerson.setValue(UUID(), forKey: "id")
            
            do {
                try context.save()
            } catch {
                print("Hata")
            }
            
            showAlert(message: "Kişi Başarıyla Eklendi")
        } else {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "Person", in: context)
            let request = NSFetchRequest<NSFetchRequestResult>()
            request.entity = entity
            let predicate = NSPredicate(format: "id = %@", chosenId?.uuidString ?? "")
            request.predicate = predicate
            do {
                let results = try context.fetch(request)
                let objectUpdate = results[0] as! NSManagedObject
                objectUpdate.setValue(nameText.text ?? "", forKey: "name")
                objectUpdate.setValue(surnameText.text ?? "", forKey: "surname")
                objectUpdate.setValue(birthdayText.text ?? "", forKey: "birthdaydate")
                objectUpdate.setValue(emailText.text ?? "", forKey: "email")
                objectUpdate.setValue(numberText.text ?? "", forKey: "numberdisplay")
                objectUpdate.setValue(noteText.text ?? "", forKey: "note")
                do {
                    try context.save()
                    
                } catch {
                    print("Hata")
                }
            } catch {
                print("Hata")
            }
            
            showAlert(message: "Kişi Başarıyla Güncellendi")
            
        }
        
        
        
        NotificationCenter.default.post(name: NSNotification.Name("newPerson"), object: nil) 
        self.navigationController?.popViewController(animated: true)
        
        
    }

}



extension DetailsViewController {
    fileprivate func coreDataSetup() {
        //veri çekme
        if chosenPerson != "" {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Person")
            let idString = chosenId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let name = result.value(forKey: "name") as? String {
                            nameText.text = name
                        }
                        if let surname = result.value(forKey: "surname") as? String {
                            surnameText.text = surname
                        }
                        if let birthday = result.value(forKey: "birthdaydate") as? String {
                            birthdayText.text = birthday
                        }
                        if let email = result.value(forKey: "email") as? String {
                            emailText.text = email
                        }
                        if let number = result.value(forKey: "numberdisplay") as? String {
                            numberText.text = number
                        }
                        if let note = result.value(forKey: "note") as? String {
                            noteText.text = note
                        }
                    }
                }
            } catch {
                print("Hata")
            }
            
        } else {
            nameText.text = ""
            surnameText.text = ""
            birthdayText.text = ""
            emailText.text = ""
            numberText.text = ""
            noteText.text = ""
        }
    }
    
    private func setupUI() {
        let inputs: [UIView] = [nameParentView, surnameParentView, birthdayParentView, emailParentView, numberParentView, noteParentView]
        inputs.map({ $0.layer.cornerRadius = 8 })
        
        saveButton.layer.cornerRadius = 25
        
    }
    
    
    
}


