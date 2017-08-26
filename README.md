# Shell bot for [minitroopers.com][minitroopers.com]

A simple CLI shell script that uses `curl` to play [minitroopers][minitroopers.com] for you.

## Features

* Battles (x3)
  * Choose at random
  * Or target your favourite army

* Missions (x3)

* Raids (as long as you have recruits)

* Prints out your money and how much you need for the next upgrade of your first trooper (after all operations have completed).

## Installation

This is a classic shell script, so you're free to download it wherever you like. **Just hit the green "[download][download]" button up above.**
Then unpack the .zip wherever you want.

The most important file is of course the `troopers.sh` which is the executable script. The rest of the files are just configuration files and, although not essential, are useful to customise the behaviour of the script.

## Usage

### Run

`cd` into the installation directory (let's assume it's `~/minitroopers.com`)

``` sh
cd ~/minitroopers.com
```

then call the script

``` sh
./troopers.sh <login> [<password>] [<friend>]
```

where `<login>` is the name of your army (e.g. if you connect to *myawesomearmy*.minitroopers.com then your login is `myawesomearmy`), `<password>` is your password (if you don't have one, then you can leave blank, or if you want to specify a `<friend>` in-line as well, then put `''`), and `<friend>` is the name of the army to attack for your battles (optional).

### Configure

The `troopers.cfg` file is the configuration file where you can customise the behaviour of the script. By changing the variables inside this file, you can customise :

* The *culture* which is the version of the site you want to use (currently either minitroopers.*com* or minitroopers.*fr*)

* The default army to attack (what to do if you don't specify the `<friend>` when calling the script)

* When to print the amount of money when the script is done

For more information on how to customise the script with the `troopers.cfg` file, please refer to the comments inside the file itself.

## About

There is a number of other bots for [minitroopers.com][minitroopers.com] that do basically the same thing.

This one tries to keep it concise and straight-forward yet full-featured with simple and well-known tools such as `shell`, `curl`, or `grep`.

[minitroopers.com]: http://bl77.minitroopers.com
[download]: https://github.com/alter/minitroopers.com/archive/master.zip