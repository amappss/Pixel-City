//
//  ViewController.swift
//  pixel_city
//
//  Created by Arsalan majlesi on 6/10/21.
//

import UIKit
import MapKit
class MainView: UIViewController ,UIGestureRecognizerDelegate{

    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var titleTx: UILabel!
    @IBOutlet weak var mkMap: MKMapView!
    @IBOutlet weak var bottomViewHeightConstraint: NSLayoutConstraint!
    
    let regionRadius:Double = 1000.0
    let locationManager = CLLocationManager()
    var spinner :UIActivityIndicatorView?
    var loadingLbl: UILabel?
    
    var photoCollection : UICollectionView?
    let collectionFlow = UICollectionViewFlowLayout()
    var images = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mkMap.delegate = self
        locationManager.delegate = self
        
        configureLocationAuth()
        centerMapBaseOnLocation()
        doubleTapRecognizer()
        swipeDownRecognizer()
        initCollectionView()
        
//        let intercation = UIContextMenuInteraction(delegate:self)
//        photoCollection?.addInteraction(intercation)
    }
    
    func initCollectionView(){
        photoCollection = UICollectionView(frame: view.bounds, collectionViewLayout: collectionFlow)
        photoCollection?.register(PhotoCell.self, forCellWithReuseIdentifier: photoCellIdenfitier)
        photoCollection?.delegate = self
        photoCollection?.dataSource = self
        photoCollection?.backgroundColor = .white
        bottomView.addSubview(photoCollection!)
    }
    
    func doubleTapRecognizer(){
        let doubleTapRec = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        doubleTapRec.numberOfTapsRequired = 2
        doubleTapRec.delegate = self
        doubleTapRec.cancelsTouchesInView = true
        mkMap.addGestureRecognizer(doubleTapRec)
    }
    func swipeDownRecognizer(){
        let swipeRec = UISwipeGestureRecognizer(target: self, action: #selector(hideBottomView))
        swipeRec.direction = .down
        bottomView.addGestureRecognizer(swipeRec)
    }
    
    func showBottomView(){
        bottomViewHeightConstraint.constant = 300
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    @objc func hideBottomView(){
        bottomViewHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        ApiServices.instance.cancelAllSessions()
    }
    
    func removePins(){
        for annotation in mkMap.annotations{
            mkMap.removeAnnotation(annotation)
        }
    }
    
    func addLoadingSpinner(){
        spinner = UIActivityIndicatorView()
        print(bottomView.center.y)
        print((spinner?.bounds.width)!)
        spinner?.style = .large
        spinner?.center = CGPoint(x:bottomView.center.x - (spinner?.frame.width)! / 2,y:(bottomView.frame.height / 2) + (spinner?.frame.height)! / 2)
        spinner?.color = UIColor.darkGray
        spinner?.startAnimating()
        photoCollection?.addSubview(spinner!)
    }
    
    func removeLoadingSpinner(){
        if spinner != nil{
            spinner?.removeFromSuperview()
        }
    }
    
    func addLoadingLabel(){
        loadingLbl = UILabel()
        loadingLbl?.frame = CGRect(x: bottomView.center.x - 250 / 2 , y: bottomView.frame.height / 2 + (50 / 2) + 20, width: 250, height: 35)
        loadingLbl?.font = UIFont(name: "Avenier Next", size: 18)
        loadingLbl?.textAlignment = .center
        loadingLbl?.textColor = UIColor.darkGray
        photoCollection?.addSubview(loadingLbl!)
    }
    
    func removeLoadingLabel(){
        if loadingLbl != nil{
            loadingLbl?.removeFromSuperview()
        }
    }
    
    @IBAction func centerLocationPressed(_ sender: Any) {
        centerMapBaseOnLocation()
    }
    
    @objc func dropPin(sender:UIGestureRecognizer){
        removePins()
        removeLoadingSpinner()
        removeLoadingLabel()
        ApiServices.instance.cancelAllSessions()
        
        self.images = []
        photoCollection?.reloadData()
        
        showBottomView()
        addLoadingSpinner()
        addLoadingLabel()

        let points = sender.location(in: mkMap)
        let coordinate = mkMap.convert(points, toCoordinateFrom: mkMap)

        let pin = DroppablePin(coordinate: coordinate, identifier: pinIdentifier)
        mkMap.addAnnotation(pin)

        let pinRegion = MKCoordinateRegion(center: coordinate,latitudinalMeters: regionRadius,longitudinalMeters: regionRadius)
        mkMap.setRegion(pinRegion, animated: true)
        
        ApiServices.instance.getImagesUrl(fromAnnotation: pin) { (imagesInfo) in
            if let images = imagesInfo{
                ApiServices.instance.getImagesArray(fromImagesInfo: images) { (uiImages) in
                    self.loadingLbl?.text = "\(uiImages.count)/40 IMAGES DOWNLOADED ..."
                    if images.count == uiImages.count{
                        self.images = uiImages
                        self.removeLoadingSpinner()
                        self.removeLoadingLabel()
                        self.photoCollection?.reloadData()
                    }
                }
            }
        }

    }
}

extension MainView : MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil
        }
        
        let pinAnnotaion = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinIdentifier)
        pinAnnotaion.pinTintColor = #colorLiteral(red: 1, green: 0.6736013293, blue: 0, alpha: 1)
        pinAnnotaion.animatesDrop = true
        return pinAnnotaion
    }
    
    func centerMapBaseOnLocation(){
        guard let coordinate = locationManager.location?.coordinate else {return}
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mkMap.setRegion(coordinateRegion, animated: true)
    }
}

extension MainView : CLLocationManagerDelegate{
    
    func configureLocationAuth(){
        if locationManager.authorizationStatus == .notDetermined{
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        centerMapBaseOnLocation()
    }
}

extension MainView : UICollectionViewDelegate,UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoCellIdenfitier, for: indexPath) as? PhotoCell else {return PhotoCell()}
        let image = images[indexPath.row]
        let imageView = UIImageView(image: image)
        cell.addSubview(imageView)
        return cell
    }
    

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let popVc = storyboard?.instantiateViewController(withIdentifier: "popVC") as? PopVC else {return}
        popVc.initData(img: images[indexPath.row])
        present(popVc, animated: true, completion: nil)
    }
    
    //3D Touch method
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: { () -> UIViewController? in
            guard let popVc = self.storyboard?.instantiateViewController(withIdentifier: "popVC") as? PopVC else {return nil}
            popVc.initData(img: self.images[(indexPath.row)])
            return popVc
        }, actionProvider: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        animator.addCompletion {
            guard let indexPath = configuration.identifier as? NSIndexPath else { return }
            guard let popVc = self.storyboard?.instantiateViewController(withIdentifier: "popVC") as? PopVC else { return }
            popVc.initData(img: self.images[indexPath.row])
            self.show(popVc, sender: self)
        }
    }
}

//extension MainView : UIContextMenuInteractionDelegate{
//    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
//        return UIContextMenuConfiguration(identifier: nil, previewProvider: { () -> UIViewController? in
//            guard let popVc = self.storyboard?.instantiateViewController(withIdentifier: "popVC") as? PopVC else {return nil}
//            let indexPath = self.photoCollection?.indexPathForItem(at: location)
//            let cell = self.photoCollection?.cellForItem(at: indexPath!)
//            popVc.initData(img: self.images[(indexPath?.row)!])
//            return popVc
//        }, actionProvider: nil)
//    }
//
//
//}
