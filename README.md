# Pokémon Azure Wave and Rose Flame Masterproject

This project contains code for a trio of fangames made by Astralneko.

Based on Essentials v21.1.

## Scripts

The scripts no longer live in the Scripts.rxdata file. They have been extracted into separate files and placed in the Data/Scripts/ folder (and subfolders within). This makes it easier to work with other people and keep track of changes.

The scripts are loaded into the game alphanumerically, starting from the top folder (Data/Scripts/) and going depth-first. That is, all scripts in a given folder are loaded, and then each of its subfolder is checked in turn (again in alphanumerical order) for files/folders to load/check.

### Extracting and reintegrating scripts

This repo contains two script files in the main folder:

* scripts_extract.rb - Run this to extract all scripts from Scripts.rxdata into individual .rb files (any existing individual .rb files are deleted).
  * Scripts.rxdata is backed up to ScriptsBackup.rxdata, and is then replaced with a version that reads the individual .rb files and does nothing else.
* scripts_combine.rb - Run this to reintegrate all the individual .rb files back into Scripts.rxdata.
  * The individual .rb files are left where they are, but they no longer do anything.

You will need Ruby installed to run these scripts. The intention is to replace these with something more user-friendly.

