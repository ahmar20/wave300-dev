# $Id: make_cfg_header.awk 10546 2011-02-08 14:21:07Z dmytrof $
#
# Script to build C header file based
# on .config generated by xconfig/menuconfig tools
#
# Part of Metalink Wlan project build system
#

BEGIN {
    FS=" |=";
    print "#ifndef __MTLK_DOT_CONFIG_H__";
    print "#define __MTLK_DOT_CONFIG_H__";
    print ""
}

# Empty lines to be preserved
/^$/ { print ""; next; }

# True boolean variables
/CONFIG_[A-Z0-9_]+=y$/ { sub(/^CONFIG_/, "MTCFG_", $1); print "#define " $1 " (1)"; next; }

# False boolean variables
/^# CONFIG_[A-Z0-9_]+ is not set$/ { sub(/^CONFIG_/, "MTCFG_", $2); print "#undef " $2; next; }

# Text variables
/^CONFIG_[A-Z0-9_]+=".*"$/ { sub(/^CONFIG_/, "MTCFG_", $1); print "#define " $1 " " $2; next; }

# Int variables
/^CONFIG_[A-Z0-9_]+=[0-9]*$/ { sub(/^CONFIG_/, "MTCFG_", $1); print "#define " $1 " (" $2 ")"; next; }

# General comments to be converted into C-style comments
/^#.*/ {
  if(!match($0, /.*CONFIG_.*/)) {
      print "/* " $0 " */";
      next;
    }
}

# Any other line should lead to error because we don't know how to process it
{
  print "#error Unknown .config entry \"" $0 "\" (line #" NR ")";
  print "Failed to process line #" NR " of input data." > "/dev/stderr";
  print "Contents of unrecognized entry \"" $0 "\"." > "/dev/stderr";
  print "The script cannot continue." > "/dev/stderr";
  exit 1;
}

END {
    print ""
    print "#endif /* __MTLK_DOT_CONFIG_H__ */"
}
