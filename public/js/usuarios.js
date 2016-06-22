var input = document.querySelector('#pesquisa');
var datalist = input.list;
var list = document.querySelector('#' + input.dataset.list);
var url = '/usuarios/pesquisa.json';

input.placeholder = 'Carregando ...';
datalist.options = null;

fetch(url)
  .then(function(response) {
    return response.json();
  })
  .then(function(json) {
    input.removeAttribute('placeholder');
    datalist.options = null;

    json.data.forEach(function(usuario) {
      var option = document.createElement('option');

      option.id = datalist.id + usuario.id;
      option.value = usuario.id;
      option.innerHTML = usuario.nome;

      if (list.querySelector('#' + list.id + usuario.id)) {
        option.disabled = true;
      }

      datalist.appendChild(option);
    });
  })
  .catch(function(exception) {
    console.log('failed', exception);
  })
;

function addUsuario() {
  var option = datalist.querySelector('#' + datalist.id + this.value);

  if (option) {
    var item = document.createElement('li')
      , itemContent = document.createElement('span')
      , itemAction = document.createElement('span')
      , itemInput = document.createElement('input')
      , itemButton = document.createElement('button')
      , itemIcon = document.createElement('i')
    ;

    item.className = 'mdl-list__item';
    itemContent.className = 'mdl-list__item-primary-content';
    itemAction.className = 'mdl-list__item-secondary-action';
    itemButton.className = 'mdl-button mdl-button--icon mdl-button--raised';
    itemIcon.className = 'material-icons';

    item.id = list.id + this.value;

    itemInput.type = 'hidden';
    itemInput.name = list.id + '[]';
    itemInput.value = this.value;

    itemButton.type = 'button';
    itemButton.addEventListener('click', function(event) {
      option.disabled = false;
      item.remove();
    });

    itemContent.innerHTML = option.innerHTML;
    itemIcon.innerHTML = 'close';

    itemButton.appendChild(itemIcon);
    itemAction.appendChild(itemInput);
    itemAction.appendChild(itemButton);
    item.appendChild(itemContent);
    item.appendChild(itemAction);
    list.appendChild(item);

    option.disabled = true;
    this.value = null;
  }
};

function removeUsuario(event) {
  datalist.querySelector('#' + datalist.id + this.dataset.id).disabled = false;
  document.querySelector('#' + list.id + this.dataset.id).remove();
}

input.addEventListener('keyup', function(event) {
  if (event.which === 13 && this.value > 0) {
    addUsuario();
  }
}, false);

input.addEventListener('input', addUsuario, false);

buttons = list.querySelectorAll('button');

for (i = 0; i < buttons.length; i++) {
  buttons[i].addEventListener('click', removeUsuario, false);
}
