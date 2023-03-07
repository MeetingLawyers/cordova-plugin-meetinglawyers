import MeetingLawyers
import MeetingLawyersSDK
import Combine

@objc(CDVMeetingLawyers) class CDVMeetingLawyers : CDVPlugin {
    var subscriptions:Set<AnyCancellable> = Set<AnyCancellable>()
    // Created as var and set in the initialize of the plugin because otherwise the constants do not work
    var ENV_DEV: String = ""
    var PRIMARY_COLOR: String = ""
    var SECONDARY_COLOR: String = ""
    var NAVIGATION_COLOR: String = ""
    var SPECIALITY_COLOR: String = ""
    
    
    override func pluginInitialize() {
        super.pluginInitialize()
        self.ENV_DEV = "DEVELOPMENT"
        self.PRIMARY_COLOR = "primaryColor"
        self.SECONDARY_COLOR = "secondaryColor"
        self.NAVIGATION_COLOR = "navigationColor"
        self.SPECIALITY_COLOR = "specialityColor"
        self.subscriptions = Set<AnyCancellable>()
    }
    
    @objc(initialize:)
    func initialize(_ command: CDVInvokedUrlCommand) {
        let id = "cordova"
        let apikey = command.arguments[0] as? String ?? ""
        let env = command.arguments[1] as? String ?? ""
        
        var environment: Environment = .production
        if env == self.ENV_DEV {
            environment = .development
        }
        
        if apikey.isEmpty {
            self.commandDelegate!.send(CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Error empty api_key"), callbackId: command.callbackId)
            return
        }
        
        self.commandDelegate.run {
            MeetingLawyersApp.configure(id: id,
                                        apiKey: apikey,
                                        environment: environment)
                .sink { result in
                    if case .finished = result {
                        self.commandDelegate!.send(CDVPluginResult(status: CDVCommandStatus_OK), callbackId: command.callbackId)
                    } else if case let .failure(error) = result {
                        self.commandDelegate!.send(CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error.localizedDescription), callbackId: command.callbackId)
                    }
                } receiveValue: { _ in }
                .store(in: &self.subscriptions)
        }
    }
    
    @objc(authenticate:)
    func authenticate(_ command: CDVInvokedUrlCommand) {
        let userid = command.arguments[0] as? String ?? ""
        
        if userid.isEmpty {
            self.commandDelegate!.send(CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Error empty userid"), callbackId: command.callbackId)
            return
        }
        
        self.commandDelegate.run {
            MeetingLawyersApp.authenticate(token: userid)
                .sink { result in
                    if case .finished = result {
                        self.commandDelegate!.send(CDVPluginResult(status: CDVCommandStatus_OK), callbackId: command.callbackId)
                    } else if case let .failure(error) = result {
                        self.commandDelegate!.send(CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error.localizedDescription), callbackId: command.callbackId)
                    }
                } receiveValue: { _ in }
                .store(in: &self.subscriptions)
        }
    }
    
    // MARK: - FCM

    @objc(setFcmToken:)
    func setFcmToken(_ command: CDVInvokedUrlCommand) {
        let token = command.arguments[0] as? String ?? ""
        
        if token.isEmpty {
            self.commandDelegate!.send(CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Error empty token"), callbackId: command.callbackId)
            return
        }
        
        self.commandDelegate.run {
            MLMediQuo.registerFirebaseForNotifications(token: token) { result in
                result.process(doSuccess: { _ in
                    self.commandDelegate!.send(CDVPluginResult(status: CDVCommandStatus_OK), callbackId: command.callbackId)
                }, doFailure: { error in
                    self.commandDelegate!.send(CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error.localizedDescription), callbackId: command.callbackId)
                })
            }
        }
    }
    
    @objc(onFcmMessage:)
    func onFcmMessage(_ command: CDVInvokedUrlCommand) {
        let data = command.arguments[0] as? String ?? ""
        
        if data.isEmpty {
            self.commandDelegate!.send(CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Error empty data"), callbackId: command.callbackId)
            return
        }
        
        let notificationRequest = self.createNotificationRequest(data)
        
        MLMediQuo.userNotificationCenter(UNUserNotificationCenter.current(),
                                         willPresent: notificationRequest) { result in
            result.process(doSuccess: { _ in
                self.commandDelegate!.send(CDVPluginResult(status: CDVCommandStatus_OK, messageAs: true), callbackId: command.callbackId)
            }, doFailure: { error in
                if case MediQuoError.notificationContentNotBelongingToFramework = error {
                    // No error, push notification not from ML
                    self.commandDelegate!.send(CDVPluginResult(status: CDVCommandStatus_OK, messageAs: false), callbackId: command.callbackId)
                    return
                }
                self.commandDelegate!.send(CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error.localizedDescription), callbackId: command.callbackId)
            })
        }
    }
    
    @objc(onFcmBackgroundMessage:)
    func onFcmBackgroundMessage(_ command: CDVInvokedUrlCommand) {
        let data = command.arguments[0] as? String ?? ""
        
        if data.isEmpty {
            self.commandDelegate!.send(CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Error empty data"), callbackId: command.callbackId)
            return
        }
        
        let notificationRequest = self.createNotificationRequest(data)
        
        MLMediQuo.userNotificationCenter(UNUserNotificationCenter.current(),
                                         didReceive: notificationRequest) { result in
            result.process(doSuccess: { _ in
                self.commandDelegate!.send(CDVPluginResult(status: CDVCommandStatus_OK, messageAs: true), callbackId: command.callbackId)
            }, doFailure: { error in
                if case MediQuoError.notificationContentNotBelongingToFramework = error {
                    // No error, push notification not from ML
                    self.commandDelegate!.send(CDVPluginResult(status: CDVCommandStatus_OK, messageAs: false), callbackId: command.callbackId)
                    return
                }
                self.commandDelegate!.send(CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error.localizedDescription), callbackId: command.callbackId)
            })
        }
    }
    
    private func createNotificationRequest(_ data: String) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.userInfo = ["data" : data]
        
        return UNNotificationRequest(identifier: "com.meetinglawyers.cordova",
                                           content: content,
                                           trigger: nil)
    }
    
    
    // END
    
    @objc(openList:)
    func openList(_ command: CDVInvokedUrlCommand) {
        let messengerResult = MLMediQuo.messengerViewController(showDivider: true)
        if let mlVC: UINavigationController = messengerResult.value {
            mlVC.modalPresentationStyle = .fullScreen
            self.viewController?.present(
                mlVC,
                animated: true,
                completion: nil)
            self.commandDelegate!.send(CDVPluginResult(status: CDVCommandStatus_OK), callbackId: command.callbackId)
            return
        }
        
        self.commandDelegate!.send(CDVPluginResult(status: CDVCommandStatus_ERROR), callbackId: command.callbackId)
    }
    
    // MARK: - STYLE
    
    @objc(setStyle:)
    func setStyle(_ command: CDVInvokedUrlCommand) {
        if let style = command.arguments[0] as? NSDictionary,
           let primaryColorString = style[self.PRIMARY_COLOR] as? String {
            
            let primaryColor = UIColor(hex: primaryColorString)
            let textPrimaryColor = self.textColor(from: primaryColor)
            
            var secondaryColor = primaryColor
            var textSecondaryColor = textPrimaryColor
            var navigationColor = primaryColor
            var textNavigationColor = textPrimaryColor
            var specialityColor = primaryColor
            var textSpecialityColor = textPrimaryColor
            
            // Override secondary color
            if let secondaryColorString = style[self.SECONDARY_COLOR] as? String {
                secondaryColor = UIColor(hex: secondaryColorString)
                textSecondaryColor = self.textColor(from: secondaryColor)
            }
            // Override navigation color
            if let navigationColorString = style[self.NAVIGATION_COLOR] as? String {
                navigationColor = UIColor(hex: navigationColorString)
                textNavigationColor = self.textColor(from: navigationColor)
            }
            // Override speciality color
            if let specialityColorString = style[self.SPECIALITY_COLOR] as? String {
                specialityColor = UIColor(hex: specialityColorString)
                textSpecialityColor = self.textColor(from: specialityColor)
            }
            
            let bubbleColor = UIColor(hex: "#E0E0E0")
            let textBubbleColor = self.textColor(from: bubbleColor)
            
            if var style = MLMediQuo.style {

                style.titleColor = textNavigationColor
                style.navigationBarColor = navigationColor
                style.navigationBarTintColor = textNavigationColor
                style.navigationBarOpaque = false
                style.accentTintColor = primaryColor
                style.preferredStatusBarStyle = self.statusBarStyle(from: navigationColor)
                style.titleFont = UIFont.boldSystemFont(ofSize: 16)
                style.inboxTitle = nil
                
                style.bubbleBackgroundIncomingColor = bubbleColor
                style.messageTextIncomingColor = textBubbleColor
                style.bubbleBackgroundOutgoingColor = primaryColor
                style.messageTextOutgoingColor = textPrimaryColor
                style.secondaryTintColor = secondaryColor

                style.inboxCellStyle = MediQuoInboxCellStyle.mediquo(overlay: primaryColor.withAlphaComponent(0.2),
                                                                     badge: secondaryColor,
                                                                     speciality: specialityColor,
                                                                     specialityIcon: UIColor.clear,
                                                                     hideSchedule: false)
                
                
                // MARK: VideoCall

                style.videoCallIconDoctorBackgroundColor = UIColor(hex: "#E8E9E1")
                style.videoCallBackgroundImage = nil
                
                // TOP
                style.videoCallTopBackgroundColor = primaryColor
                style.videoCallTopBackgroundImageTintColor = nil
                style.videoCallTitleTextColor = textPrimaryColor
                
                // BOTTOM
                style.videoCallBottomBackgroundColor = .white
                style.videoCallBottomBackgroundImageTintColor = nil
                style.videoCallNextAppointmentTextColor = .black // waiting videocall next appointment
                style.videoCallProfessionalNameTextColor = .black // wainting videocall doctor not asigned yet
                style.videoCallProfessionalSpecialityTextColor = specialityColor
                
                style.videoCallAcceptButtonBackgroundColor = UIColor(red: 3 / 255, green: 243 / 255, blue: 180 / 255, alpha: 1.0)
                style.videoCallCancelButtonBackgroundColor = UIColor(red: 239 / 255, green: 35 / 255, blue: 54 / 255, alpha: 1.0)
                style.videoCallCancelButtonTextColor = .white
                style.videoCallAcceptButtonTextColor = .white

                MLMediQuo.style = style
            }
            
            MLMediQuo.updateStyle()
            
            self.commandDelegate!.send(CDVPluginResult(status: CDVCommandStatus_OK), callbackId: command.callbackId)
        } else {
            self.commandDelegate!.send(CDVPluginResult(status: CDVCommandStatus_ERROR), callbackId: command.callbackId)
        }
    }
    
    private func textColor(from color: UIColor) -> UIColor {
        return color.isLight ? UIColor.black : UIColor.white
    }
    
    private func statusBarStyle(from color: UIColor) -> UIStatusBarStyle {
        return color.isLight ? .darkContent : .lightContent
    }

    @objc(setNavigationImage:)
    func setNavigationImage(_ command: CDVInvokedUrlCommand) {
        let imageName = command.arguments[0] as? String ?? ""
        if let image = UIImage(named: imageName),
            image.size.height != 0 {
            // Default frame
            let titleViewFrame = CGRect(x: 0, y: 0, width: 390, height: 44)
            
            // Create views
            let imageView = UIImageView(image: image)
            let containerView = UIView(frame: titleViewFrame)
            containerView.addSubview(imageView)
            // Configure title aspect and style
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            // Constraint image position inside title view
            containerView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: titleViewFrame.height - 10))
            containerView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: containerView, attribute: .centerX, multiplier: 1, constant: 0))
            containerView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: containerView, attribute: .centerY, multiplier: 1, constant: 0))
            
            if var style = MLMediQuo.style {
                style.titleView = containerView
                MLMediQuo.style = style
            }

            MLMediQuo.updateStyle()

            self.commandDelegate!.send(CDVPluginResult(status: CDVCommandStatus_OK), callbackId: command.callbackId)
        } else {
            self.commandDelegate!.send(CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Invalid image path: \(imageName)"), callbackId: command.callbackId)
        }
    }
    
    // END
}
