# learnlinux

linux学习教程，一边学一边更新

可以使用仓库中的dockerfile构建学习环境的镜像，克隆本仓库，并在仓库目录运行

```shell

docker build -t learnlinux:latest .

```

构建的镜像中，可以使用 `-build-arg user=<用户名>`指定用户名，默认密码和用户名一样，默认用户名为learner。用户目录下创建了work目录，linux和busybox的源码已经克隆好了

相关链接

[知乎专栏：https://www.zhihu.com/column/c_1550211967562051584](https://www.zhihu.com/column/c_1550211967562051584)

## 目录

[1、搭建最小的linux系统](./搭建最小的linux系统.md)

[2、在busybox中添加applet](./在busybox中添加applet.md)
