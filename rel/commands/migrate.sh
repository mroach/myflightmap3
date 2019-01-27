#!/bin/sh

release_ctl eval --mfa "Myflightmap.ReleaseTasks.migrate/1" --argv -- "$@"
