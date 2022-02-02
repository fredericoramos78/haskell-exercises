# Training on Persistent & Yesod

This project was designed to get an intro into Persistent/Esqueleto & (as a second pass) Yesod.

## Project structure

At the moment I worked on this readme file, the project had 2 executables and 1 library. I tried using internal named libraries but 
for whatever reason Cabal/Stack didn't recognized it so I reverted back to the regular single public library approach.

One executable works as a cmdline and the other is the skel of a REST based API, returning Json. I don't intend to work on a UI version
of the web executable since we don't use that (at least looks like we don't!) here at Mercury.

The code is organized like this:
 * `app` is the library with code shared by both the cmdline and web executables
 * `web` is the web executable
 * `src` holds the cmdline version

## DB setup

The code is expecting that a postgreSQL database named `lunchdb` is running in your local machine. The full conn. string used is `postgresql://lunch:pass123@localhost:5432/lunchdb` and 
that's configured manually on both `src/Main.hs` and `web/Main.hs`.


## How to run

To start the cmdline executable use this command:

`stack ghci --main-is lunchline:exe:lunchline-exe` 

And for the web version - it will start a HTTP server at port 3000:

`stack ghci --main-is lunchline:exe:lunchline-web` 

The implemented URIs for the web executable can be found at `web/Main.hs`.

## Version history 

### v0 - functional via cmdline

#### v0.2
 - [x] create table to hold weekly budget 
 - [x] read weekly budget from db
 - [x] allow for updating weekly budget
 - [x] update weekly budget should work as `upsert`

#### v0.3
 - [x] read list of items added & remaining budget 
 - [x] allow for adding new items

#### v0.4
- [x] break code into modules
- [x] alert when it's Monday to remember reset

#### v0.5
 - [x] reset week

#### v0.6
- [x] move into a more persistent storage like postgresql
- [x] allow configuring which day to alert on reset

### v1 - exposed via HTTP/REST 

#### v1.1 
- [x] list config & budget 
- [x] list weekly summary

#### v1.2 
- [x] challenges from Jan 27th

#### v1.3
- [x] list weekly items
- [ ] list spend history
- [ ] check reset week alert

#### v1.4
- [ ] add items (return will be similar to weekly summary)
- [ ] trigger weekly reset 
- [ ] update budget 

