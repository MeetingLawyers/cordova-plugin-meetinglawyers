var exec = require("cordova/exec");

exports.initialize = function (apikey, env, success, error) {
  exec(success, error, "CDVMeetingLawyers", "initialize", [apikey, env]);
};

exports.authenticate = function (userid, success, error) {
  exec(success, error, "CDVMeetingLawyers", "authenticate", [userid]);
};

exports.open_list = function (success, error) {
  exec(success, error, "CDVMeetingLawyers", "open_list", []);
};

exports.primaryColor = function (color) {
  exec(function() {}, function(error) {}, "CDVMeetingLawyers", "primary_color", [color]);
};

exports.secondaryColor = function (color) {
  exec(function() {}, function(error) {}, "CDVMeetingLawyers", "secondary_color", [color]);
};
