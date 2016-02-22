var path = require('path');

var labConf = require(path.join(process.cwd(), 'karma.conf.js'));

function addJSONReporter (config) {
  var _path = path.join(__dirname, '../../../../node_modules/karma-json-reporter');
  config.basePath = path.join(process.cwd(), config.basePath);
  config.plugins.push(require(_path));
  config.reporters.push('json');
  config.jsonReporter = {
    stdout: false,
    outputFile: path.join(process.cwd(), '.results.json')
  }
}

module.exports = function (config) {
  labConf(config);
  addJSONReporter(config);
}
