RapidPro Docker
===============

This repository's sole purpose is to build docker images versioned off of
git tags published in nyaruka/rapidpro and upload them to Docker Hub.

The idea is:

  1. Set up a GitHub commit webhook from nyaruka/rapidpro
  2. Kick off a Travis build when the webhook fires.
  3. The Travis build script should clone the latest nyaruka/rapidpro
     repository and get the latest tag.
  4. Build the docker image and tag with the latest git tag.
  5. Push the docker image to Docker hub using credentials stored in
     Travis' secrets vault.

Running RapidPro in Docker
--------------------------

To run the latest cutting edge version:

> $ docker run rapidpro/rapidpro

To run a specific version:

> $ docker run rapidpro/rapidpro:v2.0.478
