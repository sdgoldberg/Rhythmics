//
//  TestView.swift
//  Rhythmics
//
//  Created by Sam Goldberg on 4/22/24.
//

import Foundation
import SwiftUI

struct TestView: View {
    var body: some View {
        Button("Test Redirect") {
            // Replace "your-redirect-scheme" with your app's URL scheme
            if let url = URL(string: "Rhythmics://spotify-login-callback") {
                UIApplication.shared.open(url) // Attempts to open the URL, triggering your app
                print("URL redirected")
            }
        }
    }
}
