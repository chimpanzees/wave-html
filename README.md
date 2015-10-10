# Wave HTML

A simple preprocessor for ***Hyper Text Markup Language***.

## Introduction

***Wave .html*** *is a project that adds some extra functionality to* ***Hyper Text Markup Language*** *pages. An example input and output file are added in the examples folder.*

### Variables

*The compiler makes it possible to add variables to basic* ***Hyper Text Markup Language*** *pages. You should start by declaring a new variable using the code below. The* ***~*** *means a new variable will be declared. Using the variable in the page is as simple as calling it with a* ***'.'*** *in front of it. By calling a variable, the complete tag will be replaced by the value of it.*

*Declaring a variable:*

`<!-- ~title Hello World! -->`

*Followed by calling a variable:*

`<title><!-- .title --></title>`

*Results in:*

`<title>Hello World!</title>`

### Includes

***Wave .html*** *also makes it possible to include different html files. Simple write the following code, and the compiler will replace the tag with the content of the destination file.*

*Including a file:*

`<!-- .include footer.html -->`

## Important notice

*I wrote this in less than two hours, so the current version is not stable. This will change in the near future, I just need this for a project I am working on.*

## Installation

*The module will be add to* ***npm***, *but for now it should be downloaded and installed from the repository. Just run the compiler by calling the command below.*

`$ node wave.js input.html output.html`

## License

*This project is distributed with the* ***MIT*** *license.*