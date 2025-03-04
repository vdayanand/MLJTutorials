<!-----------------------------------------------------
Add here global page variables to use throughout your
website.
The website_* must be defined for the RSS to work
------------------------------------------------------->
@def prepath = "MLJTutorials"

@def website_title = "MLJ Tutorials"
@def website_descr = "Tutorials for the MLJ universe"
@def website_url   = "https://alan-turing-institute.github.io/MLJTutorials/"

@def author = "Anthony Blaom, Thibaut Lienart and collaborators"

@def hasmath = false <!-- in general pages will not have maths, can adjust locally -->
@def mintoclevel = 2 <!-- toc starts at h2 onwards -->
@def maxtoclevel = 3 <!-- toc stops at h3 included -->

<!-----------------------------------------------------
Add here global latex commands to use throughout your
pages. It can be math commands but does not need to be.
For instance:
* \newcommand{\phrase}{This is a long phrase to copy.}
------------------------------------------------------->
\newcommand{\R}{\mathbb R}
\newcommand{\scal}[1]{\langle #1 \rangle}

\newcommand{\tutorial}[1]{*Download the* ~~~<a href="https://raw.githubusercontent.com/alan-turing-institute/MLJTutorials/gh-pages/notebooks/!#1.ipynb" target="_blank"><em>notebook</em></a>~~~, *the* ~~~<a href="https://raw.githubusercontent.com/alan-turing-institute/MLJTutorials/gh-pages/scripts/!#1.jl" target="_blank"><em>raw script</em></a>~~~, *or the* ~~~<a href="https://raw.githubusercontent.com/alan-turing-institute/MLJTutorials/master/scripts/!#1.jl" target="_blank"><em>annoted script</em></a>~~~ *for this tutorial (right-click on the link and save).* <!--_-->\toc\literate{/scripts/!#1.jl}}

\newcommand{\refblank}[2]{~~~<a href="!#2" target="_blank">~~~!#1~~~</a>~~~}
