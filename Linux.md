## Day-02

### What is linux?

- The Linux Operating System is a type of operating system that is similar to Unix, and it is built upon the Linux Kernel.

### What is operating system ?

- **Operating System** a type of system software. It basically manages all the resources of the computer. An operating system acts as an interface between the software and different parts of the computer or the computer hardware.

### What is Shell?

- The shell is a program that takes commands from the keyboard and gives to the OS to perform.
    
- On most Linux system, BASH(Bourne Again SHell) act as the shell program.
    
- **Bash (Bourne-Again SHell)**: The most common default shell in Linux distributions. It’s an enhancement of the original Bourne shell (`sh`), incorporating features from other shells like `ksh` and `csh`.
    
- **sh (Bourne Shell)**: The original shell that was used on UNIX. It is simple and fast but lacks many features of more modern shells.
    
- **Ksh (Korn Shell)**: Offers many features, combining elements of both the Bourne shell and C shell. It provides powerful programming features as well as interactive use.
    
- **Csh (C Shell)** and **Tcsh (TENEX C Shell)**: `Csh` offers a syntax that is quite similar to the C programming language, from which it derives its name. `Tcsh` is an improved version of `csh` that includes command line editing and completion.
    
- **Zsh (Z Shell)**: Combines many of the useful features of Bash, ksh, and tcsh. It is known for its interactive use enhancements and extensive customization capabilities.
    
- **Fish (Friendly Interactive SHell)**: Known for its user-friendly and interactive features, like syntax highlighting, autosuggestions, and tab completions.
    
- `uname` - name of kernel
    
    - `uname -r` - kernel release
    - `uname -v` - kernel version
    - `uname -m` - print kernel bit system
    - `uname -o` - print which OS
    - `uname -a` - all details print
    - `uname -n` - print network node hostname
- `whoami` - current username
    
- `sudo -i` - login as root
    
- `man` - manual of any command
    
- `tty`(TeleTypeWriter) - Prints the filename of the terminal that is currently connected to STDIN(standard input).
    
    - A way to get access to the computer to fix things, without actually logging into a desktop.
    - The `tty` command is useful to determine which terminal session you're in, especially when working with multiple terminals or remote sessions.
- `hostname` - Get/Set hostname or DNS domain name.
    

### what is command line interface ?

- **A text-based way to interact with a computer's operating system by typing commands into a terminal.**

### what is graphical user interface ?

- **A digital interface that allows users to interact with a computer or device using visual elements like icons, buttons, and menus.**
    
- `id` - give all info id of current user
    - `-u` - print id of user
    - `-g` - print groupid
    - `G` - print all group id connected with users
    
- `groups` - prints names of groups connected with user
    
- `su` - switch user
    
- `exit` - exit from current user
    
- `usermod` - usermod -a -G sudo test2
    
- `addgroup` - create a group
    
- `delgroup` - delete the group
    
- `useradd` - Create a new user in Linux
    - -m - create the user’s home dir.
    - -M - do not create.
    - —uid UID - UID of the new account.
    - -U - create a group with the same name as the username.
    - -r - Create system account.
    
- `passwd` - Set/Change password for the user accounts.
    
- `usermod` - Modify user attributes(username, home directory, uid, gid, etc.)
    - —lock/unlock - Lock/Unlock the user account.
    - —password PASSWORD - new user password.
    - —home - Set home directory.
    - --expiredate EXPIRYDATE - Set user expiration date. YYYY-MM-DD
    - --inactive INACTIVE - The number of days after a password expires until account is permanently disabled.
    
- `userdel` - To delete a user account.
    - -r - Delete the user’s home directories and files.
    - -f - Force the deletion of the user's account, even if processes are still running.
    
- `su` - Switch current user.
	- -c - Specify a command to be executed with the new user.
    - -s - Shell to be used for the command.
    
- To logout user,
    - `logout`
    - `exit`
    - `Ctrl + D`
    
- `chmod` - Change the permission of a file/directory.
    
- `chown` - Transfer the ownership to a different user or group.
    
- `chgrp` - Change the group ownership of a file/dir.    

### Difference between useradd and adduser

- `useradd` is a portable command that requires additional parameters to set up a user account. `adduser` is a script that uses an interactive prompt to create a user.
- `adduser` is more user-friendly and interactive than `useradd`.
- `useradd` is universal, while `adduser` is available in Debian-based distributions.
- By default, `adduser` creates a home directory, while `useradd` requires a `-m` option.
- `useradd` do not require password on user creation.

### Difference between groupadd and addgroup

- `addgroup` is a perl script that prompts for various options (interactively) before invoking the `groupadd` command.

### [Linux Boot Process](https://www.freecodecamp.org/news/the-linux-booting-process-6-steps-described-in-detail/)

* An operating system (OS) is the low-level software that manages resources, controls peripherals, and provides basic services to other software. In Linux, there are 6 distinct stages in the typical booting process.

![[StartupFlow.png]]

### **1. BIOS**

BIOS stands for Basic Input/Output System. In simple terms, the BIOS loads and executes the Master Boot Record (MBR) boot loader.

When you first turn on your computer, the BIOS first performs some integrity checks of the HDD or SSD.

Then, the BIOS searches for, loads, and executes the boot loader program, which can be found in the MBR. The MBR is sometimes on a USB stick or CD-ROM such as with a live installation of Linux.

>_Once the boot loader program is detected, it's then loaded into memory and the BIOS gives control of the system to it._

### **2. MBR**

MBR stands for __Master Boot Record__, and is responsible for loading and executing the GRUB boot loader.

The MBR is located in the 1st sector of the bootable disk, which is typically `/dev/hda`, or `/dev/sda`, depending on your hardware. The MBR also contains information about GRUB, or LILO in very old systems.

### **3. GRUB**

Sometimes called GNU GRUB, which is short for GNU _GRand Unified Bootloader,_ is the typical boot loader for most modern Linux systems.

The GRUB splash screen is often the first thing you see when you boot your computer. It has a simple menu where you can select some options. If you have multiple kernel images installed, you can use your keyboard to select the one you want your system to boot with. By default, the latest kernel image is selected.

The splash screen will wait a few seconds for you to select and option. If you don't, it will load the default kernel image.

In many systems you can find the GRUB configuration file at `/boot/grub/grub.conf` or `/etc/grub.conf`. Here's an example of a simple `grub.conf` file:

```text
#boot=/dev/sda
default=0
timeout=5
splashimage=(hd0,0)/boot/grub/splash.xpm.gz
hiddenmenu
title CentOS (2.6.18-194.el5PAE)
      root (hd0,0)
      kernel /boot/vmlinuz-2.6.18-194.el5PAE ro root=LABEL=/
      initrd /boot/initrd-2.6.18-194.el5PAE.img
```

### **4. Kernel**

The kernel is often referred to as the core of any operating system, Linux included. It has complete control over everything in your system.

In this stage of the boot process, the kernel that was selected by GRUB first mounts the root file system that's specified in the `grub.conf` file. Then it executes the `/sbin/init` program, which is always the first program to be executed. You can confirm this with its process id (PID), which should always be 1.

The kernel then establishes a temporary root file system using Initial RAM Disk (initrd) until the real file system is mounted.

### **5. Init**

At this point, your system executes runlevel programs. At one point it would look for an init file, usually found at `/etc/inittab` to decide the Linux run level.

Modern Linux systems use systemd to choose a run level instead. According to [TecMint](https://www.tecmint.com/change-runlevels-targets-in-systemd/), these are the available run levels:

> **Run level 0** is matched by **poweroff.target** (and **runlevel0.target** is a symbolic link to **poweroff.target**).
> 
> **Run level 1** is matched by **rescue.target** (and **runlevel1.target** is a symbolic link to **rescue.target**).
> 
> **Run level** 3 is emulated by **multi-user.target** (and **runlevel3.target** is a symbolic link to **multi-user.target**).
> 
> **Run level 5** is emulated by **graphical.target** (and **runlevel5.target** is a symbolic link to **graphical.target**).
> 
> **Run level 6** is emulated by **reboot.target** (and **runlevel6.target** is a symbolic link to **reboot.target**).
> 
> **Emergency** is matched by **emergency.target**.

`systemd` will then begin executing runlevel programs.

### **6. Runlevel programs**

Depending on which Linux distribution you have installed, you may be able to see different services getting started. For example, you might catch `starting sendmail …. OK`.

These are known as runlevel programs, and are executed from different directories depending on your run level. Each of the 6 runlevels described above has its own directory:

- Run level 0 – `/etc/rc0.d/`
- Run level 1 – `/etc/rc1.d/`
- Run level 2  – `/etc/rc2.d/`
- Run level 3  – `/etc/rc3.d/`
- Run level 4 – `/etc/rc4.d/`
- Run level 5 – `/etc/rc5.d/`
- Run level 6 – `/etc/rc6.d/`

Note that the exact location of these directories varies from distribution to distribution.

If you look in the different run level directories, you'll find programs that start with either an "S" or "K" for startup and kill, respectively. Startup programs are executed during system startup, and kill programs during shutdown.

