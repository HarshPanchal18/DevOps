# Bandit

## Level 0

```bash
ssh bandit.labs.overthewire.org -p 2220 -l bandit0
Password: bandit0
```

If you are playing "somegame", then:
    - USERNAMES are somegame0, somegame1, ...
    - Most LEVELS are stored in /somegame/.
    - PASSWORDS for each level are stored in /etc/somegame_pass/.

## Level 1

```bash
cat readme
ZjLjTmM6FvvyRnrb2rfNWOZOTa6ip5If
```

## Level 2

```bash
cat < -
263JGJPfgU6LtdEvgfWU1XP5yac29mFx
```

## Level 3

```bash
cat "./--spaces in this filename--"
MNk8KNH3Usiio41PRUEoDFPqfxLPlSmx
```

## Level 4

```bash
cat inhere/...Hiding-From-You
2WmrDFRmJIq3IPxneAaMGhap0pFhF3NJ
```

## Level 5

```bash
cd inhere
cat ./-file07
4oQYVPkxZOOEOO5pTW81FB8j8lxXGUQw
```

## Level 6

```bash
cd inhere
ls -laRs maybehere* | grep 1033
HWasnPhtq9AVKe0dmk45nxy20cvUa6EG
```

## Level 7

```bash
find / -group bandit6
cat /var/lib/dpkg/info/bandit7.password
morbNTDkSW6jIlUc0ymOdMaLnOlFVAaj
```

## Level 8

```bash
grep millionth data.txt
dfwvzFQi4mU0wfNbFOe9RoWskMLg7eEc
```

## Level 9

```bash
sort data.txt | uniq -u
4CKMh1JI91bUIZZPXDqGanal4xvAg0JM
```

## Level 10

```bash
grep -a "=====" data.txt
FGUW5ilLVJrxX9kMYMmlN4MgbpfMiqey
```

## Level 11

```bash
cat data.txt | base64 -d
The password is dtR173fZKb0RRsDFSGsg2RWnpNVj3qRr
```

## Level 12

```bash
cat data.txt | cut -d ' ' -f4 | tr '0-9a-zA-Z' '0-9n-za-mN-ZA-M'
The password is 7x16WNeHIi5YkIhWsfFIqoognUTyj9Q4
```

## Level 13

```bash
cat data.txt
mkdir /tmp/bandit12
cd /tmp/bandit12
xxd -r /home/bandit12/data.txt passwd
ls
file passwd
passwd: gzip compressed data, was "data2.bin", last modified: Thu Oct  5 06:19:20 2023, max compression, from Unix, original size modulo 2^32 573
mv passwd passwd.gz
gunzip passwd.gz
file passwd
mv passwd passwd.bz2
bunzip2 passwd.bz2
ls
file passwd
mv passwd  passwd.gz
gunzip passwd.gz
ls
file passwd
tar -xf passwd.tar
ls
file data5.bin
mv data5.bin data5.bin.tar
tar -xf data5.bin.tar
ls
file data6.bin
mv data6.bin data6.bin.bz2
bunzip2 data6.bin.bz2
ls
file data6.bin
mv data6.bin data6.bin.tar
tar -xf data6.bin.tar
ls
file data8.bin
mv data8.bin data8.bin.gz
gunzip data8.bin.gz
ls
file data8.bin
cat data8.bin
The password is FO5dwFsc0cbaIiH0h8J2eUks2vdTDwAn
```
