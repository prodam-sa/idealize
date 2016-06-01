function ready(block) {
  /in/.test(document.readyState) ? setTimeout('ready(' + block + ')', 9) : block();
}
