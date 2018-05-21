//
//  ViewController.swift
//  GCDAsyncImage
//
//  Created by Chase Wang on 2/23/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let numberOfCells = 20_000
    
    let imageURLArray = Unsplash.defaultImageURLs
    
    fileprivate lazy var downloadQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        
        return queue
    }()
    
    fileprivate lazy var imageRenderQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        
        return queue
    }()
    
    fileprivate var opsAndUrls = [URL: Operation]()
    
    // MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfCells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath) as! ImageTableViewCell
        
        cell.pictureImageView.image = #imageLiteral(resourceName: "placeholder-image")
        
        let url = imageURLArray[indexPath.row % imageURLArray.count]
        
        
        var data: Data!
        let downloadOp = BlockOperation {
            data = try! Data(contentsOf: url)
        }
        
        var image: UIImage!
        downloadOp.completionBlock = {
            if downloadOp.isCancelled == false {
                image = UIImage(data: data)
                
                DispatchQueue.main.async {
                    cell.pictureImageView.image = image
                }
            }
        }
        
        self.opsAndUrls[url] = downloadOp
        self.downloadQueue.addOperations([downloadOp], waitUntilFinished: false)
        
        // TODO: add sepia filter to image
        //        let fillterOp =
//        let inputImage = CIImage(data: UIImagePNGRepresentation(image)!)
//        let filter = CIFilter(name: "CISepiaTone")!
//        filter.setValue(inputImage, forKey: kCIInputImageKey)
//        filter.setValue(0.8, forKey: kCIInputIntensityKey)
//        let outputCIImage = filter.outputImage
//        let imageWithFilter = UIImage(ciImage: outputCIImage!)
        
        
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let url = imageURLArray[indexPath.row % imageURLArray.count]
        if let operationToCancel = self.opsAndUrls[url] {
            operationToCancel.cancel()
        }
    }
}
