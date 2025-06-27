#!/bin/bash
nextflow run main.nf -resume \
    -params-file "./params.json"