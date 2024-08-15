# **Note Names Plugin**

## **Overview**

The Note Names Plugin is a MuseScore plugin that names notes as numerical notations. This plugin is distributed under the GNU General Public License version 2.

## **Features**

-   Names notes as numerical notations (e.g. 1, ♭2, ♯3, etc.)
-   Supports various note types, including sharps, flats, and double sharps/flats
-   Can handle grace notes and trailing notes
-   Customizable font size for small notes

## **How to Use**

1. Install the plugin in MuseScore by following the instructions provided by MuseScore.
2. Select the score or section of the score you want to apply the plugin to.
3. Run the plugin by clicking on "Plugins" > "Note Names" in the MuseScore menu.
4. The plugin will automatically add numerical notations to the notes in the selected score or section.

## **Code Overview**

The plugin is written in QtQuick and uses the MuseScore 3.0 API. The code consists of two main functions:

-   `nameChord`: takes a list of notes, a text object, and a small font size flag as input. It names the notes as numerical notations and returns the named text.
-   `renderGraceNoteNames`: takes a cursor, a list of grace notes, a text object, and a small font size flag as input. It renders the grace notes as numerical notations and returns the named text.

The `onRun` function is the main entry point of the plugin. It iterates over the score, selecting each staff and voice, and applies the `nameChord` and `renderGraceNoteNames` functions to add numerical notations to the notes.

## **License**

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License version 2 as published by the Free Software Foundation and appearing in the file LICENCE.GPL.
