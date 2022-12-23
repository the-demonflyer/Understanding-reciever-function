#! /bin/bash


isempty()
{
	if [ -z $2 ]
	then
		echo ""
	else
		echo "&$1=$2"
	fi
}
extract_sac()
{
#$seedfile $metadatafile $stla $stlo $stel $evla $evlo $evdp $event_time $origintime $model $sac_folder 
	echo $1 $2 $3 $4 $5 $6 $7 $8 $9 ${10} ${11} ${12}
	eventtime=`echo $9 | awk -F"T" '{print "date -d "$1" +%j"}' | sh | awk -v e=$9 '{print substr(e,1,4)","$1","substr(e,12)}'`
	mseed2sac $1 "-m" $2 "-k" $3"/"$4 "-E" $eventtime"/"$6"/"$7"/"$8 -O   #Specify event parameters as 'Time[/Lat][/Lon][/Depth][/Name]' #-M metaline:Channel metadata, same format as lines in metafile
	
	for file in *.SAC
	do
		o=`echo ${10}`
		nf=`echo $file | awk -F"." -v o=$o '{print $1"."$2"."$3"."$4"."$5"."o".SAC"}'`
		mv $file $nf 
	done
	taup setsac -mod ${11} -evdpkm -ph P-0 *.SAC	
	mv *.SAC ${12}
}

echo "-------------------------Initiating Station Information Download---------------------------"
station_output="station_catalogue.txt"
if [ ! -f $station_output ]
then
	read -p "Do you wish to choose channel options?" yn
	case $yn in
			[Yy]* ) echo "Select one or more network codes. Can be SEED codes or data center defined codes. Accepts wildcards and lists. The question mark ? represents any single character (exactly one), while the asterisk * represents zero or more characters. Each parameter listed under “channel options” can be prefixed with a - (minus) sign to exclude certain metadata from a request."
					read -p " Enter Networks:" network
					echo "\n"
					
					echo "Select one or more SEED station codes. Accepts wildcards and lists. The question mark ? represents any single character (exactly one), while the asterisk * represents zero or more characters. Each parameter listed under “channel options” can be prefixed with a - (minus) sign to exclude certain metadata from a request."
					read -p "Enter Stations:" station
					echo "\n"
					
					echo "Select one or more SEED location identifier. Use -- for “Blank” location IDs (ID’s containing 2 spaces). Accepts wildcards and lists.The question mark ? represents any single character (exactly one), while the asterisk * represents zero or more characters. Each parameter listed under “channel options” can be prefixed with a - (minus) sign to exclude certain metadata from a request."
					read -p "Enter Location Ids:" locid
					echo "\n"
					
					echo "Select one or more SEED channel codes. Accepts wildcards and lists. The question mark ? represents any single character (exactly one), while the asterisk * represents zero or more characters. Each parameter listed under “channel options” can be prefixed with a - (minus) sign to exclude certain metadata from a request."
					read -p "Enter Channels:" channel
					echo "\n" ;;
	
			[Nn]* ) ;;
			* ) echo "Please answer yes or no.";;
	esac
	echo "\n\n"
	
	
	read -p "Do you wish to choose time constraints?" yn
	case $yn in
			[Yy]* ) echo "Limit to metadata describing channels operating on or after the specified start time(YYYY-MM-DDThh:mm:ss[.ssssss])."
					read -p "Enter Start Time:" start
					echo "\n"
					
					echo "Limit to metadata describing channels operating on or before the specified end time(YYYY-MM-DDThh:mm:ss[.ssssss])."
					read -p "Enter End Time:" end
					echo "\n"
					
					echo "Limit to metadata epochs starting before specified time. Applied to channel epochs(YYYY-MM-DDThh:mm:ss[.ssssss])."
					read -p "Enter Start before Time:" startbefore
					echo "\n"
				
					echo "Limit to metadata epochs starting after specified time. Applied to channel epochs(YYYY-MM-DDThh:mm:ss[.ssssss])."
					read -p "Enter Start after Time:" startafter
					echo "\n"
					
					echo "Limit to metadata epochs ending before specified time. Applied to channel epochs(YYYY-MM-DDThh:mm:ss[.ssssss])."
					read -p "Enter End before Time:" endbefore
					echo "\n"
				
					echo "Limit to metadata epochs ending after specified time. Applied to channel epochs(YYYY-MM-DDThh:mm:ss[.ssssss])."
					read -p "Enter End after Time:" endafter
					echo "\n" ;;
	
			[Nn]* ) ;;
			* ) echo "Please answer yes or no.";;
	esac
	echo "\n\n"
	
	
	read -p "Do you wish to choose geographic constraints?" yn
	case $yn in
			[Yy]* ) read -p "Do you wish to choose rectangular(r) or circular(c) geographic constraints?" rc
					if [ $rc = "r" ]
					then 
						read -p "Enter Minimum Latitude:" minlat
						read -p "Enter Maximum Latitude:" maxlat
						read -p "Enter Minimum Longitude:" minlon
						read -p "Enter Maximum Longitude:" maxlon
					elif [ $rc = "c" ]
					then
						read -p "Enter Central Latitude:" centlat
						read -p "Enter Central Longitude:" centlon
						read -p "Enter Minimum Radius:" minrad
						read -p "Enter Maximum Radius:" maxrad
					else
						echo "Please answer r or c."
					fi;;
	
			[Nn]* ) ;;
			* ) echo "Please answer yes or no.";;
	esac
	echo "\n\n"
	
	 
	
	echo "Level specifies the level of detail returned within the returned XML. ‘network’ is the highest level, followed by ‘station’. To see channels within stations, level=‘channel’ is used. The most detailed level is ‘response’, which provides details to permit signal processing and proper conversion of digital readings to physical measurement. Modify in the script accordingly.\n"
	level="station" #input- 'network','station', 'channel','response'. default='station'
	
	echo "Specify output format. Valid formats include xml, text, and geocsv.  Modify in the script accordingly.\n"
	format="text" #input- 'xml', 'text' , 'geocsv'. default 'xml'
	
	echo "By default, the service returns a HTTP response code 204, which means the request was successful, but no data (no content) was retrieved. However, because there was no “error”, no error message is generated and it may appear that the browser did nothing. To force an empty query response to display an error message, add nodata=404 to the URL.  Modify in the script accordingly.\n"
	nodata=404 #input - 404 ,204 . defalut 204
	
	sensor=""
	includerestricted="" #default TRUE
	includeavailability="TRUE" #default FALSE
	includecomments="" #default TRUE
	matchtimeseries="" #default FALSE
	
	
	networkentry=`isempty "network" $network`
	stationentry=`isempty "station" $station`
	locidentry=`isempty "location" $locid`
	channelentry=`isempty "channel" $channel`
	
	startentry=`isempty "start" $start`
	endentry=`isempty "end" $end`
	startbeforeentry=`isempty "startbefore" $startbefore`
	startafterentry=`isempty "startafter" $startafter`
	endbeforeentry=`isempty "endbefore" $endbefore`
	endafterentry=`isempty "endafter" $endafter`
	
	minlatentry=`isempty "minlat" $minlat`
	maxlatentry=`isempty "maxlat" $maxlat`
	minlonentry=`isempty "minlon" $minlon`
	maxlonentry=`isempty "maxlon" $maxlon`
	
	centlatentry=`isempty "lat" $centlat`
	centlonentry=`isempty "lon" $centlon`
	minradentry=`isempty "minradius" $minrad`
	maxradentry=`isempty "maxradius" $maxrad`
	
	levelentry=`isempty "level" $level`
	formatentry=`isempty "format" $format`
	nodataentry=`isempty "nodata" $nodata`
	sensorentry=`isempty "sensor" $sensor`
	includerestrictedentry=`isempty "includerestricted" $includerestricted`
	includeavailabilityentry=`isempty "includeavailability" $includeavailability`
	includecommentsentry=`isempty "includecomments" $includecomments`
	includecommentsentry=`isempty "matchtimeseries" $matchtimeseries`
	
	
	
	
	echo "Your inputs are " $networkentry $stationentry $locidentry $channelentry $startentry $endentry $startbeforeentry $startafterentry $endbeforeentry $endafterentry $minlatentry $maxlatentry $minlonentry $maxlonentry $centlatentry $centlonentry $minradentry $maxradentry $levelentry $formatentry $nodataentry $sensorentry $includerestrictedentry $includecommentsentry $includecommentsentry"\n"
	
	link="http://service.iris.edu/fdsnws/station/1/query?"
	query=`echo $networkentry$stationentry$locidentry$channelentry$startentry$endentry$startbeforeentry$startafterentry$endbeforeentry$endafterentry$minlatentry$maxlatentry$minlonentry$maxlonentry$centlatentry$centlonentry$minradentry$maxradentry$levelentry$formatentry$nodataentry$sensorentry$includerestrictedentry $includecommentsentry $includecommentsentry | cut -c 2-`
	
	fulllink=`echo $link$query`
	
	curl  $fulllink -o $station_output
	echo "------------------------------ Station Information Download Finished--------------------------------------------"
	echo "---------------------------- Saved in $station_output-----------------------------------------------------------"
else
	echo "$station_output already exists."
fi
unset network station locid channel start end startbefore startafter endbefore endafter minlat maxlat minlon maxlon centlat centlon minrad maxrad
unset level format nodata sensor includerestricted includeavailability includecomments matchtimeseries
unset networkentry stationentry locidentry channelentry startentry endentry startbeforeentry startafterentry endbeforeentry endafterentry minlatentry maxlatentry minlonentry maxlonentry centlatentry centlonentry minradentry maxradentry
unset levelentry formatentry nodataentry sensorentry includerestrictedentry includeavailabilityentry includecommentsentry matchtimeseriesentry
echo "\n\n\n\n"











echo "-------------------------Initiating Event Information Download---------------------------"
event_output="event_catalogue.txt"
if [ ! -f $event_output ]
then
	read -p "Enter Start Time(YYYY-MM-DDThh:mm:ss[.ssssss]):" start
	read -p "Enter End Time(YYYY-MM-DDThh:mm:ss[.ssssss]):" end
	echo "\n\n"
	
	
	read -p "Do you wish to choose geographic constraints?" yn
	case $yn in
			[Yy]* ) read -p "Do you wish to choose rectangular(r) or circular(c) geographic constraints?" rc
					if [ $rc = "r" ]
					then 
						read -p "Enter Minimum Latitude:" minlat
						read -p "Enter Maximum Latitude:" maxlat
						read -p "Enter Minimum Longitude:" minlon
						read -p "Enter Maximum Longitude:" maxlon
					elif [ $rc = "c" ]
					then
						read -p "Enter Central Latitude:" centlat
						read -p "Enter Central Longitude:" centlon
						read -p "Enter Minimum Radius:" minrad
						read -p "Enter Maximum Radius:" maxrad
					else
						echo "Please answer r or c."
					fi;;
	
			[Nn]* ) ;;
			* ) echo "Please answer yes or no.";;
	esac
	echo "\n\n"
	
	
	
	read -p "Do you wish to choose depth constraints?" yn
	case $yn in
			[Yy]* ) read -p "Enter Minimum Depth(in KM):" mindepth
				read -p "Enter Maximum Depth(in KM):" maxdepth
				echo "\n" ;;
			[Nn]* ) ;;
			* ) echo "Please answer yes or no.";;
	esac
	echo "\n\n"
	
	
	read -p "Do you wish to choose magnitude constraints?" yn
	case $yn in
			[Yy]* ) read -p "Enter Minimum Magnitude:" minmag
				read -p "Enter Maximum Magnitude:" maxmag
				read -p "Enter Magnitude Type(ML,Ms,mb,Mw,all,preferred):" magtype
				echo "\n" ;;
			[Nn]* ) ;;
			* ) echo "Please answer yes or no.";;
	esac
	echo "\n\n"
	
	
	echo "Specify output format. Valid formats include xml, text, and geocsv.  Modify in the script accordingly.\n"
	format="text"  #input- 'xml', 'text' , 'geocsv'. default 'xml'
	
	echo "By default, the service returns a HTTP response code 204, which means the request was successful, but no data (no content) was retrieved. However, because there was no “error”, no error message is generated and it may appear that the browser did nothing. To force an empty query response to display an error message, add nodata=404 to the URL.  Modify in the script accordingly.\n"
	nodata=404 #input - 404 ,204 . defalut 204
	
	catalog="" #other input - NEIC%20PDE, ISC
	limit="" #set limit to the specific number of event. default - unlimited
	eventid="" #Retrieve an event based on the unique ID numbers assigned by the IRIS DMC4
	includeallmagnitudes="" #Retrieve all magnitudes for the event, or only the primary magnitude. default - FALSE
	
	
	startentry=`isempty "start" $start`
	endentry=`isempty "end" $end`

	minlatentry=`isempty "minlat" $minlat`
	maxlatentry=`isempty "maxlat" $maxlat`
	minlonentry=`isempty "minlon" $minlon`
	maxlonentry=`isempty "maxlon" $maxlon`
	
	centlatentry=`isempty "lat" $centlat`
	centlonentry=`isempty "lon" $centlon`
	minradentry=`isempty "minradius" $minrad`
	maxradentry=`isempty "maxradius" $maxrad`
	
	mindepthentry=`isempty "mindepth" $mindepth`
	maxdepthentry=`isempty "maxdepth" $maxdepth`
	
	minmagentry=`isempty "minmag" $minmag`
	maxmagentry=`isempty "maxmag" $maxmag`
	magtypeentry=`isempty "magtype" $magtype`
	
	
	formatentry=`isempty "format" $format`
	nodataentry=`isempty "nodata" $nodata`
	catalogentry=`isempty "catalog" $catalog`
	limitentry=`isempty "limit" $limit`
	eventidentry=`isempty "eventid" $eventid`
	includeallmagnitudes=`isempty "includeallmagnitudes" $includeallmagnitudes`
	
	echo "Your inputs are "  $startentry $endentry $minlatentry $maxlatentry $minlonentry $maxlonentry $centlatentry $centlonentry $minradentry $maxradentry $mindepthentry $maxdepthentry $minmagentry $maxmagentry $magtypeentry $formatentry $nodataentry $catalogentry $limitentry $eventidentry $includeallmagnitudes"\n"
	
	link="http://service.iris.edu/fdsnws/event/1/query?"
	query=`echo $startentry$endentry$minlatentry$maxlatentry$minlonentry$maxlonentry$centlatentry$centlonentry$minradentry$maxradentry$mindepthentry$maxdepthentry$minmagentry$maxmagentry$magtypeentry$formatentry$nodataentry$catalogentry$limitentry$eventidentry$includeallmagnitudes | cut -c 2-`
	fulllink=`echo $link$query`
	
	curl  $fulllink -o $event_output
	echo "------------------------------ Event Information Download Finished--------------------------------------------"
	echo "---------------------------- Saved in $event_output-----------------------------------------------------------"
	
else
	echo "$event_output already exists."
fi
unset start end minlat maxlat minlon maxlon centlat centlon minrad maxrad mindepth maxdepth minmag maxmag magtype
unset format nodata catalog limit eventid includeallmagnitudes
unset startentry endentry minlatentry maxlatentry minlonentry maxlonentry centlatentry centlonentry minradentry maxradentry mindepthentry maxdepthentry minmagentry maxmagentry magtypeentry
unset formatentry nodataentry catalogentry limitentry eventidentry includeallmagnitudesentry
echo "\n\n\n\n"





echo "------------------------------Downloading Waveform ---------------------------------------------------"

seed_folder="./SEED"
sac_folder="./SAC"
pz_folder="./PZ"
channels="BHZ,BHN,BHE,HHZ,HHN,HHE,EHZ,EHN,EHE,SHZ,SHN,SHE"
p_before=60
p_after=300

if [ ! -d $seed_folder ]
then
	mkdir $seed_folder
fi
if [ ! -d $sac_folder ]
then
	mkdir $sac_folder
fi
if [ ! -d $pz_folder ]
then
	mkdir $pz_folder
fi


no_station=`cat $station_output | wc -l | awk '{print $1-1}'`
no_event=`cat $event_output | wc -l | awk '{print $1-1}'`


for noE in `seq 1870 1 $no_event`
do
	event_time=`cat $event_output | tail -n +2 | awk -F"|" -v n=$noE 'NR==n{print $2}'`
	origintime=`echo $event_time | awk -F"T" '{print "date -d "$1" +%j"}' | sh | awk -v e=$event_time '{print substr(e,1,4)"."$1"."substr(e,12)}' | awk -F"[.:]" '{print $1"."$2"."$3$4$5}'`
	evla=`cat $event_output | tail -n +2 | awk -F"|" -v n=$noE 'NR==n{print $3}'`
	evlo=`cat $event_output | tail -n +2 | awk -F"|" -v n=$noE 'NR==n{print $4}'`
	evdp=`cat $event_output | tail -n +2 | awk -F"|" -v n=$noE 'NR==n{print $5}'`
	
	for noS in `seq 1 1 $no_station`
	do
		network=`cat $station_output | tail -n +2 | awk -F"|" -v n=$noS 'NR==n{print $1}'`
		station=`cat $station_output | tail -n +2 | awk -F"|" -v n=$noS 'NR==n{print $2}'`
		stla=`cat $station_output | tail -n +2 | awk -F"|" -v n=$noS 'NR==n{print $3}'`
		stlo=`cat $station_output | tail -n +2 | awk -F"|" -v n=$noS 'NR==n{print $4}'`
		stel=`cat $station_output | tail -n +2 | awk -F"|" -v n=$noS 'NR==n{print $5}'`
		seedfile=`echo $network $station $origintime $seed_folder | awk '{print $4"/"$1"."$2"."$3".mseed"}'`
		metadatafile=`echo $network $station $origintime $seed_folder | awk '{print $4"/"$1"."$2"."$3".meta"}'`

		starttime=`cat $station_output | tail -n +2 | awk -F"|" -v n=$noS 'NR==n{print $7}'`
		endtime=`cat $station_output | tail -n +2 | awk -F"|" -v n=$noS 'NR==n{if($8!="") print $8}'`
			
		event_time_day=$(date --date "$event_time" +'%s')
		starttime_day=$(date --date "$starttime" +'%s')
		endtime_day=$(date --date "$endtime" +'%s')
			
		if [ $event_time_day -gt $starttime_day ] && [ $event_time_day -lt $endtime_day ]
		then
			model="iasp91"
			p_arrival=`taup time -mod $model -ph P -h $evdp -sta $stla $stlo -evt $evla $evlo --time | awk '{print $1}'`
			if [ -z  $p_arrival ]
			then 
				model="ak135"
				p_arrival=`taup time -mod $model -ph P -h $evdp -sta $stla $stlo -evt $evla $evlo --time | awk '{print $1}'`				
			fi	
			if [ ! -z  $p_arrival ]
			then
				btime=`echo $event_time | awk -F"[-T:]" -v p=$p_arrival -v pb=$p_before '{print "redodate",$1,$2,$3,$4,$5,$6,000,p-pb}' | sh | awk '{print $1"-"$2"-"$3","$4":"$5":"$6"."$7}'`
				etime=`echo $event_time | awk -F"[-T:]" -v p=$p_arrival -v pa=$p_after '{print "redodate",$1,$2,$3,$4,$5,$6,000,p+pa}' | sh | awk '{print $1"-"$2"-"$3","$4":"$5":"$6"."$7}'`
				no_pz=`ls $pz_folder/SACPZ.$network.$station.*$origintime* | wc -l | awk '{if($1==0) print "y"; else print "n"}'`
				echo "-------------event no:$noE---------------station no:$noS--------------------- "
				echo $seedfile
				if [ ! -f $seedfile ]
				then 
					FetchData -v -N $network -S $station -C $channels -s $btime -e $etime -o $seedfile -F "SED"
					echo $network $station $origintime $seed_folder | awk '{print "mv",$4"/""SED-"$1"."$2"."$3".mseed",$4"/"$1"."$2"."$3".mseed"}' | sh
					if [ -f $seedfile ]
					then
						FetchData -v -N $network -S $station -C $channels -s $btime -e $etime -sd . -rd . -m $metadatafile -F "SED"
						echo $network $station $origintime $seed_folder | awk '{print "mv",$4"/""SED-"$1"."$2"."$3".meta",$4"/"$1"."$2"."$3".meta"}' | sh
						for pz in SACPZ.$network.$station.*
						do
							pzfile=`echo $pz | awk -F"." -v o=$origintime -v f=$pz_folder '{print f"/"$1"."$2"."$3"."$4"."o"."$5}'`
							mv $pz $pzfile
						done
						echo $seedfile $metadatafile $stla $stlo $stel $evla $evlo $evdp $event_time $origintime $model $sac_folder
						extract_sac $seedfile $metadatafile $stla $stlo $stel $evla $evlo $evdp $event_time $origintime $model $sac_folder
					else
						echo "Data unavilable. Seedfile don't exist"
					fi	
				else
					if [ $no_pz = "y" ]
					then
						FetchData -v -N $network -S $station -C $channels -s $btime -e $etime -sd . -m $metadatafile -F "SED"
						for pz in SACPZ.$network.$station.*
						do
							pzfile=`echo $pz | awk -F"." -v o=$origintime -v f=$pz_folder '{print f"/"$1"."$2"."$3"."$4"."o"."$5}'`
							mv $pz $pzfile
						done
					else
						echo "SEED and PZ already exists." 
					fi
					extract_sac $seedfile $metadatafile $stla $stlo $stel $evla $evlo $evdp $event_time $origintime $model $sac_folder
				fi
			else
				echo "can't determine P-arrival"
				echo $noE $noS >> undetermined_p.txt
				
			fi
		fi
		
		#break
	done
	#break
done
echo "------------------------------Downloading Finished-----------------------------------------------"
echo "\n\n\n\n"




