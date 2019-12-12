#!/bin/bash

#File location
#ctrlf="/opt/QtPalmtop/data/z/common/ctrl.dat" #Button data
ctrlf="$(dirname "$0")/term.dat"
outf="/tmp/ListSelect.tmp"

#Other data
declare -a tmp=(`cat $ctrlf`)    #Key data processing
up="${tmp[0]}"    #Key data
down="${tmp[1]}"    #Down-key data
left="${tmp[2]}"    #Left button data
right="${tmp[3]}"    #Right data
pageup="${tmp[4]}"    #Page up key data
pagedown="${tmp[5]}"    #Page down data
back="${tmp[6]}"    #Return key data

#颜色数据
titc='\E[1;31;40m'    #Title
errc='\E[1;34;40m'    #Error No list item
color='\E[1;34;40m'    #Copyright  Made By JohnFordTV (ZHIYB)
linc='\E[1;32;40m'    #Split  ###split line###colour
inc='\E[1;33;40m'    #Prompt text
declare -a listc=('\E[0;34;40m' '\E[1;34;102m') \
term=('\E[0;34;40m' '\E[1;32;44m')
light="\E[1;37;40m"    #Highlight text
end='\E[0m'    #Back to initial color

#显示内容
if [ "$1" = "" ] ; then
  in_title="      List selection" ; in_made="      AR-B-P-B"
  in_show="1" ; in_pagenum="0" ; in_init="0"
  declare -a in_list=( 'List selector'\
  'Parameter: Title About Error Emphasis Quantity Initial'\
  'Parameter 1: program title'\
  'Parameter 2: program information'\
  'Parameter 3: No option error display'\
  'Parameter 4: The left and right prompts of the options are displayed?'\
  'Parameter 5: Display quantity per page'\
  'Parameter 6: initial selection (starting from 0)'\
  'Parameter 7: list item'\
  'List item details see page 2'\
  'Program return value: selected item (starting from 0)'\
  'The return value is from 0 to 255, and a total of 256 items can be returned'\
  'List item input description:'\
  'Enclose all list items with \ "\" as position parameter 7'\
  'Separate items with spaces'\
  'It's better to enclose each item with '\'\
  'Some special characters need to be escaped with \\'\
  'other:'\
  'Can be used in text parameters \E[32;41mecho\E[7m escape \E[27m sequence'\
  'Position parameter must exist (not empty)'\
  'Otherwise this help is displayed'\
  'It will also automatically save the selected items to'\
  "\E[31m$outf In the file"\
  'You can choose more than 256 items' )
else
  in_title="$1" ; in_made="$2" ; in_err="$3"
  in_show="$4" ; in_pagenum="$5" ; in_init="$6"
  eval declare -a in_list=($7) #List item
  if [ "$in_init" = "" ] ; then in_init=0 ; fi
fi
lines="$linc################################################$end" #Split line
title="$titc$in_title$color$in_made$end"    #Title
if [ "$in_show" = 1 ] ; then
  declare -a chl=('------ ' '>>>>>> ') chr=(' ------' ' <<<<<<')
else declare -a chl=('' '') chr=('' '')
fi

#function
prog_Auto(){
  ((pagenum=in_pagenum==0?$(tput lines)-4:in_pagenum))
  n=$lnum ; pages=0
  while ((n>pagenum)) ; do
    ((pages++)) ; ((n-=pagenum))
  done
}

#Main program
lnum=${#in_list[@]} ; prog_Auto
quit=0 ; dat=$in_init ; pageno=1
echo -ne '\E[?25l' ; stty -echo
until [ "$quit" = "1" ] ; do
  if [ "$pages" = "0" ] ; then
    n=0 ; page=$lnum #Page display items
  else
    page=0 ; pageno=1 ; n=$dat
    while ((n>((pagenum-1)))) ; do
      ((page+=pagenum)) ; ((n-=pagenum)) ; ((pageno++))
    done
    n=$page ; ((page+=pagenum))
    if ((page>=((lnum+pagenum)))) ; then
      ((n-=pagenum)) ; ((pageno--)) ; page=$lnum
    elif ((page>lnum)) ; then page=$lnum
    fi
  fi
  clear ; echo -e "$title\n$lines\n$inc On down button selection, left and right buttons to page:$light$pageno$inc, Total $light$((tmp=$pages+1))$inc page $end"
  if [ "${#in_list[@]}" = "0" ] ; then
    echo -e "$errc$in_err$end" ; dat=0 ; quit=1
    read -s ; continue
  fi
  until [ "$n" = "$page" ] ; do
    echo -e "${term[((tmp=n++==dat))]}${chl[tmp]}${listc[tmp]}${in_list[((n-1))]}${term[tmp]}${chr[tmp]}$end"
  done
  read -sn 3 key
  if [ "$key" = "$up" ] ; then ((dat--))
    ((dat=dat==-1?lnum-1:dat))
  elif [ "$key" = "$down" ] ; then ((dat++))
    ((dat=dat==lnum?0:dat))
  elif [ "$key" = "$right" ] ; then ((dat+=pagenum))
    ((dat=dat>=lnum?lnum-1:dat))
  elif [ "$key" = "$left" ] ; then
    ((dat=dat>=lnum?lnum-pagenum:((dat<pagenum?0:dat-pagenum))))
  elif [ "$key" = "" ] ; then
    quit=1
  fi
  prog_Auto
done
echo -n $dat > "$outf" ; echo -ne '\E[?25h'
stty echo ; exit $dat
