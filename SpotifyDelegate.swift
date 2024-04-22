
//
//  SpotifyDelegate.swift
//  Rhythmics
//
//  Created by Sam Goldberg on 4/21/24.
//

import Foundation

//Implement Remote Delegates
//We'll need to implement two delegates: SPTAppRemoteDelegate and SPTAppRemotePlayerStateDelegate. These will respectively provide connection and playback state methods to implement inside of our AppDelegate.swift:
class SpotifyDelegate: UIResponder, UIApplicationDelegate, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate {
    let accessTokenKey = "access-token-key"
    var accessToken: String?
    var playURI: String = ""
    var previousPlaylistURI: String? // To store the previous playlist URI
    var shouldReturnToPreviousPlaylist: Bool = false // Flag to indicate returning
    @Published var isPlaying: Bool = false // Published variable to track play/pause state
    
    lazy var configuration = SPTConfiguration(
      clientID: SpotifyClientID,
      redirectURL: SpotifyRedirectURL
    )
    

    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    print("Received URL:", url) // Check if the function is called
      let parameters = appRemote.authorizationParameters(from: url);
        print("test2")
        if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
            appRemote.connectionParameters.accessToken = access_token
            self.accessToken = access_token
            appRemote.connectionParameters.accessToken = self.accessToken
        } else if let error_description = parameters?[SPTAppRemoteErrorDescriptionKey] {
            // Show the error

            }
      return true
    }

    func connect() {
      print("authorizing")
      self.appRemote.authorizeAndPlayURI(self.playURI)
    }
    lazy var appRemote: SPTAppRemote = {
      let appRemote = SPTAppRemote(configuration: self.configuration, logLevel: .debug)
      appRemote.connectionParameters.accessToken = self.accessToken
      appRemote.delegate = self
      print("test")
      return appRemote
    }()
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        // Connection was successful, you can begin issuing commands
        print("Spotify connection established")
        self.appRemote.playerAPI?.delegate = self
        self.appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in
          if let error = error {
            debugPrint(error.localizedDescription)
          }
        })
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: (any Error)?) {
        print("test1)")
        if let error = error {
            debugPrint("Connection attempt failed:", error)
        }
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: (any Error)?) {
        print("test2")
    }
   
    // Play calming music and set previous playlist URI
    func playCalmingMusic() {
        appRemote.playerAPI?.getPlayerState { [weak self] (result, error) in
        if let state = result as? SPTAppRemotePlayerState {
            self?.previousPlaylistURI = state.contextURI.absoluteString // Store current context URI as a string
            self?.shouldReturnToPreviousPlaylist = true // Set flag to return
            // Play calming music
            self?.appRemote.playerAPI?.play("spotify:playlist:37i9dQZF1DWXe9gFZP0gtP?si=TPgVgHAgR1K4tNIZdP78kw&pi=u-4BvE70lvSv68")
        }
      }
    }
    
    // Return to the previous playlist after current song finishes
    func returnToPreviousPlaylist() {
        if shouldReturnToPreviousPlaylist, let previousPlaylistURI = previousPlaylistURI {
            shouldReturnToPreviousPlaylist = false // Reset the flag
            self.appRemote.playerAPI?.play(previousPlaylistURI) // Play the previous playlist
        }
    }
    
    // Handle the "Trigger Normality" action
    func onTriggerNormality() {
      // Set the flag to return to the previous playlist after the current song finishes
      shouldReturnToPreviousPlaylist = true
    }
    func playerStateDidChange(_ playerState: any SPTAppRemotePlayerState) {
        print("player state changed")
        isPlaying = !playerState.isPaused // Update isPlaying based on the Spotify player state
        print("isPaused", playerState.isPaused)
        print("track.uri", playerState.track.uri)
        print("track.name", playerState.track.name)
        print("track.imageIdentifier", playerState.track.imageIdentifier)
        print("track.artist.name", playerState.track.artist.name)
        print("track.album.name", playerState.track.album.name)
        print("track.isSaved", playerState.track.isSaved)
        print("playbackSpeed", playerState.playbackSpeed)
        print("playbackOptions.isShuffling", playerState.playbackOptions.isShuffling)
        print("playbackOptions.repeatMode", playerState.playbackOptions.repeatMode.hashValue)
        print("playbackPosition", playerState.playbackPosition)
    }
    func applicationWillResignActive(_ application: UIApplication) {
      if self.appRemote.isConnected {
        self.appRemote.disconnect()
        print("Spotfiy Disconnected")
      }
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        if let accessToken = self.accessToken {
            self.appRemote.connect()
        } else {
            // Reauthorize
            self.connect()
        }
    }
}

