#!/bin/bash

exec gosu bitcoin bitcoind $@
