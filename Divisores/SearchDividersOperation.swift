//
//  SearchDividersOperation.swift
//  Divisores
//
//  Created by Jorge Agullo Martin on 28/1/22.
//

import UIKit

class SearchDividersOperation: Operation {

    let userNumber: Int
    let vController: ViewController
    
    
    init(_ userNumber: Int, _ viewControler: ViewController) {
        self.userNumber = userNumber
        self.vController = viewControler
    }
    
    override func main() {
        
        var numberOfDivisors: Int = 0
        let userNumber = self.userNumber
        for n in (1...userNumber) {
            
            if isCancelled {
                endSearch()
                vController.notifyUser(title: "Divisores",
                                       subtitle: "Operación cancelada",
                                       body: "La operación ha sido cancelada por el usuario.")
                return
            }
            
            if userNumber % n == 0 {
                vController.divisorsList.insert(n, at: 0)
                numberOfDivisors += 1
                DispatchQueue.main.async {
                    self.vController.divisorsTableView.reloadData()
                }
            }
            vController.progressUpdateOnlyForGlobalThread(Float(n))
        }
        
        vController.notifyUser(title: "Divisores",
                               subtitle: "Operación finalizada",
                               body: "\(userNumber) tiene \(numberOfDivisors > 1 ? "\(numberOfDivisors) divisores" : "un solo divisor"), revisa la lista.")
        
        endSearch()
    }
    
    func endSearch() {
        DispatchQueue.main.async { self.vController.startStop(false) }
    }
    
    
}
