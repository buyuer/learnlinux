# learnlinux

linux学习记录，一边学一边更新

可以使用仓库中的dockerfile构建学习环境的镜像，克隆本仓库，并在仓库目录运行

```shell
docker build -t learnlinux:latest .
```

构建的镜像中，可以使用 `-build-arg user=<用户名>`指定用户名，默认密码和用户名一样，默认用户名为learner。用户目录下创建了work目录，linux和busybox的源码已经克隆好了

相关链接

[知乎专栏：https://www.zhihu.com/column/c_1550211967562051584](https://www.zhihu.com/column/c_1550211967562051584)

## 目录

[1、搭建最小的linux系统](./mds/搭建最小的linux系统.md)

[2、在busybox中添加applet](./mds/在busybox中添加applet.md)

[3、添加linux系统调用](./mds/添加linux系统调用.md)

[4、使用clion阅读编辑linux源码](./mds/使用clion阅读编辑linux源码.md)

## 学习linux的网站

1、官方文档： [https://www.kernel.org/doc/](https://www.kernel.org/doc)

2、手册：[https://kernel.org/doc/man-pages/](https://kernel.org/doc/man-pages/)、[https://man7.org/](https://man7.org/)

3、POSIX程序员指南：[https://maxim.int.ru/bookshelf/OReilly__POSIX_Programmers_Guide.pdf](https://maxim.int.ru/bookshelf/OReilly__POSIX_Programmers_Guide.pdf)

4、LINUX程序员指南：[https://tldp.org/LDP/lpg-0.4.pdf](https://tldp.org/LDP/lpg-0.4.pdf)

5、内核文档：[https://docs.kernel.org/](https://docs.kernel.org/)

6、POSIX官网：[http://get.posixcertified.ieee.org/](http://get.posixcertified.ieee.org/)

7、linux教程和指南：[https://www.baeldung.com/linux/](https://www.baeldung.com/linux/)
