#!/bin/bash
# Usage: copy_rdf_files <source_build_dir> <destination_build_dir>

cp    $1/zebu_mdb          $2/
cp    $1/arczebu.makefile  $2/
cp -r $1/scripts/zebu_*    $2/scripts/
cp    $1/verilog/zebu_*    $2/verilog/
cat   $1/verilog/zebu_box_compile_manifest >> $2/verilog/compile_manifest
