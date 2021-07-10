# Sample portfolio/blog for your Raspberry Cluster

The scope of this repository is to create an **ARM64** docker image for your [Hugo](https://gohugo.io/) site, and runs it on your own **Raspberry cluster at Home**.    
Toha theme has been used as basic hugo theme for this sample, check the [toha repository](https://github.com/hugo-toha/toha) for more info

## Dockerfle

The dockerfile creates an nginx server that contains all the site content built with Hugo:
```
FROM nginx:alpine as build

RUN apk add --update \
    wget
    
ARG HUGO_VERSION="0.72.0"
RUN wget --quiet "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz" && \
    tar xzf hugo_${HUGO_VERSION}_Linux-64bit.tar.gz && \
    rm -r hugo_${HUGO_VERSION}_Linux-64bit.tar.gz && \
    mv hugo /usr/bin
    
WORKDIR /site
COPY . .

RUN /usr/bin/hugo

#Copy static files to Nginx
FROM nginx:alpine
COPY --from=build /site/public /usr/share/nginx/html

WORKDIR /usr/share/nginx/html
```
This **Dockerfile** :
1. Downloads the hugo bin for 64bit linux
2. Builds the content of the site in the **/site** directory with ```RUN /usr/bin/hugo```
3. Moves the content of the site in the **nginx** html directory

For **local testing** on linux 64bit machine:  
Prerequisites: 
1. Have docker already installed on your machine  
2. Run the image on linux 64bit machine

Commands:
1. Build the image with : ```docker build --tag mysite . ```
2. Run the image with: ```docker container run -d -p 80:80 mysite:latest ```

The site will be on http://localhost:80

### Option 2 local testing
You can also try the site on localhost with Hugo itself:  
Prerequisites:  
1. Have hugo installed on your machinge check this [link](https://gohugo.io/getting-started/installing/)  
2. Run the command where is located the **config.yaml** file

Command:
`hugo server start`

The site will be on http://localhost:1313

## GITHUB action build.yaml
The image above hasn't been compatible yet with **ARM64** machine, so in the repository there is a github action called **build.yaml** that has the scope to build an arm64 image and push it on your Dockerhub repository:  
build.yml
```yaml
# Build and push your docker arm image

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
        with:
          submodules: recursive
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
            --tag <your-repository>/<your-image-name>:${{ steps.prep.outputs.VERSION }} \
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
            --tag <your-repository>/<your-image-name>:${{ steps.prep.outputs.VERSION }} \
            --file ./Dockerfile ./
      -
        name: Inspect image
        run: |
          docker buildx imagetools inspect <your-repository>/<your-image-name>:${{ steps.prep.outputs.VERSION }}
```
1. Create a **DOCKER_USERNAME** and **DOCKER_PASSWORD** secret in your github repository
2. Replace **your-repository** with the name of your dockerhub repository and **your-image-name** with the name of your image 

Finally you will have your ARM64 image that you can pull and run on Your Raspberry Cluster.

## KUBERNATES CONFIGURATION

If you have in place a **kubernates raspberry cluster** you can easily use this image for your pods.  
On this [repository](https://github.com/MovieMaker93/flux-portfolio-image) , you will find a solution to automatically update the image associated with your kubernates manifest through **Flux** image scanning feature.  



