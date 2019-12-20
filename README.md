# dotfiles
 dotfiles

## .vscode-powertools/

[vscode-powertools](https://marketplace.visualstudio.com/items?itemName=ego-digital.vscode-powertools) commands.

### journal.js

Improved Performance [vscode-journal](https://marketplace.visualstudio.com/items?itemName=pajoma.vscode-journal) journal.day command.

Setting sample:

```js:settings.json
"journal.base": "your journal directory",
"journal.tpl-entry": "# ${localDate}(${weekday})\n\n## Tasks\n\n\n\n## Notes\n\n",
"journal.locale": "ja-JP",
"journal.ext": "md",
"ego.power-tools.user": {
    "commands": {
        "myjournal.open": {
            "name": "Open Journal file",
            "script": "journal.js",
        },
        "myjournal.previous": {
            "name": "Open Previous Journal file",
            "script": "journal-prev.js",
        }
    }
}
```

```js:keybindings.json
{
    "key": "ctrl+shift+j",
    "command": "myjournal.open"
},
{
    "key": "ctrl+shift+alt+P",
    "command": "myjournal.previous",
}
```
