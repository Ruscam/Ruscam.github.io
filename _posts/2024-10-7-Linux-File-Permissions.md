---
title: Linux File Permissions
date: 2024-10-07
categories: [Introduction Guide]
tags: [linux, permissions, file, bash, chmod, chown]
---
# Overview
This refence will cover:
- Linux commands used to change permissions
- How permissions work in linux 

# Checking file and directory details
1. Navigate to the projects directory.
![](https://lh7-rt.googleusercontent.com/docsz/AD_4nXeDPRs5rbGlffhgGOGfIwt9X6aOzJc9zE4xyxN-Un5SsPD_aQt9dx61-JZK8upYIc-El3_7nlI6RnbcSt1HGk3wx2rEPna2vWUgOPBPJh2kV_qe-3wXpNkEptX1TRaow9H3HWmfREZGXil8VscWXzPrGbU?key=wlreC3UtJanLEHo7mIIXPw)

2. List the contents and permissions of the projects directory.
![](https://lh7-rt.googleusercontent.com/docsz/AD_4nXdaS30ggvj9LXbjj39wswQ4POLGWllEGNH_-qGNFpGLGq67rKS9xaxdElzpUQviDojLu6kpQeDwYXEu2uDAUV8tmQIhv8TbsFxJ7JnSCfujNu1EUewosT2qWnhC0Y8IcXywRqVVAt8bS5k_gymWfQdO2ocO?key=wlreC3UtJanLEHo7mIIXPw)

# Linux Permissions String
A permission string like `-rw-r-----` describes which users can have which permissions for the given file or directory.

The leading character will specify whether the item is a file or directory. Files will have a dash `-`, while directories will have a `d`.

The next 9 characters consist of 3 groups of 3 characters. The first block refers to the permissions of the user who owns the file. The second block refers to the permissions of the group that the owner of the file belongs to. The third block refers to the permissions for all other users on the system.

These blocks consist of either `r` for read permissions, `w` for write permissions, `x` for execute permissions, or a dash `-` indicating that the permission is not granted.
  
In our example above:
`-rw-r----- 1 researcher2 research_team   46 Mar 25 02:00 project_m.txt`

We know:
- The file is a regular file, not a directory
- The file is owned by researcher2, who can read and write the file, but not execute it
- The file can be read by users of the research_team group, but not write or execute the file
- And the file can’t be read, written to, or executed by any other user on the system

# Changing File Permissions
Changing file permissions is done with the `chmod` command. It can be remembered as a portmanteau of “change mode bits.” There are two syntax standards to specify which users and permissions will be changed: the alphabetic syntax and the numeric syntax. 

This guide will exclusively use the alphabetic way because it is more intuitive (`chmod u+rwx file` is probably more intuitive than `chmod 700 file` for most people).

The syntax is: `chmod [permission change string] [file]`

The `[permission change string]` can be broken down into three parts:
1.  `[usertype]`
2.  `[operand]`
3. `[permission]`

Where `[usertype]` can be: 
- `u` for user
- `g` for group
- `o` for other

`[operand]` can be a `+` or `-` depending on whether permissions are being granted or revoked

And `[permission]` corresponds with the `rwx` style syntax we saw earlier. `r` for read, `w` for write, and `x` for execute.

![](https://lh7-rt.googleusercontent.com/docsz/AD_4nXcurJ17v6KGYoTN_nvG_aCSR-7UfEQMZVqIKiQfoqeJGgscq5PGXadca6YCT-I9Yd_tNrEF7Pn9-iGFQ1X2jfObNnw9V-1aIPM0YgHTAiq_AXZlkrBIMWOGC2lg503VTXrczG-4cqyWYpt-egPFTODlFeZI?key=wlreC3UtJanLEHo7mIIXPw)

Permissions can be added to files. In this example, group write permissions were added to the project_m.txt file and the file permissions were checked only for project_m.txt

# Changing File Permissions of a Hidden File
To list the permissions of all files in the directory, including the hidden files:  
![](https://lh7-rt.googleusercontent.com/docsz/AD_4nXfC7GrHEVUvfG_T8QnfUn1i8FeqqUU7v8YVLaLrM-fIvBWbiU2OWxNHPdexU6lHY34aXn07Zd-ndCT5WmE6UPTURfAccH1yc0wLWK6oOnm8MvF0pNpX74cUsiR9H8isCmLFLPTvKwVgjUhDLgzbdLqEmbFh?key=wlreC3UtJanLEHo7mIIXPw)

The hidden file’s permissions can be edited in much the same way as non hidden files:
![](https://lh7-rt.googleusercontent.com/docsz/AD_4nXcNrGyTVgha5lWC4pPxAveeoM5H4HxoAjzyv2H-FLLo85X2xSbuFR6C-YjGHhJTlmPBPIzRRhdzoRdcWRwxpV-px6qhVSDprB_u4xGR1icoqe0E4GpfnEz50VrluWK9zx9L-9F_FP-38RGiuCReWrjDfVmr?key=wlreC3UtJanLEHo7mIIXPw)

# Changing Directory Permissions
Next, the directory’s permissions will be changed:  
![](https://lh7-rt.googleusercontent.com/docsz/AD_4nXcgefK5CH7FqH1nbofM_X9myNE8RlY-E1MpLjS5VVRRoqpJLyO-UFUNMxdl9bBNeto5GYCgDt6xbYoc9jCgOe30LdF20Gvzqx9o-krAog1_nnZj2cO9EEyRq4BJXBezEwrYYZ-KjS_Iq_JGiXmt_8-WEfQw?key=wlreC3UtJanLEHo7mIIXPw)

Removing group execute permissions for the “drafts” directory:  
![](https://lh7-rt.googleusercontent.com/docsz/AD_4nXfJ7FZe831X1tcvzNILM490ZDCBCTYe7-6w0qRDUJHGjKGhGlFYEyDaa17nxDX1Ejrd7DeNJYuAwW3Fj67PBrrXybmuRt3hbqz2cH0ksuI2sqFneYl3rFTGWBckiOPfeK0NEF2eGI3wlgvYdiWWplg8cV2j?key=wlreC3UtJanLEHo7mIIXPw)

# Summary
This guide covered:
- Using the linux command line to check file permissions
- Using the linux command line to change file permissions
- Using the linux command line to change directory permissions
