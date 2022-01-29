//
//  ViewController.swift
//  Divisores
//
//  Created by Jorge Agullo Martin on 25/1/22.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //  Propiedades, variables y outles
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
        
        //  propiedad de acceso a la tableView
        divisorsTableView.delegate = self
        divisorsTableView.dataSource = self
        
        //  Solicitud al usuario de los permisos necesarios para las notificaciones, en este caso.
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (garanted, error) in
            if garanted {
                print("permiso concedido")
            } else {
                print("Permiso denegado")
                print(error!)
                
            }
            
        }
        
    }

    //Acción principal de la app
    @IBAction func actionSearchButton(_ sender: UIButton) {
        //  Oculta el teclado al pulsar el botón.
        UIApplication.shared.keyWindow?.endEditing(true)
        
        //  Se consulta la validación para activar la función...
        if searchStart {
            //  ...en caso de que se esté ejecutando el cálculo, se cancela esta mediante la boolean...
            if cancelSearh == false { cancelSearh = true}
            //  ...y se cancela la cola de ejecución
            queue?.cancelAllOperations()
            
            //  Si no se está ejecutando el cálculo y las validaciones son correctas...
        } else if validateInput() && !searchStart{
            //  ...se llama a la función principal
            searchDivisors()
            
        }
        
    }
    
    //  Función de búsqueda de divisores
    func searchDivisors(){
        //  Puesta en marcha de indicadores y bloqueos de interfaz
        startStop(true)
        
        //  Se crea una variable del tipo Operation cargando su constructor con los valores necesarios...
        let getDividers = SearchDividersOperation(userNumber, self)
        //  ...y se agrega a la cola de ejecución
        queue?.addOperation(getDividers)
        
    }
    
    //  Función de control del progreso. Se encarga de calcular y mostrar el proceso al usuario
    func progressUpdateOnlyForGlobalThread(_ n: Float) {
        //  Variable interna
        var progressUpdate: Float = 0
        //  Para evitar que el indicador pueda incrementarse en más de 100, se bloquea el set en dicho valor
        if progressUpdate < 100.0 {
            //  Mientras la variable no sea 100 se calcula el porcentaje con el número del usuario
            progressUpdate = (Float(n) * 100.0) / Float(userNumber)
            
        }
        
        //  Se llama, desde el hilo principal, al texto y a la barra de progreso para actualizarlas
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
            
        } else {
            ActivityIndicator.stopAnimating()
            searchStart = false
            //  En caso de cancelación
            if cancelSearh {
                divisorsList.removeAll()
                divisorsList.append(0)
                divisorsTableView.reloadData()
                progressBar.isHidden = false
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
        
        //  se comprueba que haya valor...
        if let n = Int(userNumberString) {
            //  Si es mayor de cero se parsea a Int, se guarda en la varible
            //y se devuelve un true para confirmarlo
            if n > 0 {
                userNumber = Int(userNumberString)!
                return true
                
            }
            //  En caso de que sea 0, se avisa al usuario y se devuelve un false
            showAlert("Atención!!", "El número debe ser mayor de 0")
            return false
            
        }
        //  En caso de que no se haya introducido ningún número, se avisa al usuario y se devuelve un false
        showAlert("Atención!!", "Debes introducir un número")
        return false
        
    }
    
    //  Función configurable para generar la alerta mediate pop-up al usuario
    func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
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
    
    //  Carga de la celda en la tabla con el valor deseado.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = divisorsTableView.dequeueReusableCell(withIdentifier: "divisorCell", for: indexPath)
        
        //  En caso de que el cálculo esté en marcha, se carga el valor nuevo correspondiente del array
        if !cancelSearh {
            cell.textLabel?.text = "\(divisorsList[indexPath.row]) es divisor de \(userNumber)"
            
        } else {
            //  Si se ha cancelado la operación, se notifica al usuario.
            cell.textLabel?.text = "Operación Cancelada por usuario"
            
        }
        //  Se devuelve la celda
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

