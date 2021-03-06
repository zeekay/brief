# brief
Generate and publish Github pages quickly and easily from markdown/pug
templates.

## Usage
- Create a gh-pages branch.
- Add an index.pug file which will render your content. Use `read()` to specify which file to use as content for your template:

```pug
p!= read("README.md")
```

- Make sure you have a README.md file which will be injected into your pug template.
- Run `brief` from cli or instantiate a brief instance and run `brief.update()`

## API
If you want to customize behavior of brief you can instantiate a new brief
instance with various options:

```javascript
var Brief = require('brief').Brief;

var brief = new Brief({
    templateFile: 'index.pug',
    outputFile:   'index.html',
    ctx:          {title: 'Title'},
    branch:       'gh-pages',
    remote:       'origin',
    push:         true,
    quiet:        false
});

brief.update();
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

## Advanced
Tastes good with Cake!

```coffeescript
task 'gh-pages', 'Publish docs to gh-pages', ->
  require('brief').update()
```
