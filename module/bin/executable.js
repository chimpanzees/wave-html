#!/usr/bin/env node
(function(){var e,r,s,i,n,o,c,a,t
i=require("fs"),c=require("path"),a=require("./wave"),t=require("winston"),e=require("minimist")(process.argv.slice(2)),r=e._,(e.version||e.v)&&(s=JSON.parse(i.readFileSync("../../package.json","utf8")),t.info("Wave v"+s.version),process.exit()),2!==r.length&&(t.error("Invalid number of arguments!"),process.exit()),n=c.resolve(process.cwd(),r[0]),o=c.resolve(process.cwd(),r[1]),a(n,o,function(){return t.info("Compilation successful.")})}).call(this)
