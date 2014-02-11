# brief
Generate and publish Github pages quickly and easily from markdown/jade
templates.

## Usage
- Create a gh-pages branch.
- Add an index.jade file which will render your content. Use `read()` to specify which file to use as content for your template:

```jade
p!= read('README.md')
```

- Make sure you have a README.md file which will be injected into your jade template.
- If you use `cake` add a new task to your `Cakefile`:

```coffeescript
task 'gh-pages', 'Publish docs to gh-pages', ->
  brief = require 'brief'
  brief.update()
```

## CLI
To update the `gh-pages` branch using defaults:

```bash
$ brief
> git checkout gh-pages
Switched to branch 'gh-pages'
Your branch is ahead of 'origin/gh-pages' by 1 commit.
> git add /Users/zk/go/src/github.com/zeekay/brief/index.html
> git commit -m "Updating generated content"
[gh-pages f869f85] Updating generated content
 1 file changed, 29 insertions(+), 71 deletions(-)
 rewrite index.html (99%)
> git push -f origin gh-pages
To git@github.com:zeekay/brief
   0052836..f869f85  gh-pages -> gh-pages
> git checkout master
Switched to branch 'master'
Your branch is up-to-date with 'origin/master'.
```

Most configuration options are available from command line, `brief --help` for
more detail.
