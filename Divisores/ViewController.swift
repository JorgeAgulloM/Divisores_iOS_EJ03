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
    var userNumber: Int = 0
    var queue: OperationQueue? = OperationQueue()
    var searchStart: Bool = false
    var cancelSearh: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        divisorsTableView.delegate = self
        divisorsTableView.dataSource = self
        
        //  Solicitud al usuario de los permisos necesarios
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (garanted, error) in
            if garanted {
                print("permiso concedido")
            } else {
                print("Permiso denegado")
                print(error!)
                
            }
            
        }
        
    }
    
    //Acción principal de la app al pulsar el botón
    @IBAction func actionSearchButton(_ sender: UIButton) {
        //  Oculta el teclado al pulsar el botón. *Nota a profesor => Creo que esto no es lo oportuno para ocultar el teclado, por no he encontrado otra opción "simple" como esta.
        UIApplication.shared.keyWindow?.endEditing(true)
        
        //  Se consulta la validación para activar la función...
        if searchStart {
            //  ...se activa la cancelación del cálculo
            cancelSearh = true
            queue?.cancelAllOperations()
            
          //  Si no se está ejecutando el cálculo y las validaciones son correctas se inicia el cáculo
        } else if validateInput() && !searchStart{
            searchDivisors()
            
        }
        
    }
    
    //  Función de búsqueda de divisores
    func searchDivisors(){
        //  Puesta en marcha de indicadores y bloqueos de interfaz
        startStop(true)
        
        //  Se crea una variable del tipo Operation y se agrega a la cola de ejecución
        let getDividers = SearchDividersOperation(userNumber, self)
        queue?.addOperation(getDividers)
        
    }
    
    //  Función de control del progreso
    func progressUpdateOnlyForGlobalThread(_ n: Float) {
        var progressUpdate: Float = 0
        
        //  Se calcula el porcentaje con el número del usuario
        if progressUpdate < 100.0 { progressUpdate = (Float(n) * 100.0) / Float(userNumber) }
        
        //  Se actualizan marcadores de progreso
        DispatchQueue.main.async {
            self.progressBar.progress = progressUpdate / 100
            self.progressLabel.text = "\(Int(progressUpdate))%"
            
        }
        
    }
    
    //  Función para bloquear o liberar objetos y variables según se inicie o finalice el cálculo.
    func startStop(_ initProcess: Bool) {
        //  Si se inicia...
        if initProcess {
            cancelSearh = false
            searchStart = true
            searchButton.setTitle("   Cancelar", for: UIButton.State.normal)
            divisorsList.removeAll()
            ActivityIndicator.startAnimating()
            progressBar.isHidden = false
            progressBar.progress = 0
            progressLabel.text = "0"
            
            //  Si se detiene...
        } else {
            ActivityIndicator.stopAnimating()
            searchStart = false
            //  En caso de cancelación
            if cancelSearh {
                divisorsList.removeAll()
                divisorsList.append(0)
                divisorsTableView.reloadData()
                progressBar.isHidden = true
                progressBar.progress = 0
                progressLabel.text = ""
                
            }
            searchButton.setTitle("Calcular", for: UIButton.State.normal)
            
        }
        
    }
    
    //  Validación del número de usuario
    func validateInput() -> Bool {
        //  Se carga el valor del input
        let userNumberString = inputText.text!
        
        //  se comprueba que haya valor numérico...
        if let n = Int(userNumberString) {
            if n > 0 {
                //  ...si es correcto
                userNumber = Int(userNumberString)!
                return true
                
            }
            
            //  ...si es 0
            showAlert("Atención!!", "El número debe ser mayor de 0")
            return false
            
        }
        
        //  ...si no se ha introducido ningún número
        showAlert("Atención!!", "Debes introducir un número")
        return false
        
    }
    
    //  Función configurable para generar la alerta mediate pop-up al usuario
    func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        //Se carga la alerta para que el sistema la muestre
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    //  Número de secciones de cada línea
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }
    
    //  Número total de lineas
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //  Se utiliza el número total de objetos del array
        return divisorsList.count
        
    }
    
    //  Carga la celda en la tabla con el valor deseado.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = divisorsTableView.dequeueReusableCell(withIdentifier: "divisorCell", for: indexPath)
        
        //  Mientras no se cancele...
        if !cancelSearh {
            cell.textLabel?.text = "\(divisorsList[indexPath.row]) es divisor de \(userNumber)"
            
          //    ...si se cancela
        } else {
            cell.textLabel?.text = "Operación Cancelada por usuario"
            
        }

        return cell
        
    }
    
    //  Función configurable para las notificaciones al usuario
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
        
        //  Se añade la notificación
        UNUserNotificationCenter.current().add(request) { (error) in
            print(error ?? "Sin errores")
            
        }
        
    }
    
}

