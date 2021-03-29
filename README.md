# portfolio-alfonso
My portfolio and blog

My portfolio is created with hugo framework, you can find information [here](https://gohugo.io/)  
I choose as theme the Toha theme and i customized it with my contents and configuration.

For testing purpose on local env i do:

`hugo server start`

## Netlify 

netlify.toml
```toml
[build]
command = "hugo --gc --minify"
publish = "public"

[context.production.environment]
HUGO_ENABLEGITINFO = "true"
HUGO_ENV           = "production"
HUGO_THEME         = "toha"
HUGO_VERSION       = "0.77.0"

[context.split1]
command = "hugo --gc --minify --enableGitInfo"

    [context.split1.environment]
    HUGO_ENV     = "production"
    HUGO_VERSION = "0.77.0"

[context.deploy-preview]
command = "hugo --gc --minify --buildFuture -b $DEPLOY_PRIME_URL"

    [context.deploy-preview.environment]
    HUGO_VERSION = "0.77.0"

[context.branch-deploy]
command = "hugo --gc --minify -b $DEPLOY_PRIME_URL"

    [context.branch-deploy.environment]
    HUGO_VERSION = "0.77.0"

[context.next.environment]
HUGO_ENABLEGITINFO = "true"
```
The above example is used to deploy the site on netlify.  

## Github Page

deploy-site.yml
```yaml
name: Deploy to Github Pages

# run when a commit is pushed to "source" branch
on:
  push:
    branches:
    - master

jobs:
  deploy:
    runs-on: ubuntu-18.04
    steps:
    # checkout to the commit that has been pushed
    - uses: actions/checkout@v2
      with:
        submodules: true  # Fetch Hugo themes (true OR recursive)
        fetch-depth: 0    # Fetch all history for .GitInfo and .Lastmod
    
    # install Hugo
    - name: Setup Hugo
      uses: peaceiris/actions-hugo@v2
      with:
        hugo-version: '0.77.0'
        extended: true

    # build website
    - name: Build
      run: hugo --minify

    # push the generated content into the `main` (former `master`) branch.
    - name: Deploy
      uses: peaceiris/actions-gh-pages@v3
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
        publish_branch: main # if your main branch is `master` use that here.
        publish_dir: ./public
```
The above github action (configured in the repository) gives the possibility to deploy the site for github page.
