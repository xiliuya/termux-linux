#!/data/data/com.termux/files/usr/bin/bash
arch="";
#linux="archlinux";
#linux_ver="";
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
		linux_ver="aid";
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
if ! [ -f ${linux}.tar.xz ]; then
	if ! [ -f images.json     ]; then
		wget -c "https://mirrors.tuna.tsinghua.edu.cn/lxc-images/streams/v1/images.json"
	fi
#解析json
	rootfs_url=`cat images.json  |	awk -F '[,"}]' '{for(i=1;i<=NF;i++){ print $i}}' | grep "images/${linux}/" | grep "${linux_ver}" | grep "/${arch}/default/" | grep "rootfs.tar.xz" | awk 'END {print}' `
	echo  "https://mirrors.tuna.tsinghua.edu.cn/lxc-images/${rootfs_url}"
	if [ $rootfs_url ]; then
		echo "正在下载"
		wget -c -O ${linux}.tar.xz  "https://mirrors.tuna.tsinghua.edu.cn/lxc-images/${rootfs_url}"
		#删除json
		rm images.json
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
cd "$cur"

if [ $linux == "alpine" ]; then 
	bash_tmp="sh";
else
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
command+=" /bin/${bash_tmp} --login"
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
rm $linux.tar.xz
echo "现在可以执行 ./${bin} 运行 ${linux} ${linux_ver} 了"
