import MeetingLawyers
import MeetingLawyersSDK
import Combine

@objc(CDVMeetingLawyers) class CDVMeetingLawyers : CDVPlugin {
    var subscriptions:Set<AnyCancellable> = Set<AnyCancellable>()
    var ENV_DEV: String = ""
    
    override func pluginInitialize() {
        super.pluginInitialize()
        self.ENV_DEV = "DEVELOPMENT"
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

    @objc(setFcmToken:)
    func setFcmToken(_ command: CDVInvokedUrlCommand) {
        let token = command.arguments[0] as? String ?? ""
        
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
    
    @objc(primaryColor:)
    func primaryColor(_ command: CDVInvokedUrlCommand) {
        let colorString = command.arguments[0] as? String ?? ""
        let color = UIColor(hex: colorString)
        let textColor = self.textColor(from: color)
        
        let bubbleColor = UIColor(hex: "#E0E0E0")
        let textBubbleColor = self.textColor(from: bubbleColor)
        
        if var style = MLMediQuo.style {

            style.titleColor = textColor
            style.navigationBarColor = color
            style.navigationBarTintColor = textColor
            style.navigationBarOpaque = false
            style.accentTintColor = color
            style.preferredStatusBarStyle = self.statusBarStyle(from: color)
            style.titleFont = UIFont.boldSystemFont(ofSize: 16)
            style.inboxTitle = nil
            
            style.bubbleBackgroundIncomingColor = bubbleColor
            style.messageTextIncomingColor = textBubbleColor
            style.bubbleBackgroundOutgoingColor = color
            style.messageTextOutgoingColor = textColor

            style.inboxCellStyle = MediQuoInboxCellStyle.mediquo(overlay: color.withAlphaComponent(0.2),
                                                                 badge: color,
                                                                 speciality: color,
                                                                 specialityIcon: UIColor.clear,
                                                                 hideSchedule: false)
            
            
            // MARK: VideoCall

            style.videoCallIconDoctorBackgroundColor = UIColor(hex: "#E8E9E1")
            style.videoCallBackgroundImage = nil
            
            // TOP
            style.videoCallTopBackgroundColor = color
            style.videoCallTopBackgroundImageTintColor = nil
            style.videoCallTitleTextColor = color
            
            // BOTTOM
            style.videoCallBottomBackgroundColor = .white
            style.videoCallBottomBackgroundImageTintColor = nil
            style.videoCallNextAppointmentTextColor = .black // waiting videocall next appointment
            style.videoCallProfessionalNameTextColor = .black // wainting videocall doctor not asigned yet
            
            style.videoCallAcceptButtonBackgroundColor = UIColor(red: 3 / 255, green: 243 / 255, blue: 180 / 255, alpha: 1.0)
            style.videoCallCancelButtonBackgroundColor = UIColor(red: 239 / 255, green: 35 / 255, blue: 54 / 255, alpha: 1.0)
            style.videoCallCancelButtonTextColor = .white
            style.videoCallAcceptButtonTextColor = .white

            MLMediQuo.style = style
        }
        
        MLMediQuo.updateStyle()
        
        self.commandDelegate!.send(CDVPluginResult(status: CDVCommandStatus_OK), callbackId: command.callbackId)
    }
    
    
    @objc(secondaryColor:)
    func secondaryColor(_ command: CDVInvokedUrlCommand) {
        let colorString = command.arguments[0] as? String ?? ""
        let color = UIColor(hex: colorString)
        let textColor = self.textColor(from: color)
        
        if var style = MLMediQuo.style {

            style.secondaryTintColor = color
            style.videoCallProfessionalSpecialityTextColor = color
            
            let primary: UIColor = style.navigationBarColor ?? color
            
            style.inboxCellStyle = MediQuoInboxCellStyle.mediquo(overlay: primary.withAlphaComponent(0.2),
                                                                 badge: color,
                                                                 speciality: color,
                                                                 specialityIcon: UIColor.clear,
                                                                 hideSchedule: false)

            MLMediQuo.style = style
        }
        
        MLMediQuo.updateStyle()
        
        self.commandDelegate!.send(CDVPluginResult(status: CDVCommandStatus_OK), callbackId: command.callbackId)
    }
    
    private func textColor(from color: UIColor) -> UIColor {
        return color.isLight ? UIColor.black : UIColor.white
    }
    
    private func statusBarStyle(from color: UIColor) -> UIStatusBarStyle {
        return color.isLight ? .darkContent : .lightContent
    }
}