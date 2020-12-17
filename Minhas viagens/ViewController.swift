//
//  ViewController.swift
//  Minhas viagens
//
//  Created by Breno Luizetto Cintra on 15/12/20.
//  Copyright © 2020 Breno Luizetto Cintra. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapa: MKMapView!
    var gerenciadorLocalizacao = CLLocationManager()
    var viagem: Dictionary<String, String> = [:]
    var indiceSelecionado: Int!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configuraGerenciadorLocalizacao()
        
        if let indice = indiceSelecionado{
            if indice == -1{//adicionando
                
                configuraGerenciadorLocalizacao()

                
            }else{//listando
                
                exibirAnotacao(viagem: viagem)
            }
        }
        //reconhecedor de gestos
        let reconhecedorGesto = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.marcar(gesture:)))
        reconhecedorGesto.minimumPressDuration = 2
        
        mapa.addGestureRecognizer(reconhecedorGesto)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let local = locations.last!
        
        //exibe local
        let localizacao = CLLocationCoordinate2DMake(local.coordinate.latitude, local.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        
        let regiao = MKCoordinateRegion(center: localizacao, span: span)
        self.mapa.setRegion(regiao, animated: true)
        
    }
    
    func exibirLocal(latitude: Double, longitude: Double){
        //exibe local
        let localizacao = CLLocationCoordinate2DMake(latitude, longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        
        let regiao = MKCoordinateRegion(center: localizacao, span: span)
        self.mapa.setRegion(regiao, animated: true)
    }
    
    func exibirAnotacao(viagem: Dictionary<String, String>){
        if let localViagem = viagem["local"]{
            if let latitudeS = viagem["latitude"]{
                if let longitudeS = viagem["longitude"]{
                    
                    if let latitude = Double(latitudeS){
                        if let longitude = Double(longitudeS){
                            
                            
                            
                            let anotacao = MKPointAnnotation()
                            //exibe anotaçao com os dados de endereco
                            
                            anotacao.coordinate.latitude = latitude
                            anotacao.coordinate.longitude = longitude
                            anotacao.title = localViagem
                            
                            self.mapa.addAnnotation(anotacao)
                            
                            exibirLocal(latitude: latitude, longitude: longitude)
                            
                        }
                    }
                }
            }
                    
        }
    }
    
    @objc func marcar(gesture: UIGestureRecognizer){
        
        if gesture.state == UIGestureRecognizer.State.began{
            
            //recuperar as coordenadas do ponto selecionado
            let pontoSelecionado = gesture.location(in: self.mapa)
            let coordenadas = mapa.convert(pontoSelecionado, toCoordinateFrom: self.mapa)
            let localizacao =  CLLocation(latitude: coordenadas.latitude, longitude: coordenadas.longitude)
            
            //reupera endereço do ponto selecionado
            
            var localCompleto = "enedereço não encontrado"
            CLGeocoder().reverseGeocodeLocation(localizacao) { (local, erro ) in
                if erro == nil{
                    
                    if let dadosLocal = local?.first{
                        
                        if let nome = dadosLocal.name{
                            localCompleto = nome
                        }else{
                            if let endereco = dadosLocal.thoroughfare{
                                localCompleto = endereco
                            }
                        }
                    }
                    
                    //salvar viagens
                    self.viagem = ["local":localCompleto,"latitude": String(coordenadas.latitude), "longitude":String(coordenadas.longitude)]
                    ArmazenamentoDeDados().salvarViagem(viagem: self.viagem)
                    
                    self.exibirAnotacao(viagem: self.viagem)

                }else{
                    print(erro)
                }
            }
            
           
        }
        
    }
    
    func configuraGerenciadorLocalizacao(){
        gerenciadorLocalizacao.delegate = self
        gerenciadorLocalizacao.desiredAccuracy = kCLLocationAccuracyBest
        gerenciadorLocalizacao.requestWhenInUseAuthorization()
        gerenciadorLocalizacao.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != .authorizedWhenInUse{
            let alertaController = UIAlertController(title: "permissao de localizaçao",
                message: "necessario permissao para acesso a localizaçao",
                preferredStyle: .alert)
            
            let acaoConfiguracoes = UIAlertAction(title: "abri configuraçoes", style: .default, handler:{(alertaConfiguraçoes) in
                
                if let configuracoes = NSURL(string: UIApplication.openSettingsURLString){
                    UIApplication.shared.open(configuracoes as URL)
                }
            })
            
            let acaoCancelar = UIAlertAction(title: "cancelar", style: .default, handler: nil)
            alertaController.addAction(acaoConfiguracoes)
            alertaController.addAction(acaoCancelar)
            
            present( alertaController, animated:true, completion: nil)
        }
    }


}

