Graphics 640,480,0,2
Global font = LoadAnimImage("font.bmp",6,6,0,80)

Function Txt(s$)
	For i = 1 To Len(s$)
		char$ = Mid$(s$, i, 1)
		frame = Asc(char$) ;- 32
		Print frame
		DrawImage font, i*6, 100, frame
	Next
End Function

txt("test")
WaitKey()
End