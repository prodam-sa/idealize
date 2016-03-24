require.config({
  paths: {
    'scribe': '/src/scribe/scribe.min',
    'scribe-plugin-blockquote-command': '/src/scribe-plugin-blockquote-command/scribe-plugin-blockquote-command.min',
    'scribe-plugin-code-command': '/src/scribe-plugin-code-command/scribe-plugin-code-command.min',
    'scribe-plugin-curly-quotes': '/src/scribe-plugin-curly-quotes/scribe-plugin-curly-quotes.min',
    'scribe-plugin-formatter-plain-text-convert-new-lines-to-html': '/src/scribe-plugin-formatter-plain-text-convert-new-lines-to-html/scribe-plugin-formatter-plain-text-convert-new-lines-to-html.min',
    'scribe-plugin-heading-command': '/src/scribe-plugin-heading-command/scribe-plugin-heading-command.min',
    'scribe-plugin-intelligent-unlink-command': '/src/scribe-plugin-intelligent-unlink-command/scribe-plugin-intelligent-unlink-command.min',
    'scribe-plugin-keyboard-shortcuts': '/src/scribe-plugin-keyboard-shortcuts/scribe-plugin-keyboard-shortcuts.min',
    'scribe-plugin-link-prompt-command': '/src/scribe-plugin-link-prompt-command/scribe-plugin-link-prompt-command.min',
    'scribe-plugin-sanitizer': '/src/scribe-plugin-sanitizer/scribe-plugin-sanitizer.min',
    'scribe-plugin-smart-lists': '/src/scribe-plugin-smart-lists/scribe-plugin-smart-lists.min',
    'scribe-plugin-toolbar': '/src/scribe-plugin-toolbar/scribe-plugin-toolbar.min',
    'scribe-plugin-content-cleaner': '/src/scribe-plugin-content-cleaner/scribe-plugin-content-cleaner.min'
  }
});

define('editor', [
  'scribe',
  'scribe-plugin-blockquote-command',
  'scribe-plugin-code-command',
  'scribe-plugin-curly-quotes',
  'scribe-plugin-formatter-plain-text-convert-new-lines-to-html',
  'scribe-plugin-heading-command',
  'scribe-plugin-intelligent-unlink-command',
  'scribe-plugin-keyboard-shortcuts',
  'scribe-plugin-link-prompt-command',
  'scribe-plugin-sanitizer',
  'scribe-plugin-smart-lists',
  'scribe-plugin-toolbar',
  'scribe-plugin-content-cleaner'
] ,
function(
  Scribe,
  scribePluginBlockquoteCommand,
  scribePluginCodeCommand,
  scribePluginCurlyQuotes,
  scribePluginFormatterPlainTextConvertNewLinesToHtml,
  scribePluginHeadingCommand,
  scribePluginIntelligentUnlinkCommand,
  scribePluginKeyboardShortcuts,
  scribePluginLinkPromptCommand,
  scribePluginSanitizer,
  scribePluginSmartLists,
  scribePluginToolbar,
  scribePluginContentCleaner
  ) {
  editor = function(id, defaulMessage) {
    'use strict';

    var editorBase = document.querySelector(id + '.editor');
    var editorToolbar = editorBase.querySelector('.editor__toolbar');
    var editorArea = editorBase.querySelector('.editor__area');
    var editorCode = editorBase.querySelector('.editor__code');

    var scribe = new Scribe(editorArea, {
      allowBlockElements: true
    });

    var platformKey = function() {
      return navigator.platform.toUpperCase().indexOf('MAC') >= 0 ? '⌘' : 'ctrl';
    }

    var ctrlKey = function (event) {
      return (event.metaKey || event.ctrlKey);
    };

    var commandsToKeyboardShortcutsMap = Object.freeze({
      h2: function(event) { return ctrlKey(event) && event.keyCode === 50; }, // 2
      bold: function(event) { return ctrlKey(event) && event.keyCode === 66; }, // b
      italic: function(event) { return ctrlKey(event) && event.keyCode === 73; }, // i
      underline: function(event) { return ctrlKey(event) && event.keyCode === 85; }, // u
      strikeThrough: function(event) { return event.altKey && event.shiftKey && event.keyCode === 83; }, // s
      removeFormat: function(event) { return event.altKey && event.shiftKey && event.keyCode === 76; }, // l
      linkPrompt: function(event) { return ctrlKey(event) && ! event.shiftKey && event.keyCode === 75; }, // k
      unlink: function(event) { return ctrlKey(event) && event.shiftKey && event.keyCode === 75; }, // k,
      insertOrderedList: function(event) { return event.altKey && event.shiftKey && event.keyCode === 78; }, // n
      insertUnorderedList: function(event) { return event.altKey && event.shiftKey && event.keyCode === 66; }, // b
      blockquote: function(event) { return event.altKey && event.shiftKey && event.keyCode === 81; }, // q
      quote: function(event) { return event.altKey && event.shiftKey && event.keyCode === 87; }, // w
      cleanup: function(event) { return event.altKey && event.shiftKey && event.keyCode === 90; }, // z
    });

    function linkValidator(url) {
        if(/dailymail/.test(url)) {
          return {
            valid: false,
            message: "URL é inválida. Tente novamente."
          }
        }

        return {
          valid: true
        };
    }

    scribe.on('content-changed', function updateHTML() {
      editorCode.value = scribe.getHTML();
    });
    editorCode.addEventListener('change', function() {
      scribe.setHTML(this.value);
    });

    scribe.use(scribePluginToolbar(editorToolbar));

    scribe.use(scribePluginBlockquoteCommand());
    scribe.use(scribePluginCodeCommand());
    scribe.use(scribePluginContentCleaner(scribe));
    scribe.use(scribePluginCurlyQuotes());
    scribe.use(scribePluginFormatterPlainTextConvertNewLinesToHtml());
    scribe.use(scribePluginHeadingCommand(2));
    scribe.use(scribePluginIntelligentUnlinkCommand());
    scribe.use(scribePluginKeyboardShortcuts(commandsToKeyboardShortcutsMap));
    scribe.use(scribePluginSmartLists());

    scribe.use(scribePluginLinkPromptCommand({
      validation: linkValidator,
      transforms: {
        post: [function(link) {
          return link.replace('www.guardian.co.uk', 'www.theguardian.com');
        }]
      }
    }));

    scribe.use(scribePluginSanitizer({
      tags: {
        p: {},
        br: {},
        b: {},
        strong: {},
        i: {},
        strike: {},
        blockquote: {},
        code: {},
        ol: {},
        ul: {},
        li: {},
        a: { href: true },
        h2: {},
        u: {},
      }
    }));

    if (editorCode.value) {
      defaulMessage = editorCode.value;
    } else {
      defaulMessage = '<p>' + defaulMessage + '</p>'
    }

    scribe.setContent(defaulMessage);
  }
  return editor;
});
