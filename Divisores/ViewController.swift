//
//  ViewController.swift
//  Divisores
//
//  Created by Jorge Agullo Martin on 25/1/22.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var inputText: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var divisorsTableView: UITableView!
    var divisorsList: Array<Int> = []
    var userNumberString: String = ""
    var userNumber: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //  propiedad de acceso a la tabla
        divisorsTableView.delegate = self
        divisorsTableView.dataSource = self
        
        //  Solicitud al usuario de permisos necesarios
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (garanted, error) in
            if garanted {
                print("permiso concedido")
            } else {
                print("Permiso denegado")
                print(error!)
            }
        }
    }

    @IBAction func actionSearchButton(_ sender: UIButton) {
        //  Se consulta la validación para activar la función
        if validateInput() {
            searchDivisors()
        }
    }
    
    //  Función de búsqueda de divisores
    func searchDivisors(){
        //  Puesta en marcha de indicadores y bloqueos
        startStop(true)
        
        DispatchQueue.global().async {
            let userNumber = self.userNumber
            for n in (1...userNumber) {
                if userNumber % n == 0 {
                    self.divisorsList.append(n)
                    DispatchQueue.main.async {
                        self.divisorsTableView.reloadData()
                    }
                }
                self.progressUpdateOnlyForGlobalThread(Float(n))
            }
            DispatchQueue.main.async { self.startStop(false) }
        }
    }
    
    func progressUpdateOnlyForGlobalThread(_ n: Float) {
        var progressUpdate: Float = 0
        if progressUpdate < 100.0 {
            progressUpdate = (Float(n) * 100.0) / Float(userNumber)
        }
        
        DispatchQueue.main.async {
            self.progressBar.progress = progressUpdate / 100
            self.progressLabel.text = "\(Int(progressUpdate))%"
        }
    }
    
    func startStop(_ initProcess: Bool) {
        if initProcess {
            //Deshabilita el botón para evitar realizar más peticiones
            searchButton.isEnabled = false
            divisorsList.removeAll()
            ActivityIndicator.startAnimating()
            progressBar.isHidden = false
            progressBar.progress = 0
            progressLabel.text = "0"
        } else {
            ActivityIndicator.stopAnimating()
            searchButton.isEnabled = true
            notifyUser(title: "Divisores",
                            subtitle: "Operación finalizada",
                            body: "\(userNumber) tiene \(divisorsList.count > 1 ? "\(divisorsList.count) divisores" : "un solo divisor"), revisa la lista.")
            searchButton.isEnabled = true
        }
    }
    
    func validateInput() -> Bool {
        userNumberString = inputText.text!
        
        if let n = Int(userNumberString) {
            if n > 0 {
                userNumber = Int(userNumberString)!
                return true
            }
            showAlert("Atención!!", "El número debe ser mayor de 0")
            return false
        }
        showAlert("Atención!!", "Debes introducir un número")
        return false
    }
    
    func showAlert(_ title: String, _ message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return divisorsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = divisorsTableView.dequeueReusableCell(withIdentifier: "divisorCell", for: indexPath)
        
        cell.textLabel?.text = "\(divisorsList[indexPath.row]) es divisor de \(userNumber)"
        
        return cell
    }
    
    func notifyUser(title: String, subtitle: String, body: String) {
        //  Crea la notificación
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = body
        content.sound = .default
        
        //  Disparador de la notificación
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        //  Solicitar lanzamiento
        let request = UNNotificationRequest(identifier: "idNotify", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            print(error ?? "Sin errores")
        }
    }
    
}

