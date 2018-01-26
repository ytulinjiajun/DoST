# 背景
首先得从ARM说起。ARM有三个架构系列的产品，Cortex-A、Cortex-M、Cortex-R,STM32属于Cortex-M系列，ARM公司不做硬件，他们只设计内核的架构，提供一套接口（CMSIS），然后授权给各大芯片厂商，比如意法半导体公司（ST），这些厂商生产硬件，并提供接口库（比如HALLI库），普通开发者使用厂商提供的库函数进行开发（当然你也可以基于寄存器开发，不过在实际的开发中你可能不想那样去做）。普通开发者在实际开发过程中所做的绝大部分工作均是一些外设相关的驱动，移植第三方模块（比如，FATFS，UCOSIII，LWIP，STEMWIN），以及使用外设驱动，接口库和第三方组建去实现一些具体的功能。
    
# 简介
1. DoST是 Linux 下开发 STM32 的一个简洁的命令行集成开发环境;
2. 基于CMAKE架构;
3. 基本元素：架构（CMake），编辑器（Emacs/Spacemacs、Vim）,编译器（arm-none-eabi-gcc）,烧录器（STLink）,版本控制工具（Git）；
4. 支持ST全系列产品;
5. 是一个命令行的开发环境而非图形界面，但是，使用shellscript脚本封装了单个指令，因此编译，烧录，调试均是一键性质的；
5. DoST不仅仅是一个软件，更是一个开发STM32的“生态系统”，集编译、调试、烧录，软件升级机制为一体，编辑器任意选择，使用原生的版本控制；
6. 可同时管理任意套不同型号板子的工程，开发者只需在编译时以参数的形式提供板子的型号，即可随意的切换，工作环境。

# 我为什么放着Keil不用而自己去造一个“轮子”
1. 首先，我是Linux阵营的，我的所有工作环境都在Linux下完成，MDK不支持Linux,我用Linux,又要做STM32的开发，只能自己写一个软件来满足我的需求;
2. 其次，我确实没有在Linux下找到像Keil那样好用的开发工具，sw4stm32算是一个linux下支持stm32开发的集成开发环境,我不会去说它不好用的，我可以说我对图形界面“过敏”吗，好吧，我确实那样说了。事实是，我有相当一段时间是去配置过sw4stm32并尝试用它的,但是，我放弃它了，你尽可以去试试它，我相信不久之后你会回到DoST的怀抱；
3. 最后，也是最重要的一点，我习惯了Linux下的Git,Emacs/Spacemacs,Vim,Patch，Cmake等工具，你可能会质问我，你的DoST能有Keil下的那种定义跳转，语法检查，查找，代码折叠，代码补全等这样的一些功能吗？我只想说，Emacs号称神之编辑器，Vim号称编辑器之神,DoST使用神之编辑器的编辑器之神Spacemacs来开发，那些个功能只会比Keil更多更好！
4. 无与伦比的裁剪性和定制性，这一点，DoST 做的淋漓尽至，这个特性keil无法做到的，你别忙着反驳我，DoST基于CMake，如果你懂CMAKE，这一句话就足够解释前面我说的了，如果你不懂CMAKE，那我可以简单的说一下，CMAKE是专门有一套cmake语法的，用DoST做开发，用户除了开发自己的源码之外，还可以去维护CMakeList.txt文件,里面都是cmake语法，是用来处理编译源码行为的。

# 核心思想
STM32的开发是一个很有意思的事，它有太多可重用的代码，以及太多无需用户过多关心的代码，比如说：内存管理的内部实现，文件系统内核源码（FATFS），字库相关的源码，网络相关的组件（LWIP），实时操作系统（UCOSIII，FreeRTOS），用户图形接口（STemwin） ，USB 驱动等等，这些代码通常都可以独立出来。我们可能比较关心这些模块提供的接口函数，而不太关心具体的实现，很巧的是这些组件通常对于ST任意型号的开发板都是一致的，除非这些模块的厂家对其进行升级，否则STM32开发者基本上可以在ST不同型号的开发板之间重用这些代码。当然还有一些重用率在满足一定条件下也很高的源码，比如 ARM 提供的 CMSIS，所有的 Cortex-M4 内核的 ST 产品均可以重用同一套 CMSIS。再比如 ST提供的 HAL 库，所有 STM32F4 系列的产品均可以重用同一套 HAL 库。如果你手头有一块 STM32F407的板，以及一块 STM32F767 的板子，而你又想让两块板子都工作能跑操作系统 FreeRTOS，在Windows 下的 Keil/MDK 下面，你不得新建两个工程，组织两遍 FreeRTOS 的源代码，尽管它是一模一样的。组织这些重复的代码会花费我们大量的时间，极大的降低了效率。DoST的核心思想就是将这些可重用的代码使用Cmake语法，将其封装成组件的形式，用户只需在使用到相关的组件时，简单的进行加载，然后就可以愉快的使用这些组件所提供出来的接口函数，如果你没有去加载这些组建，那么这些组件就不会参与编译，这样的形式使得代码具有高度可裁剪性以及通用性，对于RAM尤其珍贵的STM32来说，这样的特性更是难能可贵，能节省相当多RAM。使用这样的方案，用户甚至能同时管理任意多个不同型号ST板子的工程，而又能保持代码的简洁和逻辑的清晰。

# 安装与配置
1. 依赖： cmake >= 3.9
2. 安装： git clone git@github.com:ytulinjiajun/DoST
3. 下载STM32Cube: 执行脚本compile.sh并附加-r参数，填写你的板子型号。比如 ./compile.sh -r 回车之后，输入STM32F767IGT6,DoST会自动从官网下载

# 使用
1. 编译：cd DoST && ./compile.sh
2. 重新编译： cd DoST && ./compile.sh -r
3. 调试：cd DoST && ./debug.sh
4. 重新编译：cd DoST && ./debug.sh -r
5. 烧录：cd DoST && ./burn.sh

# 目前已支持的ST型号
1. STM32F4
2. STM32F7

# 最新支持的ST型号
STM32F7

# 顶层目录结构
1. 顶层 CMakeLists.txt: 整个系统的 "指挥中心", 它负责规范系统的基本行为, 比如禁止 CMAKE 内部编译, CMAKE 的版本限制, 创建工程等. 它还负责控制程序的加载顺序, 脚本调度, 以及控制进入子目录的时机等;
2. core: DoST 内核的源码，主要是一些脚本，以及组件，DoST 开发者才会关心这个目录，普通用户一般不需要关心它;
3. .dost.conf: DoST 内核中提供给用户配置的接口，用户可以在该目录下对相应的变量进行个性配置，DoST 在工作时会去加载这些配置。一些需要对 DoST 进行深层次定制的用户才会去修改这个目录下的配置，它会影响内核的工作方式，所以一般不建议用户去随意修改他们，除非你很确定的知道你自己正在做什么;
4. ST: 该目录就是普通用户最关心的目录，用户创建的 ST 所有型号板子的工程可以在该目录下面按照相应的目录规则进行创建，由于 DoST 系统可以根据用户在编译时提供的 STM32_CHIP 参数自动选择应当编译哪个子目录下的工程，因此，用户只需要按照符合实例所示的目录命名规范就可以轻易的创建自己的项目，而且可以同时创建多个不同的项目。值得说明的是，用户只需要只需要实现个性代码，比如外设相关的驱动，或者项目中某一具体的功能，而那些共性的代码全部由 DoST 内核提供,用户只需要简单的调用 find_package() 进行加载即可，详细信息请参看该目录下的源代码的实现;
5. compile.sh: DoST 的编译脚本，直接运行该脚本，即可立即编译工程，如果你是第一次编译某一型号开发板的源码，那么系统会提示你输入你想要编译的开发板的型号，之后再次编译时不会再要求你输入型号;如果你需要重新编译该工程或者编译其他型号的开发板对应的源码，那么可以在运行脚本时加上 -r 参数，此时系统会要求你输入待编译的开发板的型号，该参数十分重要，DoST 就是依靠这个参数进行解析的ST产品的;
6. debug.sh:DoST 的调试脚本，直接运行该脚本，即可立即开始调试工程，如果你是第一次调试某一型号开发板的源码，那么系统会提示你输入你想要调试的开发板的型号，之后再次调试时不会再要求你输入型号;如果你需要重新调试该项目或者调试另外一个型号的开发板，那么，你在运行调试脚本的同时可以加上 -r 参数，此时系统会要求你输入待调试的开发板的型号，该参数十分重要，DoST 就是依靠这个参数进行解析的ST产品的;
7. burn.sh,直接运行该脚本，可以将程序烧录到开发板中。

# 深度配置
1. 升级编译器
2. 升级STM32Cube
3. 升级STLink

# 编辑器的选择
我是在Spacemacs下完成的DoST,因此，我极力推荐Spacemacs,当然了，你也可以使用Emacs,如果你是Vim阵营的，你当然也可以用vim。你可能已经知道我要说什么了，是的，你甚至可以使用任何编辑器都是可以的。那么，为什么我会推荐Spacemacs/Emacs呢，一句话，因为可以自由的按照你的意志去定制自己想要的辅助功能，比如：代码自动补全，语义补全，定义跳转，函数跳转，头文件跳转，语法检查，折叠代码，模板，高亮等等，当然，它能干的事情比这里说的多得多，换句话说，它几乎可以定制你想要的任何功能，毕竟，它有着数以百万记的插件可以供你随意定制。我的Spacemacs中有专门定制一个层来配置我上面列出的功能，如果你和我的品味一样，也需要上面列举出的功能，非常欢迎你使用我的配置： git clone git@github.com:ytulinjiajun/spacemacs-private, 当然了，Spacemacs的安装步骤肯定不是这样的，具体的安装步骤你可以参考Spacemacs的作者托管在Github上的源码下给出的ReadMe.md: https://github.com/syl20bnr/spacemacs

# 说明及参考文献
1. DoST开源，在遵守GPLV3协议的前提下即可随意使用该软件；
2. DoST是一套开发stm32的“生态系统”，使用 DoST 开发 STM32 的标准工具组合是 Spacemacs+Cmake+Git;
3. 由于近些年 ST 大力主推 HAL 库，并以 Cube 包的形式发布，这将会是将来的发展趋势，这也从侧面反映了 ST 有意想逐渐淘汰掉 FWLIB 固件库，因此，在该系统中不打算去支持 FWLIB，不过由于该系统是基于Cmake 的，有着相当强大的扩展能力，如果有必要，用户可以仿照 core/Scripts 目录下 HAL 库的解析脚本，自己实现对FWLIB 固件库的解析;
4. 由于该系统是我个人在管理，时间有限，一些技术细节可能不能尽述，有对 DoST 感兴趣的朋友如果在使用DoST 的过程中有遇到技术相关问题的，可在 Github 上提 issues 或者直接给我发送邮件：ytulinjiajun@163.com
5. 该软件的一些思想和实现有参考 https://github.com/ObKo/stm32-cmake， 基于对该作者的尊重，以及LICENSE的要求，特此说明
