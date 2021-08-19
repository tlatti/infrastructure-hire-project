#!/bin/bash

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 709004257235.dkr.ecr.us-east-1.amazonaws.com
