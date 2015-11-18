/*
  File that compiles the wave html source code to
  an html file, with all code correctly replaced.
 */
(function(){var t,e,i,o,r,n,l,a,s,u,c,p,h,d
n=require("fs"),u=require("path"),e=require("js-beautify").html,h={},i={callVariable:/<!-- \.(\w+) -->/i,includeFile:/<!-- \.include (.+) -->/i,notincludeFile:/<!-- \.notinclude (.+) -->/i,startOfLoop:/<!-- .loop ([0-9]+):([0-9]+) -->/i,endOfLoop:/<!-- .endloop -->/i,fetchDeclaredVariableName:/<!-- ~(\w+)/i,declareVariableCommand:/<!-- ~(.)+( )(.)+ -->/i},t=function(){function t(t){var e
this.path=t,e=[[],[],0,0],this.lines=e[0],this.loops=e[1],this.startValueForLoop=e[2],this.endValueForLoop=e[3],this.isLooping=!1}return t.prototype.detectDeclareVariable=function(t){var e,o,r
return i.declareVariableCommand.test(t)&&(e=t.match(i.declareVariableCommand)[0],r=e.match(i.fetchDeclaredVariableName)[1],o=e.substring(6+r.length,e.length-3).trim(),h[r]=o,t=t.replace(i.declareVariableCommand,"")),t},t.prototype.detectCallVariable=function(t){var e
return i.callVariable.test(t)&&(e=t.match(i.callVariable)[1],t=t.replace(i.callVariable,h[e])),t},t.prototype.detectIncludeFile=function(e){var o,r,n,l,a
if(i.includeFile.test(e))for(a=e.match(i.includeFile)[1],o=new t(u.dirname(this.path)+"/"+a),o.parse(),l=o.lines,r=0,n=l.length;n>r;r++)e=l[r],this.lines.push(e)
return e},t.prototype.detectNotincludeFile=function(t){return i.notincludeFile.test(t)?t="":t},t.prototype.detectStartOfLoop=function(t){var e
return i.startOfLoop.test(t)&&(this.isLooping=!0,e=t.match(i.startOfLoop),this.startValueForLoop=e[1],this.endValueForLoop=e[2],t=""),t},t.prototype.detectEndOfLoop=function(t){return i.endOfLoop.test(t)},t.prototype.formatLine=function(t){var e,i,o,r,n,l,a,s
if(this.isLooping){if(this.detectEndOfLoop(t)){for(this.isLooping=!1,r=e=n=this.startValueForLoop,l=this.endValueForLoop;l>=n?l>=e:e>=l;r=l>=n?++e:--e)for(a=this.loops,i=0,o=a.length;o>i;i++)s=a[i],this.lines.push(s)
return this.loops=[],this.startValueForLoop=0,this.endValueForLoop=0}return this.loops.push(t)}return t=this.detectDeclareVariable(t),t=this.detectCallVariable(t),t=this.detectIncludeFile(t),t=this.detectNotincludeFile(t),t=this.detectStartOfLoop(t),this.lines.push(t)},t.prototype.parse=function(){var t,e,i,o,r,l
for(t=n.readFileSync(this.path,"utf-8"),r=t.split(/\r?\n/i),l=[],e=0,i=r.length;i>e;e++)o=r[e],l.push(this.formatLine(o))
return l},t}(),p=function(t){return console.log("Stopped with error: "+t),process.exit()},c=function(t){var i
return i="",t.forEach(function(t){return""!==t?i+=t+"\n":void 0}),i=e(i,{indent_size:2,end_with_newline:!0}),n.writeFile(a,i,function(){return"undefined"!=typeof l&&null!==l?l():void 0})},o=function(e){var i
return i=new t(e),i.parse(),c(i.lines)},s="error.error",a="output.html",l=null,r=function(t){return u.isAbsolute(t)?t:u.resolve(process.cwd(),t)},d=function(t,e,i){return null==e&&(e="output.html"),null==i&&(i=null),s=r(t),a=r(e),l=i,n.lstat(s,function(t,e){return t&&p(t),e.isFile()?o(s):void 0})},module.exports=d}).call(this)
