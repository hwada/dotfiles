function getJournalFile(args, offset) {
    const vscode = args.require('vscode');
    const path = args.require('path');
    const moment = args.require('moment');
    const config = vscode.workspace.getConfiguration("journal");

    moment.locale(config.get('locale')); // journal.locale

    const base = config.get('base'); // journal.base
    const ext = config.get('ext'); // journal.ext
    const day = moment(Date.now()).add(offset, 'days');
    const parent = path.join(base, day.format('YYYY'), day.format('MM'));
    return [day, parent, path.join(parent, `${day.format('YYYYMMDD')}.${ext}`)];
}

async function openJournal(args, offset) {
    const vscode = args.require('vscode');
    const fs = args.require('fs');
    const fsExtra = args.require('fs-extra');

    const [day, parent, fileName] = getJournalFile(args, offset);

    if (!fs.existsSync(fileName)) {
        fsExtra.mkdirpSync(parent);

        const config = vscode.workspace.getConfiguration("journal");
        let template = config.get('tpl-entry');  // journal.tpl-entry
        template = template.replace('${localDate}', day.format('LL'));
        template = template.replace('${weekday}', day.format('dddd'));
        fs.writeFileSync(fileName, template, err => console.error(err));
    }

    await vscode.commands.executeCommand("vscode.open", vscode.Uri.file(fileName));
}

async function pickJournalOffset(args) {
    const disposables = [];
    try {
        return await new Promise((resolve, _) => {
            const vscode = args.require('vscode');
            const input = vscode.window.createQuickPick();
            input.items = [
                {label: 'Today', parsedInput: 0, alwaysShow: true},
                {label: 'Yesterday', parsedInput: -1, alwaysShow: true},
                {label: 'Tomorrow', parsedInput: +1, alwaysShow: true}
            ];

            input.onDidAccept(() => {
                const offset = input.value.length === 0 ? input.selectedItems[0].parsedInput : parseInt(input.value);
                resolve(offset);
            }, disposables);

            input.onDidHide(() => {
                input.dispose();
            }, disposables);

            input.show();
        });
    } finally {
        disposables.forEach(d => d.dispose());
    }
}

exports.getJournalFile = (args, offset) => {
    const arr = getJournalFile(args, offset);
    return arr[arr.length - 1];
}

exports.open = async (args, offset) => {
    openJournal(args, offset);
};

exports.execute = async args => {
    const offset = await pickJournalOffset(args);
    openJournal(args, offset);
};