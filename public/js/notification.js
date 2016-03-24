var notification = document.querySelector('.mdl-js-snackbar');
var notificationConfig = {
  message: 'Ok',
  actionHandler: function(event) {},
  actionText: 'Ok',
  timeout: 10000
};
notification.MaterialSnackbar.showSnackbar(notificationConfig);
