# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT

{ pkgs ? import <nixpkgs> {}, jdk ? "jdk11" }:
  pkgs.mkShell {
    # nativeBuildInputs is usually what you want -- tools you need to run
    nativeBuildInputs = [ 
        pkgs.buildPackages.sbt
        pkgs.buildPackages.coursier
        pkgs.buildPackages.${jdk}
        pkgs.buildPackages.nodejs
    ];
}

