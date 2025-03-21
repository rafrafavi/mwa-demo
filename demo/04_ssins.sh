#!/bin/bash
# wrapper for 04_ssins.py

# ### #
# ENV #
# ### #
# see: 00_env.sh
if [ -n "$ZSH_VERSION" ]; then ME="${0:A}"; else ME=$(realpath ${BASH_SOURCE:0}); fi
export SCRIPT_BASE=${SCRIPT_BASE:-$(dirname $ME)}
source "$SCRIPT_BASE/00_env.sh"

export obsid=${obsid:-1341914000}

# ### #
# RAW #
# ### #
# check for raw files
export raw_glob=${outdir}/${obsid}/raw/${obsid}_2\*.fits
if ! eval ls -1 $raw_glob; then
    echo "raw not present: $raw_glob , try ${SCRIPT_BASE}/02_download.sh"
    exit 1
fi
# check for metafits files
export metafits=${outdir}/${obsid}/raw/${obsid}.metafits
if [[ ! -f "$metafits" ]]; then
    echo "metafits not present, downloading $metafits"
    curl -L -o "$metafits" $'http://ws.mwatelescope.org/metadata/fits?obs_id='"${obsid}"
fi

# ##### #
# SSINS #
# ##### #
# DEMO: use SSINS (sky-subtracted incoherent noise spectra) to identify RFI
# - top plots are baseline-averaged auto amplitudes, differenced in time
# - bottom plots are z-score: (subtract mean of each frequency, divide by std dev)
set -x
python "${SCRIPT_BASE}/04_ssins.py" "$metafits" $raw_glob

# DEMO: SSINS can also be used to generate RFI flag files, but this out of scope
