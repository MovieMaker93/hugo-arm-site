# My-portfolio
My portfolio and blog

My portfolio is created with hugo framework, you can find information [here](https://gohugo.io/)  
I choose as theme the Toha theme and i customized it with my contents and configuration.

For testing purpose on local env:

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

## DOCKER

build.yml
```yaml
# This is a basic workflow to help you get started with Actions

name: buildx

# Controls when the action will run. 
on:
  # Triggers the workflow on push or pull request events but only for the master branch
  push:
    branches: [ master ]
  pull_request:
    branches: [ master ]

  # Allows you to run this workflow manually from the Actions tab
  workflow_dispatch:

# A workflow run is made up of one or more jobs that can run sequentially or in parallel
jobs:
  # This workflow contains a single job called "build"
  build:
    # The type of runner that the job will run on
    runs-on: ubuntu-latest

    # Steps represent a sequence of tasks that will be executed as part of the job
    steps:
      - 
        name: Prepare
        id: prep
        run: |
          VERSION=master-${GITHUB_SHA::8}-$(date +%s)
          echo ::set-output name=BUILD_DATE::$(date -u +'%Y-%m-%dT%H:%M:%SZ')
          echo ::set-output name=VERSION::${VERSION}          
      # Checks-out your repository under $GITHUB_WORKSPACE, so your job can access it
      -
        name: Checkout
        uses: actions/checkout@v2
      -
        name: Set up Docker Buildx
        uses: crazy-max/ghaction-docker-buildx@v3
      -
        name: Cache Docker layers
        uses: actions/cache@v2
        id: cache
        with:
          path: /tmp/.buildx-cache
          key: ${{ runner.os }}-buildx-${{ github.sha }}
          restore-keys: |
            ${{ runner.os }}-buildx-
      -
        name: Docker Buildx (build)
        run: |
          docker buildx build \
            --cache-from "type=local,src=/tmp/.buildx-cache" \
            --cache-to "type=local,dest=/tmp/.buildx-cache" \
            --platform linux/arm/v6,linux/arm/v7,linux/arm64 \
            --output "type=image,push=false" \
            --tag alfonsofortunato/hugo-app:${{ steps.prep.outputs.VERSION }} \
            --file ./Dockerfile ./
      -
        name: Login to DockerHub
        uses: docker/login-action@v1
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}
      -
        name: Docker Buildx (push)
        run: |
          docker buildx build \
            --cache-from "type=local,src=/tmp/.buildx-cache" \
            --platform linux/arm/v6,linux/arm/v7,linux/arm64 \
            --output "type=image,push=true" \
            --tag alfonsofortunato/hugo-app:${{ steps.prep.outputs.VERSION }} \
            --file ./Dockerfile ./
      -
        name: Inspect image
        run: |
          docker buildx imagetools inspect alfonsofortunato/hugo-app:${{ steps.prep.outputs.VERSION }}
```
The above action build a multi-arch docker image with hugo and push it to my dockerhub repository.
The tag version is built with 'branch - sha8 - timestamp date', this format will be useful for the flux automation image find [here](https://gohugo.io/)   
