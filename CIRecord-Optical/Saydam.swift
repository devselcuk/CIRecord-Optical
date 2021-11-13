//
//  Saydam.swift
//  CIRecord-Optical
//
//  Created by MacMini on 23.10.2021.
//

import UIKit


enum UsageTime : String, Codable, Hashable {
    case day = "Daily"
    case month = "Monthly"
}

enum OpticState : Int,CaseIterable, Codable, Hashable {
    case  current,new,used
    
 
}

struct Optic : Codable , Hashable {
    let id : UUID
    let name : String
    let usageTime : UsageTime
    let degree : Double
    var state : OpticState = .new
    
    var additionDate : Date?
    
    mutating func startUsing() {
        self.state = OpticState.current
     }
     
     mutating func throwAways() {
         self.state = OpticState.used
     }
    
    
    var stateButtonTitle :  String {
        switch state {
            
        case .new:
            return "Start Using"
        case .current:
            return "Remove This Pair"
        case .used:
            return "Expired"
        }
    }
    
    var buttonStated : UIButton.State {
        switch state {
        case .used :
            return .disabled
        default :
            return .normal
            
        }
    }
    
    
    @available(iOS 15.0, *)
    var buttonColor : UIColor {
        switch state {
        case .new:
            return .systemMint
        case .current:
            return .systemRed
        case .used:
            return .systemGray2
        }
    }
    
    @available(iOS 13.0, *)
    var backGroundCl : UIColor {
        switch state {
        case .new:
            return .systemGray6
        case .current:
            return .systemBlue
        case .used:
            return .darkGray
        }
    }
    
    
    
    
    var numberOfDaysLeft : Int {
        
        let now = Date()
        
        guard let additionDate = additionDate else {
            return self.state == .new ? 30 : 0
        }

        guard let expirationDate = Calendar.current.date(byAdding: .day, value: usageTime == .month ? 30 : 1, to: additionDate) else { return 0}
        
        let difference = Calendar.current.dateComponents([.day], from: now, to: expirationDate)
        
        return difference.day ?? 0
        
        
    }
    
    var title : String {
        switch state {
        case .new:
            return "New"
        case .current:
            return "Currently using"
        case .used:
            return "Expired"
        }
    }
    
    
}




class LensWorld {
    
    
//    var isDebug : Bool
    
    
    
    
//    init(isDebug : Bool) {
//        self.isDebug = isDebug
//        guard isDebug else { return }
//        let lenses = [Optic(name: "Baush&Laumbs", usageTime: .month, degree: -20, state : .current, additionDate: Date()), Optic(name: "Toyota", usageTime: .month, degree: 2.0, additionDate: Calendar.current.date(byAdding: .day, value: -10, to: Date())!), Optic(name: "Golf", usageTime: .day, degree: 1.00, additionDate: Calendar.current.date(byAdding: .day, value: -5, to: Date())!), Optic(name: "Hyundai", usageTime: .month, degree: 3.0, additionDate: Calendar.current.date(byAdding: .day, value: -7, to: Date())!)]
//        self.lenses = lenses
//    }
    
    let world = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("optics").appendingPathExtension("plist")
    
    
    
    var hasActiveLens : Bool {
        let states = lenses.map({ $0.state})
        
        return states.contains(where: { $0 == .current})
    }
    
    var currentLens : Optic? {
        lenses.first(where: { $0.state == .current})
    }
    
    
    
    var lenses : [Optic] {
        get {
            do {
                let data = try Data(contentsOf: world)
                
               let optics =  try PropertyListDecoder().decode([Optic].self, from: data)
                return optics.sorted(by: { $0.state.rawValue < $1.state.rawValue})
            } catch {
                return []
            }
        }
        
        set {
            do {
                let data = try PropertyListEncoder().encode(newValue)
                try data.write(to: world)
            } catch {
                print("ok")
            }
        }
    }
    
    
    
    
}


protocol OpticChangeable {
    func changeOptic(optic : Optic)
}

@available(iOS 15.0, *)
class BoxVC : UIViewController, OpticChangeable {
    
    func changeOptic(optic: Optic) {
        print(optic)
        print(LensWorld().lenses)
        if let index = LensWorld().lenses.firstIndex(where: { $0.id == optic.id}) {
            
            print("abcd")
            
            
            
            if LensWorld().lenses[index].state == .new {
                if LensWorld().lenses.contains(where: { $0.state == .current }) {
                    let alert = UIAlertController(title: "You have already an active lens, please remove that pairs before starting using this pair", message: "", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                LensWorld().lenses[index].startUsing()
            } else  if LensWorld().lenses[index].state == .current {
                LensWorld().lenses[index].throwAways()
            }
            
           
            
            applYSnap()
        }
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var dataSource : UITableViewDiffableDataSource<Int,Optic>!
    
    
     
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        dataSource = UITableViewDiffableDataSource<Int,Optic>(tableView: tableView, cellProvider: { tableView, indexPath, optic in
            let cell = tableView.dequeueReusableCell(withIdentifier: "box") as! BoxTableViewCell
            
            cell.optic = optic
            cell.dhangeDelegate = self
            return cell
        })
        
        applYSnap()
        
       
    }
    
    private func applYSnap() {
        var snapShot = NSDiffableDataSourceSnapshot<Int,Optic>()
        snapShot.appendSections([0])
        snapShot.appendItems(LensWorld().lenses, toSection: 0)
        dataSource.apply(snapShot,animatingDifferences: true)
    }
}


class NewController : UIViewController , UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    
    
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        dataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        dataSource[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        duraTf.text = dataSource[row]
        
        row == 0 ? (duration = .month) : (duration = .day)
        view.endEditing(true)
    }
    
    
    @IBOutlet weak var brandTf: UITextField!
    
    @IBOutlet weak var duraTf: UITextField!
    
    @IBOutlet weak var odsTf: UITextField!
    
    @IBOutlet weak var brandErrorLabel: UILabel!
    
    @IBOutlet weak var durationErrorLabel: UILabel!
    
    @IBOutlet weak var odsErrorLabel: UILabel!
    @IBOutlet weak var secondView: UIView!
    
    @IBOutlet weak var button: UIButton!
    var duration : UsageTime?
    
    let pickerView = UIPickerView()
    
    let secondPickerViwe = UIPickerView()
    
    var dataSource : [String] = ["Monthly","Daily"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        secondPickerViwe.delegate = self
        secondPickerViwe.dataSource = self
        
        odsTf.keyboardType = .decimalPad
        
        duraTf.inputView = pickerView
        
    
        
        if #available(iOS 15.0, *) {
            var buttonConfiguration = UIButton.Configuration.filled()
            buttonConfiguration.background.backgroundColor = .systemTeal
            buttonConfiguration.cornerStyle = .capsule
            buttonConfiguration.title = "ADD"
            buttonConfiguration.image = UIImage(systemName: "plus.circle.fill")
            buttonConfiguration.imagePlacement = .top
            buttonConfiguration.imagePadding = 8
            buttonConfiguration.cornerStyle = .capsule
            
            button.configuration = buttonConfiguration
        } else {
            // Fallback on earlier versions
        }
      
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    var optic : Optic? {
        brandErrorLabel.text = ""
        durationErrorLabel.text = ""
        odsErrorLabel.text = ""
        guard let brand = brandTf.text, !brand.isEmpty else {
            
            brandErrorLabel.text = "Please type a brand"
            
            return nil
        }
        
        guard let duration = duration else {
            durationErrorLabel.text = "Please choose duration of lens"
            return nil
        }
        
        guard let degree = odsTf.text , !degree.isEmpty, let degreeDouble = Double(degree) else {
            odsErrorLabel.text = "Please choose a lens degree"
            return nil
        }
       
        
        
       
        
        
        return Optic(id: UUID(), name: brand, usageTime: duration, degree: degreeDouble)
    }
    
    
    
    @IBAction func opticSend(_ sender: Any) {
        
        guard var optic = optic else {
            return
        }

        optic.additionDate = Date()
        LensWorld().lenses.append(optic)
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
    
}





class WelcomeViewController : UIViewController {
    
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
  
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }
    
    
    
    
}
