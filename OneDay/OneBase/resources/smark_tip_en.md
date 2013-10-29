Smark Introduce
---

###What is Smark?
>Smark is a kind oi input format, text which based on Smark could
be recognize automaticly, time, location and so on, on purpose to
input efficently.

>Smark focus on more eﬁiently inputing and easy life.

>pure text to input todos, records, easy to use, quickly input,
intelligent recognise, new experience of life management!

###What's offered by Smark?
1. Create a new todo by press "Enter";
2. Line number automatically;
3. Intelligent iind time, duration and so on in the text;
4. Automatic make a timeline for today records;
5. Base on your text to calculate degree of completion for your
informations;
6. Wildcard: [Space]
	* [space] + number + unit, will be recognized, eg. [space] + 5
+ dollars, will be recognized to the money infonnation.
7. keyword + number + unit, can be reconized too.

###How to input a recognized format?
>lf following document is not interest for you, just ignore it for free. We are
making efforts to let "Smark" smarter, so that you can understand
everything that you want he do from your input! If you are interested in the
"Smark“, keep going. l'm it will help to more effective for your input.

####To all kinds ot text, Smark supports to recognized "tlme' and "duration
####To all kinds of text, Smark supports to recognized "time" and "duration"

1. Daily Schedule
	* [space] + time, to Input time
	
			eg. Input “Have lunch at 11:59 am“, will
			automatically adjust the record's start time
			to 11:50 am
		* Almost all kinds of time format can be recognized
	
	* bracket + duration + bracket clse, to input duration
	
			eg: Input "Have a nap 12:50 pm (1h30m)“, will
			automatically adjust the record's start time
			to 12:50 pm, end time to one and half hours
			later, which should be 2:20 pm
		* Units support for duration (also support Chinese):
		
			@"小时" , @"时" , @"分钟", @"分", @"hours",
			@"hour" , @"h" , @"minutes"
			@"minute", @"m";



2. Daily Cash
	* Daily cash also support automaticly recognize "money" , beside "time" and "duration"
	* { ' + ', '- ', [space], spend, spent gain, cost, make, eam,
pay, lose, lost } + number + money unit, to input lose or gain
money;
		* Input Samples:
		
				Spent 5 dollars to buy shoes
				Subway -400d
				Listen to the concert spending 200 dollar
	* Units support for money units (also support Chinese):
	
			@"元" , @"块", @"yuan", @"RMB", @"$", @"d",
			@"dollar", @"dollars"


3. Daily Calorie
	* Daily calorie also support automaticly recognize "heat" , beside "time" and "duration"
	* {'+ ', '- ', [space], lose, lost, gain, fat, have, eat, absorb}+
number + calorie unit, to input lose or gain calories;
		- Input Samples:
		
				Do yoga -1000ca1ories
				Eat an apple this morning, gain 30 kilocalorie
				Eat 300 kiloculories ice cream before go to bed
				A listen to coke heat is 594 kilojoules
	* Units support for calorie (also support Chinese):
	
			@"kilocalorie", @"calorie", @"cal", @"KJ", @"J", 
			@"kilojoule", @"joule", @"大卡", @"千卡", 
			@"卡路里", @"卡", @"焦耳", @"千焦", @"焦"


3. Daily Workout
	* Beside "time" and "duration", daily workout also support:
	* {[space], run, walk, do} + number + distance unit, to input
distance
		- Input Samples:
		
				Have run 200m
		- Units suppon for distance (also support Chinese):
		
				@"kilometer", @"kilometre", @"meter", @"metre", 
				@"km", @"m", @"千米", @"米", @"公里
	* {[space], do }+ number + times, to input times
		- Input Samples:
		
				sit—up 50times
		- Units support for times:
		
				@"times", @"time", @"次数", @"次", @"回"
4. Daily Period
	* Daily Period also support automaticly recognize "current day" , beside "time" and "duration"
	* { period } + ":" + number + day, to input current day
		- Input Samples:
		
				period:4day
	* { pray, thanks }, to input your wishes.