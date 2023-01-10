var exec = require("cordova/exec");

// exports.coolMethod = function (arg0, success, error) {
//     exec(success, error, 'MeetingLawyers', 'coolMethod', [arg0]);
// };

exports.echo = function (arg0, success, error) {
  exec(success, error, "CDVMeetingLawyers", "echo", [arg0]);
};

exports.echojs = function (arg0, success, error) {
  if (arg0 && typeof arg0 === "string" && arg0.length > 0) {
    success(arg0);
  } else {
    error("Empty message!");
  }
};

exports.initialize = function (apikey, env, success, error) {
  exec(success, error, "CDVMeetingLawyers", "initialize", [apikey, env]);
};

exports.authenticate = function (userid, success, error) {
  exec(success, error, "CDVMeetingLawyers", "authenticate", [userid]);
};
