#!/bin/bash
make | tee >(grep -i warn > warn.txt)
cat warn.txt
