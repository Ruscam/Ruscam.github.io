---
title: "Reverse Engineering CAN Bus Telemetry: Finding a Drone's Maximum Altitude"
description: "Step-by-step walkthrough analyzing CAN bus data to extract altitude values from drone telemetry"
date: 2025-06-05
categories: [CTF Problem Writeup]
tags: [thotcon, ctf, writeup, wireshark, python, linux, can]
---
## Introduction
In this industrial control systems (ICS) challenge, we analyze a CAN bus packet capture from a drone to determine its maximum flight altitude. This write-up demonstrates:
- **Protocol Analysis**: Filtering CAN bus traffic in Wireshark
- **Data Forensics**: Extracting and parsing hexadecimal telemetry data
- **Binary Interpretation**: Converting raw bytes to floating-point values
- **Automation**: Scripting the solution in Python
 
I will do my best to explain these skills and my thought process that lead to my answer. A basic understanding of the Linux command line and python are helpful, but not necessary. 
## Prompt
```
 ICS - Hard

500

We have captured a protocol dump from an enemy drone. We need to determine the maximum
height it reaches during flight before reaching its target. Download drone.cap and analyze it.

There is some additional information we recovered from a print out in the enemy's lab:
'speed': 0x100, 'rpm': 0x101, 'altimeter': 0x102, 'x_axis': 0x200, 'y_axis': 0x201,
'z_axis': 0x202

The flag will be the maximum height in meters that the drone reached in the format 
FLAG{NN.nn} for example FLAG{25.25}.

Good luck!
```

The original problem and packet capture can be found at: [https://asmb1337.hacknwa.org/challenges#ICS%20-%20Hard-13](https://asmb1337.hacknwa.org/challenges#ICS%20-%20Hard-13)
## CAN
The CAN (Controller Area Network) protocol, often seen in cars and industrial automation, is seeing adoption for other applications such as drones and 3D printers. It is half duplex protocol, meaning that it can send and receive data, but only perform one of these actions at a time. CAN offers decentralized communication with error correction for sending serialized data across a network. Data is in 32 bit, 64 bit, or 127 bit increments. CAN is a reliable, cost effective, and efficient protocol, which is why it's often used in automotive or industrial contexts.
## Wireshark
Download drone.cap from the CTF prompt and open the `.cap` file in Wireshark.
![Image]({{ site.baseurl }}/assets/images/posts/2025-06-05/Screenshot_2025-06-03_21_17_21 1.png)

The source, destination, and length columns are irrelevant to the problem. 
![Image]({{ site.baseurl }}/assets/images/posts/2025-06-05/Screenshot_2025-06-04_13-59-43.png)

Expand the Frame 2, Controller Area Network ID, and Data sections of the packets
![Image]({{ site.baseurl }}/assets/images/posts/2025-06-05/Screenshot_2025-06-03_21_23_25.png)

The prompt explains the altimeter label is 0x102. Find a packet with the 0x102 label, right click it, and apply a filter to only display packets with a 0x102 label.
![Image]({{ site.baseurl }}/assets/images/posts/2025-06-05/Screenshot_2025-06-03_21-27-04.png)

Now only packets with the 0x102 label should be displayed
![Image]({{ site.baseurl }}/assets/images/posts/2025-06-05/Screenshot_2025-06-03_21-28-26.png)

Verify the filter by looking at the displayed packet number is the bottom right corner: "Displayed: 200 (16.7%)"
![Image]({{ site.baseurl }}/assets/images/posts/2025-06-05/Screenshot_2025-06-03_21-28-07.png)

Look at the data values
![Image]({{ site.baseurl }}/assets/images/posts/2025-06-05/Screenshot_2025-06-03_21_23_25 1.png)

Right click on data, and click "Apply As Column"
![Image]({{ site.baseurl }}/assets/images/posts/2025-06-05/Screenshot_2025-06-03_21-30-39.png)

Now there should be a column of the data from the 0x102 label
![Image]({{ site.baseurl }}/assets/images/posts/2025-06-05/Screenshot_2025-06-03_21-31-22.png)

File > Export Packet Dissections > as CSV...
![Image]({{ site.baseurl }}/assets/images/posts/2025-06-05/Screenshot_2025-06-03_21-34-28.png)

Name the file and verify there is data in the file
![Image]({{ site.baseurl }}/assets/images/posts/2025-06-05/Screenshot_2025-06-03_21-35-45.png)
## Data processing
Check file:
```shell
┌──(ruscam㉿kali)-[~]
└─$ ls altimeter-packets.csv   
altimeter-packets.csv

┌──(ruscam㉿kali)-[~]
└─$ cat altimeter-packets.csv 
"No.","Time","Protocol","Data","Info"
"3","0.000026","CAN","feffc73600000000","ID: 258 (0x102), Length: 8"
"9","0.100255","CAN","c4dbfd3e00000000","ID: 258 (0x102), Length: 8"
...
"1185","19.768974","CAN","0000000000000000","ID: 258 (0x102), Length: 8"
"1191","19.869451","CAN","0000000000000000","ID: 258 (0x102), Length: 8"
"1197","19.969776","CAN","0000000000000000","ID: 258 (0x102), Length: 8"
```
Note: file contents shortened for brevity. Actual file is about 200 lines long

We'll want to work with just the data without the other elements. Isolate the relevant data with the cut command and write the isolated data to a file. In this example the file name is "data"
`cat altimeter-packets.csv | cut -d'"' -f8 >> data`

Breakdown of command:
`cat altimeter-packets.csv` - `cat` displays the output of a file.
 `|`  - the pipe takes the output of one command and passes it as the input to another command.
`cut -d'"' -f8` - 
The `cut` command will take a file, cut it up, and output the results based on the flags:
The `-d` flag specifies the delimiter. This is the symbol the program will treat as the dotted line to cut along.
The `-f` flag species which field to display. In this case, `-f8` is the 8th field from the left after cutting the line up, which will be displayed.

Some other examples to better illustrate how this works:
```shell
┌──(ruscam㉿kali)-[~]
└─$ cat altimeter-packets.csv| cut -d'"' -f2 | head
No.
3
9
15
21
27
33
39
45
51
┌──(ruscam㉿kali)-[~]
└─$ cat altimeter-packets.csv| cut -d'"' -f4 | head
Time
0.000026
0.100255
0.200707
0.300905
0.401109
0.501306
0.601516
0.701702
0.801977

┌──(ruscam㉿kali)-[~]
└─$ cat altimeter-packets.csv| cut -d'"' -f8 | head
Data
feffc73600000000
c4dbfd3e00000000
4fa67b3f00000000
18bdba3f00000000
355ff63f00000000
7b5b184000000000
60e3344000000000
7fc5504000000000
aa086c4000000000
```
Note: in these examples the `head` command takes input and only displays the first few (10) lines of what was input.

` >> ` takes the output of a command and appends it to a file. If the file does not exit, the file will be created. In this example, we are creating a file called data to work with.

```shell
┌──(ruscam㉿kali)-[~]
└─$ cat altimeter-packets.csv | cut -d'"' -f8 >> data

┌──(ruscam㉿kali)-[~]
└─$ cat data                                         
Data
feffc73600000000
c4dbfd3e00000000
4fa67b3f00000000
...
000000000000000
0000000000000000
0000000000000000
```
Note: file contents shortened for brevity.

To clean up the data file and make the data more homogeneous, delete the first line that reads "data" so the file only contains our data with no header. This header won't be necessary from this point onward. 
```shell
┌──(ruscam㉿kali)-[~]
└─$ tail -n +2 altimeter-packets.csv | cut -d'"' -f8 > data

┌──(ruscam㉿kali)-[~]
└─$ cat data                                         
feffc73600000000
c4dbfd3e00000000
4fa67b3f00000000
...
000000000000000
0000000000000000
0000000000000000
```
The `tail` command outputs the last lines of a file. The `-n` flag displays the last number of files, but the '+2' counts from the top of the file. Essentially displays the whole file starting from the second from the first line, which is a roundabout way of saying "remove the first line."
## Scripting
To get the answer / flag, this short python script can be used:
```python
import struct

def convert(line):
    bytes_data = bytes.fromhex(line)[:4]
    float_value = struct.unpack('<f', bytes_data)[0] 
    #print(f"{float_value:.2f}")
    return float_value

max_height = 0.0
with open("data", "r") as f:
    for line in f:
        float_value = convert(line)
        if float_value > max_height:
            max_height = float_value 
print(f"FLAG{{{max_height:.2f}}}")
```
I'll explain how I came to this script and my general thought process.

Looking at an excerpt from the data file:
```
feffc73600000000
c4dbfd3e00000000
4fa67b3f00000000
18bdba3f00000000
355ff63f00000000
7b5b184000000000
60e3344000000000
7fc5504000000000
aa086c4000000000
a551834000000000
```
We may notice a few things about this data:
1. the data appears to be in hexadecimal (hex) notation
2. there appears to be padding

It might be better to think of the data like this:
```
fe ff c7 36 00000000
c4 db fd 3e 00000000
4f a6 7b 3f 00000000
18 bd ba 3f 00000000
35 5f f6 3f 00000000
7b 5b 18 40 00000000
60 e3 34 40 00000000
7f c5 50 40 00000000
aa 08 6c 40 00000000
a5 51 83 40 00000000
```

Let's open a python shell and start playing with data:
```python
┌──(ruscam㉿kali)-[~]
└─$ python          
Python 3.13.3 (main, Apr 10 2025, 21:38:51) [GCC 14.2.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> data = "feffc73600000000"
```
but right now, the variable named "data" isn't actually hex data, it's the string `"feffc73600000000"`

To get real hex data, the bytes.fromhex() method can be used:
```python
>>> bytes_data = bytes.fromhex(data)
>>> print(bytes_data)
b'\xfe\xff\xc76\x00\x00\x00\x00'  
```

Now there is a variable that contains actual bytes that the initial hex data represents. 

Let's take a closer look at how `bytes.fromhex()` works:
`bytes.fromhex()` takes a string of ASCII that represents hexadecimal. The hex must be in pairs of two (it takes 2 characters from 0-9,A-F to represent a single byte). Any white space will be ignored (so `"feffc736"` is treated the same as `"fe ff c7 36"`).

`bytes.fromhex()` returns an object in python called "bytes". Python's documentation says these are "immutable sequences of single bytes." In python the bytes object type is displayed in the interactive shell with a leading `b` prefix and is surrounded by single quotes `'`, double quotes `"`, or triple quotes `'''`. We can essentially think of this as "real binary" represented in hex, as opposed to ASCII that looks like hex.

That looks better, but we still have that padding to deal with. While I'm in the interactive shell, I'll fix that. Using using the `[:4]` notation specifies to use the first 4 bytes of our sequence and ignore the rest, which was our trailing zero padding:

```python
>>> bytes_data = bytes_data[:4]
>>> print(bytes_data)
b'\xfe\xff\xc76'
```

Now we need to convert this binary hexadecimal data into a human readable number. The prompt told us to round to decimal places of accuracy, so it seems reasonable to assume that a float is the correct data type.

We can do this by importing `struct` in python and using the `struct.unpack` method.
```python
>>> import struct
>>> struct.unpack('<f', bytes_data)
(5.960463568044361e-06,)
```

Let's break down what is happening in this line: `struct.unpack('<f', bytes_data)`
`struct.unpack()`
`struct.unpack` will unpack the buffer we provide it depending on the type of format string we give it.

`bytes_data` - the data that will be processed by the type of formatting specified in the formatting string.

`<f` - the format string we're passing to `unpack`. The `f` is for the float option, which interprets the buffer as a IEEE 754 single-precision float. This format is a way of storing numbers with 32 bits of binary: 
- 1 bit for the sign
- 8 bits for the exponent
- 23 bits for the significand. 
Note: A significand is the number being multiplied in scientific notation. If the number is 103.5x10^3, 103.5 is the significand. 

`<` specifies the use of little-endian formatting. If the `<` is committed, the method will default to whatever your system normally uses, which is probably little-endian. I have little-endian specified to be verbose and increase the portability of the script, but it probably isn't necessary.
### A quick aside about endiannes
Endianness is the order computers use to store bytes. Sometimes this concept is refereed to as byte-order. Think of it like reading direction in human languages: the information is still the same, but the data is arranged differently. 
The two main standards are:
Big-endian
- stores the most significant bit (MSB) first
- usually the standard for sending data across a network
- Example: `0x36 0xc7 0xff 0xfe`
Little-endian
- stores the least significant bit (LSB) first
- usually used in most processor architectures like x86 or ARM CPUs
- Example: `0xfe 0xff 0xc7 0x36`
If the wrong endianness is chosen when unpacking the binary `bytes_data` variable, the values will be completely wrong. For an example of how wrong the resulting data is, see the section at the end of this write up "Doing things wrong."

`struct.unpack('<f', bytes_data)` doesn't actually return a float. It returns a single-element tuple containing a float as the first element. To get a cleaner result we can specify to assign a variable to the first element with the `[0]` notation. We'll also assign it to a variable to display and format later.
```python
>>> float_value = struct.unpack('<f', bytes_data)[0] # 5.960463568044361e-06 (~0.00000596)
>>> print(f"{float_value:.2f}") # Format to to decimal places
0.00
```

This value is actually basically zero. Looking back at the original data, that might not be very surprising:
```shell
"No.","Time","Protocol","Data","Info"
"3","0.000026","CAN","feffc73600000000","ID: 258 (0x102), Length: 8"
"9","0.100255","CAN","c4dbfd3e00000000","ID: 258 (0x102), Length: 8"
```

Given that this is only the third packet in the packet capture, and we're getting a altitude of zero, it's possible the drone hadn't taken off yet or was still initializing. Applying that same data processing to other numbers gets us results that seem promising:
```python
>>> data = "72f5c84000000000"
>>> bytes_data = bytes.fromhex(data)[:4]
>>> float_value = struct.unpack('f', bytes_data)[0]
>>> print(f"{float_value:.2f}")
6.28
```

Now all we have to do is perform this calculation on every line in the data file, add some logic to compare values to find the largest, and display result. Putting that into a script, we get:
```python
import struct

def convert(line):
    bytes_data = bytes.fromhex(line)[:4]
    float_value = struct.unpack('<f', bytes_data)[0] 
    #print(f"{float_value:.2f}")
    return float_value

max_height = 0.0 # set an initial max height
with open("data", "r") as f: # read the data file
    for line in f: # look at the string on each line
        float_value = convert(line) # convert that string into a float value
        if float_value > max_height: # check to see if our value is the new highest
            max_height = float_value # update max height if our tested value is the highest in the data set so far
print(f"FLAG{{{max_height:.2f}}}") # display data in flag format
```
I took the conversion steps done above to take the raw strings from the data file and convert them to floats, and placed that code in it's own self contained function. The code at the bottom takes care of reading the data file and finding the maximum height

Running this script we get our flag nicely formatted for us
`FLAG{XX.XX}`

Note: actual value redacted. Try it out for yourself to get the answer! 

If we want to verify our logic, we could add some print statements and give the output a quick overview:

```python
import struct

def convert(line):
    bytes_data = bytes.fromhex(line)[:4]
    float_value = struct.unpack('<f', bytes_data)[0] 
    print(f"{float_value:.2f}")
    return float_value

max_height = 0.0
with open("data", "r") as f:
    for line in f:
        float_value = convert(line)
        if float_value > max_height:
            max_height = float_value 
print(f"FLAG{{{max_height:.2f}}}")
```

Now our output looks something like this:
```shell
0.00
0.50
0.98
1.46
1.92
...
2.23
1.77
1.30
0.82
0.33
0.00
FLAG{XX.XX}
```
Note: output abbreviated and redacted

Looking at the data now, we can see the drone took off, reached it's maximum height, and came back down.

## Doing things wrong
If for some reason we incorrectly ran our script treating the data as big endian, our output looks like this:
```
-169993750625060287739375631146286055424.00
-1759.91
5586189824.00
0.00
0.00
1137604860452015803655959416942886912.00
130974247313142185984.00
nan
-0.00
...
-140240403546456981504.00
-392.34
-551816298678452224.00
-0.00
-1878196673644117351028265844736.00
288163949181919850416126644191232.00
0.00
0.00
FLAG{296029718869860761292316319841907638272.00}
```
Note: file contents shortened for brevity.

This poor drone would have to move very quickly to move from 0.00 altitude to 1137604860452015803655959416942886912, to 130974247313142185984, to nan, to -0.00. This data is obviously wrong. When data formats aren't obvious in a CTF challenge, it can be useful to try both formats, especially if one is producing consistently impossible data.

## Conclusion
In this challenge, we both demonstrated real-world cyber security skills and demonstrated an understanding of computer science theory:
##### Protocol analysis
Analyzed a CAN bus packet capture.
Filtered and exported altimeter data from packets containing a 0x102 label.
##### Data parsing 
Used a Bash and Linux command line tools (cut and tail) to isolate and normalize data.
##### Binary Interpretation
Decoded single-precision floating-point values from binary data to float values, accounting for CAN bus conventions.
##### Automation / Scripting
Wrote a python script to convert hex payloads into float values and found the maximum value.

## Further reading
CAN bus protocol:

[https://en.wikipedia.org/wiki/CAN_bus](https://en.wikipedia.org/wiki/CAN_bus)

Wireshark references:

[https://www.wireshark.org/docs/wsug_html_chunked/ChapterIntroduction.html](https://www.wireshark.org/docs/wsug_html_chunked/ChapterIntroduction.html)

[https://wiki.wireshark.org/DisplayFilters](https://wiki.wireshark.org/DisplayFilters)

Bash output redirection and pipes:

[https://homepages.uc.edu/~thomam/Intro_Unix_Text/IO_Redir_Pipes.html](https://homepages.uc.edu/~thomam/Intro_Unix_Text/IO_Redir_Pipes.html)

Python documentation:

[https://docs.python.org/3/library/stdtypes.html#bytes-objects](https://docs.python.org/3/library/stdtypes.html#bytes-objects)

[https://docs.python.org/3/library/functions.html#func-bytes](https://docs.python.org/3/library/functions.html#func-bytes)

[https://www.geeksforgeeks.org/bytes-fromhex-method-python/](https://www.geeksforgeeks.org/bytes-fromhex-method-python/)

[https://docs.python.org/3/library/struct.html](https://docs.python.org/3/library/struct.html)

Floating point format and Endianness:

[https://developer.mozilla.org/en-US/docs/Glossary/Endianness](https://developer.mozilla.org/en-US/docs/Glossary/Endianness)

[https://en.wikipedia.org/wiki/Endianness](https://en.wikipedia.org/wiki/Endianness)

[https://en.wikipedia.org/wiki/Single-precision_floating-point_format](https://en.wikipedia.org/wiki/Single-precision_floating-point_format)
