#!/bin/bash
# Source: http://superuser.com/questions/523194/how-to-recursively-upload-a-directory-to-a-webdav-server-through-https-from-the
# Use it like: ./upload.sh "_build/html" "http://msdl.cs.mcgill.ca/projects/DEVS/PythonPDEVS/documentation/"

src="_build/html";

cd "$(dirname "$src")";
src="$(basename "$src")";
root="$(pwd)";
rc="$(mktemp)";
{
    find "$src" '(' -type d -a -readable ')' \
    -printf 'mkcol "%p"\n';
    find "$src" '(' -type f -a -readable ')' \
    -printf 'cd "%h"\nlcd "%h"\n'            \
    -printf 'mput "%f"\n'                    \
    -printf 'cd -\nlcd "'"$root"'"\n';
    echo "quit";
} > "$rc";

cadaver -r "$rc" "http://msdl.cs.mcgill.ca/projects/DEVS/PythonPDEVS/documentation/";
rm -f "$rc";
