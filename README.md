## Summary:
Rhythmics is an iOS application that measures heart rate and HRV levels and sends vibrational haptics to users when stress levels rise.

## Function
The app is initiated during a focused work session through the "Start Session" button. The start button initiates data collection on the Apple Watch. 
The iOS application interfaces with Apple Healthkit and WatchOS to monitor Heart Rate (HR) and Heart Rate Variability (HRV) levels. 
When HR or HRV exceeds a certain threshold, the iOS app initiates a "de-stressor protocol," which simultaneously initiates haptic vibrations via an Arduino Nano and starts playing the user's desired calming playlist.

### Spotify Integration
Spotify is integrated into the application through the [Spotify SDK]([url](https://developer.spotify.com/documentation/ios)). The user preselects their desired playlist within the application. 
When the "destress" protocol is initiated, Spotify begins playing this playlist automatically. The user can control the music through the Rhythmics app.

### Apple Watch Integration
The Apple Watch is integrated through WatchOS and Apple Healthkit. The watch constantly monitors HR and HRV levels. When HR elevates or HRV decreases past the threshold, the Watch pings the iPhone to initiate the destress protocol.
The watch continues to monitor as the HR and HRV return to baseline. After returning to baseline, the Watch sends another signal to the iPhone to terminate destressor mode. The Watch displays the current Heart Rate and HRV levels throughout the session.

### iPhone Integration
The iPhone acts as the primary hub for data flow. The user starts a session by pressing the "Start Session" button. This initiates data collection on the Apple Watch. The Apple Watch then sends signals to the iPhone to initiate de-stressor protocol.
The iPhone sends a signal to an Arduino Uno via Bluetooth to send a vibrational pattern to a haptic device. Simultaneously, the iPhone begins playing music on the Spotify application. The user can control the music directly within the Rhythmics app. 
Additionally, they may see the data from the previous session. The user can also see that the Arduino is connected in the top left corner.
## Current Bugs
During the development of this application, xCode was having difficulties connecting to Apple Watch. Therefore, our team instead installed a manual start/stop button to initiate de-stressor protocols. 
Additionally, although we connected the App to Spotify, we had difficulties fully implementing the Spotify control.
