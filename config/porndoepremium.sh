scenepicsoption="-m"
siteparturl=$(echo "$releasesite" | sed -e 's/\([[:lower:]]\)\([[:upper:]]\)/\1\n\2/g' -e 's/\([[:upper:]]\+\)\([[:upper:]][[:lower:]]\)/\1\n\2/g' -e 's/_\+/\n/g' | tr '\n' '-' | sed -r 's/\-$//g' | tr '[:upper:]' '[:lower:]')
scenetries[0]="site = '$siteparturl' and date = '${releasedate}'"
