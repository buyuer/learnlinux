# 添加linux系统调用

[主仓库：https://github.com/buyuer/learnlinux](https://github.com/buyuer/learnlinux)

系统调用是用户态程序和内核的接口，用户态的程序想要请求内核功能，就要通过系统调用来完成。由此可见，系统调用就是内核提供给用户态程序的API。用户态程序通常通过软中断，使CPU进入到高权限的内核态，进而把请求传递给内核。但是通常用户态程序并不直接使用软中断，而是使用glibc这种封装了系统调用的库。在POSIX中，有一个很重要的函数，就是syscall函数，通常通过这个函数进行系统调用。

## 1、在内核中添加新的系统调用

首先修改tbl文件，x86_64的系统调用表在如下目录

> arch/x86/entry/syscalls/syscall_64.tbl

在文件末尾添加

```
801	common	my_hello		sys_my_hello
```

801就是系统调用号，在这里定义了系统调用后，在编译的时候就会生成相应的代码。

接下来找到kernel/sys.c文件，把my系统调用的实现添加到文件末尾

```c
SYSCALL_DEFINE0(my_hello){
	struct task_struct* task = get_current();
	set_task_comm(task, "my_hello");
	return 123;
}

```

我们在系统调用里，把当前task的名字改为my_hello，并返回123。（注意linux调度器里并无和pthread对应的概念，这里的task就是用户态的thread）

修改好后，重新编译内核

```shell
make bzImage -j
```

添加系统调用并不复杂，主要就是两步：先修改tbl文件，然后实现系统调用。

修改可参考[github.com/buyuer/linux](https://github.com/buyuer/linux)，my分支

## 2、在用户态调用系统调用

在busybox中添加一个名为myscl的applet，来调用801号系统调用，源文件如下。（添加applet的方式参考：[在busybox中添加applet.md](./在busybox中添加applet.md)，其他文件的修改可参考[github.com/buyuer/busybox](https://github.com/buyuer/busybox)，[my分支](https://github.com/buyuer/busybox/tree/my)）

```c
#include "busybox.h"

#include <sys/prctl.h>

int myscl_main(int argc, char *argv[])MAIN_EXTERNALLY_VISIBLE;

int myscl_main(int argc, char *argv[]) {
    long int ret = 0;
    const char name[1024];

    prctl(PR_GET_NAME, name);
    printf("old: %s\n", name);
    ret = syscall(801);
    prctl(PR_GET_NAME, name);
    printf("new: %s, and ret: %ld\n", name, ret);

    return 0;
}

```

通过prctl函数来查看当前线程的名字，并分别在系统调用前后打印当前线程的名字，来验证系统调用的修改，并打印系统调用的返回值。

重新编译busybox，然后通过qemu启动系统：

```shell
qemu-system-x86_64 -kernel ./linux/arch/x86_64/boot/bzImage -hda ./rootfs.img -append "root=/dev/sda console=ttyS0" -nographic
```

进入终端后，运行myscl命令，将看到如下输出

```shell
/ # myscl 
old: myscl
new: my_hello, and ret: 123
```

可以看到，在调用801号系统调用后，线程名字已经被修改为my_hello了，并且返回值为123。
