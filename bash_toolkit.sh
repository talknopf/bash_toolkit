#!/bin/bash

#find execution dir of this toolbox.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
. $DIR/bash_colors.sh
. $DIR/bash_logger.sh
. $DIR/argument_validator.sh
. $DIR/argument_parser.sh

info "bash wrapper is loaded"
