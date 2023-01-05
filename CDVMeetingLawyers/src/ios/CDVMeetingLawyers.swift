@objc(CDVMeetingLawyers) class CDVMeetingLawyers : CDVPlugin {
    @objc(echo:)
    func echo(_ command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult(
            status: CDVCommandStatus_ERROR
        )
        
        let msg = command.arguments[0] as? String ?? ""
        
        if msg.characters.count > 0 {
            /* UIAlertController is iOS 8 or newer only. */
            let toastController: UIAlertController =
            UIAlertController(
                title: "",
                message: msg,
                preferredStyle: .alert
            )
            

            self.viewController?.present(
                toastController,
                animated: true,
                completion: nil
            )
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0)
            {
                toastController.dismiss(
                    animated: true,
                    completion: nil
                )
            }
            
            pluginResult = CDVPluginResult(
                status: CDVCommandStatus_OK,
                messageAs: msg
            )
        }
        
        self.commandDelegate!.send(
            pluginResult,
            callbackId: command.callbackId
        )
    }
}
