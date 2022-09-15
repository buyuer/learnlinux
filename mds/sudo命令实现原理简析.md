# sudo命令实现原理简析

sudo是Linux上的常用命令，其目的是为了给普通用户提升操作权限，完成一些需要root权限才能完成的任务。那么sudo是如何提升权限的呢？

linux操作系统有着严格、灵活的权限访问控制。主要体现在两方面：

> 1、文件权限
> 2、进程权限

### 文件权限

文件权限包括五种：

> r： 可读取文件内容或目录结构
> w：可修改文件的内容或目录的结构（但不包括删除）
> x：文件可被系统执行或目录可被作为工作目录
> s：文件在执行阶段具有文件所有者的权限
> t：使一个目录既能够让任何用户写入文档，又不让用户删除这个目录下他人的文档

一个文件拥有三组权限，所有者权限、所属组权限、其他人权限

### 进程权限

进程是用户访问计算机资源的代理，用户执行的操作其实是带有用户身份信息的进程执行的操作。这里介绍两个最重要的进程权限id

> reaal user id(ruid)：执行进程者的 user id，一般情况下就是用户登录时的 user id
> effective user id(euid)：决定进程是否对某个文件有操作权限，默认为ruid

在文件权限和进程权限id里，s文件权限和euid权限id是sudo实现提升权限的根本。一个进程是否能操作某个文件，取决于进程的euid是否拥有这个文件的相应权限，而不是ruid。也就是说，如果想要让进程获得某个用户的权限，只要把进程的euid设置为该用户id就可以了。在具体一点，我们想要让进程拥有root用户的权限，我只要想办法把进程的euid设置成root的id：0就可以了。

Linux提供了一个seteuid的函数，可以更改进程的euid。函数声明在头文件里。

> ```
> int seteuid(uid_t euid);
> ```

但是，如果一个进程本身没有root权限，也就是说euid不是0，是无法通过调用seteuid将进程的权限提升的，调用seteuid会出现错误。  那该怎么把进程的euid该为root的id：0呢？那就是通过s权限。

如果一个文件拥有x权限，表示这个文件可以被执行。shell执行命令或程序的时候，先fork一个进程，再通过exec函数族执行这个命令或程序，这样的话，执行这个文件的进程的ruid和euid就是当前登入shell的用户id。

当这个文件拥有x权限和s权限时，在shell进行fork后调动exec函数族执行这个文件的时候，这个进程的euid将被系统更改为这个文件的拥有者id。

比如，一个文件的拥有者为user_1，权限为rwsr-xr-x，那么你用user_2的文件执行他的时候，执行这个文件的进程的ruid为user_2的id，euid为user_1的id。

创建一个main.c文件，并写入如下代码：

```c
#include <stdio.h>
#include <unistd.h>

int main(int argc, char* argv[])
{
        printf("ruid: %d\n",getuid());
        printf("euid: %d\n",geteuid());
        return 0;
}
```

编译代码

```shell
gcc ./main.c -o ./main
```

编译运行，结果如下：

```shell
ruid: 1000
euid: 1000
```

通过chmod和chown为文件更改拥有者和添加s权限

```shell
sudo chown root ./main
sudo chmod +s ./main
```

再次运行，结果如下：

```shell
ruid: 1000
euid: 0
```

此时由于文件的s权限，euid已经变为了root的id：0

将代码修改如下：

```c
#include <stdio.h>
#include <unistd.h>

int maind(int argc, char* argv[])
{
    printf("ruid: %d\n",getuid());
    printf("euid: %d\n",geteuid());

    if(execvp(argv[1], argv+1) == -1){
        perror("execvp error");
    };
    return 0;
}
```

编译

```shell
gcc ./main.c --o main
```

执行如下命令

```shell
sudo chown root ./main
sudo chmod +s ./main
./main apt update
```

可以看到，已经成功运行apt并进行了软件列表的更新。

查看sudo的权限

```shell
ls -al /usr/bin/sudo
```

输出如下

```shell
-rwsr-xr-x 1 root root
```

可以看到，sudo就是一个拥有者为root且拥有s权限的可执行文件。

当然sudo的实现要比这复杂的很多，比如sudo通过检查配置文件，来决定哪些用户可以使用sudo，为了安全考虑sudo还要求验证ruid的用户密码等。
