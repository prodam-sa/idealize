var dialog = document.querySelector('dialog');
var button = document.querySelector('#dialog-show');
if (! dialog.showModal) {
  dialogPolyfill.registerDialog(dialog);
}
button.addEventListener('click', function() {
  dialog.showModal();
});
dialog.querySelector('.mdl-button--close-dialog').addEventListener('click', function() {
  dialog.close();
});
