<p align="center">
<img src="http://i.imgur.com/9hGN9Oe.png" height="300" />
</p>

<p align="center">
<img src="https://img.shields.io/npm/v/wave-html.svg">
<img src="https://img.shields.io/npm/dt/wave-html.svg">
<img src="https://img.shields.io/badge/Built%20with-Grunt-orange.svg">
<img src="https://img.shields.io/npm/l/wave-html.svg">
</p>

***Simple preprocessor for HTML with HTML5 syntax.***

#### Installation

The compiler van be installed globally via **npm**.

```bash
$ npm install --global wave-html
```

#### Syntax

Variables can be declared using a wave sign. Call them by using a dot in front of a variable name. All declaration will be done inside HTML5 comments. The code snippets below show a `.whtml` file before compilation, as well as a `.html` output file.

```html
<!-- ~title Hello World! -->
<h1><!-- .title --></h1>
```

```html
<h1>Hello World!</h1>
```

You can also include other files with the include command. This will take the content of the given file and writes it where the include tag is located.

```html
<!-- .include ../head.html -->
```

It might be useful to use loops to quickly generate a template (for debugging). In this case, you can use the build in loop function of wave. Here is another example of input and output.

```html
<!-- .loop 1:3 -->
  <p>Some paragraph</p>
<!-- .endloop -->
```

```html
<p>Some paragraph</p>
<p>Some paragraph</p>
<p>Some paragraph</p>
```

#### Command line compilation

Run the compiler with `wave`, followed by an input and output path.

```
$ wave source.whtml output.html
```

#### License

This project is distributed under the **MIT** license.

*Icons made by <a href="http://www.freepik.com" title="Freepik">Freepik</a> from <a href="http://www.flaticon.com" title="Flaticon">www.flaticon.com</a>             is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" title="Creative Commons BY 3.0">CC BY 3.0</a>*
