//
//  ArmazenamentoDeDados.swift
//  Minhas viagens
//
//  Created by Breno Luizetto Cintra on 15/12/20.
//  Copyright © 2020 Breno Luizetto Cintra. All rights reserved.
//

import UIKit

class ArmazenamentoDeDados{
    let chaveArmazenamento = "locaisViagem"
    var viagens: [Dictionary<String, String>] = []
    
    func getDefaults() -> UserDefaults{
       return  UserDefaults.standard
    }
    func salvarViagem(viagem: Dictionary<String, String>){
        
        viagens = listarViagens()
        
        viagens.append(viagem)
        getDefaults().set(viagens, forKey: chaveArmazenamento)
        getDefaults().synchronize()
       
    }
    
    func listarViagens() -> [Dictionary<String, String>] {
        
       let dados = getDefaults().object(forKey: chaveArmazenamento)
        if dados != nil{
            return dados as! Array
        }else{
            return []
        }
    }
    
    func removerViagens(indice: Int){
        
        viagens = listarViagens()
        viagens.remove(at: indice)
        
        getDefaults().set(viagens, forKey: chaveArmazenamento)
        getDefaults().synchronize()

    }
    
}
