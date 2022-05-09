//
//  ViewController.swift
//  CombineUIKitProject
//
//  Created by Michael Novosad on 09.05.2022.
//

import UIKit
import Combine

struct BlogPost {
    let title: String
    let url: URL
}

class ViewController: UIViewController {
    
    @IBOutlet weak var acceptTermsSwitch: UISwitch!
    
    @IBOutlet weak var makePostButton: UIButton!
    
    @IBOutlet weak var postLabel: UILabel!
    
    var cancellables = Set<AnyCancellable>()
    
    @Published
    var canMakePost: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        $canMakePost
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: makePostButton)
            .store(in: &cancellables)
        
        setupCombine()
    }
    
    private func setupCombine() {
        let blogPostPublisher =
        NotificationCenter.Publisher(center: .default,
                                     name: .newBlogPost,
                                     object: nil)
        .map({ (notification) -> String? in
            (notification.object as? BlogPost)?.title ?? ""
        })
        .eraseToAnyPublisher()
        
        let postLabelSubscriber = Subscribers.Assign(object: postLabel, keyPath: \.text)
        blogPostPublisher.subscribe(postLabelSubscriber)
    }

    
    @IBAction func toggleSwitch(_ sender: UISwitch) {
        canMakePost = sender.isOn
    }
    
    @IBAction func makePostAction(_ sender: Any) {
        let blogPost = BlogPost(title: "Blog Post\n Current time is \(Date())", url: URL(string: "Someurl")!)
        NotificationCenter.default.post(name: .newBlogPost, object: blogPost)
    }
    
}

extension Notification.Name {
    
    static let newBlogPost = Notification.Name("newBlogPost")
    
}
