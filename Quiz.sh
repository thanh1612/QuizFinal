#!/bin/bash
 
welcome(){
    clear
    echo
    echo "                  	WELCOME TO QUIZ"
    echo "--------------------------------------------------------------"
    echo
}

 
show-menu(){
	welcome
    printf "\n\033[34;01m\t\t\t     MENU\033[0m\n"
    echo "		   +-----------------------+"
    echo "		   |  1 - Quiz             |"
    echo "		   |  2 - Champion         |"
    echo "		   |  3 - Add questions    |"
    echo "		   |  4 - Print Quiz       |"
    echo "		   |  5 - About            |"
    echo "		   |  Q - Quit             |"
    echo "		   +-----------------------+"
    echo -n "			Your choice:  "
    read action
}

 
show-quiz(){
    welcome
    
    printf "\n\033[34;01m\t\t\t CHOOSE SUBJECT\033[0m\n"
    echo "		   +-----------------------+"
    echo "		   |  1 - Sports           |" 
    echo "		   |  2 - Culture          |"
    echo "		   |  3 - Music            |"
    echo "		   |  4 - General          |"
    echo "		   |  B - Back             |"
    echo "		   +-----------------------+"
    echo -n "			Your choice:  "
    read choice
    
    case $choice in
        1) subject="sport"
        subject-quiz;;
        2) subject="culture"
        subject-quiz;;
        3) subject="music"
        subject-quiz;;
        4) general-quiz;;
        b|B) show-menu;;
        *) echo "TYPE WRONG! Try again..."
           show-quiz;;
    esac     
}

q=1
i=0
arrayA[0]=0
point=0

random-quiz(){
    while [ $q -le $numQ ]
    do
        let x=$RANDOM%$total+1
        for (( j=startQ;j<=i;j++ ))
        do
            while [ $x -eq ${arrayA[$j]} ]
            do
                let x=$RANDOM%$total+1
                let j=startQ
            done
        done
        let i++
        arrayA[$i]=$x
        
        grep "^$x:" $subject-q-$levelQuiz.txt | (
            while IFS=":" read num afficheQ
            do
                printf "\033[34;01m$q.$afficheQ\033[0m\n"
            done )
            

        grep "^$x:" $subject-a-$levelQuiz.txt | (
            while IFS=":" read num ansA ansB ansC ansD ansCorrect
            do
                printf "  a. $ansA\n  b. $ansB\n  c. $ansC\n  d. $ansD\n"
            done )
        
        printf "\033[35;01m---Your answer: \033[0m"
        read answer
        
        case $answer in
        a) answer='a';;
        b) answer='b';;
        c) answer='c';;
        d) answer='d';;
        *) while [ "$answer" != 'a' ] && [ "$answer" != 'b' ] && [ "$answer" != 'c' ] && [ "$answer" != 'd' ]
		   do
				echo "Type wrong! Try again!"
				printf "\033[35;01m---Your answer: \033[0m"
				read answer
		   done;;
        esac
        
        ansCorrect=`grep "^$x:" $subject-a-$levelQuiz.txt | cut -d: -f6`
        if [ "$answer" == "$ansCorrect" ]
            then
                printf "\033[32;01m TRUE!\033[0m\n\n"   
                let point+=$add
                let true++
            else
                printf "\033[31;01m FALSE!\033[0m The true answer is $ansCorrect.\n\n"
        fi
        
        let q++       
    done
}

save=0

subject-quiz(){
	if [ $save -eq 0 ]
    then		   
		echo
		echo -n "		Enter your name:  "
		read player
		
		clear
		welcome
		echo "SUBJECT: $subject"
		echo "NAME: $player"
		echo
	fi
	
    startQ=0
    numQ=10
    levelQuiz="easy"
    total=`awk 'BEGIN { i=0 } { i++ } END { print i }' $subject-q-$levelQuiz.txt`
    echo "--PART 1: Subject $subject - Level $levelQuiz"
    echo
    add=5
    true=0
    random-quiz
    let true_easy=$true
    
    startQ=10
    numQ=15
    levelQuiz="hard"
    total=`awk 'BEGIN { i=0 } { i++ } END { print i }' $subject-q-$levelQuiz.txt`
    echo "--PART 2: Level $levelQuiz: point x2"
    echo
    add=10
    true=0
    random-quiz
	let true_hard=$true

	printf "\n TOTAL:"
    printf "\n\t Level easy: $true_easy/10"
    printf "\n\t Level hard: $true_hard/5"
    printf "\n---> $player! You got $point/100 points! <---\n\n"
    
    if [ $save -eq 0 ]
    then
		echo $player:$point:$subject >> champion.txt
		echo "--Press any key to go back"
		read key
	fi
}


general-quiz(){
	echo
	echo -n "		Enter your name:  "
	read player
		
	clear
    welcome
    echo "MODE GENERAL"
    echo "NAME: $player"
    echo
    
    save=1
    pointFinal=0
    
    subject="culture"
    subject-quiz 
    
    subject="music"
    q=1
    numQ=10
    subject-quiz
    
    subject="sport"
    q=1
    numQ=10
    subject-quiz
    
    clear

    pointFinal=`echo "scale=1;$point/3"|bc`
    printf "\n---> $player! You got $pointFinal/100 points! <---\n\n"
    echo $player:$pointFinal:general >> champion.txt     
    
    echo "--Press any key to go back"
	read key
}

show-champion(){
	clear
	welcome
	
    printf "\n\033[34;01m\t\t\t   CHAMPION\033[0m\n"
    echo "      +-----------------------+---------+---------------+"
    echo "      |          NAME         |  NOTES  |    SUBJECT    |" 
    echo "      +-----------------------+---------+---------------+"
     
    while IFS=":" read line
    do
        name=`echo $line | cut -d: -f1`
        notes=`echo $line | cut -d: -f2`
        subject=`echo $line | cut -d: -f3`
        printf "      | %-21s | %4s    |    %-10s |\n" "$name" "$notes" "$subject"
    done < champion.txt  
    echo "      +-----------------------+---------+---------------+"
	echo  "      Press '1' to find		      '2' to back to menu"
	read key
	
	case $key in
		1) 
			echo -n "Enter name:  "
			read name		
			clear
			welcome
			
			printf "      Result of \033[32;01m$name \033[0m\n\n"  
			echo "      +-----------------------+---------+---------------+"
			echo "      |          NAME         |  NOTES  |    SUBJECT    |" 
			echo "      +-----------------------+---------+---------------+"
	
			grep "^$name" champion.txt | (
			while IFS=":" read player score subject
			do 
				printf "      | %-21s | %4s    |    %-10s |\n" "$player" "$score" "$subject"
			done )
			
			echo "      +-----------------------+---------+---------------+"
			echo
			echo "--Press any key to go back"
			read pause
			show-champion;;
		2)	show-menu;;
	esac
}

menu-questions(){
	welcome 
	printf "\n\033[34;01m\t\t\t ADD QUESTIONS\033[0m\n"
    echo "		   +----------------------+"  
    echo "		   |  1 - Sport           |"  
    echo "		   |  2 - Culture         |"
    echo "		   |  3 - Music           |"
    echo "		   |  B - Back            |"
    echo "		   +----------------------+"  
    echo -n "			Your choice:  "
    read choice
     
    case $choice in
        1) 	subject="sport"
			add-question;;
        2) 	subject="culture"
			add-question;;
        3) 	subject="music"
			add-question;;
        b|B) show-menu;;
        *) echo "TYPE WRONG! Try again..."
           add-questions;;
    esac
}

add-question(){ 
    welcome 
    printf "\n\033[34;01mADD QUESTIONS SUBJECT: $subject\033[0m\n\n"
    
    echo -n "--QUESTION:  "
    read question
    echo
     
    echo -n "   Answer a:  "
    read ansA
    echo -n "   Answer b:  "
    read ansB
    echo -n "   Answer c:  "
    read ansC
    echo -n "   Answer d:  "
    read ansD
    echo
    echo -n "   Right answer (a,b,c or d):  "
    read right
    echo
     
    echo "--LEVEL"
    echo "  1 - Easy"
    echo "  2 - Hard"
    echo
    echo -n "   Your choice:  "
    read level
         
    case $level in
        a|1) level="easy";;
        b|2) level="hard";;
        *) echo "TYPE WRONG! Try again..."
           add-questions;;
    esac
     
    lastLine=`awk -F: 'END{print $1}' $subject-q-$level.txt`
    let nextID=lastLine+1
     
    echo $nextID:$question >> $subject-q-$level.txt
    echo $nextID:$ansA:$ansB:$ansC:$ansD:$right >> $subject-a-$level.txt
}
 
info(){
	clear
	welcome
	
    printf "\n\033[34;01m\t\t\t   INFORMATION\033[0m\n"
    echo
    echo "   A project of team 1, LINF14, for course ASR1-Shell Scripts"
    echo
    printf "\n\t\t\t\033[32;01mNguyen Cong Thanh\033[0m\n"
    printf "\n\t\t\t  \033[32;01mPhan Anh Thu\033[0m\n"
    printf "\n\t\t     \033[32;01mNguyen Duc Hoang Trieu\033[0m\n"
    echo
    echo "--Press any key to back to main menu"
    
    read key
    show-menu
}
 
print_quiz(){
	welcome
	
	echo -n "Name of file:  "
	read name
	if [ -f $name.txt ]
	then
		echo "File exist, enter another name:  "
		echo "--Press any key to return"
		read key
		print_quiz
	fi
	
	echo "Choose subject: "
	echo "		   +-----------------------+"
    echo "		   |  1 - Sports           |" 
    echo "		   |  2 - Culture          |"
    echo "		   |  3 - Music            |"
    echo "		   +-----------------------+"
	echo -n "   Your choice:  "
	read subject
	
	case $subject in
		1) subject="sport";;
		2) subject="culture";;
		3) subject="music";;
	esac
	
	echo -n "Number of level easy (Max 20): "
	read numE
	echo -n "Number of level hard (Max 20): "
	read numH
	
	if [ $numE -gt 20 ] || [ $numH -gt 20 ]
	then
		echo
		echo "--Max 20, you should retype!"
		echo "--Press any key to return"
		read key
		print_quiz
	fi
	
	q=1
	levelQuiz="easy"
	let startQ=0
	let numQ=numE
	total=`awk 'BEGIN { i=0 } { i++ } END { print i }' $subject-q-$levelQuiz.txt`
	print
	
	levelQuiz="hard"
	let startQ=numE
	let numQ=numE+numH
	total=`awk 'BEGIN { i=0 } { i++ } END { print i }' $subject-q-$levelQuiz.txt`
	print
	
	echo
	echo "Press any key to back to main menu"
	read key
	show-menu
}
print(){
	while [ $q -le $numQ ]
    do
        let x=$RANDOM%$total+1
        for (( j=startQ;j<=i;j++ ))
        do
            while [ $x -eq ${arrayA[$j]} ]
            do
                let x=$RANDOM%$total+1
                let j=startQ
            done
        done
        let i++
        arrayA[$i]=$x
        
        grep "^$x:" $subject-q-$levelQuiz.txt | (
            while IFS=":" read num afficheQ
            do
                echo "$q.$afficheQ"
                echo "$q.$afficheQ" >> $name.txt
            done )
            

        grep "^$x:" $subject-a-$levelQuiz.txt | (
            while IFS=":" read num ansA ansB ansC ansD ansCorrect
            do
                printf "  a. $ansA\n  b. $ansB\n  c. $ansC\n  d. $ansD\n"
                printf "  a. $ansA\n  b. $ansB\n  c. $ansC\n  d. $ansD\n" >> $name.txt
            done )
        let q++
	done
}

show-menu
 
while [ "$action" != "q|Q" ]
do
    case $action in
        1) show-quiz;;
        2) show-champion;;
        3) menu-questions;;
        4) print_quiz;;
        5) info;;
        Q|q) exit;;
        *) echo "TYPE WRONG! Try again...";;
    esac
   
done
