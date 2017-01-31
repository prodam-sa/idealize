var dialog = document.querySelector('dialog');
var buttons = document.querySelectorAll('.mdl-button--open-dialog');

if (!dialog.showModal) {
  dialogPolyfill.registerDialog(dialog);
}

var openDialog = function() {
  dialog.showModal();
}

for (i = 0; i <= buttons.length - 1; i++) {
  buttons[i].addEventListener('click', openDialog);
}

dialog.querySelector('.mdl-button--close-dialog').addEventListener('click', function() {
  dialog.close();
});
