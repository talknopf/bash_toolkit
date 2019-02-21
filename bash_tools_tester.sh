#!/bin/bash
. bash_toolkit.sh
parse_args $@

validate_args "T" "R"

info "$T $R"
warn "$T $R"
error "$T $R"

exit_on_error "$T $R"