# file structure should be output/nameSuffix/sessionTime/type of command/
measure(){
path="/home/nickdu/output/$3-$2/$1"
mkdir -p "$path/iperf"
mkdir -p "$path/ss"
mkdir -p "$path/iw"
iperf3 -c eecslab-11.cwru.edu -p 80 -t $1 -J --logfile "$path/iperf/$(date +"%m-%d-%T").json"&
end=$((SECONDS+$1+1))
while [ $SECONDS -lt $end ]; do
ss -int dst 192.168.230.230|sed -n '3 p'> "$path/ss/$(date +"%m-%d-%T").raw"
sudo iwconfig 2>/dev/null|grep "Noise level">"$path/iw/$(date +"%m-%d-%T").raw"
sleep 5
done
}

init(){
for cca in ${list[@]}; do
sudo sed -i 's/^net\.ipv4\.tcp_congestion_control.*$/net.ipv4.tcp_congestion_control = '$cca'/' /etc/sysctl.conf
sudo sysctl -p
measure 1 $cca $nameSuffix
measure 3 $cca $nameSuffix
measure 5 $cca $nameSuffix
measure 180 $cca $nameSuffix
python3 /home/nickdu/output/scripts/postProcessing.py "/home/nickdu/output/$nameSuffix-$cca"& 
done
}
#init
list=( "bbr" "cubic" )
list=$(shuf -e "${list[@]}")
nameSuffix=$(date +"%m-%d-%T")
init
