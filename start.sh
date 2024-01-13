#!/bin/bash
sdb-admin start-node --all --yes &
sleep 20
netstat -tpl
