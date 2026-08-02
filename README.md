# Blog

## Prerequisites

You need to first install nix + devenv by running the commands in [this script](./setup_devenv.sh)

## Build and serve locally

To build the blog locally simply run

```
devenv shell
cd blog
bundle install
bundle exec jekyll serve
```

The blog should now be served at http://127.0.0.1:4000/
