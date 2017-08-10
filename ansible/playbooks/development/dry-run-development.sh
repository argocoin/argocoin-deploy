#!/bin/sh

ansible-playbook \
--ask-become-pass \
--check \
"development.yml"

