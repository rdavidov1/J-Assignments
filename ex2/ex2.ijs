NB. ================================================================
NB. Project 8 VM Translator in J - syntax-safe version
NB. ================================================================

CurrentFile =: ''
CurrentFunction =: ''
inputFile =: ''
outputFile =: ''
labelCounter =: 0
callCounter =: 0

readFile =: 3 : 0
  1!:1 < y
)

WriteText =: 3 : 0
  y 1!:3 < outputFile
)

GetFileName =: 3 : 0
  parts =. <;._1 '/' , y
  fullName =. > {: parts
  dot =. fullName i. '.'
  dot {. fullName
)

GetPathTitle =: 3 : 0
  path =. y
  if. ('/' = {: path) do.
    path =. }: path
  end.
  parts =. <;._1 '/' , path
  > {: parts
)

IsVMFile =: 3 : 0
  if. 3 > # y do.
    0
  else.
    '.vm' -: _3 {. y
  end.
)

ListVMFiles =: 3 : 0
  dir =. y
  if. '/' = {: dir do.
    dir =. }: dir
  end.
  files =. 1!:0 < dir , '/*.vm'
  if. 0 = # files do.
    i. 0 0
  else.
    names =. {."1 files
    (< dir , '/') ,&.> names
  end.
)

CleanLine =: 3 : 0
  clean =. y -. CR
  clean =. clean -. LF
  mask =. '//' E. clean
  if. +./ mask do.
    where =. mask i. 1
    clean =. where {. clean
  end.
  dltb clean
)

WordsOf =: 3 : 0
  line =. y
  line =. ' ' (I. line = (9 { a.)) } line
  a: -.~ <;._1 ' ' , line
)

PushD =: 3 : 0
  r =. '@SP' , LF
  r =. r , 'A=M' , LF
  r =. r , 'M=D' , LF
  r =. r , '@SP' , LF
  r =. r , 'M=M+1' , LF
  r
)

PopToD =: 3 : 0
  r =. '@SP' , LF
  r =. r , 'AM=M-1' , LF
  r =. r , 'D=M' , LF
  r
)

TranslateAdd =: 3 : 0
  r =. '@SP' , LF
  r =. r , 'AM=M-1' , LF
  r =. r , 'D=M' , LF
  r =. r , 'A=A-1' , LF
  r =. r , 'M=D+M' , LF
  r
)

TranslateSub =: 3 : 0
  r =. '@SP' , LF
  r =. r , 'AM=M-1' , LF
  r =. r , 'D=M' , LF
  r =. r , 'A=A-1' , LF
  r =. r , 'M=M-D' , LF
  r
)

TranslateNeg =: 3 : 0
  r =. '@SP' , LF
  r =. r , 'A=M-1' , LF
  r =. r , 'M=-M' , LF
  r
)

TranslateAnd =: 3 : 0
  r =. '@SP' , LF
  r =. r , 'AM=M-1' , LF
  r =. r , 'D=M' , LF
  r =. r , 'A=A-1' , LF
  r =. r , 'M=D&M' , LF
  r
)

TranslateOr =: 3 : 0
  r =. '@SP' , LF
  r =. r , 'AM=M-1' , LF
  r =. r , 'D=M' , LF
  r =. r , 'A=A-1' , LF
  r =. r , 'M=D|M' , LF
  r
)

TranslateNot =: 3 : 0
  r =. '@SP' , LF
  r =. r , 'A=M-1' , LF
  r =. r , 'M=!M' , LF
  r
)

TranslateCompare =: 3 : 0
  jump =. y
  trueLabel =. 'BOOL_TRUE' , (": labelCounter)
  endLabel =. 'BOOL_END' , (": labelCounter)
  labelCounter =: labelCounter + 1
  r =. '@SP' , LF
  r =. r , 'AM=M-1' , LF
  r =. r , 'D=M' , LF
  r =. r , 'A=A-1' , LF
  r =. r , 'D=M-D' , LF
  r =. r , '@' , trueLabel , LF
  r =. r , 'D;' , jump , LF
  r =. r , '@SP' , LF
  r =. r , 'A=M-1' , LF
  r =. r , 'M=0' , LF
  r =. r , '@' , endLabel , LF
  r =. r , '0;JMP' , LF
  r =. r , '(' , trueLabel , ')' , LF
  r =. r , '@SP' , LF
  r =. r , 'A=M-1' , LF
  r =. r , 'M=-1' , LF
  r =. r , '(' , endLabel , ')' , LF
  r
)

TranslateEq =: 3 : 0
  TranslateCompare 'JEQ'
)
TranslateGt =: 3 : 0
  TranslateCompare 'JGT'
)
TranslateLt =: 3 : 0
  TranslateCompare 'JLT'
)

SegmentBase =: 3 : 0
  if. y -: 'local' do. 'LCL'
  elseif. y -: 'argument' do. 'ARG'
  elseif. y -: 'this' do. 'THIS'
  elseif. y -: 'that' do. 'THAT'
  else. ''
  end.
)

TranslatePushConstant =: 3 : 0
  r =. '@' , y , LF
  r =. r , 'D=A' , LF
  r =. r , PushD ''
  r
)

TranslatePushSegment =: 3 : 0
  segment =. > 0 { y
  index =. > 1 { y
  base =. SegmentBase segment
  r =. '@' , base , LF
  r =. r , 'D=M' , LF
  r =. r , '@' , index , LF
  r =. r , 'A=D+A' , LF
  r =. r , 'D=M' , LF
  r =. r , PushD ''
  r
)

TranslatePopSegment =: 3 : 0
  segment =. > 0 { y
  index =. > 1 { y
  base =. SegmentBase segment
  r =. '@' , base , LF
  r =. r , 'D=M' , LF
  r =. r , '@' , index , LF
  r =. r , 'D=D+A' , LF
  r =. r , '@R13' , LF
  r =. r , 'M=D' , LF
  r =. r , PopToD ''
  r =. r , '@R13' , LF
  r =. r , 'A=M' , LF
  r =. r , 'M=D' , LF
  r
)

TranslatePushTemp =: 3 : 0
  addr =. 5 + ". y
  r =. '@' , (": addr) , LF
  r =. r , 'D=M' , LF
  r =. r , PushD ''
  r
)

TranslatePopTemp =: 3 : 0
  addr =. 5 + ". y
  r =. PopToD ''
  r =. r , '@' , (": addr) , LF
  r =. r , 'M=D' , LF
  r
)

PointerName =: 3 : 0
  if. y -: '0' do. 'THIS' else. 'THAT' end.
)

TranslatePushPointer =: 3 : 0
  index =. ". > y
  if. index = 0 do.
    r =. '@THIS' , LF
  else.
    r =. '@THAT' , LF
  end.
  r =. r , 'D=M' , LF
  r =. r , PushD ''
  r
)

TranslatePopPointer =: 3 : 0
  index =. ". > y
  r =. PopToD ''
  if. index = 0 do.
    r =. r , '@THIS' , LF
  else.
    r =. r , '@THAT' , LF
  end.
  r =. r , 'M=D' , LF
  r
)
TranslatePushStatic =: 3 : 0
  name =. CurrentFile , '.' , y
  r =. '@' , name , LF
  r =. r , 'D=M' , LF
  r =. r , PushD ''
  r
)

TranslatePopStatic =: 3 : 0
  name =. CurrentFile , '.' , y
  r =. PopToD ''
  r =. r , '@' , name , LF
  r =. r , 'M=D' , LF
  r
)

TranslatePushPointer =: 3 : 0
  index =. ". > y
  if. index = 0 do.
    r =. '@THIS' , LF
  else.
    r =. '@THAT' , LF
  end.
  r =. r , 'D=M' , LF
  r =. r , PushD ''
  r
)

TranslatePopPointer =: 3 : 0
  index =. ". > y
  r =. PopToD ''
  if. index = 0 do.
    r =. r , '@THIS' , LF
  else.
    r =. r , '@THAT' , LF
  end.
  r =. r , 'M=D' , LF
  r
)

FullLabelName =: 3 : 0
  if. 0 < # CurrentFunction do.
    CurrentFunction , '$' , y
  else.
    CurrentFile , '.' , y
  end.
)

TranslateLabel =: 3 : 0
  '(' , (FullLabelName y) , ')' , LF
)
TranslateGoto =: 3 : 0
  r =. '@' , (FullLabelName y) , LF
  r =. r , '0;JMP' , LF
  r
)
TranslateIfGoto =: 3 : 0
  r =. PopToD ''
  r =. r , '@' , (FullLabelName y) , LF
  r =. r , 'D;JNE' , LF
  r
)

TranslateFunction =: 3 : 0
  functionName =. > 0 { y
  k =. ". > 1 { y
  CurrentFunction =: functionName
  r =. '(' , functionName , ')' , LF
  for_i. i. k do.
    r =. r , '@0' , LF
    r =. r , 'D=A' , LF
    r =. r , PushD ''
  end.
  r
)

TranslateCall =: 3 : 0
  functionName =. > 0 { y
  nArgs =. > 1 { y
  returnLabel =. functionName , '$ret.' , (": callCounter)
  callCounter =: callCounter + 1
  r =. '@' , returnLabel , LF
  r =. r , 'D=A' , LF
  r =. r , PushD ''
  r =. r , '@LCL' , LF
  r =. r , 'D=M' , LF
  r =. r , PushD ''
  r =. r , '@ARG' , LF
  r =. r , 'D=M' , LF
  r =. r , PushD ''
  r =. r , '@THIS' , LF
  r =. r , 'D=M' , LF
  r =. r , PushD ''
  r =. r , '@THAT' , LF
  r =. r , 'D=M' , LF
  r =. r , PushD ''
  r =. r , '@SP' , LF
  r =. r , 'D=M' , LF
  r =. r , '@' , nArgs , LF
  r =. r , 'D=D-A' , LF
  r =. r , '@5' , LF
  r =. r , 'D=D-A' , LF
  r =. r , '@ARG' , LF
  r =. r , 'M=D' , LF
  r =. r , '@SP' , LF
  r =. r , 'D=M' , LF
  r =. r , '@LCL' , LF
  r =. r , 'M=D' , LF
  r =. r , '@' , functionName , LF
  r =. r , '0;JMP' , LF
  r =. r , '(' , returnLabel , ')' , LF
  r
)

TranslateReturn =: 3 : 0
  r =. '@LCL' , LF
  r =. r , 'D=M' , LF
  r =. r , '@R13' , LF
  r =. r , 'M=D' , LF
  r =. r , '@5' , LF
  r =. r , 'A=D-A' , LF
  r =. r , 'D=M' , LF
  r =. r , '@R14' , LF
  r =. r , 'M=D' , LF
  r =. r , PopToD ''
  r =. r , '@ARG' , LF
  r =. r , 'A=M' , LF
  r =. r , 'M=D' , LF
  r =. r , '@ARG' , LF
  r =. r , 'D=M+1' , LF
  r =. r , '@SP' , LF
  r =. r , 'M=D' , LF
  r =. r , '@R13' , LF
  r =. r , 'AM=M-1' , LF
  r =. r , 'D=M' , LF
  r =. r , '@THAT' , LF
  r =. r , 'M=D' , LF
  r =. r , '@R13' , LF
  r =. r , 'AM=M-1' , LF
  r =. r , 'D=M' , LF
  r =. r , '@THIS' , LF
  r =. r , 'M=D' , LF
  r =. r , '@R13' , LF
  r =. r , 'AM=M-1' , LF
  r =. r , 'D=M' , LF
  r =. r , '@ARG' , LF
  r =. r , 'M=D' , LF
  r =. r , '@R13' , LF
  r =. r , 'AM=M-1' , LF
  r =. r , 'D=M' , LF
  r =. r , '@LCL' , LF
  r =. r , 'M=D' , LF
  r =. r , '@R14' , LF
  r =. r , 'A=M' , LF
  r =. r , '0;JMP' , LF
  r
)

WriteBootstrap =: 3 : 0
  r =. '@256' , LF
  r =. r , 'D=A' , LF
  r =. r , '@SP' , LF
  r =. r , 'M=D' , LF
  r =. r , TranslateCall ('Sys.init' ; '0')
  r
)

ProcessLine =: 3 : 0
  clean =. CleanLine y
  if. 0 = # clean do.
    ''
    return.
  end.
  words =. WordsOf clean
  if. 0 = # words do.
    ''
    return.
  end.
  command =. > 0 { words

  if. command -: 'push' do.
    segment =. > 1 { words
    value =. > 2 { words
    if. segment -: 'constant' do.
      TranslatePushConstant value
    elseif. (segment -: 'local') +. (segment -: 'argument') +. (segment -: 'this') +. (segment -: 'that') do.
      TranslatePushSegment (segment ; value)
    elseif. segment -: 'temp' do.
      TranslatePushTemp value
    elseif. segment -: 'pointer' do.
      TranslatePushPointer value
    elseif. segment -: 'static' do.
      TranslatePushStatic value
    else.
      ''
    end.
  elseif. command -: 'pop' do.
    segment =. > 1 { words
    value =. > 2 { words
    if. (segment -: 'local') +. (segment -: 'argument') +. (segment -: 'this') +. (segment -: 'that') do.
      TranslatePopSegment (segment ; value)
    elseif. segment -: 'temp' do.
      TranslatePopTemp value
    elseif. segment -: 'pointer' do.
      TranslatePopPointer value
    elseif. segment -: 'static' do.
      TranslatePopStatic value
    else.
      ''
    end.
  elseif. command -: 'add' do. TranslateAdd ''
  elseif. command -: 'sub' do. TranslateSub ''
  elseif. command -: 'neg' do. TranslateNeg ''
  elseif. command -: 'and' do. TranslateAnd ''
  elseif. command -: 'or' do. TranslateOr ''
  elseif. command -: 'not' do. TranslateNot ''
  elseif. command -: 'eq' do. TranslateEq ''
  elseif. command -: 'gt' do. TranslateGt ''
  elseif. command -: 'lt' do. TranslateLt ''
  elseif. command -: 'label' do. TranslateLabel (> 1 { words)
  elseif. command -: 'goto' do. TranslateGoto (> 1 { words)
  elseif. command -: 'if-goto' do. TranslateIfGoto (> 1 { words)
  elseif. command -: 'function' do. TranslateFunction ((> 1 { words) ; (> 2 { words))
  elseif. command -: 'call' do. TranslateCall ((> 1 { words) ; (> 2 { words))
  elseif. command -: 'return' do. TranslateReturn ''
  else. ''
  end.
)

ProcessFile =: 3 : 0
  inputFile =: y
  CurrentFile =: GetFileName y
  CurrentFunction =: ''
  lines =. <;._2 (readFile y) , LF
  for_line. lines do.
    asm =. ProcessLine > line
    if. 0 < # asm do.
      WriteText asm
      WriteText LF
    end.
  end.
)

Main =: 3 : 0
  path =. y
  labelCounter =: 0
  callCounter =: 0
  CurrentFile =: ''
  CurrentFunction =: ''
  if. IsVMFile path do.
    outputFile =: (_3 }. path) , '.asm'
    '' 1!:2 < outputFile
    ProcessFile path
  else.
    dir =. path
    if. '/' = {: dir do.
      dir =. }: dir
    end.
    files =. ListVMFiles dir
    outputFile =: dir , '/' , (GetPathTitle dir) , '.asm'
    '' 1!:2 < outputFile
    if. 1 < # files do.
      WriteText WriteBootstrap ''
      WriteText LF
    end.
    for_file. files do.
      ProcessFile > file
    end.
  end.
  smoutput 'Wrote: ' , outputFile
  0
)
