/* 文档请参考同目录下的README.md */

// required modules
"use strict";
var path = require('path');
var util = require('util');
var spawn = require('child_process').spawn;
var chalk = require('chalk');
var program = require('commander');
var Promise = require('bluebird');
var Spinner = require('cli-spinner').Spinner;
var fs = Promise.promisifyAll(require('fs'));
// shortcut for console.log
var log = console.log.bind(console);

// commanderjs
program
    .version('0.0.1')
    .usage('[options]')
    .option('-l, --local', '不将ipa文件复制到SMB服务器目录')
    .option('-s, --scheme [value]', '编译Target，默认MyMoneyPro')
    .option('-c, --conf [value]', '编译Conf，默认AdHoc_DEV')
    .option('-v, --set-version [value]', '设置版本号')
    .option('-b, --bug [value]', '编译"MyMoneyPro_#<BUG_ID>.ipa，使用AdHoc_DEV配置')
    .option('-e, --beta', '编译"MyMoneyEnterprise_#<BUG_ID>.ipa，使用AdHoc_DEV配置')
    .option('-r, --release', '编译"MyMoneyPro_AdHoc.ipa，使用AdHoc_PRT配置')
    .option('-d, --app-store', '编译"MyMoneyAppStore.ipa，使用Distribution配置')
    .option('-o, --show-output', '运行进程时显示输出')
    .option('-f, --forced-name [value]', '强制指定文件名称')
    .option('--smb-dir [value]', '强制指定复制到SMB服务器的目录')
    .option('--archiveAppName [value]', '强制指定xcarchive内的AppName')
    .option('--debug', 'DEBUG parameters')
    .parse(process.argv);

// Promisify child_process.spawn
function spawnPromise(command, args, options, stdout, stderr, disableLogging) {
    if (!disableLogging) {
        logInfo(util.format('正在%s...', command.text));
    }

    var spinner = new Spinner('%s');
    spinner.setSpinnerString('|/-\\');
    spinner.start();

    return new Promise(function(resolve, reject) {
        var process = spawn(command.cmd, args, options || {});

        if (!disableLogging) {
            process.stdout.on('data', function (data) {
                if (stdout)
                    stdout(data);
            });

            process.stderr.on('data', function (data) {
                if (stderr)
                    stderr(data);
            });
        }

        process.on('close', function (code) {
            spinner.stop(true);
            if (code == 0) {
                if (!disableLogging) {
                    logSuccess(util.format('%s完毕', command.text));
                }
                resolve();
            } else {
                if (!disableLogging) {
                    logError(util.format('%s发生错误', command.text));
                }
                reject({command: command.text, code: code});
            }
        });
    });
}

// Returns a Promise from spawnPromise
function spawnProcessAsync(command, args, options, disableLogging) {
    return spawnPromise(command, args, options,
                function(out) { if(program.showOutput) process.stdout.write(out); },
                function(err) { process.stdout.write(err); }, disableLogging);
}

// log info message
function logInfo(str) {
    log(chalk.bgCyan.black(str));
}

// Log success message
function logSuccess(str) {
    log(chalk.bgGreen.black(str));
}

// Log error message
function logError(str) {
    log(chalk.bgRed.white(str));
}

// Log warning message
function logWarning(str) {
    log(chalk.bgYellow.black(str));
}

// Log alert message
function logAlert(str) {
    log(chalk.bgBlack.white(str));
}

// Wrapping the result in double-quotes (")
function quotePath(str) {
    return '"' + str + '"';
}

// Returns a bool value that indicates whether a specified file exists
fs.dirExists = function(dir) {
    try {
        var stat = fs.statSync(dir);
        if(stat.isDirectory())
            return true;
        throw new Error(util.format('路径"%s"不是文件夹', dir));
    } catch (err) {
        if(err.code == 'ENOENT')
            return false;
        throw err;
    }
};

// This will call fs.mkdir if directory does not exist
fs.ensureDirAsync = function (dir) {
    if (!fs.dirExists(dir))
        return fs.mkdirAsync(dir);
    return Promise.resolve();
};
// Reject the SMB directory, return Promise
function unmountSmb(dirName) {
    var localDir = path.join('/Volumes', dirName);
    var cmd = util.format('umount "%s"', localDir);
    return spawnProcessAsync({cmd: cmd, text: '写在SMB服务器'});
}

// Convert project configuration to display value
function confToString(c) {
    if(c == 'AdHoc_DEV')
        return '_T';
    if(c == 'AdHoc_PRT')
        return '_AdHoc';
    return '_' + c;
}

// Processing parameters
var appInfo = {};

if (program.bug) {
    appInfo.scheme = program.scheme || 'MyMoneyPro';
    appInfo.conf = program.conf || 'AdHoc_DEV';
    appInfo.name = util.format('%s_#%s%s', appInfo.scheme, program.bug, confToString(appInfo.conf));
    appInfo.type = 'Feature';
} else if (program.beta) {
    appInfo.scheme = 'MyMoneyEnterprise';
    appInfo.conf = 'AdHoc_DEV';
    appInfo.type = 'Version';
} else if (program.appStore) {
    appInfo.conf = 'Distribution';
    appInfo.type = 'Version';
} else if (program.release) {
    appInfo.conf = 'AdHoc_PRT';
    appInfo.type = 'Version';
}

if (program.scheme)
    appInfo.scheme = program.scheme;
if (program.conf)
    appInfo.conf = program.conf;
if (program.smbDir)
    appInfo.type = program.smbDir;

appInfo.scheme = appInfo.scheme || 'MyMoneyPro';
appInfo.conf = appInfo.conf || 'AdHoc_DEV';
appInfo.type = appInfo.type || 'Feature';

if (!appInfo.name) {
    var name = appInfo.scheme;
    if (program.setVersion)
        name += '_v' + program.setVersion;
    name += confToString(appInfo.conf);

    appInfo.name = name;
}

if (program.forcedName)
    appInfo.name = program.forcedName;

// Workspace path
var workspaceDir = path.dirname(__dirname);
var workspacePath = path.join(workspaceDir, 'GCDSocket-Manager.xcworkspace');

// Output files
var outputDir = path.join(workspaceDir, 'build');
var archivePath = path.join(outputDir, appInfo.name + '.xcarchive');
var ipaPath = path.join(outputDir, appInfo.name + '.ipa');
var smbIpaPath = null;
var smbDir = appInfo.type;
var appPath = path.join(archivePath, 'Products/Applications/' + (program.archiveAppName || appInfo.scheme) + '.app');

// Output app name
logInfo(util.format('Building App: %s', appInfo.name));

function uploadIpaToFirimAsync() {
    spawnProcessAsync({cmd: 'fir', text: '上传ipa到fir.im'},
                             ['-p', ipaPath]);
    spawnProcessAsync({cmd: 'curl', text: ''},
                      ['-X', 'PUT','--data','changelog=changelog','http://fir.im/api/v2/app/appID?token=3a0c28a66aaaf385f62dcd7b987d0ac5']);
}

// Call agvtool to set the version or build number of the project
function setVersionAsync() {
    return spawnProcessAsync({cmd: 'agvtool', text: '设置版本号'},
                             ['new-marketing-version', program.setVersion],
                             {cwd: path.join(workspaceDir, 'MyMoney')});
}

// Call xcodebuild to clean the project
function xcCleanAsync() {
    return spawnProcessAsync({cmd: 'xcodebuild', text: 'Clean工程'},
                             ['clean', '-workspace', workspacePath, '-scheme', appInfo.scheme, '-configuration', appInfo.conf]);
}

// Call xcodebuild to archive the project to a specified file
function xcArchiveAsync() {
    return spawnProcessAsync({cmd: 'xcodebuild', text: '编译工程'},
                             ['archive', '-workspace', workspacePath, '-scheme', appInfo.scheme, '-configuration', appInfo.conf, '-archivePath', archivePath, '-destination', 'generic/platform=iOS']);
}

// Call xcrun to convert xcarchive file to ipa file
function xrunIpaAsync() {
    return spawnProcessAsync({cmd: 'xcrun', text: '转换xcarchive到ipa'},
                             ['-sdk', 'iphoneos', 'PackageApplication', appPath, '-o', ipaPath]);
}

function sendNotificationAsync() {
    var cmd = util.format('display notification "%s (不要点我，我自己会消失)" with title "打包完毕了哦"', appInfo.name);
    return spawnProcessAsync({cmd: 'osascript', text: 'sendNotification'},
                             ['-e', cmd], null, true).catch(function (err) {
                                 return err;
                             });
}

// Debug routine
if (program.debug) {
    log('-----');
    log(util.format(program));
    log('-----');
    log(util.format(appInfo));
    process.exit(0);
}

// Main routine

// Never copy the ipa file if --local option is on
Promise.resolve(program.local)
// 'mouse smb directory' phase
//.then(function(res) {
//    if(!res)
//        return mountFeideeSmbAsync();
//    return res;
//})
// 'setVersion' phase
.then(function(res) {
    if(program.setVersion)
        return setVersionAsync();
    return res;
})
// 'clean' phase
.then(xcCleanAsync)
// 'archive' phase
.then(xcArchiveAsync)
// 'xca to ipa' phase
.then(xrunIpaAsync)
// 'copy ipa to smb directory' phase
.then(function(res) {
    if(program.local)
        return res;
//   uploadIpaToFirimAsync()
})
// All succeeded
.then(function(res) {
    // print path info
    logAlert(util.format('--> 服务器ipa路径: %s\n--> 本地ipa路径: %s\n--> 本地xca路径: %s', smbIpaPath || '无', ipaPath, archivePath));

    // Additional output for bug fix
    if (program.bug && smbIpaPath) {
        logWarning(util.format('--- Dear 海微 ---\n%s\nhttp://172.22.23.231/browse/%s', path.basename(smbIpaPath), program.bug));
    }

    logSuccess('** 完毕 **');
})
.then(sendNotificationAsync)
// Error occurred, fuck!
.catch(function(err) {
    if(err.stack)
        logError(util.format('%s', err.stack));
    log('** 遇到错误而停止 **');
});



/* -- end of file -- */
