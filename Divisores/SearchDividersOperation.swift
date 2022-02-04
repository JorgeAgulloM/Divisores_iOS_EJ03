//
//  SearchDividersOperation.swift
//  Divisores
//
//  Created by Jorge Agullo Martin on 28/1/22.
//

import UIKit

class SearchDividersOperation: Operation {

    //  Propiedades de la clase
    let userNumber: Int
    let vController: ViewController
    
    //  Iniciación de las propiedades
    init(_ userNumber: Int, _ viewControler: ViewController) {
        self.userNumber = userNumber
        self.vController = viewControler
    }
    
    override func main() {
        
        //  Variables y constantes para la función
        var numberOfDivisors: Int = 0
        let userNumber = self.userNumber
        
        //  ***Solo para observar que el progreso se pone a cero
        if userNumber <= 9999 { sleep(1) }
        
        //  En cada iteración se recorre desde el 1 hasta el número que solicita el usuario...
        for n in (1...userNumber) {
            
            //  ...si se cancela la acción...
            if isCancelled {
                //  ...se pone fin a la búsqueda, se notifica al usaurio y se sale del bloque
                endSearch()
                vController.notifyUser(title: "Divisores",
                                       subtitle: "Operación cancelada",
                                       body: "La operación ha sido cancelada por el usuario.")
                return
                
            }
            
            //  ...si el número de usuario sea módulo de n...
            if userNumber % n == 0 {
                //  ...se incrementa el arrya con el valor y el contador
                vController.divisorsList.insert(n, at: 0)
                numberOfDivisors += 1
                
                //  ...se recarga la tableView
                DispatchQueue.main.async { self.vController.divisorsTableView.reloadData() }
                
            }
            
            //  ...se actualiza el progreso
            vController.progressUpdateOnlyForGlobalThread(Float(n))
        }
        
        //  Una vez que han terminado las iteraciones, se notifica al usuario
        vController.notifyUser(title: "Divisores",
                               subtitle: "Operación finalizada",
                               body: "\(userNumber) tiene \(numberOfDivisors > 1 ? "\(numberOfDivisors) divisores" : "un solo divisor"), revisa la lista.")
        
        endSearch()
    }
    
    //  Función de llamada a startStop para reiniciar objetos
    func endSearch() {
        DispatchQueue.main.async { self.vController.startStop(false) }
        
    }
    
    
}
