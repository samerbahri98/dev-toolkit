#!/usr/bin/make

SHELL = /bin/sh

UID := $(shell id -u)
GID := $(shell id -g)

export UID
export GID

default:
	/usr/bin/env sh ./scripts/ansible_docker_container.sh