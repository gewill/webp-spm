#!/bin/bash
# This script adds module.modulemap and umbrella headers to library-based XCFrameworks
# to make them directly importable in Swift (e.g., `import WebP`).

set -e

TARGET_DIR=$1
if [ -z "$TARGET_DIR" ]; then
  TARGET_DIR="."
fi

create_modulemap() {
  local framework_dir=$1
  local name=$(basename "${framework_dir%.xcframework}")
  
  echo "Adding modulemap to ${name}.xcframework..."
  
  find "$framework_dir" -path "*/Headers" -type d | while read -r headers_dir; do
    local umbrella_header="$headers_dir/${name}-umbrella.h"
    local modulemap="$headers_dir/module.modulemap"
    local upper_name=$(echo "$name" | tr '[:lower:]' '[:upper:]')
    
    # Generate umbrella header
    echo "#ifndef ${upper_name}_UMBRELLA_H" > "$umbrella_header"
    echo "#define ${upper_name}_UMBRELLA_H" >> "$umbrella_header"
    echo "" >> "$umbrella_header"
    
    # Import all headers in the subdirectory
    find "$headers_dir/$name" -name "*.h" -type f | while read -r h; do
      local h_name=$(basename "$h")
      echo "#import \"$name/$h_name\"" >> "$umbrella_header"
    done
    
    echo "" >> "$umbrella_header"
    echo "#endif" >> "$umbrella_header"
    
    # Generate module map
    echo "module $name [system] {" > "$modulemap"
    echo "    umbrella header \"${name}-umbrella.h\"" >> "$modulemap"
    echo "    export *" >> "$modulemap"
    echo "}" >> "$modulemap"
  done
}

create_modulemap "${TARGET_DIR}/WebP.xcframework"
create_modulemap "${TARGET_DIR}/WebPDecoder.xcframework"
create_modulemap "${TARGET_DIR}/WebPDemux.xcframework"
create_modulemap "${TARGET_DIR}/WebPMux.xcframework"
create_modulemap "${TARGET_DIR}/SharpYuv.xcframework"

echo "Successfully added modulemaps and umbrella headers!"
