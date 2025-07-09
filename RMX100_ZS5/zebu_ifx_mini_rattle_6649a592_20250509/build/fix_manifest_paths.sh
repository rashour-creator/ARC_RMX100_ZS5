#!/bin/bash

# If you rename the build directory, you may need to fix the manifest
# files to reflect the new names.
# We also try to change other related files.
CD=current_directory.txt
FROM=`cat $CD`
PWD=`pwd`
if [ x$OS = x ] ; then
    # Not windows (where $OS) is set
    for f in $(find . -type f -exec grep -Il $FROM {} +); do
      echo changing absolute paths in file $f.
      cp -p $f temp_file
      sed -e "s#$FROM#$PWD#g" < $f > temp_file
      touch -r $f temp_file
      mv temp_file $f
      done
else
    for f in ./verilog/RTL/compile_manifest ./verilog/compile_manifest  \
      vcs_commandline_args makefile test.xref rascal.env */test.xref \
      tests/*/*.arg tests/*/*.cmd tests/*akefile* tests/*/*akefile*  \
      *.makefile additional_makefiles/makefile_interface_vcs_verilog \
      scripts/pt/rm_setup/common_setup.tcl \
      scripts/runseif*.tcl \
      scripts/gen_bist_ish.tcl \
      scripts/*.syn ; do
	if [ -f $f ] ; then
	  echo changing absolute paths in file $f.
	  PWD=`pwd`
	  sed -e "s#$FROM#$PWD#g" < $f > tmp1
	  mv tmp1 $f
	  fi
	done
      if [ -f scripts/runseif.tcl ]; then
	chmod 755 scripts/runseif.tcl
	fi 
    fi
