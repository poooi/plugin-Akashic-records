window.remote = require('remote');

window.ROOT = remote.getGlobal('ROOT');

window.APPDATA_PATH = remote.getGlobal('APPDATA_PATH');

window.POI_VERSION = remote.getGlobal('POI_VERSION');

window.SERVER_HOSTNAME = remote.getGlobal('SERVER_HOSTNAME');

window.MODULE_PATH = remote.getGlobal('MODULE_PATH');

require('module').globalPaths.push(MODULE_PATH);

require(ROOT + "/components/coffee-script/extras/coffee-script.js");
