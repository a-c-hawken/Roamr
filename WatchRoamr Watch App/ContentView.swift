//
//  ContentView.swift
//  WatchRoamr Watch App
//
//  Created by Aydan Hawken on 18/07/23.
//

import SwiftUI
import AuthenticationServices

struct ContentView: View {
    @State private var name = " "
    
    var body: some View {
        VStack {
            TextField("Search", text: $name)
                .padding()
            Button("Search", action: signInWithGoogle)
                .padding()
        }
    }
    
    func signInWithGoogle() {
        let textSearch = name.replacingOccurrences(of: " ", with: "+")
        guard let url = URL(string: "https://www.google.com/search?q=" + textSearch) else { return }
        
        // Initialize an ASWebAuthenticationSession
        let session = ASWebAuthenticationSession(url: url, callbackURLScheme: nil) { callbackURL, error in
            if let callbackURL = callbackURL {
            } else if let error = error {
            }
        }
        
        // Start the authentication session
        session.start()
    }
}


#Preview {
    ContentView()
}
