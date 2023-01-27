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
    
    @objc(open_list:)
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
    
    @objc(primary_color:)
    func primaryColor(_ command: CDVInvokedUrlCommand) {
        // TODO:
        self.commandDelegate!.send(CDVPluginResult(status: CDVCommandStatus_OK), callbackId: command.callbackId)
    }
    
    
    @objc(secondary_color:)
    func secondaryColor(_ command: CDVInvokedUrlCommand) {
        // TODO:
        self.commandDelegate!.send(CDVPluginResult(status: CDVCommandStatus_OK), callbackId: command.callbackId)
    }
    
    
}