func loginWithFacebook(inBackground: Bool = false) {

  if let currentFacebookToken = FBSDKAccessToken.current() {

    // Graph call to extend the token
    FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "email"]).start(completionHandler: {
      [weak self] (connection, result, error) -> Void in

      let error = error as? NSError
      let result = result as AnyObject?

      guard let unwrappedSelf = self else {
        log.severe("loginWithFacebook .self does not exist")
        return
      }

      if error != nil &&  error?.code == NSURLErrorNotConnectedToInternet {
        //no internet connection, we shouldn't log the user out.
        log.info("no internet connection, could not renew facebook token, returning")
        return
      }

      if result != nil, let email = result?["email"] as? String   {
        if let newFacebookToken = FBSDKAccessToken.current() {

          // Server Request for Login
        } else {
          log.error("Cannot get Facebook Access Token")
        }

      } else {
        if let error = error {
          log.error("\(error)")
        }

      }
    })


  } else {
    log.debug("No Facebook Access Token!!")

    // We don't have a valid token so we need to show the UI to ask permissions
    facebookLoginManager.logIn(withReadPermissions: ["email"], from: nil) {
      [weak self] (result, error) -> Void in

      guard let unwrappedSelf = self else {
        log.severe("UserService, loginWithFacebook .self does not exist")
        return
      }

      let error = error as NSError?

      if error != nil {


        if let localizedError = error?.userInfo[FBSDKErrorLocalizedDescriptionKey] as? String,
          let developerError = error?.userInfo[FBSDKErrorDeveloperMessageKey] as? String {
          log.warning("Facebook login failed with error \(developerError)")
          log.warning("user facing error \(localizedError)")


        }

      } else if (result?.isCancelled)! {
        log.info("User aborted Facebook login")

      } else {
        // Recursive call to this method to login to server with new token
        unwrappedSelf.loginWithFacebook(inBackground: inBackground)
      }
    }
    
  }
}
