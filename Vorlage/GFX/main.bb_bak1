;BFont Beispiel incl. 2 Bitmap-Fonts.
;(c) 2003 Christian Tietze
;
;GNU GPL spare ich mir hierbei mal, weil der 
;Vermerk länger ausfallen würde, als der Code
;selber. Trotzdem: Code könnt ihr behalten und
;verändern, solange Name erwähnt bleibt, die
;Free Software Foundation wird euch jagen, wenn
;ihr den Kram in eine NICHT GPL-Abhängige
;Software stecke etc.
;
;  http://www.gnu.org/licenses/licenses.html#TOCLGPL
;Die 'GNU GPL.txt' habt ihr auch in der Zip, also war's
;das erstmal.



Graphics 640, 480, 0, 2
SetBuffer BackBuffer()


;Bitmap-Font in S/W
font = LoadAnimImage("font.bmp", 6, 6, 0, 59)

;Reihenfolge der Zeichen schonmal hier definieren
set$ = "!" + Chr$(34) + "#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ "


;ClsColor für netten Hintergrund setzen
ClsColor 0, 0, 0


While Not KeyHit(1)
	Cls
	
	;Schriften anzeigen
	BFont("DivineDominion",0,0,set$,font)
	BFont("Tutorien",0,6,set$,font)
	BFont("Galerie",0,12,set$,font)
	BFont("Projekte",0,18,set$,font)
	BFont("Texte",0,24,set$,font)
	BFont("Main",0,30,set$,font)
	BFont("Downloads",0,36,set$,font)
	
	;Tada.
	
	Flip
Wend
End


;BFont()
;Parameter:
;	STRING	Value 	- Text, der angezeigt wird
;	INT		X|Y		- Koordinaten
;	STRING	Set		- Reihenfolge der Zeichen in der Font
;	HANDLE	Fnt		- Image Handle der Bitmap
Function BFont(Value$, X%, Y%, Set$, Fnt)
	While value$ <> ""
		Lang% = Len(Value$)
		Buchstabe$ = Upper$(Left$(value$, 1))
		
		;[Anm.: Upper$() funktioniert mit Umlauten scheinbar nicht.
		;Deswegen keine benutzt und eingebaut.]
		
		Frm% = Instr(Set$, Buchstabe$) - 1

		DrawImage Fnt, X% + count% * 6, Y%, Frm%
		
		;Ausgabestring vorne um ein Zeichen beschneiden,
		;Zähler erhöhen.
		Value$ = Right(Value$, Lang% - 1)
		Count% = Count% + 1
	Wend
End Function