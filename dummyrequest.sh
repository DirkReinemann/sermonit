#!/bin/bash

while :; do sleep 0.$(($RANDOM%10)); curl -s localhost >/dev/null; done
