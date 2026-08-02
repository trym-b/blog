{ pkgs, lib, config, inputs, ... }:

{
  packages = [
    pkgs.git
    pkgs.jekyll
    pkgs.bundler
  ];
}
