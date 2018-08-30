docker-registry-cache
=====================

This is a pull-through docker private registry cache implemented using a
Squid HTTP proxy.

**WARNING**: This only works with the modern [docker registry API (v2+)](https://docs.docker.com/registry/spec/api/). This will not work with docker registries that use the legacy v1 API. 

What is this useful for?
------------------------

Bottom line, it's a HTTP cache. 

* Data center A contains your private registry, and DC B is connected to it over a slow link. Run an instance of this cache on DC B's network, and anytime you pull from it the second time will be significantly faster since you don't have to traverse that slow link as much!
* I'm sure there are other usecases..

Requirements
============

You must have docker installed. You must create an SSL certificate and key for
your proxy (out of scope for this guide -- google it yourself).

SSL-enabled squid
-----------------

You must have an SSL-enabled version of squid. Currently, Ubuntu's squid
package is not ssl enabled due to licensing issues. To build your own, do this:

```console
$ build-squid/make.sh
```
  
After about 30 minutes or so, you should have a bunch of deb packages in
the `build-squid` directory.

Build the cache server image
----------------------------

First, copy squid.conf.template to squid.conf, and change the variables.

* `{{ registry_host }}` is your private docker registry host
* `{{ registry_port }}` is your private docker registry port
* `{{ cache_size }}` should be set to the cache size, in MB. According to the 
  squid docs, this should not exceed 80% of the disk. For example, 500000 is
  500GB.

Next, build the image:

```console
$ ./build.sh
```
    
Setup
=====

* Create an empty directory for your cache.
* Create a directory for your SSL certificates, and place them in a directory,
  with the certificate called 'cert.pem' and the private key called 'key.pem'

```console
$ ./run.sh /path/to/ssl /path/to/cache
```

The registry will start, and be listening on port 443. It should restart on
bootup if your docker daemon is running.

Registry authentication
-----------------------

https://github.com/virtuald/docker-registry-cache/pull/7 added a configuration option
to squid that passes basic authentication thru to the remote registry. This should
work without any further configuration.

It is unknown if other authentication schemes will work with this cache. Feel free
to try it out and leave a note with what you find out!

Using the cache
===============

Once the registry cache starts, you pull from it like you would pull from a
normal docker registry -- but you pull from the cache hostname, not your
original private registry hostname!

```console
$ docker pull CACHE_HOST/foo/bar:latest
```

Bugs
====

I'm sure this isn't ideal, but it seems to work. Submit issues and PRs!

License
=======

The contents of this repository are available under the Apache v2 license. 


Author
======

Dustin Spicuzza (dustin@virtualroadside.com)
