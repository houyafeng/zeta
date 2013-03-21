zeta
====

perl library for process management, IPC, logging etc...

zeta运行原理
0、规范
   0.1、应用的HOME目录是$APP_HOME
   0.2、主要配置文件:
        $APP_HOME/conf/zeta.conf         : zeta主配置文件
        $APP_HOME/libexec/main.pl        : 主控模块loop钩子函数
        $APP_HOME/libexec/plugin.pl      : 插件钩子, 负责加载helper
        $APP_HOME/libexec/module-A.pl    : 模块A的loop函数
        $APP_HOME/libexec/module-B.pl    : 模块B的loop函数

1、读配置文件$APP_HOME/conf/zeta.conf, 配置文件里主要包含以下信息：
   1.1、kernel配置
        1.1.1、pid文件
        1.1.2、运行模式:process_tree, logger, loggerd
        1.1.3、日志路径、级别
        1.1.4、插件加载钩子文件
        1.1.5、主控函数钩子文件以及参数
        1.1.6、预先建立的管道
        1.1.7、主控进程的显示名称(prctl name)

    1.2、module配置
        1.2.1、reader: STDIN从哪个管道读
        1.2.2、writer: STDOUT往哪个管道写
        1.2.3、mreader: 从哪些管道读
        1.2.4、mwriter: 往哪些管道写
        1.2.5、code: 模块钩子函数文件
        1.2.6、exec: 模块可执行文件(code, exec不能同时有)
        1.2.7、para: 模块钩子函数参数、或是模块可执行文件参数
        1.2.8、reap: 此模块的进程异常退出后是否自动重启
        1.2.9、size: 次模块启动几个进程

2、读完配置后, zeta会加载:
   plugin.pl   可以在plugin.pl放置你的helper函数   : 这将给zkernel增加一些helper
   code.pl     你的模块函数                        : 返回一个函数指针,模块的loop函数
   main.pl     主控函数文件                        : 主控函数指针

3、zeta为每个模块fork相应数量的子进程, 同时:
   3.1、每个子进程要么用exec对应的文件执行exec($efile)， 
   3.2、要么调用code.pl返回的loop函数指针

4、zeta然后调用main.pl返回的函数指针
   
