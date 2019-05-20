#!/bin/bash
export LC_NUMERIC="en_US.UTF-8"
#surnames=('Хаятова')
surnames=('Ситников' 'Турнаев' 'Хаятова' 'Зайчиков' 'Загоруйко' 'Суртаев' 'Сердцев' 'Кулиев' 'Рылов')
cur_date=$(date +%Y-%m)
#cur_date='2018-11'
month="month.html"
nowTime="now.html"
curl --silent "http://10.1.1.49/?date=$cur_date" -o $month
curl --silent http://10.1.1.49/ -o $nowTime

people=()
avg_array=()
declare -A hashMap
echo 'Time Attandance (v1.0): '$cur_date
for index in ${!surnames[*]}
do
	#echo '------------------'
	surname=${surnames[$index]}
	#echo 'Surname:'$surname
	avg=$(cat $month | grep -A 10 $surname | grep -v td | sed '2,3!D' | tr -d '&nbsp;'  | sed 's/ *//g' | tr ':' '.' | tr '\n' ' ')	
	if [[ ${#avg} -eq 0 ]]; then
		continue;
	fi
	
	array=($avg)
	days=${array[0]}
	worked_total=${array[1]}

	avg=$(echo $days" "$worked_total | awk '{print $2/$1}')

	if [[ ${#avg} -eq 0 ]]; then
		avg=0;
	fi

	#echo 'avg: '$avg
	avg_array+=($avg)
	need_work=$(echo $days" "$worked_total | awk '{print 8*$1-$2}')
	#echo 'need work: '$need_work
	today=$(cat $nowTime | grep -A 10 $surname | tail -n 2 | head -n 1 | sed 's/ *//g'  | tr ':' '.')
	#echo 'today: '$today
	peopleString="$surname $avg $need_work $today $days"
	#echo $peopleString
	people+=($peopleString)
	hashMap+=(["$avg"]="$peopleString")
done

header='+------------+-----------+--------------+------------+-------+'
echo $header
sortedColNums=( $( printf "%s\n" "${avg_array[@]}" | sort -n ) )
echo '| Фамилия    | Среднее   | Доработать   | Сегодня    | Дней  |'
echo $header
for index in ${!sortedColNums[*]}
do
	KEY=${sortedColNums[$index]}
	VALUE="${hashMap[$KEY]}"
	valueArray=($VALUE)
	surname=${valueArray[0]}
	avg=${valueArray[1]}	
	need_work=${valueArray[2]}
	today=${valueArray[3]}
	total_days=${valueArray[4]}
#	printf '%12.2f %12.2f %12.2f %18.16s \n' "$avg" "$need_work" "$today" "$surname"
	printf '| %s\033[12G %12.2f %12.2f %11.2f %8.0f   |\n' "$surname" "$avg" "$need_work" "$today" "$total_days"

done





echo $header

