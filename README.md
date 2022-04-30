# termux-linux
termux run lxc-images (alpine、archlinux、ubuntu、kali、centos、debian、fedora....)

这是一个termux环境下，安装使用 lxc-images 的各发行版(alpine、archlinux、ubuntu、kali、centos、debian、fedora....)

使用的lxc-images镜像为 [清华源镜像](https://mirrors.tuna.tsinghua.edu.cn/lxc-images/images/) 

使用原理为 proot 启动

使用过程：

1、下载 [install_linux.sh](https://github.com/xiliuya/termux-linux/releases/download/untagged-d42e22a770f3c95aac45/install_linux.sh) 在termux任意目录下执行bash install_linux.sh

2、按照终端提示，依次输入linux发行版名称序号与发行版本名序号。(可直接输入清华源下存在的linux发行版英文名，以及对应目录下的版本英文名。如：alpine edge)

3、等待下载完成，按照提示，执行对应启动脚本。

本脚本参照anlinux，并在其基础上适配了lxc-images下各容器。
