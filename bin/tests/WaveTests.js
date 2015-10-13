(function() {
  var chai, expect, fs, wave;

  fs = require('fs');

  chai = require('chai');

  wave = require(__dirname + '/../wave');

  chai.should();

  expect = chai.expect;

  describe('Wave', function() {
    return it('Generate sample output', function() {
      var example, i, index, len, line, output;
      wave('../../examples/input.whtml', '../../examples/example.html');
      output = fs.readFileSync(__dirname + '/../../examples/output.html', 'utf-8');
      example = fs.readFileSync(__dirname + '/../../examples/example.html', 'utf-8');
      for (index = i = 0, len = output.length; i < len; index = ++i) {
        line = output[index];
        expect(line).to.equal(example[index]);
      }
      return expect(fs.statSync(__dirname + '/../../examples/output.html')["size"]).to.equal(fs.statSync(__dirname + '/../../examples/example.html')["size"]);
    });
  });

}).call(this);
