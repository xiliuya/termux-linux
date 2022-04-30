#!/data/data/com.termux/files/usr/bin/bash
#set -x
arch="";
#linux="archlinux";
#linux_ver="";
qemu_command="";
if [ ! -d ~/storage  ]; then
	termux-setup-storage
fi
if [ -x "$(command -v apt)" ]; then
	if [ ! -x "$(command -v proot)" ] || [ ! -x "$(command -v wget)" ] || [ ! -x "$(command -v tar)" ]; then
		apt update && apt upgrade -y &&
		apt install -y tar proot wget 
		fi
fi
case `dpkg --print-architecture` in
aarch64)
	arch="arm64" ;;
arm)
	arch="armhf" ;;
amd64)
	arch="amd64" ;;
x86_64)
	arch="amd64" ;;	
*)
	echo "系统架构不支持"; exit 1 ;;
esac


echo "********************************"
echo "   请选择安装的系统架构   "
echo "   aarch64 请输入：1"
echo "   armhf 请输入：2"
echo "   x86   请输入：3"
echo "   amd64 请输入：4"
echo "   其它 输入平台名称 （如："
echo "   默认使用本机架构)"
echo "********************************"
read -p "请输入:" charch
case $charch in
"1")
	newarch="arm64"
	echo $newarch
	qemu_user="qemu-aarch64"
	;;

"2")
	newarch="armhf"
	echo $newarch
	qemu_user="qemu-arm"
	;;
"3")
	newarch="i386"
	echo $newarch
	qemu_user="qemu-i386"
	;;
"4")
	newarch="amd64"
	echo $newarch
	qemu_user="qemu-x86_64"
	;;
"")
	newarch=$arch
	echo $newarch
	;;
*)
	newarch=$charch
	echo $newarch
	qemu_user="qemu-$newarch"
	esac;
echo "********************************"
echo "   请选择安装的Linux 发行版  "
echo "   debian 请输入：1"
echo "   ubuntu 请输入：2"
echo "   kali   请输入：3"
echo "   fedora 请输入：4"
echo "   其它 输入发行版名称 （如："
echo "   archlinux、alpine、centos...)"
echo "********************************"
read -p "请输入:" name 
case $name in
"1")
	linux="debian";
	echo "请选择$linux版本:"
	echo "bullseye  输入：1"
	echo "buster    输入：2"
	echo "sid       输入：3"
	echo "其它版本请输入对应名称"
	read -p "请输入:" banben
	case $banben in
	"1")
		linux_ver="bullseye";
		echo $linux_ver
	;;
	"2")
		linux_ver="buster";
		echo $linux_ver
	;;
	"3")
		linux_ver="sid";
		echo $linux_ver
	;;
	*)
		linux_ver=$banben
		echo $linux_ver
	esac;
;;
"2")
	linux="ubuntu";
	echo $linux
	echo "请选择$linux版本:"
	echo "bionic    输入：1"
	echo "focal     输入：2"
	echo "xenial    输入：3"
	echo "其它版本请输入对应名称"
	read -p "请输入:" banben
	case $banben in
	"1")
		linux_ver="bionic";
		echo $linux_ver
	;;
	"2")
		linux_ver="focal";
		echo $linux_ver
		;;	
	"3")
		linux_ver="xenial";
		echo $linux_ver
	;;
	*)
		linux_ver=$banben
		echo $linux_ver
	esac;
;;
"3")
	linux="kali";
	echo $linux
	linux_ver="current";
;;
"4")
	linux="fedora";
	echo $linux
	echo "请选择$linux版本:"
	echo "30        输入：1"
	echo "31        输入：2"
	echo "32        输入：3"
	echo "其它版本请输入对应名称"
	read -p "请输入:" banben
	case $banben in
	"1")
		linux_ver="30";
		echo $linux_ver
	;;
	"2")
		linux_ver="31";
		echo $linux_ver
	;;
	"3")
		linux_ver="32";
		echo $linux_ver
	;;
	*)
		linux_ver=$banben
		echo $linux_ver
		esac;
;;
*)
	linux=$name;
	echo $linux
	read -p "请输入系统版本:" banben
	linux_ver=$banben
esac

if [ $newarch != $arch ];then
	echo $newarch"已使用qemu-user 正在配置"
	arch="$newarch"
	qemu_command=" -q $qemu_user  -b /vendor -b /system -b /apex -b /data/dalvik-cache  -b $PREFIX "
    qemu_command+=" -L --sysvipc"
    qemu_command+=" --kill-on-exit"
    qemu_command+=" --kernel-release=5.4.0-fake-kernel"
    qemu_command+=" -b $linux/sys/fs/selinux/:/sys/fs/selinux"
    qemu_command+=" -b $linux/tmp/:/dev/shm/"
    qemu_command+=" -b /dev/urandom:/dev/random"
    qemu_command+=" -b $linux/proc/.stat:/proc/stat"
    qemu_command+=" -b $linux/proc/.loadavg:/proc/loadavg"
    qemu_command+=" -b $linux/proc/.uptime:/proc/uptime"
    qemu_command+=" -b $linux/proc/.version:/proc/version"
    qemu_command+=" -b $linux/proc/.vmstat:/proc/vmstat"
	if [ ! -x "$(command -v $qemu_user)" ]; then
		apt update && apt upgrade -y &&
		apt install -y qemu-user-* 
		fi
	if [ ! -x "$(command -v $qemu_user)" ]; then
		echo "找不到适配的$qemu_user"
		exit 1;
	fi
	echo $newarch"qemu-user 配置完成"
fi



if ! [ -f ${linux}.tar.xz ]; then
	if ! [ -f images.json     ]; then
		wget -c "https://mirrors.tuna.tsinghua.edu.cn/lxc-images/streams/v1/images.json"
	fi
#解析json
	rootfs_url=`cat images.json  |	awk -F '[,"}]' '{for(i=1;i<=NF;i++){ print $i}}' | grep "images/${linux}/" | grep "${linux_ver}" | grep "/${arch}/default/" | grep "rootfs.tar.xz" | awk 'END {print}' `
	echo  "https://mirrors.tuna.tsinghua.edu.cn/lxc-images/${rootfs_url}"
	if [ $rootfs_url ]; then
		echo "正在下载"
		wget -T 5 -t 0 -c -O ${linux}.tar.xz  "https://mirrors.tuna.tsinghua.edu.cn/lxc-images/${rootfs_url}"
	else 
		echo "${linux} ${linux_ver} 版本无法找到，请重新确认输入"
		exit 1
	fi
fi
if [ -d $linux  ]; then
	echo "安装中断，由于${linux}文件夹已存在，请清理后安装"
	exit 1
fi

echo "下载完成"

echo "开始安装";
cur=`pwd`
mkdir -p "$linux"
cd "$linux"
echo "正在解压rootfs，请稍候"
proot --link2symlink tar -xJf ${cur}/${linux}.tar.xz --exclude='dev' --exclude='etc/rc.d' --exclude='usr/lib64/pm-utils'
echo "更新DNS"
echo "127.0.0.1 localhost" > etc/hosts
rm -rf etc/resolv.conf &&
echo "nameserver 114.114.114.114" > etc/resolv.conf
echo "nameserver 8.8.4.4" >> etc/resolv.conf
echo "export  TZ='Asia/Shanghai'" >> root/.bashrc

if [ -n "$qemu_command" ]; then

	echo "建立proc文件"
	chmod 700 proc
	echo "cpu  1050008 127632 898432 43828767 37203 63 99244 0 0 0
cpu0 212383 20476 204704 8389202 7253 42 12597 0 0 0
cpu1 224452 24947 215570 8372502 8135 4 42768 0 0 0
cpu2 222993 17440 200925 8424262 8069 9 17732 0 0 0
cpu3 186835 8775 195974 8486330 5746 3 8360 0 0 0
cpu4 107075 32886 48854 8688521 3995 4 5758 0 0 0
cpu5 90733 20914 27798 1429573 2984 1 11419 0 0 0
intr 53261351 0 686 1 0 0 1 12 31 1 20 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7818 0 0 0 0 0 0 0 0 255 33 1912 33 0 0 0 0 0 0 3449534 2315885 2150546 2399277 696281 339300 22642 19371 0 0 0 0 0 0 0 0 0 0 0 2199 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2445 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 162240 14293 2858 0 151709 151592 0 0 0 284534 0 0 0 0 0 0 0 0 0 0 0 0 0 0 185353 0 0 938962 0 0 0 0 736100 0 0 1 1209 27960 0 0 0 0 0 0 0 0 303 115968 452839 2 0 0 0 0 0 0 0 0 0 0 0 0 0 160361 8835 86413 1292 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3592 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 6091 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 35667 0 0 156823 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 138 2667417 0 41 4008 952 16633 533480 0 0 0 0 0 0 262506 0 0 0 0 0 0 126 0 0 1558488 0 4 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2 2 8 0 0 6 0 0 0 10 3 4 0 0 0 0 0 3 0 0 0 0 0 0 0 0 0 0 0 20 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 12 1 1 83806 0 1 1 0 1 0 1 1 319686 2 8 0 0 0 0 0 0 0 0 0 244534 0 1 10 9 0 10 112 107 40 221 0 0 0 144
ctxt 90182396
btime 1595203295
processes 270853
procs_running 2
procs_blocked 0
softirq 25293348 2883 7658936 40779 539155 497187 2864 1908702 7229194 279723 7133925" >proc/.stat
	echo "0.54 0.41 0.30 1/931 370386">proc/.loadavg
	echo "284684.56 513853.46">proc/.uptime
	echo "Linux version 5.4.0-faked (termu) (gcc version 6.9.x (Faked /proc/version ) ) #1 SMP PREEMPT Sun May 11 11:11:11 UTC 2022">proc/.version
	echo "nr_free_pages 146031
nr_zone_inactive_anon 196744
nr_zone_active_anon 301503
nr_zone_inactive_file 2457066
nr_zone_active_file 729742
nr_zone_unevictable 164
nr_zone_write_pending 8
nr_mlock 34
nr_page_table_pages 6925
nr_kernel_stack 13216
nr_bounce 0
nr_zspages 0
nr_free_cma 0
numa_hit 672391199
numa_miss 0
numa_foreign 0
numa_interleave 62816
numa_local 672391199
numa_other 0
nr_inactive_anon 196744
nr_active_anon 301503
nr_inactive_file 2457066
nr_active_file 729742
nr_unevictable 164
nr_slab_reclaimable 132891
nr_slab_unreclaimable 38582
nr_isolated_anon 0
nr_isolated_file 0
workingset_nodes 25623
workingset_refault 46689297
workingset_activate 4043141
workingset_restore 413848
workingset_nodereclaim 35082
nr_anon_pages 599893
nr_mapped 136339
nr_file_pages 3086333
nr_dirty 8
nr_writeback 0
nr_writeback_temp 0
nr_shmem 13743
nr_shmem_hugepages 0
nr_shmem_pmdmapped 0
nr_file_hugepages 0
nr_file_pmdmapped 0
nr_anon_transparent_hugepages 57
nr_unstable 0
nr_vmscan_write 57250
nr_vmscan_immediate_reclaim 2673
nr_dirtied 79585373
nr_written 72662315
nr_kernel_misc_reclaimable 0
nr_dirty_threshold 657954
nr_dirty_background_threshold 328575
pgpgin 372097889
pgpgout 296950969
pswpin 14675
pswpout 59294
pgalloc_dma 4
pgalloc_dma32 101793210
pgalloc_normal 614157703
pgalloc_movable 0
allocstall_dma 0
allocstall_dma32 0
allocstall_normal 184
allocstall_movable 239
pgskip_dma 0
pgskip_dma32 0
pgskip_normal 0
pgskip_movable 0
pgfree 716918803
pgactivate 68768195
pgdeactivate 7278211
pglazyfree 1398441
pgfault 491284262
pgmajfault 86567
pglazyfreed 1000581
pgrefill 7551461
pgsteal_kswapd 130545619
pgsteal_direct 205772
pgscan_kswapd 131219641
pgscan_direct 207173
pgscan_direct_throttle 0
zone_reclaim_failed 0
pginodesteal 8055
slabs_scanned 9977903
kswapd_inodesteal 13337022
kswapd_low_wmark_hit_quickly 33796
kswapd_high_wmark_hit_quickly 3948
pageoutrun 43580
pgrotated 200299
drop_pagecache 0
drop_slab 0
oom_kill 0
numa_pte_updates 0
numa_huge_pte_updates 0
numa_hint_faults 0
numa_hint_faults_local 0
numa_pages_migrated 0
pgmigrate_success 768502
pgmigrate_fail 1670
compact_migrate_scanned 1288646
compact_free_scanned 44388226
compact_isolated 1575815
compact_stall 863
compact_fail 392
compact_success 471
compact_daemon_wake 975
compact_daemon_migrate_scanned 613634
compact_daemon_free_scanned 26884944
htlb_buddy_alloc_success 0
htlb_buddy_alloc_fail 0
unevictable_pgs_culled 258910
unevictable_pgs_scanned 3690
unevictable_pgs_rescued 200643
unevictable_pgs_mlocked 199204
unevictable_pgs_munlocked 199164
unevictable_pgs_cleared 6
unevictable_pgs_stranded 6
thp_fault_alloc 10655
thp_fault_fallback 130
thp_collapse_alloc 655
thp_collapse_alloc_failed 50
thp_file_alloc 0
thp_file_mapped 0
thp_split_page 612
thp_split_page_failed 0
thp_deferred_split_page 11238
thp_split_pmd 632
thp_split_pud 0
thp_zero_page_alloc 2
thp_zero_page_alloc_failed 0
thp_swpout 4
thp_swpout_fallback 0
balloon_inflate 0
balloon_deflate 0
balloon_migrate 0
swap_ra 9661
swap_ra_hit 7872">proc/.vmstat

	mkdir -p sys/fs/selinux
fi


cd "$cur"


if [ $linux == "alpine" ]; then 
	echo "is sh"
	bash_tmp="sh";
else
	echo "is bash"
	bash_tmp="bash";
fi

if [ $linux == "ubuntu" ]; then
	touch "${linux}/root/.hushlogin"
fi
bin=start-${linux}.sh
echo "写入启动脚本"
cat > $bin <<- EOM
#!/bin/bash
cd \$(dirname \$0)
## unset LD_PRELOAD in case termux-exec is installed
unset LD_PRELOAD
command="proot"
command+=" --link2symlink"
command+=" -0"
command+=" -r $linux"

command+=" $qemu_command "
command+=" -b /dev"
command+=" -b /proc"
command+=" -b $linux/root:/dev/shm"
## uncomment the following line to have access to the home directory of termux
#command+=" -b /data/data/com.termux/files/home:/root"
## uncomment the following line to mount /sdcard directly to / 
#command+=" -b /sdcard"
command+=" -w /root"
command+=" /usr/bin/env -i"
command+=" HOME=/root"
command+=" PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games"
command+=" TERM=\$TERM"
command+=" LANG=C.UTF-8"
command+=" /bin/$bash_tmp --login"
com="\$@"
if [ -z "\$1" ];then
    exec \$command
else
    \$command -c "\$com"
fi
EOM

echo "fixing shebang of $bin"
termux-fix-shebang $bin
echo "授予 $bin 执行权限"
chmod +x $bin
echo "正在删除镜像文件"
#rm $linux.tar.xz
#删除json
#rm images.json
echo "现在可以执行 ./${bin} 运行 ${linux} ${linux_ver} 了"
