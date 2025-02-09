#!/bin/bash

#sudo apt install sleuthkit

case "$1" in
    -h)
        echo "Usage: $0 [option] [arguments]"
        echo ""
        echo "Options:"
        echo "  -systime             Display the current system time in the format YYYY-MM-DD HH:MM:SS."
        echo "  -cmosclock           Display the hardware clock time (requires sudo)."
        echo "  -fileinfo <file>     Display file access, modification, and change times for the specified file."
        echo "  -deleted <num> <drive(optional)> Check the first <num> deleted files on drive(defaults to /dev/nvme0n1p5) and show their metadata if recoverable."
        echo "  -h         Display this help text."
        exit 0
        ;;
    
    -systime)
        echo "system time: $(date +"%Y-%m-%d %H:%M:%S")"
        ;;    
    
    -cmosclock)
        echo "clock time in the hardware: $(sudo hwclock)"
        ;;
    
    -fileinfo)
        if [ -z "$2" ]; then
            echo "please specify a file"
            exit 1
        fi
        echo "File: $2"
        stat --format="Access Time: %x Modification Time: %y Change Time: %z" $2
        ;;
    
    -deleted)
        drive=${3:-/dev/nvme0n1p5}
        echo "checking $2 deleted files in $drive if they are recoverable and show metadata"

        deleted_files=$(sudo fls -rd "$drive" 2 \
        | head -$2 \
        | grep -av '(realloc)' \
        | grep -av '* 0:' \
        | awk '{
            inode = $3;
            gsub(/:/, "", inode);
            filename = $4
            print inode " " filename
        }')
        
        while read -r inode filename; do
            stat_output=$(sudo istat $drive $inode) 

            accessed_line=$(echo "$stat_output" | grep '^Accessed:')
            deleted_line=$(echo "$stat_output" | grep '^Deleted:')

            if [ -z "$deleted_line" ]; then
                continue
            else
                echo "Recovering $filename (inode: $inode)..."
                echo $deleted_line
                echo $accessed_line
                echo -e "---------"
            fi
        done <<< "$deleted_files"

        ;;
    *)
        echo "invalid option. run the same command with -h to get help"
        ;;

esac