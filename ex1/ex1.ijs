labelCounter =: 0
NB. Read full file content
readFile =: 3 : 0
  1!:1 < y
)

NB. Split text into lines
SplitLines =: 3 : 0
  <;._2 y
)

NB. Global variables
inputFile =: ''
outputFile =: ''

NB. Append text to output file
WriteText =: 3 : 0
  y 1!:3 < outputFile
)

NB. Get file name without extension
GetFileTitle =: 3 : 0
  parts =. <;._1 '/' , y
  fullName =. > {: parts
  _3 }. fullName
)

NB. Translate push constant x
TranslatePushConstant =: 3 : 0
  value =. y

  result =. '@',value,LF
  result =. result , 'D=A',LF
  result =. result , '@SP',LF
  result =. result , 'A=M',LF
  result =. result , 'M=D',LF
  result =. result , '@SP',LF
  result =. result , 'M=M+1',LF

  result
)

NB. Translate add command
TranslateAdd =: 3 : 0
  result =. '@SP' , LF
  result =. result , 'AM=M-1' , LF
  result =. result , 'D=M' , LF
  result =. result , 'A=A-1' , LF
  result =. result , 'M=M+D' , LF
  result
)

NB. Translate sub command
TranslateSub =: 3 : 0
  result =. '@SP' , LF
  result =. result , 'AM=M-1' , LF
  result =. result , 'D=M' , LF
  result =. result , 'A=A-1' , LF
  result =. result , 'M=M-D' , LF
  result
)

NB. Translate neg command
TranslateNeg =: 3 : 0
  result =. '@SP' , LF
  result =. result , 'A=M-1' , LF
  result =. result , 'M=-M' , LF
  result
)

NB. Translate and command
TranslateAnd =: 3 : 0
  result =. '@SP' , LF
  result =. result , 'AM=M-1' , LF
  result =. result , 'D=M' , LF
  result =. result , 'A=A-1' , LF
  result =. result , 'M=M&D' , LF
  result
)

NB. Translate or command
TranslateOr =: 3 : 0
  result =. '@SP' , LF
  result =. result , 'AM=M-1' , LF
  result =. result , 'D=M' , LF
  result =. result , 'A=A-1' , LF
  result =. result , 'M=M|D' , LF
  result
)

NB. Translate not command
TranslateNot =: 3 : 0
  result =. '@SP' , LF
  result =. result , 'A=M-1' , LF
  result =. result , 'M=!M' , LF
  result
)

NB. Translate eq command
TranslateEq =: 3 : 0
  trueLabel =. 'TRUE' , (": labelCounter)
  endLabel =. 'END' , (": labelCounter)
  labelCounter =: labelCounter + 1

  result =. '@SP' , LF
  result =. result , 'AM=M-1' , LF
  result =. result , 'D=M' , LF
  result =. result , 'A=A-1' , LF
  result =. result , 'D=M-D' , LF

  result =. result , '@' , trueLabel , LF
  result =. result , 'D;JEQ' , LF

  result =. result , '@SP' , LF
  result =. result , 'A=M-1' , LF
  result =. result , 'M=0' , LF

  result =. result , '@' , endLabel , LF
  result =. result , '0;JMP' , LF

  result =. result , '(' , trueLabel , ')' , LF
  result =. result , '@SP' , LF
  result =. result , 'A=M-1' , LF
  result =. result , 'M=-1' , LF

  result =. result , '(' , endLabel , ')' , LF
  result
)

NB. Translate gt command
TranslateGt =: 3 : 0
  trueLabel =. 'TRUE' , (": labelCounter)
  endLabel =. 'END' , (": labelCounter)
  labelCounter =: labelCounter + 1

  result =. '@SP' , LF
  result =. result , 'AM=M-1' , LF
  result =. result , 'D=M' , LF
  result =. result , 'A=A-1' , LF
  result =. result , 'D=M-D' , LF

  result =. result , '@' , trueLabel , LF
  result =. result , 'D;JGT' , LF

  result =. result , '@SP' , LF
  result =. result , 'A=M-1' , LF
  result =. result , 'M=0' , LF

  result =. result , '@' , endLabel , LF
  result =. result , '0;JMP' , LF

  result =. result , '(' , trueLabel , ')' , LF
  result =. result , '@SP' , LF
  result =. result , 'A=M-1' , LF
  result =. result , 'M=-1' , LF

  result =. result , '(' , endLabel , ')' , LF
  result
)

NB. Translate lt command
TranslateLt =: 3 : 0
  trueLabel =. 'TRUE' , (": labelCounter)
  endLabel =. 'END' , (": labelCounter)
  labelCounter =: labelCounter + 1

  result =. '@SP' , LF
  result =. result , 'AM=M-1' , LF
  result =. result , 'D=M' , LF
  result =. result , 'A=A-1' , LF
  result =. result , 'D=M-D' , LF

  result =. result , '@' , trueLabel , LF
  result =. result , 'D;JLT' , LF

  result =. result , '@SP' , LF
  result =. result , 'A=M-1' , LF
  result =. result , 'M=0' , LF

  result =. result , '@' , endLabel , LF
  result =. result , '0;JMP' , LF

  result =. result , '(' , trueLabel , ')' , LF
  result =. result , '@SP' , LF
  result =. result , 'A=M-1' , LF
  result =. result , 'M=-1' , LF

  result =. result , '(' , endLabel , ')' , LF
  result
)

NB. Map segment to base symbol
SegmentBase =: 3 : 0
  if. y -: 'local' do. 'LCL'
  elseif. y -: 'argument' do. 'ARG'
  elseif. y -: 'this' do. 'THIS'
  elseif. y -: 'that' do. 'THAT'
  else. ''
  end.
)

NB. Translate push segment i
TranslatePushSegment =: 3 : 0
  'segment index' =. y
  base =. SegmentBase segment

  result =. '@' , base , LF
  result =. result , 'D=M' , LF
  result =. result , '@' , index , LF
  result =. result , 'A=D+A' , LF
  result =. result , 'D=M' , LF
  result =. result , '@SP' , LF
  result =. result , 'A=M' , LF
  result =. result , 'M=D' , LF
  result =. result , '@SP' , LF
  result =. result , 'M=M+1' , LF

  result
)

NB. Translate pop segment i
TranslatePopSegment =: 3 : 0
  'segment index' =. y
  base =. SegmentBase segment

  result =. '@' , base , LF
  result =. result , 'D=M' , LF
  result =. result , '@' , index , LF
  result =. result , 'D=D+A' , LF
  result =. result , '@R13' , LF
  result =. result , 'M=D' , LF

  result =. result , '@SP' , LF
  result =. result , 'AM=M-1' , LF
  result =. result , 'D=M' , LF

  result =. result , '@R13' , LF
  result =. result , 'A=M' , LF
  result =. result , 'M=D' , LF

  result
)

NB. Push temp
TranslatePushTemp =: 3 : 0
  index =. ". y
  addr =. 5 + index

  result =. '@' , (": addr) , LF
  result =. result , 'D=M' , LF
  result =. result , '@SP' , LF
  result =. result , 'A=M' , LF
  result =. result , 'M=D' , LF
  result =. result , '@SP' , LF
  result =. result , 'M=M+1' , LF
  result
)

NB. Pop temp
TranslatePopTemp =: 3 : 0
  index =. ". y
  addr =. 5 + index

  result =. '@SP' , LF
  result =. result , 'AM=M-1' , LF
  result =. result , 'D=M' , LF
  result =. result , '@' , (": addr) , LF
  result =. result , 'M=D' , LF
  result
)

NB. Pointer name
PointerName =: 3 : 0
  if. '0' = {. y do.
    'THIS'
  else.
    'THAT'
  end.
)

NB. Push pointer
TranslatePushPointer =: 3 : 0
  base =. PointerName y

  result =. '@' , base , LF
  result =. result , 'D=M' , LF
  result =. result , '@SP' , LF
  result =. result , 'A=M' , LF
  result =. result , 'M=D' , LF
  result =. result , '@SP' , LF
  result =. result , 'M=M+1' , LF
  result
)

NB. Pop pointer
TranslatePopPointer =: 3 : 0
  base =. PointerName y

  result =. '@SP' , LF
  result =. result , 'AM=M-1' , LF
  result =. result , 'D=M' , LF
  result =. result , '@' , base , LF
  result =. result , 'M=D' , LF
  result
)

NB. Push static
TranslatePushStatic =: 3 : 0
  index =. y
  name =. (GetFileTitle inputFile) , '.' , index

  result =. '@' , name , LF
  result =. result , 'D=M' , LF
  result =. result , '@SP' , LF
  result =. result , 'A=M' , LF
  result =. result , 'M=D' , LF
  result =. result , '@SP' , LF
  result =. result , 'M=M+1' , LF
  result
)

NB. Pop static
TranslatePopStatic =: 3 : 0
  index =. y
  name =. (GetFileTitle inputFile) , '.' , index

  result =. '@SP' , LF
  result =. result , 'AM=M-1' , LF
  result =. result , 'D=M' , LF
  result =. result , '@' , name , LF
  result =. result , 'M=D' , LF
  result
)

NB. Process one line
ProcessLine =: 3 : 0
  clean =. y
  clean =. clean -. CR

  NB. Remove inline comments
  commentPos =. clean ss '//'
  if. 0 < # commentPos do.
    clean =. ({. commentPos) {. clean
  end.
  clean =. dtb clean

  NB. Skip empty line
  if. 0 = # clean do.
    ''
    return.
  end.

  words =. ;: clean
  command =. > 0 { words

  NB. push
  if. command -: 'push' do.
    segment =. > 1 { words
    value   =. > 2 { words

    if. segment -: 'constant' do.
      TranslatePushConstant value

    elseif. segment -: 'local' do.
      TranslatePushSegment segment ; value

    elseif. segment -: 'argument' do.
      TranslatePushSegment segment ; value

    elseif. segment -: 'this' do.
      TranslatePushSegment segment ; value

    elseif. segment -: 'that' do.
      TranslatePushSegment segment ; value

    elseif. segment -: 'temp' do.
      TranslatePushTemp value

    elseif. segment -: 'pointer' do.
      TranslatePushPointer value

    elseif. segment -: 'static' do.
      TranslatePushStatic value

    else.
      ''
    end.

  NB. pop
  elseif. command -: 'pop' do.
    segment =. > 1 { words
    value   =. > 2 { words

    if. segment -: 'local' do.
      TranslatePopSegment segment ; value

    elseif. segment -: 'argument' do.
      TranslatePopSegment segment ; value

    elseif. segment -: 'this' do.
      TranslatePopSegment segment ; value

    elseif. segment -: 'that' do.
      TranslatePopSegment segment ; value

    elseif. segment -: 'temp' do.
      TranslatePopTemp value

    elseif. segment -: 'pointer' do.
      TranslatePopPointer value

    elseif. segment -: 'static' do.
      TranslatePopStatic value

    else.
      ''
    end.

  NB. arithmetic
  elseif. command -: 'add' do.
    TranslateAdd ''

  elseif. command -: 'sub' do.
    TranslateSub ''

  elseif. command -: 'neg' do.
    TranslateNeg ''

  elseif. command -: 'and' do.
    TranslateAnd ''

  elseif. command -: 'or' do.
    TranslateOr ''

  elseif. command -: 'not' do.
    TranslateNot ''

  elseif. command -: 'eq' do.
    TranslateEq ''

  elseif. command -: 'gt' do.
    TranslateGt ''

  elseif. command -: 'lt' do.
    TranslateLt ''

  else.
    ''
  end.
)

NB. Process one vm file
ProcessFile =: 3 : 0
  lines =. <;._2 (readFile y) , LF

  for_line. lines do.
    current =. > line
    asm =. ProcessLine current

    if. 0 < # asm do.
      WriteText asm
      WriteText LF
    end.
  end.
)

NB. Main program
Main =: 3 : 0
  inputFile =: y
  outputFile =: (inputFile -. '.vm') , '.asm'
  labelCounter =: 0

  '' 1!:2 < outputFile
  ProcessFile inputFile
)