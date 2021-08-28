//
//  ApiServices.swift
//  pixel_city
//
//  Created by Arsalan majlesi on 6/13/21.
//

import Foundation
import Alamofire
import AlamofireImage

class ApiServices{
    static let instance = ApiServices()
    
    func cancelAllSessions(){
        AF.session.getTasksWithCompletionHandler { (sessionTasks, uploadTasks, downloadTasks) in
            sessionTasks.forEach({$0.cancel()})
            downloadTasks.forEach({$0.cancel()})
        }
    }
    
    func getImagesArray(fromImagesInfo imgsInfo:[ImageInfo],withResponse responde:@escaping (_ images:[UIImage])->()){
        var images = [UIImage]()
        for imageInfo in imgsInfo{
            AF.request(imageInfo.url!).responseImage { (response) in
                if response.error == nil{
                    if let img = response.value {
                        images.append(img)
                    }
                    responde(images)
                }else{
                    responde(images)
                }
            }
        }
        
    }
    
    func getImagesUrl(fromAnnotation annotation:DroppablePin,withCompletion handler:@escaping (_ photosResponse:[ImageInfo]?)->()){
        
        var  imageInfoList = [ImageInfo]()
        
        AF.request(getFlickrUrl(callApiKey: apiKey, withAnnotation: annotation, andNumberOfPhotos: 40)).responseJSON { (response) in
            
            if response.error == nil{
                if let res = response.value as? Dictionary<String,Any>{
                    let photos = res["photos"] as! Dictionary<String,Any>
                    let photoArray = photos["photo"] as! [Dictionary<String,Any>]
                    do{
                        let jsonData = try?  JSONSerialization.data(withJSONObject: photoArray, options: [])
                        let photosArray = try JSONDecoder().decode([ImageInfo].self, from:jsonData!)
                        for var photo in photosArray{
                            photo.url =  "https://live.staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret)_c_d.jpg"
                            
                            imageInfoList.append(photo)
                        }
                        
                        handler(imageInfoList)
                    }catch let error{
                        print(error as Any)
                        handler(imageInfoList)
                    }
                }
            }else{
                handler(imageInfoList)
            }
        }
    }
}

