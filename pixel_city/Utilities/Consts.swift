//
//  Consts.swift
//  pixel_city
//
//  Created by Arsalan majlesi on 6/12/21.
//

import Foundation


let pinIdentifier = "droppablePin"
let photoCellIdenfitier = "photoCell"
let apiKey = "6a536eefbc3f6ad7da7733aad1e6dc88"

func getFlickrUrl(callApiKey key:String,withAnnotation annotation:DroppablePin,andNumberOfPhotos count:Int) -> String{
    return "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(key)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=km&per_page=\(count)&format=json&nojsoncallback=1"
}
