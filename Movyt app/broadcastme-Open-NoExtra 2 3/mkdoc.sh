#!/usr/bin/env bash
appledoc                        \
  --project-name "Video Stream" \
  --project-company "Agilio"    \
  --company-id eu.agilio        \
  --output doc                  \
  --no-create-docset            \
  ./src
