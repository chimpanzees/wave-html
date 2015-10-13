(function() {
  var HTMLSource, callsite, commands, compileFile, completePathFrom, fixUI, fs, mainCallback, outputPath, path, pathlib, saveOutput, stopWith, vars, wave;

  fs = require('fs');

  pathlib = require('path');

  callsite = require('callsite');

  fixUI = require('js-beautify').html;

  vars = {};

  commands = {
    callVariable: /<!-- \.(\w+) -->/i,
    includeFile: /<!-- \.include (.+) -->/i,
    fetchDeclaredVariableName: /<!-- ~(\w+)/i,
    declareVariableCommand: /<!-- ~(.)+( )(.)+ -->/i
  };

  HTMLSource = (function() {
    function HTMLSource(path1) {
      this.path = path1;
      this.lines = [];
    }

    HTMLSource.prototype.detectDeclareVariable = function(line) {
      var cmnd, data, name;
      if (commands.declareVariableCommand.test(line)) {
        cmnd = line.match(commands.declareVariableCommand)[0];
        name = cmnd.match(commands.fetchDeclaredVariableName)[1];
        data = cmnd.substring(6 + name.length, cmnd.length - 3).trim();
        vars[name] = data;
        line = line.replace(commands.declareVariableCommand, '');
      }
      return line;
    };

    HTMLSource.prototype.detectCallVariable = function(line) {
      var name;
      if (commands.callVariable.test(line)) {
        name = line.match(commands.callVariable)[1];
        line = line.replace(commands.callVariable, vars[name]);
      }
      return line;
    };

    HTMLSource.prototype.detectIncludeFile = function(line) {
      var component, i, len, ref, source;
      if (commands.includeFile.test(line)) {
        source = line.match(commands.includeFile)[1];
        component = new HTMLSource(pathlib.dirname(this.path) + '/' + source);
        component.parse();
        ref = component.lines;
        for (i = 0, len = ref.length; i < len; i++) {
          line = ref[i];
          this.lines.push(line);
        }
      }
      return line;
    };

    HTMLSource.prototype.formatLine = function(line) {
      line = this.detectDeclareVariable(line);
      line = this.detectCallVariable(line);
      line = this.detectIncludeFile(line);
      return this.lines.push(line);
    };

    HTMLSource.prototype.parse = function() {
      var data, i, len, line, ref, results;
      data = fs.readFileSync(this.path, 'utf-8');
      ref = data.split(/\r?\n/i);
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        line = ref[i];
        results.push(this.formatLine(line));
      }
      return results;
    };

    return HTMLSource;

  })();

  stopWith = function(error) {
    console.log('Stopped with error: ' + error);
    return process.exit();
  };

  saveOutput = function(output) {
    var buffer;
    buffer = '';
    output.forEach(function(str) {
      if (str !== '') {
        return buffer += str + '\n';
      }
    });
    buffer = fixUI(buffer, {
      indent_size: 2,
      end_with_newline: true
    });
    return fs.writeFile(outputPath, buffer, function(error) {
      if (error) {
        console.log(error);
      }
      return mainCallback();
    });
  };

  compileFile = function(file) {
    var html;
    html = new HTMLSource(file);
    html.parse();
    return saveOutput(html.lines);
  };

  path = 'error.error';

  outputPath = 'output.html';

  mainCallback = function() {
    return console.log('Done.');
  };

  completePathFrom = function(path) {
    var caller, dir;
    if (pathlib.isAbsolute(path)) {
      return path;
    }
    caller = callsite()[2].getFileName();
    dir = pathlib.dirname(caller);
    return pathlib.resolve(dir, path);
  };

  wave = function(input, output, callback) {
    if (output == null) {
      output = 'output.html';
    }
    if (callback == null) {
      callback = null;
    }
    path = completePathFrom(input);
    outputPath = completePathFrom(output);
    if (callback != null) {
      mainCallback = callback;
    }
    return fs.lstat(path, function(error, stats) {
      if (error) {
        stopWith(error);
      }
      if (stats.isFile()) {
        return compileFile(path);
      }
    });
  };

  module.exports = wave;

}).call(this);
