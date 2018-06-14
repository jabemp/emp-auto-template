#!/bin/bash

scenetries=("time='upcoming' and titleclean like '%${releasecasttitle}%'")
scenetries+=("time='updates' and titleclean like '%${releasecasttitle}%'")
