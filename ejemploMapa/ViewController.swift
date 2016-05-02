//
//  ViewController.swift
//  ejemploMapa
//
//  Created by José Manuel Mora on 27/04/16.
//  Copyright © 2016 Morasoft. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapa: MKMapView!
    
    private let manejador = CLLocationManager()
    @IBOutlet weak var swMap: UISwitch!
    @IBOutlet weak var swSat: UISwitch!
    @IBOutlet weak var swHib: UISwitch!
    
    
    private var contar: Int = 0
    private var distanciaIni:Double = 0.0
    private var recorrido:Double = 0.0
    
    private var posicion : CLLocation!
    private var distancia : Double = 0;
    
    private var cambio:Double = 50.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        manejador.delegate = self
        manejador.desiredAccuracy = kCLLocationAccuracyBest
        manejador.requestWhenInUseAuthorization()
    
        assignBackground()
    }
    
    @IBAction func acSwNor(sender: UISwitch) {
        if sender.on {
            swSat.setOn(false, animated: true)
            swHib.setOn(false, animated: true)
            mapa.mapType = MKMapType.Standard
        }else{
            swMap.setOn(true, animated: true)
        }
    }
    
    @IBAction func acSwSat(sender: UISwitch) {
        if sender.on {
            swMap.setOn(false, animated: true)
            swHib.setOn(false, animated: true)
            mapa.mapType = MKMapType.Satellite
        }else{
            swSat.setOn(true, animated: true)
        }
    }
    
    @IBAction func acSwHib(sender: UISwitch) {
        if sender.on {
            swSat.setOn(false, animated: true)
            swMap.setOn(false, animated: true)
            mapa.mapType = MKMapType.Hybrid
        }else{
            swHib.setOn(true, animated: true)
        }
    }
    

    // Pido autorizacion y defino parametros
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if status == .AuthorizedWhenInUse{
            manejador.startUpdatingLocation()
            manejador.distanceFilter = cambio
            mapa.showsUserLocation = true
            mapa.zoomEnabled = true
            print("Autorizado")
        }else{
            manejador.stopUpdatingLocation()
            mapa.showsUserLocation = false
            print("No Autorizado")
        }
    }

    
    //Recibo las lecturas.
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation:CLLocation = locations[0]
        var punto = CLLocationCoordinate2D()
        let localiza = manager.location!
        print ("Latitud: \(localiza.coordinate.latitude) Longitud \(localiza.coordinate.longitude)")
        
        if posicion == nil {
            posicion = userLocation
            distancia = 0
            
            let latitude:CLLocationDegrees = userLocation.coordinate.latitude
            let longitude:CLLocationDegrees = userLocation.coordinate.longitude
            let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
            let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
            let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
            mapa.setRegion(region, animated: false)
            
            fnDibujaPin()
        } else {
            let distanciaActual = userLocation.distanceFromLocation(posicion)
            if distanciaActual >= 50 {
                distancia += distanciaActual
                posicion = userLocation
                let span : MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
                punto.latitude = posicion.coordinate.latitude
                punto.longitude = posicion.coordinate.longitude
                let region : MKCoordinateRegion = MKCoordinateRegion(center: punto, span: span)
                mapa.setRegion(region, animated: true)
                fnDibujaPin()
            }
        }
        
    }
    
    func fnDibujaPin() {
        let titulo : String = "Lat:\(posicion.coordinate.longitude), Lon:\(posicion.coordinate.latitude)"
        let subtitulo : String = "Distancia: \(String(format: "%.2f",distancia)) mts."
        
        let annotation = MKPointAnnotation()
        annotation.title = titulo
        annotation.subtitle = subtitulo
        annotation.coordinate = posicion.coordinate
        mapa.addAnnotation(annotation)
    }
    
    //En caso de tener  error
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        let alerta = UIAlertController(title: "Error", message: "Tipo: \(error.description)", preferredStyle: .Alert)
        let accionOK = UIAlertAction(title: " OK ", style: .Default, handler: {
            accion in
            //Aqui pongo los que debemos hacer
        })
        alerta.addAction(accionOK)
        self.presentViewController(alerta, animated: true, completion: nil)
    }
    
    
    func assignBackground(){
        let bg = UIImage(named: "fondo.jpg")
        
        var imgView : UIImageView!
        imgView = UIImageView(frame: view.bounds)
        imgView.contentMode = UIViewContentMode.ScaleAspectFit
        imgView.clipsToBounds = true
        imgView.image = bg
        imgView.center = view.center
        view.addSubview(imgView)
        self.view.sendSubviewToBack(imgView)
    }
}

