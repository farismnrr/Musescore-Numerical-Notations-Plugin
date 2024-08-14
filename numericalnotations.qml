//=============================================================================
//  MuseScore
//  Music Composition & Notation
//
//  Note Names Plugin
//
//  Copyright (C) 2012 Werner Schweer
//  Copyright (C) 2013 - 2021 Joachim Schmitz
//  Copyright (C) 2014 Jörn Eichler
//  Copyright (C) 2020 Johan Temmerman
//  Copyright (C) 2024 Faris Munir Mahdi
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2
//  as published by the Free Software Foundation and appearing in
//  the file LICENCE.GPL
//=============================================================================

import QtQuick 2.2
import MuseScore 3.0

MuseScore {
   version: "1.0"
   description: "This plugin names notes as numerical notations"
   title: "Numerical Notations"
   categoryCode: "lyrics"
   thumbnailName: "numerical_notations.png"

   property real fontSizeMini: 0.7;

   function nameChord (notes, text, small) {
      var sep = "\n";   
      var oct = "";
      var name;
      for (var i = 0; i < notes.length; i++) {
         if (!notes[i].visible)
            continue 
         if (text.text) 
            text.text = sep + text.text;
         if (small)
            text.fontSize *= fontSizeMini
         if (typeof notes[i].tpc === "undefined") 
            return
         switch (notes[i].tpc) {
            case -1: name = qsTranslate("global", "♭♭4"); break;
            case  0: name = qsTranslate("global", "♭♭1"); break;
            case  1: name = qsTranslate("global", "♭♭5"); break;
            case  2: name = qsTranslate("global", "♭♭2"); break;
            case  3: name = qsTranslate("global", "♭♭6"); break;
            case  4: name = qsTranslate("global", "♭♭3"); break;
            case  5: name = qsTranslate("global", "♭♭7"); break;

            case  6: name = qsTranslate("global", "♭4"); break;
            case  7: name = qsTranslate("global", "♭1"); break;
            case  8: name = qsTranslate("global", "♭5"); break;
            case  9: name = qsTranslate("global", "♭2"); break;
            case 10: name = qsTranslate("global", "♭6"); break;
            case 11: name = qsTranslate("global", "♭3"); break;
            case 12: name = qsTranslate("global", "♭7"); break;

            case 13: name = qsTranslate("global", "4"); break;
            case 14: name = qsTranslate("global", "1"); break;
            case 15: name = qsTranslate("global", "5"); break;
            case 16: name = qsTranslate("global", "2"); break;
            case 17: name = qsTranslate("global", "6"); break;
            case 18: name = qsTranslate("global", "3"); break;
            case 19: name = qsTranslate("global", "7"); break;

            case 20: name = qsTranslate("global", "♯4"); break;
            case 21: name = qsTranslate("global", "♯1"); break;
            case 22: name = qsTranslate("global", "♯5"); break;
            case 23: name = qsTranslate("global", "♯2"); break;
            case 24: name = qsTranslate("global", "♯6"); break;
            case 25: name = qsTranslate("global", "♯3"); break;
            case 26: name = qsTranslate("global", "♯7"); break;

            case 27: name = qsTranslate("global", "♯♯4"); break;
            case 28: name = qsTranslate("global", "♯♯1"); break;
            case 29: name = qsTranslate("global", "♯♯5"); break;
            case 30: name = qsTranslate("global", "♯♯2"); break;
            case 31: name = qsTranslate("global", "♯♯6"); break;
            case 32: name = qsTranslate("global", "♯♯3"); break;
            case 33: name = qsTranslate("global", "♯♯7"); break;

            default: name = qsTr("?") + text.text; break;
         } 

         var octaveTextPostfix = [",,,,", ",,,", ",,", ",", "", "'", "''", "'''", "''''"];
         oct = octaveTextPostfix[Math.floor((notes[i].pitch / 12))];
         text.text = name + oct + text.text
         text.offsetY = -5.5
      } 
   }

   function renderGraceNoteNames (cursor, list, text, small) {
      if (list.length <= 0) 
         return text;

      for (const chord of list) {
         const newText = nameChord(chord.notes, text, small);
         if (newText.text)
            cursor.add(newText);
            newText.offsetX = chord.offsetX;
            newText.placement = cursor.voice === 1 || cursor.voice === 3 ? Placement.BELOW : undefined;
      }
      return text;
   }

   onRun: {
      curScore.startCmd()

      var cursor = curScore.newCursor();
      var startStaff;
      var endStaff;
      var endTick;
      var fullScore = false;
      cursor.rewind(1);
      
      fullScore = !cursor.segment;
      startStaff = cursor.segment ? cursor.startStaff : 0;
      endStaff = cursor.segment ? cursor.endStaff : curScore.nstaves - 1;
      endTick = cursor.segment ? cursor.tick : curScore.lastSegment.tick + 1;

      for (var staff = startStaff; staff <= endStaff; staff++) {
         for (var voice = 0; voice < 4; voice++) {
            cursor.rewind(1); 
            cursor.voice    = voice;
            cursor.staffIdx = staff;

            if (fullScore)
               cursor.rewind(0); 
            while (cursor.segment && (fullScore || cursor.tick < endTick)) {
               if (cursor.element && cursor.element.type === Element.CHORD) {
                  var text = newElement(Element.STAFF_TEXT);      
                  var leadingLifo = Array();  
                  var trailingFifo = Array(); 
                  var graceChords = cursor.element.graceNotes;
                  if (graceChords.length > 0) {
                     for (var chordNum = 0; chordNum < graceChords.length; chordNum++) {
                        var noteType = graceChords[chordNum].notes[0].noteType
                        const isTrailing = [NoteType.GRACE8_AFTER, NoteType.GRACE16_AFTER, NoteType.GRACE32_AFTER].includes(noteType);
                        isTrailing ? trailingFifo.unshift(graceChords[chordNum]) : leadingLifo.push(graceChords[chordNum]);
                     }
                  }

                  text = renderGraceNoteNames(cursor, leadingLifo, text, true)
                  var notes = cursor.element.notes;
                  nameChord(notes, text, false);

                  if (text.text)
                     cursor.add(text);

                  switch (cursor.voice) {
                     case 1: case 3: text.placement = Placement.BELOW; break;
                  }

                  if (text.text)
                     text = newElement(Element.STAFF_TEXT) 

                  text = renderGraceNoteNames(cursor, trailingFifo, text, true)
               } 
               cursor.next();
            } 
         } 
      } 
      curScore.endCmd()
      quit();
   }
}
