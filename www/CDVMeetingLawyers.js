var exec = require("cordova/exec");

exports.initialize = function (apikey, env, success, error) {
  exec(success, error, "CDVMeetingLawyers", "initialize", [apikey, env]);
};

exports.authenticate = function (userid, success, error) {
  exec(success, error, "CDVMeetingLawyers", "authenticate", [userid]);
};

exports.setFcmToken = function (userid, success, error) {
  exec(success, error, "CDVMeetingLawyers", "setFcmToken", [userid]);
};

exports.openList = function (success, error) {
  exec(success, error, "CDVMeetingLawyers", "openList", []);
};

exports.primaryColor = function (color) {
  exec(function() {}, function(error) {}, "CDVMeetingLawyers", "primaryColor", [color]);
};

exports.secondaryColor = function (color) {
  exec(function() {}, function(error) {}, "CDVMeetingLawyers", "secondaryColor", [color]);
};
