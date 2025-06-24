# **JobsSwiftBaseConfigDemo**

[toc]



## 一、第三方管理

* Mac OS 15 以后，苹果采取了更加严格的权限写入机制。新swift项目如果要利用`Cocoapod`来集成第三方，就比如在xcode里面做如下设置，否则编译失败：`TARGETS`->`Build Settings`->`ENABLE_USER_SCRIPT_SANDBOXING`-><font color=red>`NO`</font>

  ![image-20250616173410872](./assets/image-20250616173410872.png)

* <font color=red>**S**</font>wift <font color=red>**P**</font>ackage <font color=red>**M**</font>anager

  ![image-20250616173604040](./assets/image-20250616173604040.png)

![image-20250616174404275](./assets/image-20250616174404275.png)

