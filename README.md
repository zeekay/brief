# brief

A simple tool for generating github pages (or other things from markdown/jade templates).

## Usage

- Create a gh-pages branch.
- Add an index.jade file which will render your content:

        p!= content

- Make sure you have a README.md file which will be injected into your jade template and rendered as index.html
- If you use `cake` add a new task to your `Cakefile`:

        task 'gh-pages', 'Publish docs to gh-pages', ->
          brief = require('brief')
            quiet: false
          brief.updateGithubPages()
