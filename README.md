# Scalke
A PoC project to play with Scala.js and nix

# What, why, where

1. Yarn 3 - just because it is modern, less commonly used, and has interesting approach to achieve reproducability by incentivising to commit cache folder (yes, `.yarn/cache` contains full cache used to reproduce `node_modules` when running `yarn install`). https://yarnpkg.com/
2. Scala.js - to play with it in a more real-life scenario (even though it is still a playground project)
3. nix - to finally learn this monstrosity
4. Scalably typed - to convert TS Type definitions into Scala code. In that way a Scala code can blend in into otherwise-JS/TS app. It also enables one cool thing - implementing TS API's in Scala, at least as long as nothing crazy happens (that's why rxjs compaliation is disabled there and the implementation of `aref` is a TS wrapper for Scala implementation)

# Installation

## Nodejs Gallium LTS
The best tool for the job is either nvm (https://github.com/nvm-sh/nvm) or ASDF (https://github.com/asdf-vm/asdf/), it is a cool feature of both to adjust path as one changes directories in shell (based on proper version file in directory, here it is `.nvmrc`)

## Corepack
Modern yarn relies on corepack. It is a tool, that allows to pick proper package manager version based on project settings, a bit like sbt works. Given node.js Gallium, it is enough to run

        corepack enable

And call it a day.

## Sbt and JDK
ASDF FTW!

## The project
After all of the above, running

        yarn install
in project directory should do the job

# Building & Running
Run

        yarn run build

in project directory, it will walk through packages and build each of them, then

        yarn run start

This will run a little timer in shell, do some logging, log couple of times current date&time, then exit.


