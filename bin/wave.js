(function() {
  var HTMLSource, callsite, commands, compileFile, completePathFrom, fixUI, fs, getFileExtension, outputPath, path, pathlib, saveOutput, stopWith, vars, wave;

  fs = require('fs');

  pathlib = require('path');

  callsite = require('callsite');

  fixUI = require('js-beautify').html;

  vars = {};

  commands = {
    callVariable: /<!-- \.(\w+) -->/i,
    includeFile: /<!-- \.include (.+) -->/i,
    notincludeFile: /<!-- \.notinclude (.+) -->/i,
    startOfLoop: /<!-- .loop ([0-9]+):([0-9]+) -->/i,
    endOfLoop: /<!-- .endloop -->/i,
    fetchDeclaredVariableName: /<!-- ~(\w+)/i,
    declareVariableCommand: /<!-- ~(.)+( )(.)+ -->/i
  };

  HTMLSource = (function() {
    function HTMLSource(path1) {
      this.path = path1;
      this.lines = [];
      this.loops = [];
      this.startValueForLoop = 0;
      this.endValueForLoop = 0;
      this.isLooping = false;
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

    HTMLSource.prototype.detectNotincludeFile = function(line) {
      if (commands.notincludeFile.test(line)) {
        line = "";
      }
      return line;
    };

    HTMLSource.prototype.detectStartOfLoop = function(line) {
      var elements;
      if (commands.startOfLoop.test(line)) {
        this.isLooping = true;
        elements = line.match(commands.startOfLoop);
        this.startValueForLoop = elements[1];
        this.endValueForLoop = elements[2];
        line = '';
      }
      return line;
    };

    HTMLSource.prototype.detectEndOfLoop = function(line) {
      return commands.endOfLoop.test(line);
    };

    HTMLSource.prototype.formatLine = function(line) {
      var i, j, len, num, ref, ref1, ref2, subline;
      if (this.isLooping) {
        if (this.detectEndOfLoop(line)) {
          this.isLooping = false;
          for (num = i = ref = this.startValueForLoop, ref1 = this.endValueForLoop; ref <= ref1 ? i <= ref1 : i >= ref1; num = ref <= ref1 ? ++i : --i) {
            ref2 = this.loops;
            for (j = 0, len = ref2.length; j < len; j++) {
              subline = ref2[j];
              this.lines.push(subline);
            }
          }
          this.loops = [];
          this.startValueForLoop = 0;
          return this.endValueForLoop = 0;
        } else {
          return this.loops.push(line);
        }
      } else {
        line = this.detectDeclareVariable(line);
        line = this.detectCallVariable(line);
        line = this.detectIncludeFile(line);
        line = this.detectNotincludeFile(line);
        line = this.detectStartOfLoop(line);
        return this.lines.push(line);
      }
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
    return fs.writeFileSync(outputPath, buffer);
  };

  compileFile = function(file) {
    var html;
    html = new HTMLSource(file);
    html.parse();
    return saveOutput(html.lines);
  };

  path = 'error.error';

  outputPath = 'output.html';

  completePathFrom = function(path) {
    var caller, dir;
    if (pathlib.isAbsolute(path)) {
      return path;
    }
    caller = callsite()[2].getFileName();
    dir = pathlib.dirname(caller);
    return pathlib.resolve(dir, path);
  };

  getFileExtension = function(path) {
    var extension, index;
    index = path.lastIndexOf('.');
    return extension = path.substr(index).replace('.', '');
  };

  wave = function(input, output) {
    var extension;
    if (output == null) {
      output = 'output.html';
    }
    extension = getFileExtension(input);
    if (extension === "whtml") {
      path = completePathFrom(input);
      outputPath = completePathFrom(output);
      return fs.lstat(path, function(error, stats) {
        if (error) {
          stopWith(error);
        }
        if (stats.isFile()) {
          return compileFile(path);
        }
      });
    } else {
      return stopWith("The extension '." + extension + "' of the input file is not valid.");
    }
  };

  module.exports = wave;

}).call(this);
