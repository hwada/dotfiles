exports.execute = async args => {
    const vscode = args.require('vscode');
    const fs = args.require('fs');
    const path = args.require('path');
    const journal = require('./journal.js');

    const currentFile = vscode.window.activeTextEditor.document.uri.path;
    let offsetDays = 0; // today
    if (currentFile) { 
        // YYYYMMDD -> YYYY-MM-DD (決め打ち)
        const fileName = path.basename(currentFile, path.extname(currentFile));
        const date = new Date(`${fileName.substr(0, 4)}-${fileName.substr(4, 2)}-${fileName.substr(6, 2)}`);
        offsetDays = Math.round((Date.now() - date.getTime()) / (1000*60*60*24));
    }

    // 直近10日前まで遡って、最初に見つかったファイルを開く
    // (getJournalFileの効率が悪いし、1ヶ月空いてもいいようにしたいし、もうちょっとうまくやりたい)
    for (let i = 1; i <= 10; ++i) {
        const offset = -(i + offsetDays);
        const fileName = journal.getJournalFile(args, offset);
        if (fs.existsSync(fileName)) {
            vscode.commands.executeCommand("vscode.open", vscode.Uri.file(fileName));
            return;
        }
    }
};