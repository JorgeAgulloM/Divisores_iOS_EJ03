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
        
        //  En cada iteración se recorre desde el 1 hasta el número que solicita el usuario
        for n in (1...userNumber) {
            
            //  si se cancela la acción, se llama a la función auxiliar,
            //se notifica al usaurio y se sale del bloque.
            if isCancelled {
                endSearch()
                vController.notifyUser(title: "Divisores",
                                       subtitle: "Operación cancelada",
                                       body: "La operación ha sido cancelada por el usuario.")
                return
            }
            
            //  En caso de que el número de usuario se módulo de n...
            if userNumber % n == 0 {
                //  ...se inserta el valor de n en el array, se incrementa el contador de divisrores totales...
                vController.divisorsList.insert(n, at: 0)
                numberOfDivisors += 1
                //  ...y se abre el hilo de ejecución principal para recargar la tableView
                DispatchQueue.main.async {
                    self.vController.divisorsTableView.reloadData()
                }
            }
            
            //  Se llama a la función con el valor de n en Float
            vController.progressUpdateOnlyForGlobalThread(Float(n))
        }
        
        //  Una vez que han terminado las iteraciones, se notifica al usuario y se le faciclita información.
        vController.notifyUser(title: "Divisores",
                               subtitle: "Operación finalizada",
                               body: "\(userNumber) tiene \(numberOfDivisors > 1 ? "\(numberOfDivisors) divisores" : "un solo divisor"), revisa la lista.")
        
        //  Se llama a la función
        endSearch()
    }
    
    //  Esta función conecta, mediante el hilo principal, a la función que configura los objetos de la vista para el inicio y el final
    func endSearch() {
        DispatchQueue.main.async { self.vController.startStop(false) }
    }
    
    
}
