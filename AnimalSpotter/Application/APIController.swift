//
//  APIController.swift
//  AnimalSpotter
//
//  Created by Ben Gohlke on 4/16/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import UIKit

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

enum NetworkError: Error {
    case noAutho
    case badAuth
    case otherError
    case badData
    case noDecode
}


class APIController {
    
    private let baseUrl = URL(string: "https://lambdaanimalspotter.vapor.cloud/api")!
    
    var bearer: Bearer?
    
    //create function for sign up
    func signUp(with user: User, completion: @escaping (Error?) -> Void) {
        //create endpoint URL
        let signUpURL = baseUrl.appendingPathComponent("users/signup")
        
        //set up request
        var request = URLRequest(url: signUpURL)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Initialize JSON Encoder
        let jsonEncoder = JSONEncoder()
        
        
        //Encode data and catch errors
        do {
            let jsonData = try jsonEncoder.encode(user)
            request.httpBody = jsonData
        } catch {
            NSLog("Error encoding urser object: \(error)")
            completion(error)
            return
        }
        
        // Create Data task, handle bad response and errors
        URLSession.shared.dataTask(with: request) { (_, response, error) in
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                completion(NSError(domain: "", code: response.statusCode, userInfo: nil))
                return
            }
            
            if let error = error {
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
    //create function for sign in
    func signIn(with user: User, completion:@escaping (Error?)-> Void) {
        let loginURL = baseUrl.appendingPathComponent("users/login")
        
        var request = URLRequest(url: loginURL)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonEncoder = JSONEncoder()
        
        do {
            let jsonData = try jsonEncoder.encode(user)
            request.httpBody = jsonData
        } catch {
            NSLog("Error encoding user object: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, response , error) in
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                completion(NSError(domain: "", code: response.statusCode, userInfo: nil))
                return
            }
            
            if let error = error {
                completion(error)
                return
            }
            
            guard let data = data else {
                completion(NSError())
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                self.bearer = try decoder.decode(Bearer.self, from: data)
            } catch {
                NSLog("Error decoding token: \(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    //create function for fetching all animal names
    func fetchAllAnimalNames(completion: @escaping (Result<[String], NetworkError>) -> Void) {
        guard let bearer = self.bearer else {
            completion(.failure(.noAutho))
            return
        }
        
        let allAnimalURL = baseUrl.appendingPathComponent("animals/all")
        
        var request = URLRequest(url: allAnimalURL)
        request.httpMethod = HTTPMethod.get.rawValue
        request.addValue("Bearer \(bearer.token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse,
                response.statusCode == 401 {
                completion(.failure(.badAuth))
                return
            }
            if let _ = error {
                completion(.failure(.otherError))
                return
            }
            
            guard let data = data else {
                completion(.failure(.badData))
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                let animalNames = try decoder.decode([String].self, from: data)
                completion(.success(animalNames))
            } catch {
                NSLog("Error decoding animal objects: \(error)")
                completion(.failure(.noDecode))
                return
            }
        }.resume()
    }
    
    //create function for fetching animal details
    
    func fetchDetailsForAnimal(for animalName: String, completion:@escaping (Result<Animal, NetworkError>)-> Void) {
        guard let bearer = self.bearer else {
            completion(.failure(.noAutho))
            return
        }
        
        let animalDetailURL = baseUrl.appendingPathComponent("animals/\(animalName)")
        
        var request = URLRequest(url: animalDetailURL)
        request.httpMethod = HTTPMethod.get.rawValue
        request.addValue("Bearer \(bearer.token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse,
                response.statusCode == 401 {
                completion(.failure(.badAuth))
                return
            }
            
            if let _ = error {
                completion(.failure(.otherError))
                return
            }
            
            guard let data = data else {
                completion(.failure(.badData))
                return
            }
            
            let jsonDecoder = JSONDecoder()
            jsonDecoder.dateDecodingStrategy = .secondsSince1970
            
            do {
                let animal = try jsonDecoder.decode(Animal.self, from: data)
                completion(.success(animal))
            } catch {
                NSLog("Error decoding animal objects: \(error)")
                completion(.failure(.noDecode))
                return
            }
        }.resume()
    }
    
    //create function to fetch image
    
    func fetchImage(at urlString: String, completion: @escaping (Result<UIImage, NetworkError>)-> Void) {
        
        let imageUrl = URL(string: urlString)!
        var request = URLRequest(url: imageUrl)
        request.httpMethod = HTTPMethod.get.rawValue
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let _ = error {
                completion(.failure(.otherError))
                return
            }
            
            guard let data = data else {
                completion(.failure(.badData))
                return
            }
            let image = UIImage(data: data)!
            completion(.success(image))
        }.resume()
    }
    
}
    /*
    var bearer: Bearer?
    
    // create function for sign up  POST - we need URLRequest so we specify that we are posting if it is GET then we do not need it
    func signUp(with user: User, completion: @escaping (Error?) -> ()) {
        //Create endpoint URL
        let signUpURL = baseUrl.appendingPathComponent("users/signup")
        
        //Set up request - this would not be needed if it is GET because default is GET
        var request = URLRequest(url: signUpURL)
        request.httpMethod = HTTPMethod.post.rawValue   //giving this POST because required method is POST
        request.setValue("application/json", forHTTPHeaderField: "Content-Type") //content type of file is json - this is setting what kind of data this is going to be
        
        //initialize JSON Encoder
        let jsonEncoder = JSONEncoder()
        
        
        // Encode the data, catch errors
        do {
            let jsonData = try jsonEncoder.encode(user)  //user object which has username and password
            request.httpBody = jsonData
        } catch {
            NSLog("Error encoding user object: \(error)")
            completion(error)
            return
        }
        //by posting signUp we arent getting any data back so we set it as underscore
        //Create Data Task, handle bad response and errors
        URLSession.shared.dataTask(with: request) { (_, response, error) in   //when you use request, this is when GET/POST/PUT/DELETE is required. if you are just doing GET you do not need to create URLrequest because default value of this is GET
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                completion(NSError(domain: "", code: response.statusCode, userInfo: nil))
                return
            }
            
            if let error = error {
                completion(error)
                return
            }
            completion(nil)     //from Error within closure
        }.resume()
    }
    
    // create function for sign in POST
    func signIn(with user: User, completion:@escaping (Error?) -> ()) {
        let loginURL = baseUrl.appendingPathComponent("users/login")
        
        var request = URLRequest(url: loginURL)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonEncoder = JSONEncoder()
        
        do {
            let jsonData = try jsonEncoder.encode(user)
            request.httpBody = jsonData  //for post or put
        } catch {
            NSLog("Error encoding user object: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in  //we want to handle the data here because we are getting token back
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                completion(NSError(domain: "", code: response.statusCode, userInfo: nil))
                return
            }
            
            if let error = error {
                completion(error)
                return
            }
            
            // we are setting this because token being downloaded as data for us to store
            guard let data = data else {
                completion(NSError())
                return
            }
            
            //we are decoding here because we are getting data (token) so it can be stored into Bearer object as token String
            
            let decoder = JSONDecoder()
            
            do {
                self.bearer = try decoder.decode(Bearer.self, from: data)   //same format as our Bearer object so no need to change anything
                
            } catch {
                NSLog("Error decoding bearer object: \(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
    // create function for fetching all animal names GET
    // authentication is required to get these datas
    func fetchAllAnimalNames(completion:@escaping (Result<[String], NetworkError>)->Void) {
        guard let bearer = self.bearer else {
            completion(.failure(.noAuth))   //if bearer does not exist then it cannot even be judged whether it is bad or good
            return
        }
        
        let allAnimalsURL = baseUrl.appendingPathComponent("animals/all")
        
        //we are using URLRequest even though it is GET becaue we need to pass required headervalue accodring to API document
        var request = URLRequest(url: allAnimalsURL)
        request.httpMethod = HTTPMethod.get.rawValue
        request.addValue("Bearer \(bearer.token)", forHTTPHeaderField: "Authorization")  //creating headerValue Authorization being key and bearer.token being value
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse,
                response.statusCode == 401 {
                completion(.failure(.badAuth)) //unauthorized access
                return
            }
            
            if let _ = error {   //undersocre was used here because it is not going to be used within {}
                completion(.failure(.otherError)) //if there is an error it would be "other error"
                return
            }
            
            guard let data = data else { //if data does not exist and baddata
                completion(.failure(.badData))
                return
            }
            
            // we are decoding it because we are getting datas from here
            let decoder = JSONDecoder()
            
            do {
                let animalNames = try decoder.decode([String].self, from: data)
                
//               [ "Lion",
//                "Zebra",
//                "Flamingo"]
                
                completion(.success(animalNames)) //.success([String]) becuase of closue set up (Result<[String], NetworkError>)->Void
            } catch {
                NSLog("Error decoding animal objects: \(error)")
                completion(.failure(.noDecode))   //in case there is no decoding happening it shows noDecode error
                return
            }
        }.resume()
    }
    
    // create function to fetch details of animal GET
    // we also get response (such as 200, 400). getting data is getting actual datas not just response
    func fetchDetailsForAnimal(for animalName: String, completion: @escaping (Result<Animal, NetworkError>)->Void) {
        guard let bearer = self.bearer else {
            completion(.failure(.noAuth))
            return
        }
        
        let animalURL = baseUrl.appendingPathComponent("animals/\(animalName)") //this is how url should be based on API document
        
        var request = URLRequest(url: animalURL)  //we use this here even though this is GET because haedervalue is required to "GET"
        request.httpMethod = HTTPMethod.get.rawValue
        request.addValue("Bearer \(bearer.token)", forHTTPHeaderField: "Authorization")  //Bearer \(bearer.token) is what the value shoud be

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse,
                response.statusCode == 401 {
                completion(.failure(.noAuth))
                return
            }
            
            if let _ = error {
                completion(.failure(.otherError))
                return
            }
            
            guard let data = data else {
                completion(.failure(.badData))
                return
            }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970  //this will make random non sense number into actual date
            
            do {
                let animal = try decoder.decode(Animal.self, from: data)  //Animal.self is fine because same format as object we have
                completion(.success(animal)) // animal is String which makes sense with Result<String, NetworkError>
               /*
                {
                    "id": 1,
                    "name": "Lion",
                    "latitude": 41.0059666,
                    "longitude": -8.596247,
                    "timeSeen": 1476381432,
                    "description": "A large tawny-colored cat that lives in prides, found in Africa and northwestern India. The male has a flowing shaggy mane and takes little part in hunting, which is done cooperatively by the females.",
                }
            */
            } catch {
                NSLog("Error decoding animal object: \(error)")
                completion(.failure(.noDecode))
                return
            }
        }.resume()
    }
    
    // create function to fetch image GET
    //"imageURL": "https://user-images.githubusercontent.com/16965587/57208108-357e8000-6f8f-11e9-89fa-acd05e383c63.jpg"
    func fetchImage(at urlString: String, completion: @escaping (Result<UIImage, NetworkError>)->Void) {
        let imageURL = URL(string: urlString)!
        
        var request = URLRequest(url: imageURL)
        request.httpMethod = HTTPMethod.get.rawValue
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let _ = error {
                completion(.failure(.otherError))
                return
            }
            
            guard let data = data else {
                completion(.failure(.badData))
                return
            }
            
            let image = UIImage(data: data)! //for the images no decoding needed because it comes in as an image data so you just need to change it to UIImage
            completion(.success(image))  // Result<UIImage, NetworkError>  here image = UIImage
        }.resume()
    }
 */

