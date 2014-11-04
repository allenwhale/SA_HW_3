#!/bin/sh
RSS_DIR='/home/allenwhale/.feed'
TEMP_FILE=${RSS_DIR}'/.tmp'
TITLE_FILE=${RSS_DIR}'/title'
ITEM_FILE=${RSS_DIR}'/item_view'
SUSCRIPTION=''
NOW_PAGE='Welcome'
Welcome(){
    env dialog --title 'RSS Reader' --msgbox 'My RSS Reader' 0 0 
    NOW_PAGE='Menu'
}
Menu(){
    env dialog --menu 'Choose Action' 0 0 5 'R' 'Read - read subscribed feeds' 'S' 'Subscribe - new subscription' 'D' 'Delete - delete subscription' 'U' 'Update - update subscription' 'Q' 'Bye' 2>${TEMP_FILE}
    action=$(cat ${TEMP_FILE})
    env rm ${TEMP_FILE}
    case ${action} in
	'R')
	    NOW_PAGE='Read';;
	'S')
	    NOW_PAGE='Subscribe';;
	'D')
	    NOW_PAGE='Delete';;
	'U')
	    NOW_PAGE='Update';;
	'Q')
	    NOW_PAGE='Quit';;
    esac
}
Read(){
    s=''
    flag='1'
    cnt='1'
    while read line ; do
	if [ ${#line} -eq 0 ] ; then
	    return
	fi
	if [ $flag -eq 1 ] ; then
	    s=${s}' '${cnt}' '${line}' '
	    flag='0'
	    eval TITLE_NAME$cnt='${line}'
	    cnt=$((${cnt} + 1))
	else
	    flag='1'
	fi
    done < ${TITLE_FILE}
    if [ ${#s} -eq 0 ] ; then 
	env dialog --title 'Read' --msgbox 'No Subscription' 0 0 
	NOW_PAGE='Menu'
	return 
    fi
    env dialog --title 'Read' --menu 'choose subscription' 0 0 $(($cnt - 1)) ${s} 2>${TEMP_FILE}
    if [ $? -eq 1 ] ; then 
	NOW_PAGE='Menu'
	return
    fi
    SUBSCRIPTION=$(cat ${TEMP_FILE})
    env rm ${TEMP_FILE}
    eval SUBSCRIPTION=\$TITLE_NAME$SUBSCRIPTION
    NOW_PAGE='ReadItems'
}
ReadItems(){
    flag=1
    cnt=1
    s=''
    while read line ; do
	if [ ${flag} -eq 1 ] ; then
	    eval SUBTITLE${cnt}='${line}'
	    s=${s}' '${cnt}' '\""${line}"\"' '
	    flag=2
	elif [ ${flag} -eq 2 ] ; then
	    eval URL${cnt}='${line}'
	    flag=3
	else
	    eval CONTENT${cnt}=\""${line}"\"
	    cnt=$((${cnt} + 1))
	    flag=1
	fi
    done < ${RSS_DIR}'/'${SUBSCRIPTION}
    eval env dialog --title \'Read\' --menu \'choose item\' 0 0 $((${cnt} - 1)) ${s} 2>${TEMP_FILE}
    if [ $? -eq 1 ] ; then
	NOW_PAGE='Read'
	return
    fi
    itemno=$(env cat ${TEMP_FILE})
    env rm ${TEMP_FILE}
    eval IN_TITLE=\$SUBTITLE${itemno}
    eval IN_URL=\$URL${itemno}
    eval IN_CONTENT=\$CONTENT${itemno}
    NOW_PAGE='Items'
}
Items(){
    echo "${IN_TITLE}" > ${ITEM_FILE}
    echo '==============================================' >> ${ITEM_FILE}
    echo "${IN_URL}" >> ${ITEM_FILE}
    echo '==============================================' >> ${ITEM_FILE}
    cnt=0
    for i in ${IN_CONTENT} ; do
	echo -n "${i} " >> ${ITEM_FILE}
	cnt=$((${cnt} + ${#i}))
	if [ ${cnt} -gt 50 ] ; then
	    echo '' >>${ITEM_FILE}
	    cnt=0
	fi
    done
    if [ ${cnt} -ne 0 ] ; then 
	echo '' >> ${ITEM_FILE}
    fi
    echo '==============================================' >> ${ITEM_FILE}
    env dialog --textbox ${ITEM_FILE} 0 0
    NOW_PAGE='ReadItems'
}
Subscribe(){
    env dialog  --inputbox 'Enter feed url' 0 0 2>${TEMP_FILE}
    if [ $? -eq 1 ] ; then
	NOW_PAGE='Menu'
	return
    fi
    url=$(cat ${TEMP_FILE})
    env rm ${TEMP_FILE}
    if [ ${#url} -eq 0 ] ; then
	env dialog --title 'Subscribe' --msgbox 'url can not be empty' 0 0
	return
    fi
    env python3 myfeed.py -a $url
    res=$(env cat ${TEMP_FILE})
    env rm ${TEMP_FILE}
    if [ ${#res} -eq 0 ] ; then
	env dialog --title 'Subscribe' --msgbox 'Success' 0 0
	NOW_PAGE='Menu'
    else
	env dialog --title 'Subscribe' --msgbox 'Something Wrong' 0 0
    fi
}
Delete(){
    s=''
    flag='1'
    cnt='1'
    while read line ; do
	if [ $flag -eq 1 ] ; then
	    s=${s}' '${cnt}' '${line}' '
	    flag='0'
	    eval TITLE_NAME$cnt='${line}'
	    cnt=$((${cnt} + 1))
	else
	    flag='1'
	fi
    done < ${TITLE_FILE}
    if [ ${#s} -eq 0 ] ; then 
	env dialog --title 'Delete' --msgbox 'No Subscription' 0 0
	NOW_PAGE='Menu'
	return 
    fi
    env dialog --title 'Delete' --menu 'choose item to delete' 0 0 ${cnt} ${s} 2>${TEMP_FILE}
    if [ $? -eq 1 ] ; then 
	NOW_PAGE='Menu'
	return
    fi
    SUBSCRIPTION=$(cat ${TEMP_FILE})
    env rm ${TEMP_FILE}
    eval SUBSCRIPTION=\$TITLE_NAME$SUBSCRIPTION
    env python3 myfeed.py -d $SUBSCRIPTION
    tmp=$(cat ${TEMP_FILE})
    if [ ${#tmp} -eq 0 ] ; then
	env dialog --title 'Delete' --msgbox 'OK' 0 0
    else
	env dialog --title 'Delete' --msgbox 'Something Wrong' 0 0
    fi
}
Update(){
    s=''
    flag='1'
    cnt='1'
    while read line ; do
	if [ $flag -eq 1 ] ; then
	    s=${s}' '${cnt}' '${line}' off '	    
	    flag='0'
	    eval TITLE_NAME$cnt='${line}'
	else
	    eval TITLE_URL$cnt='${line}'
	    cnt=$((${cnt} + 1))
	    flag='1'
	fi
    done < ${TITLE_FILE}
    if [ ${#s} -eq 0 ] ; then 
	env dialog --title 'Update' --msgbox 'No Subscription' 0 0
	NOW_PAGE='Menu'
	return 
    fi
    env dialog --title 'Update' --checklist 'choose item to delete' 0 0 ${cnt} ${s} 2>${TEMP_FILE}
    if [ $? -eq 1 ] ; then 
	NOW_PAGE='Menu'
	return
    fi
    SUBSCRIPTION=$(cat ${TEMP_FILE})
    env rm ${TEMP_FILE}
    cnt=0
    for i in $SUBSCRIPTION ; do
	cnt=$((${cnt} + 1))
    done
    OK=0
    no=1
    for i in $SUBSCRIPTION ; do
        eval SUBSCRIPTION=\$TITLE_NAME$i
	eval SUBSCRIPTIONURL=\$TITLE_URL$i
	env python3 myfeed.py -u $SUBSCRIPTIONURL $SUBSCRIPTION 
	tmp=$(cat ${TEMP_FILE})
	env rm ${TEMP_FILE}
	if [ ${#tmp} -eq 0 ] ; then
	    echo $((100 * ${no} / ${cnt}))
	    no=$((${no} + 1))
	else
	    OK=1
	    break
	fi
    done | env dialog --title 'Update' --guage 'Please wait' 0 0
    if [ ${OK} -eq 0 ] ; then 
	env dialog --title 'Update' --msgbox 'Success' 0 0
    else
	env dialog --title 'Update' --msgbox 'Something Wrong' 0 0
    fi
    NOW_PAGE='Menu'
}
Quit(){
    env dialog --title 'Quit?' --yesno 'Do you want to quit?' 0 0
    tmp=$?
    if [ $tmp -eq 1 ] ; then
	NOW_PAGE='Menu'
    else
	NOW_PAGE='Exit'
    fi
}
while [ 1=1 ]; do
    case ${NOW_PAGE} in 
	'Welcome')
	    Welcome;;
	'Menu')
	    Menu;;
	'Read')
	    Read;;
	'ReadItems')
	    ReadItems;;
	'Items')
	    Items;;
	'Subscribe')
	    Subscribe;;
	'Update')
	    Update;;
	'Delete')
	    Delete;;
	'Quit')
	    Quit;;
	'Exit')
	    break;;
    esac
done
