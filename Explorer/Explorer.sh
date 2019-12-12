#!/bin/bash

#variable
#app='/opt/QtPalmtop/bin/z'
app="$PWD"
listfile='/tmp/ListSelect.tmp' ; null='/dev/null'
recycle="$PWD/Recycle"
outfile='/tmp/DirFile.tmp' ; lstmp='/tmp/ls.tmp'
#optbin='/opt/QtPalmtop/bin'
declare -a dir style click clickterms \
title=('File management' 'open a file' 'Select the file' 'save document') bak \
clickbak clickmsg=('Select this' 'cancel selection') \
clickshow=('[ ]' '\E[94m[\E[31mX\E[94m]') \
dirlink=("Mount to this folder" "Go to the link directory") \
linkshow=([1]="Go to the link directory") clicknames \
tar=("turn on..." "turn on..." "Unzip...") copy ok=("carry out")
xy="4 14 0 0" ; select=1
for ((n=1;n<=255;n++)) ; do
  ok[$n]="failure"
done

#Escape sequence
inc='\E[33;40m' ; comc='\E[31m' ; end='\E[0m'
declare -a color=('\E[94m' '\E[92m' '\E[96m'\
 '\E[95m' '\E[31m' '\E[22;36m' '\E[92m') linkp=('' '\E[3;1H\E[2K')

#function
prog_find(){
  n=0 ; unset dir[@] ; ls -1a > "$lstmp"
  while read line ; do
    if [ "${click[n]}" = "" ] ; then click[$n]=0 ; fi
    prog_sure ; dir[$((n++))]="$line"
  done < "$lstmp"
  if [ "${dir[*]}" != "${bak[*]}" ] ; then
    prog_click_back
  fi
  for ((n=0;n<=${#dir[@]};n++)) ; do
    bak[$n]="${dir[n]}"
  done
  $app/List.sh "  ${title[open]}  "\
  "${PWD:((${#PWD}>36?-36:0))}" "" "0" "10" "$((select-1))"\
  "'..' `for ((n=2;n<${#dir[@]};n++)) ; do echo "'${clickshow[click[n]]}${color[style[n]]}${dir[n]}'" ; done`\
  '> $inc Directory operations...' '> $inc Select an action...' '> $inc Disk information' '> $inc drop out'"
}
prog_sure(){
  if [ -d "$line" ] ; then style[n]=0
    if [ -h "$line" ] ; then style[n]=5 ; fi
  elif [ -h "$line" ] ; then style[n]=2
  elif [ -b "$line" ] ; then style[n]=3
  elif [ -c "$line" ] ; then style[n]=4
  else
    if [ "${line:(-7)}" = '.tar.gz' ] ; then style[n]=6
    else style[n]=1
    fi
  fi
}
prog_msgbox_dirmenu(){
  $app/Msgbox.sh "$xy" "Directory operations"\
  "'Run command...' 'Create a new file (Folder)...' Create link Paste Find Back"
  case "$?" in
  0 ) prog_msgbox_run ;;
  1 ) prog_msgbox_new ;;
  2 ) prog_link_make ;;
  3 ) prog_paste ;;
  4 ) prog_search ;;
  esac
}
prog_msgbox_run(){
  echo -e "$inc This feature is not carry out!$end"
}
prog_msgbox_new(){
  $app/Msgbox.sh "$xy" "'Create a new file (Folder)'"\
  "New file folder Cancel"
  case "$?" in
  0 ) prog_input "create a new file" ; echo -n "" >> "$read" ;;
  1 ) prog_input "create a new file folder" ; mkdir "$read" ;;
  esac
}
prog_link_make(){
  if [ "$mount" = "" ] ; then
    echo -e "$inc No original link selected!$end" ; return
  fi
  prog_input Create link ; ln -sn "$mount" "./$read"
  echo -e "$inc Link creation${ok[$?]}!$end"
}
prog_input(){
  echo -e "\E[1m$inc$1 Please enter a name: $end"
  read -r read
}
prog_paste(){
  if [ "${copy[0]}" = "" ] ; then
    echo -e "$inc No files in clipboard!$end"
    usleep 500000 ; return
  fi
  echo -e "$inc Pasting...$end"
  for ((n=1;n<${#copy[@]};n++)) ; do
    echo -e "$inc$n/$((${#copy[@]}-1)): ${copy[n]}$end"
    if [ "${copy[0]}" = 0 ] ; then mv "${copy[n]}" .
    else cp -rf "${copy[n]}" .
    fi
  done
}
prog_search(){
  echo -e "$inc This feature is not carry out!$end"
}
prog_file(){
  pwd="$PWD/${dir[select]}" ; tmp="$1"
  if [ "$tmp" = 2 ] ; then tmp=0 ; fi
  echo -ne "${linkp[$1]}$3$end"
  if [ $1 = 2 ] ; then
    $app/Msgbox.sh "$xy" "Configuration file" "Restore configuration Cancel"
    if [ $? = 0 ] ; then echo "${PWD}/${dir[select]}" > /tmp/BakFilename.tmp ; echo -e "\033[?25h" ; stty echo ; break ; exit 1 ; fi 
  fi
  $app/Msgbox.sh "$xy" "$2"\
  "'${clickmsg[click[select]]}' 'run...' ${linkshow[$1]} ${tar[$1]} 'Mount / link' ' Double naming' 'delete...' 'return'"
  case "$?" in
  0 ) click[$select]=$((click[select]==0)) ;;
  1 ) prog_file_msgbox_run ;;
  $((tmp+1)) ) cd "$(dirname "$(readlink "${dir[select]}")")" ; select=1 ;;
  $((tmp+2)) )
    if [ "$1" = 2 ] ; then prog_unpick
    else prog_file_open
    fi ;;
  $((tmp+3)) ) prog_mount ;;
  $((tmp+4)) ) prog_rename ;;
  $((tmp+5)) ) prog_delete ;;
  esac
}
prog_file_open(){
  $app/Msgbox.sh "$xy" "open a file please choose turn on the way:"\
  "'Backup and restore' '  Vim  ' 'MPlayer' '  return  '"
  tmp=$?
  if [ "$tmp" = 3 ] ; then return ; fi
  case $tmp in
  0 ) echo "$PWD/${dir[select]}" > /tmp/BakFilename.tmp ;;
  1 ) vim "$PWD/${dir[select]}" ;;
  2 ) mplayer "$PWD/${dir[select]}" ;;
  esac
}
prog_file_msgbox_run(){
  $app/Msgbox.sh "$xy" "run file"\
  "Run cancel in this terminal"
  case "$?" in
  0 ) (${dir[select]}) ;;
  esac
}
prog_mount(){
  mount="$pwd"
  echo -e "$inc$pwd Saved as Mount / link original file!$end" ; sleep 1s
}
prog_delete(){
  $app/Msgbox.sh "$xy" "delete file'Are you sure you want to delete?'"\
  "Delete to recycle bin Completely delete Cancel delete operation"
  case "$?" in
  0 )
    rm -rf "$recycle/${dir[select]}" > "$null"
    mv "${dir[select]}" "$recycle" ; tmp="$?" ;;
  1 ) rm -rf "${dir[select]}" ; tmp="$?" ;;
  2 ) return ;;
  esac
  echo -e "$incdelete${ok[tmp]}!$end" ; usleep 500000
}
prog_rename(){
  prog_input Double naming file
  mv "${dir[select]}" "$read"
  echo -e "$incDouble naming${ok[$?]}!$end" ; usleep 500000
}
prog_click_back(){
  clickbak=(${click[@]}) ; unset click[@]
  for ((n=0;n<=${#bak[@]};n++)) ; do
    if [ "${clickbak[n]}" = 1 ] ; then
      if [ "${bak[n]}" = "${dir[n]}" ] ; then
        click[$n]=1 ; continue
      fi
      for ((m=0;m<=${#dir[@]};m++)) ; do
        if [ "${bak[n]}" = "${dir[m]}" ] ; then
          click[$m]=1
        fi
      done
    fi
  done
}
prog_click(){
  clicknum=0 ; unset clickterms[@] ; unset clicknames[@]
  declare -a clickterms ; declare -a clicknames
  for ((n=0;n<=${#dir[@]};n++)) ; do
    if [ "${click[n]}" = 1 ] ; then
      clickterms[${#clickterms[@]}]="$PWD/${dir[n]}"
      clicknames[${#clicknames[@]}]="${dir[n]}"
      ((clicknum++))
    fi
  done
  if [ $clicknum = 0 ] ; then
    echo ; echo -e "$inc No selection!$end"
    usleep 500000 ; return
  fi
  $app/Msgbox.sh "$xy" "Select item operation $clicknum item selected"\
  "Cut copy 'delete...' 'Bale...' 'return'"
  case $? in
  0 ) prog_multicut ;;
  1 ) prog_multicopy ;;
  2 ) prog_multidelete ;;
  3 ) prog_pickup ;;
  esac
}
prog_click_clear(){
  unset clicktrems[@] clickname[@] click[@] ; clicknum=0
}
prog_multicut(){
  unset copy[@] ; copy[0]=0 ; prog_copy_data
  echo -e "$inc Cut: saved$clicknum each file to clipboard$end"
  usleep 500000
}
prog_multicopy(){
  unset copy[@] ; copy[0]=1 ; prog_copy_data
  echo -e "$inc Copy: saved$clicknum each file to clipboard$end"
  usleep 500000
}
prog_copy_data(){
  for ((n=0;n<${#clickterms[@]};n++)) ; do
    copy[${#copy[@]}]="${clickterms[n]}"
  done
}
prog_multidelete(){
  $app/Msgbox.sh "$xy" "delete file chosen$clicknum each file"\
  "Delete to recycle bin Completely delete Cancel delete operation"
  tmp="$?"
  if [ $tmp = 2 ] ; then return ; fi
  echo -e "$inc In delete file...$end"
  for ((n=0;n<${#clickterms[@]};n++)) ; do
    echo -e "$inc$((n+1))/${#clickterms[@]}: ${clickterms[n]}$end"
    if [ $tmp = 0 ] ; then
      rm -rf "$recycle/`basename "${clickterms[n]}"`" > "$null"
      mv "${clickterms[n]}" "$recycle"
    else
      rm -rf "${clickterms[n]}"
    fi
  done
  unset click[@] ; select=1
}
prog_pickup(){
  $app/Msgbox.sh "$xy" "'create.tar.gz compression file' 'chosen$clicknum item'"\
  "'Compress to the current directory' 'Zip to home directory' 'Zip to root directory' 'cancel'"
  case $? in
  0 ) tardir="$PWD" ;;
  1 ) tardir="$HOME" ;;
  2 ) tardir="/" ;;
  3 ) return ;;
  esac
  prog_input " file打包"
  echo -e "$inc Compressed to$tardir/$read.tar.gz: Compressing...$end"
  tar -czvf "$tardir/$read.tar.gz" -C "$PWD" ${clicknames[@]}
  echo -e "$inc Compress ${ok[$?]}!$end"
}
prog_dir(){
  echo -e "${linkp[$1]}$3$end"
  $app/Msgbox.sh "$xy" " file夹$2"\
  "'进入' ${linkshow[$1]} '${clickmsg[click[select]]}' 'Mount to this folder' 'Mount / link' 'Double naming' 'delete...' 'return'"
  case $? in
  0 ) cd "${dir[select]}" ; prog_click_clear ; select=1 ;;
  $1 ) cd "`readlink "${dir[select]}"`" ; select=1 ;;
  $((1+$1)) ) click[$select]=$((click[select]==0)) ;;
  $((2+$1)) ) prog_mount_to ;;
  $((3+$1)) ) pwd="$PWD/${dir[select]}" ; prog_mount ;;
  $((4+$1)) ) prog_rename ;;
  $((5+$1)) ) prog_delete ;;
  esac
}
prog_mount_to(){
  if [ "$mount" = "" ] ; then
    echo -e "$inc No option to mount the original file!$end"
    usleep 500000 ; return
  fi
  umount -l "${dir[select]}" ; usleep 300000
  mount "$mount" "${dir[select]}"
  echo -e "$inc Mount${ok[$?]}!$end"
}
prog_unpick(){ 
  $app/Msgbox.sh "$xy" "Unzip file"\
  "Unzip to the current directory and mount Unzip to home directory  Unzip to the root directory cancel"
  case $? in
  0 ) tardir="$PWD" ;;
  1 ) tardir="$HOME" ;;
  2 ) tardir="/" ;;
  3 ) return ;;
  esac
  tar -xzvf "${dir[select]}" -C "$tardir"
  echo -e "$incUnzip${ok[$?]}$end"
}

#initialization
mkdir -p "$recycle"
initdir="$1"
power=1 ; open=0

#Main program
stty -echo ; stty erase '^?' ; cd "$initdir"
trap 'echo -e "\033[?25h" ; stty echo ; exit 0' 2
until [ "$quit" = 1 ] ; do
  prog_find ; select="$(($(<$listfile)+1))"
  case "$select" in
  1 ) cd .. ;;
  ${#dir[@]} ) prog_msgbox_dirmenu ;;
  $((${#dir[@]}+1)) ) prog_click ;;
  $((${#dir[@]}+2)) ) df -h
    echo -e "$inc Press enter to continue...$end" ; read -s ;;
  $((${#dir[@]}+3)) ) exit 1 ;;
  * )
    case "${style[select]}" in
    0 ) prog_dir 0 ;;
    1 ) prog_file 0 ordinary file ;;
    2 ) prog_file 1  file link "\E[2G$inc address: `readlink "${dir[select]}"`" ;;
    5 ) prog_dir 1 link "\E[2G$inc address: `readlink "${dir[select]}"`" ;;
    6 ) prog_file 2 compression file ;;
    esac ;;
  esac
done
echo $result > $outfile ; echo -e "\033[?25h" ; stty echo ; exit 0
