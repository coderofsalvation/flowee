#!/bin/bash 

tohtml(){
  cat - > /tmp/.bashdown
  curl -s -X POST -H "Content-Type: text/x-markdown" --data-binary @/tmp/.bashdown https://api.github.com/markdown/raw
}

cat - | tohtml
