//
//  Constants.swift
//  Rhythmics
//
//  Created by Sam Goldberg on 4/21/24.
//
import Foundation


let SpotifyClientID = "a1313c38f6d94985941fc21b977b60e3"
let SpotifyRedirectURL = URL(string: "spotify-ios-quick-start://spotify-login-callback")!

var configuration = SPTConfiguration(
  clientID: SpotifyClientID,
  redirectURL: SpotifyRedirectURL
)
