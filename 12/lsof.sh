#!/bin/bash

sudo find /proc/[0-9]*/fd/ -type l -exec ls -l {} \;
