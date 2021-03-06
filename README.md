zeta
====

perl library for process management, IPC, logging etc...

zeta运行原理

1、规范

    1.1、应用的HOME目录是$APP_HOME

    1.2、主要配置文件:
         1.2.1、$APP_HOME/conf/zeta.conf         : zeta主配置文件
         1.2.2、$APP_HOME/libexec/main.pl        : 主控模块loop钩子函数
         1.2.3、$APP_HOME/libexec/plugin.pl      : 插件钩子, 负责加载helper
         1.2.4、$APP_HOME/libexec/module-A.pl    : 模块A的loop函数
         1.2.5、$APP_HOME/libexec/module-B.pl    : 模块B的loop函数

2、读配置文件$APP_HOME/conf/zeta.conf, 配置文件里主要包含以下信息：

    2.1、kernel配置
         2.1.1、pid文件
         2.1.2、运行模式:process_tree, logger, loggerd
         2.1.3、日志路径、级别
         2.1.4、插件加载钩子文件
         2.1.5、主控函数钩子文件以及参数
         2.1.6、预先建立的管道
         2.1.7、主控进程的显示名称(prctl name)

    2.2、module配置
         2.2.1、 reader: STDIN从哪个管道读
         2.2.2、 writer: STDOUT往哪个管道写
         2.2.3、 mreader: 从哪些管道读
         2.2.4、 mwriter: 往哪些管道写
         2.2.5、 code: 模块钩子函数文件
         2.2.6、 exec: 模块可执行文件(code, exec不能同时有)
         2.2.7、 para: 模块钩子函数参数、或是模块可执行文件参数
         2.2.8、 reap: 此模块的进程异常退出后是否自动重启
         2.2.9、 size: 次模块启动几个进程
         2.2.10、plugin: 子进程插件{ plugin_name => para, ... }

3、读完配置后, zeta会加载:
    
    3.1、plugin.pl   可以在plugin.pl放置你的helper函数   : 这将给zkernel增加一些helper
    3.2、code.pl     你的模块函数                        : 返回一个函数指针,模块的loop函数
    3.3、main.pl     主控函数文件                        : 主控函数指针

4、zeta为每个模块fork相应数量的子进程, 同时:

    4.1、每个子进程要么用exec对应的文件执行exec($efile)， 
    4.2、要么调用code.pl返回的loop函数指针

5、zeta然后调用main.pl返回的函数指针


zeta tutorial
====

1、任务描述

   有一个消息队列， 2个模块分别为Zdispatch, Zworker.

   Zdispatch : 负责从消息队列中读取任务，通过管道分发给Zworker模块

   Zworker   : 负责处理Zdispatch分发的任务
   
   下面将描述zeta框架如何简化应用开发。 根据前面描述，zeta将会产生如下进程树:

   Zeta
     |         
     |        消息队列
     |          || 
     |          || 
     |         \||/
     |   --------------
     |---|Zdispatch.0 |
     |---|Zdispatch.1 |.>..>..>..>.>.
     |---|Zdispatch.N |             .
     |   --------------            \./  
     |                              . 通过管道
     |   --------------            \./
     |---|Zdispatch.0 |             .
     |---|Zdispatch.1 |.<.<..<..<..<.
     |---|Zdispatch.N |
     |   --------------
     |
 ------------
 |  主控loop|
 |----------|

2、开始建立应用结构

   2.1、建立应用目录
  
       mkdir -p conf etc libexec plugin log sbin 

3、开始配置、开发

    3.1、etc设置 
        进入etc目录, vi profile.mak, 添加:
        export ZETA_HOME=zeta安装目录
        export TAPP_HOME=你的zeta应用的home目录
        export PERL5LIB=$ZETA_HOME/lib:$TAPP_HOME/lib
        export PATH=$ZETA_HOME/bin:$TAPP_HOME/bin:$PATH

    3.2、conf设置, 进入conf目录
        3.2.1、编辑应用主配置文件tapp.conf
            {
               qkey => 9898,
            };

        3.2.2、编辑zeta主配置文件zeta.conf
            {
                 kernel => {}
            }
        

4、观察日志、运行、停止
   

